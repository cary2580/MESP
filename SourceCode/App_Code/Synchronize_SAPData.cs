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
/// Synchronize_SAPData 的摘要描述
/// </summary>
[WebService(Namespace = "http://irf.com.tw/webservices")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允許使用 ASP.NET AJAX 從指令碼呼叫此 Web 服務，請取消註解下列一行。
// [System.Web.Script.Services.ScriptService]
public partial class Synchronize_SAPData : System.Web.Services.WebService
{

    public Synchronize_SAPData()
    {

        //如果使用設計的元件，請取消註解下列一行
        //InitializeComponent(); 
    }

    /// <summary>
    /// SAP基本資料資料
    /// </summary>
    [WebMethod]
    public void SynchronizeBaseData()
    {
        SynchronizeBaseData_Customer();

        SynchronizeBaseData_Warehouse();

        SynchronizeBaseData_PalletCHARG(new List<string>());
    }

    public static void SynchronizeBaseData_Customer()
    {
        string GUID = Util.TS.CreateSynchronizeDataLog("BaseDataCustomer");

        string Query = @"Select 
                          KNVV.KUNNR,
                          KNA1.NAME1
                        From KNVV Inner Join KNA1 On KNA1.KUNNR = KNVV.KUNNR And KNA1.MANDT = KNVV.MANDT
                        Where KNVV.MANDT = ? And KNVV.VKORG = ?";

        HanaCommand Command = new HanaCommand(Query);

        Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
        Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());

        DataTable DT = SAP.GetSelectSAPData(Command);

        Query = @"Select KUNNR,KUNNR_Name From T_SAPKNVV";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT_Current = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataRow> NowRows = DT_Current.AsEnumerable();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_SAPKNVV"];

        foreach (DataRow Row in DT.Rows)
        {
            bool IsExists = NowRows.Where(NRow => NRow["KUNNR"].ToString().Trim() == Row["KUNNR"].ToString().Trim()).Count() > 0;

            Query = string.Empty;

            dbcb = new DbCommandBuilder();

            if (IsExists)
                Query = @"Update T_SAPKNVV Set KUNNR_Name = @KUNNR_Name Where KUNNR = @KUNNR";
            else
                Query = @"Insert Into T_SAPKNVV (KUNNR,KUNNR_Name) Values (@KUNNR,@KUNNR_Name)";

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["KUNNR"].copy(Row["KUNNR"].ToString().Trim()));
            dbcb.appendParameter(Schema.Attributes["KUNNR_Name"].copy(Row["NAME1"].ToString().Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);
        }

        Util.TS.UpdateSynchronizeDataLog(GUID);
    }

    /// <summary>
    /// 同步SAP倉庫別基礎資料表
    /// </summary>
    public static void SynchronizeBaseData_Warehouse()
    {
        string GUID = Util.TS.CreateSynchronizeDataLog("BaseDataWarehouse");

        string Query = @"Select LGORT,LGOBE 
                         From T001L
                         Where MANDT = ? And WERKS = ?";

        HanaCommand Command = new HanaCommand(Query);

        Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
        Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());

        DataTable DT = SAP.GetSelectSAPData(Command);

        Query = @"Select LGORT,LGOBE From T_SAPT001L";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT_CurrentT001L = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataRow> NowT001LRows = DT_CurrentT001L.AsEnumerable();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_SAPT001L"];

        foreach (DataRow Row in DT.Rows)
        {
            bool IsExists = NowT001LRows.Where(NRow => NRow["LGORT"].ToString().Trim() == Row["LGORT"].ToString().Trim()).Count() > 0;

            Query = string.Empty;

            dbcb = new DbCommandBuilder();

            if (IsExists)
                Query = @"Update T_SAPT001L Set LGOBE = @LGOBE Where LGORT = @LGORT";
            else
                Query = @"Insert Into T_SAPT001L (LGORT,LGOBE) Values (@LGORT,@LGOBE)";

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["LGORT"].copy(Row["LGORT"].ToString().Trim()));
            dbcb.appendParameter(Schema.Attributes["LGOBE"].copy(Row["LGOBE"].ToString().Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);
        }

        Util.TS.UpdateSynchronizeDataLog(GUID);
    }

    /// <summary>
    /// 指定棧板號同步SAP入庫後資料，更新棧板批次號及倉庫別
    /// </summary>
    /// <param name="SynchronizePalletNoList">棧板號清單</param>
    public static void SynchronizeBaseData_PalletCHARG(List<string> SynchronizePalletNoList)
    {
        string GUID = Util.TS.CreateSynchronizeDataLog("BaseDataPalletCHARG");

        string Query = @"Select 
                              NSDM_V_MCHB.CHARG,
                              NSDM_V_MCHB.LGORT,
                              NSDM_V_MCHB.CLABS,
                              ZTMM008.SERIAL,
                              ZTMM008.MARKINGNO,
                              ZTMM008.DISSCO
                        From NSDM_V_MCHB
                        Left Join ZTMM008 On NSDM_V_MCHB.MANDT = ZTMM008.MANDT And NSDM_V_MCHB.MATNR = ZTMM008.MATNR And NSDM_V_MCHB.CHARG = ZTMM008.CHARG 
                        Where ZTMM008.SERIAL <> '' And NSDM_V_MCHB.MANDT = ? And NSDM_V_MCHB.WERKS = ? ";

        HanaCommand Command = new HanaCommand();

        Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
        Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());

        string QueryPalletNo = string.Empty;

        foreach (string PalletNo in SynchronizePalletNoList)
        {
            if (string.IsNullOrEmpty(PalletNo))
                continue;

            if (!string.IsNullOrEmpty(QueryPalletNo))
                QueryPalletNo += ",";

            QueryPalletNo += "?";

            Command.Parameters.Add("PalletNo", PalletNo);
        }

        if (!string.IsNullOrEmpty(QueryPalletNo))
            Query += "And ZTMM008.SERIAL in (" + QueryPalletNo + ")";

        Query += " And NSDM_V_MCHB.CLABS > 0 ";

        Command.CommandText = Query;

        DataTable DT = SAP.GetSelectSAPData(Command);

        var PalletNoList = DT.AsEnumerable().GroupBy(Row => Row["SERIAL"].ToString().Trim()).Select(item => item.Key).ToList();

        IEnumerable<DataRow> Rows = DT.AsEnumerable();

        foreach (string PalletNo in PalletNoList)
        {
            string LGORT = Rows.Where(Row => Row["SERIAL"].ToString().Trim() == PalletNo).Select(Row => Row["LGORT"].ToString().Trim()).FirstOrDefault();

            DBAction DBA = new DBAction();

            ObjectSchema T_WMProductPallet_Schema = DBSchema.currentDB.Tables["T_WMProductPallet"];

            ObjectSchema T_WMProductBoxBrand_Schema = DBSchema.currentDB.Tables["T_WMProductBoxBrand"];

            DbCommandBuilder dbcb;

            var CHARGRows = Rows.Where(Row => Row["SERIAL"].ToString().Trim() == PalletNo).OrderBy(Row => Row["DISSCO"].ToString().Trim());

            foreach (DataRow Row in CHARGRows)
            {
                string CHARG = Row["CHARG"].ToString().Trim();

                string Brand = Row["MARKINGNO"].ToString().Trim();

                string BoxNo = Row["DISSCO"].ToString().Trim();

                string CHARGLGORT = Row["LGORT"].ToString().Trim();

                decimal CLABS = (decimal)Row["CLABS"];

                if (!string.IsNullOrEmpty(CHARG))
                {
                    Query = @"Update T_WMProductBoxBrand Set CHARG = @CHARG,CHARGQty = @CHARGQty, CHARGLGORT = @CHARGLGORT Where BoxNo In (Select BoxNo From T_WMProductBox Where PalletNo = @PalletNo) And BoxNo = IIF(@BoxNo = '',BoxNo,@BoxNo) And Brand = @Brand";

                    dbcb = new DbCommandBuilder(Query);

                    dbcb.appendParameter(T_WMProductPallet_Schema.Attributes["PalletNo"].copy(PalletNo));

                    dbcb.appendParameter(T_WMProductBoxBrand_Schema.Attributes["BoxNo"].copy(BoxNo));

                    dbcb.appendParameter(T_WMProductBoxBrand_Schema.Attributes["CHARG"].copy(CHARG));

                    dbcb.appendParameter(T_WMProductBoxBrand_Schema.Attributes["Brand"].copy(Brand));

                    dbcb.appendParameter(T_WMProductBoxBrand_Schema.Attributes["CHARGQty"].copy(CLABS));

                    dbcb.appendParameter(T_WMProductBoxBrand_Schema.Attributes["CHARGLGORT"].copy(CHARGLGORT));

                    DBA.AddCommandBuilder(dbcb);
                }
            }

            if (!string.IsNullOrEmpty(LGORT))
            {
                Query = @"Update T_WMProductPallet Set LGORT = @LGORT Where PalletNo = @PalletNo";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(T_WMProductPallet_Schema.Attributes["LGORT"].copy(LGORT));

                dbcb.appendParameter(T_WMProductPallet_Schema.Attributes["PalletNo"].copy(PalletNo));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();
        }

        Util.TS.UpdateSynchronizeDataLog(GUID);
    }
}
