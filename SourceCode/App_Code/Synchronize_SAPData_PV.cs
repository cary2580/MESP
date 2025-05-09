using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using Sap.Data.Hana;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

/// <summary>
/// Synchronize_SAPData_PV 的摘要描述 (Production Version)
/// </summary>
public partial class Synchronize_SAPData
{
    /// <summary>
    /// 同步生產版本
    /// </summary>
    [WebMethod]
    public void SynchronizeDataProductionVersion()
    {
        PV.SynchronizeDataProductionVersion();
    }

    /// <summary>
    /// 指定物料代碼、生產版本號碼同步生產版本
    /// </summary>
    /// <param name="MATNR">物料代碼</param>
    /// <param name="VERID">生產版本號碼</param>
    [WebMethod]
    public void SynchronizeDataProductionVersionByKey(string MATNR, string VERID)
    {
        PV.SynchronizeDataProductionVersion(MATNR, VERID);
    }

    /// <summary>
    /// 同步Production Version類別
    /// </summary>
    public partial class PV
    {
        /// <summary>
        /// 指定物料代碼、生產版本號碼同步生產版本
        /// </summary>
        /// <param name="MATNR">物料代碼</param>
        /// <param name="VERID">生產版本號碼</param>
        public static void SynchronizeDataProductionVersion(string MATNR = "", string VERID = "")
        {
            SynchronizeData_MAPL(global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim(), MATNR, VERID);
        }

        /// <summary>
        /// 指定工廠代碼、物料代碼、生產版本號碼同步生產版本
        /// </summary>
        /// <param name="WERKS">工廠代碼</param>
        /// <param name="MATNR">物料代碼</param>
        /// <param name="VERID">生產版本號碼</param>
        private static void SynchronizeData_MAPL(string WERKS, string MATNR = "", string VERID = "")
        {
            string Query = @"Select 
                            MATNR,
                            VERID,
                            PLNNR,
                            ALNAL,
                            TEXT1,
                            MKSP,
                            TO_DATE(ADATU) As ADATU,
                            TO_DATE(BDATU) As BDATU,
                            STLAL
                            From MKAL
                            Where MANDT = ? AND WERKS = ? ";

            HanaCommand Command = new HanaCommand();

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS", WERKS.Trim());

            if (!string.IsNullOrEmpty(MATNR))
            {
                Query += "And MATNR = ? ";
                Command.Parameters.Add("MATNR", MATNR);
            }

            if (!string.IsNullOrEmpty(VERID))
            {
                Query += "And VERID = ? ";
                Command.Parameters.Add("VERID", VERID);
            }

            Command.CommandText = Query + " Order By PLNNR,ALNAL,MATNR";

            DataTable DT = SAP.GetSelectSAPData(Command);

            DataTable NowMKALDT = GetNowMKALData();

            IEnumerable<DataRow> NowMKALRows = NowMKALDT.AsEnumerable();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPMKAL"];

            DBAction DBA = new DBAction();

            foreach (DataRow Row in DT.Rows)
            {
                bool IsExist = NowMKALRows.Where(NRow => NRow["MATNR"].ToString().Trim() == Row["MATNR"].ToString().Trim() && NRow["VERID"].ToString().Trim() == Row["VERID"].ToString().Trim()).Count() > 0;

                double PackageQty = 0;

                Query = string.Empty;

                DbCommandBuilder dbcb = new DbCommandBuilder();

                // 因為裝箱數量，有些是由DB直接輸入(SAP沒有維護打上)，因此當有資料的話就不再更新
                if (!IsExist)
                {
                    SAPBAPI.RfcParameter[] RPA = {
                        new SAPBAPI.RfcParameter { Key = "MATERIAL", Value = Row["MATNR"].ToString().Trim() },
                        new SAPBAPI.RfcParameter { Key = "BOM_USAGE", Value = "1" },
                        new SAPBAPI.RfcParameter { Key = "ALTERNATIVE", Value = Row["STLAL"].ToString().Trim() },
                        new SAPBAPI.RfcParameter { Key = "PLANT", Value = global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim() }
                    };

                    SAPBAPI.GetRfcData GRD = new SAPBAPI.GetRfcData();

                    DataTable[] BOM_DT = GRD.GetMultipleData("CSAP_MAT_BOM_READ", new string[] { "T_STKO", "T_STPO" }, RPA);

                    DataTable T_STKO = BOM_DT.Where(T => T.TableName == "T_STKO").FirstOrDefault();

                    DataTable T_STPO = BOM_DT.Where(T => T.TableName == "T_STPO").FirstOrDefault();

                    double BASE_QUAN = 0;

                    double COMP_QTY = 0;

                    if (T_STKO != null && T_STKO.Rows.Count > 0 && T_STPO != null && T_STPO.Rows.Count > 0)
                    {
                        if (!double.TryParse(T_STKO.AsEnumerable().Select(STKORow => STKORow["BASE_QUAN"].ToString().Trim()).FirstOrDefault(), out BASE_QUAN))
                            BASE_QUAN = 0;
                        if (!double.TryParse(T_STPO.AsEnumerable().Where(STPORow => STPORow["COMPONENT"].ToString().Trim().StartsWith("400100")).Select(STPORow => STPORow["COMP_QTY"].ToString().Trim()).FirstOrDefault(), out COMP_QTY))
                            COMP_QTY = 0;
                    }

                    // 避免無限小，所以還是得判斷是否數字大於0
                    if (BASE_QUAN > 0 && COMP_QTY > 0)
                        PackageQty = BASE_QUAN / COMP_QTY;

                    Query = @"Insert Into T_TSSAPMKAL (MATNR,VERID,PLNNR,ALNAL,TEXT1,PackageQty,ADATU,BDATU,IsLock) Values (@MATNR,@VERID,@PLNNR,@ALNAL,@TEXT1,@PackageQty,@ADATU,@BDATU,@IsLock)";
                }
                else
                {
                    Query = @"Update T_TSSAPMKAL Set PLNNR = @PLNNR,ALNAL = @ALNAL,TEXT1 = @TEXT1,PackageQty = @PackageQty,ADATU = @ADATU,BDATU = @BDATU,IsLock = @IsLock Where MATNR = @MATNR And VERID = @VERID";

                    PackageQty = NowMKALRows.Where(NRow => NRow["MATNR"].ToString().Trim() == Row["MATNR"].ToString().Trim() && NRow["VERID"].ToString().Trim() == Row["VERID"].ToString().Trim()).Select(NRow => (int)NRow["PackageQty"]).FirstOrDefault();
                }

                dbcb.CommandText = Query;

                dbcb.appendParameter(Schema.Attributes["MATNR"].copy(Row["MATNR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["VERID"].copy(Row["VERID"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(Row["PLNNR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["ALNAL"].copy(Row["ALNAL"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["TEXT1"].copy(Row["TEXT1"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["PackageQty"].copy((int)Math.Ceiling(PackageQty)));
                dbcb.appendParameter(Schema.Attributes["ADATU"].copy(Row["ADATU"]));
                dbcb.appendParameter(Schema.Attributes["BDATU"].copy(Row["BDATU"]));
                dbcb.appendParameter(Schema.Attributes["IsLock"].copy(!string.IsNullOrEmpty(Row["MKSP"].ToString().Trim())));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();
        }

        /// <summary>
        /// 取得現有生產版本資料
        /// </summary>
        /// <returns>現有生產版本資料</returns>
        private static DataTable GetNowMKALData()
        {
            string Query = @"Select * From T_TSSAPMKAL";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            return CommonDB.ExecuteSelectQuery(dbcb);
        }
    }
}