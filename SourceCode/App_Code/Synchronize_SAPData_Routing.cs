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
/// Synchronize_SAPData_Routing 的摘要描述
/// </summary>
public partial class Synchronize_SAPData
{
    /// <summary>
    /// 同步途程(路由表)
    /// </summary>
    [WebMethod]
    public void SynchronizeDataRouting()
    {
        Routing.SynchronizeDataRouting();
    }

    /// <summary>
    /// 指定群組、群組計數器同步途程(路由表)
    /// </summary>
    /// <param name="PLNNR">群組碼</param>
    /// <param name="PLNAL">群組計數器</param>
    [WebMethod]
    public void SynchronizeDataRoutingByKey(string PLNNR, string PLNAL)
    {
        Routing.SynchronizeDataRouting(PLNNR, PLNAL);
    }

    /// <summary>
    /// 同步路由資料類別
    /// </summary>
    public partial class Routing
    {
        /// <summary>
        /// 指定工廠代碼、群組、群組計數器同步途程(路由表)
        /// </summary>
        /// <param name="PLNNR">群組碼</param>
        /// <param name="PLNAL">群組計數器</param>
        public static void SynchronizeDataRouting(string PLNNR = "", string PLNAL = "")
        {
            string GUID = Util.TS.CreateSynchronizeDataLog("PLKO", string.Empty, PLNNR, PLNAL);

            // PLKO
            SynchronizeData_PLKO(global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim(), PLNNR, PLNAL);

            Util.TS.UpdateSynchronizeDataLog(GUID);

            GUID = Util.TS.CreateSynchronizeDataLog("PLAS", string.Empty, PLNNR, PLNAL);

            // PLAS
            SynchronizeData_PLAS(global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim(), PLNNR, PLNAL);

            Util.TS.UpdateSynchronizeDataLog(GUID);

            GUID = Util.TS.CreateSynchronizeDataLog("PLPO", string.Empty, PLNNR, PLNAL);

            // PLPO
            SynchronizeData_PLPO(global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim(), PLNNR, PLNAL);

            Util.TS.UpdateSynchronizeDataLog(GUID);

            GUID = Util.TS.CreateSynchronizeDataLog("MAPL", string.Empty, PLNNR, PLNAL);

            // MAPL
            SynchronizeData_MAPL(global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim(), PLNNR, PLNAL);

            Util.TS.UpdateSynchronizeDataLog(GUID);
        }

        /// <summary>
        /// 指定工廠代碼同步任務清單資料
        /// </summary>
        /// <param name="WERKS">工廠代碼</param>
        /// <param name="PLNNR">群組碼</param>
        /// <param name="PLNAL">群組計數器</param>
        public static void SynchronizeData_PLKO(string WERKS, string PLNNR = "", string PLNAL = "")
        {
            string Query = @"Select 
                        PLNNR,
                        PLNAL,
                        LOEKZ,
                        TO_DATE(DATUV) As DATUV,
                        TO_DATE(VALID_TO)  As VALID_TO,
                        KTEXT
                        From SAPHANADB.PLKO
                        Where PLKO.MANDT = ? And PLKO.WERKS = ? ";

            HanaCommand Command = new HanaCommand();

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS", WERKS.Trim());

            if (!string.IsNullOrEmpty(PLNNR))
            {
                Query += "And PLNNR = ? ";
                Command.Parameters.Add("PLNNR", PLNNR);
            }

            if (!string.IsNullOrEmpty(PLNAL))
            {
                Query += "And PLNAL = ? ";
                Command.Parameters.Add("PLNAL", PLNAL);
            }

            Command.CommandText = Query + " Order By PLNNR,PLNAL ";

            DataTable DT = SAP.GetSelectSAPData(Command);

            DataTable NowPLKODT = GetNowPLKOData();

            IEnumerable<DataRow> NowPLKORows = NowPLKODT.AsEnumerable();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPPLKO"];

            ObjectSchema BaseRoutingSchema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

            DBAction DBA = new DBAction();

            DbCommandBuilder dbcb;

            foreach (DataRow Row in DT.Rows)
            {
                bool IsExist = NowPLKORows.Where(NRow => NRow["PLNNR"].ToString().Trim() == Row["PLNNR"].ToString().Trim() && NRow["PLNAL"].ToString().Trim() == Row["PLNAL"].ToString().Trim()).Count() > 0;

                Query = string.Empty;

                if (!IsExist)
                    Query = @"Insert Into T_TSSAPPLKO (PLNNR,PLNAL,DATUV,VALID_TO,KTEXT,IsDelete) Values (@PLNNR,@PLNAL,@DATUV,@VALID_TO,@KTEXT,@IsDelete)";
                else
                    Query = @"Update T_TSSAPPLKO Set DATUV = @DATUV,VALID_TO = @VALID_TO,KTEXT = @KTEXT,IsDelete = @IsDelete Where PLNNR = @PLNNR And PLNAL = @PLNAL";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(Row["PLNNR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(Row["PLNAL"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["DATUV"].copy(Row["DATUV"]));
                dbcb.appendParameter(Schema.Attributes["VALID_TO"].copy(Row["VALID_TO"]));
                dbcb.appendParameter(Schema.Attributes["KTEXT"].copy(Row["KTEXT"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["IsDelete"].copy(Row["LOEKZ"].ToString().Trim() == "X" ? true : false));

                DBA.AddCommandBuilder(dbcb);

                if (IsExist)
                {
                    Query = @"Update T_TSBaseRouting Set KTEXT = @KTEXT Where PLNNR = @PLNNR And PLNAL = @PLNAL";

                    dbcb = new DbCommandBuilder(Query);

                    dbcb.appendParameter(BaseRoutingSchema.Attributes["PLNNR"].copy(Row["PLNNR"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["PLNAL"].copy(Row["PLNAL"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["KTEXT"].copy(Row["KTEXT"].ToString().Trim()));

                    DBA.AddCommandBuilder(dbcb);
                }
            }

            DBA.Execute();
        }

        /// <summary>
        /// 取得現有PLKO資料表
        /// </summary>
        /// <returns>現有PLKO資料表</returns>
        private static DataTable GetNowPLKOData()
        {
            string Query = @"Select * From T_TSSAPPLKO";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            return CommonDB.ExecuteSelectQuery(dbcb);
        }

        /// <summary>
        /// 指定工廠代碼同步任務作業概觀資料
        /// </summary>
        /// <param name="WERKS">工廠代碼</param>
        /// <param name="PLNNR">群組碼</param>
        /// <param name="PLNAL">群組計數器</param>
        public static void SynchronizeData_PLAS(string WERKS, string PLNNR = "", string PLNAL = "")
        {
            string Query = @"Select 
                            PLAS.PLNNR,
                            PLAS.PLNAL,
                            PLAS.PLNKN,
                            PLAS.LOEKZ,
                            TO_DATE(PLAS.DATUV) As DATUV,
                            TO_DATE(PLAS.VALID_TO) As VALID_TO
                            From PLAS
                            Inner Join PLKO On (PLAS.PLNNR = PLKO.PLNNR And PLAS.PLNAL = PLKO.PLNAL) And PLAS.MANDT = PLKO.MANDT
                            Where PLKO.MANDT = ? And PLKO.WERKS = ? ";

            HanaCommand Command = new HanaCommand();

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS", WERKS.Trim());

            if (!string.IsNullOrEmpty(PLNNR))
            {
                Query += "And PLKO.PLNNR = ? ";
                Command.Parameters.Add("PLNNR", PLNNR);
            }

            if (!string.IsNullOrEmpty(PLNAL))
            {
                Query += "And PLKO.PLNAL = ? ";
                Command.Parameters.Add("PLNAL", PLNAL);
            }

            Command.CommandText = Query + " Order By PLAS.PLNNR,PLAS.PLNAL ";

            DataTable DT = SAP.GetSelectSAPData(Command);

            DataTable NowPLASDT = GetNowPLASData();

            IEnumerable<DataRow> NowPLASRows = NowPLASDT.AsEnumerable();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPPLAS"];

            DBAction DBA = new DBAction();

            DbCommandBuilder dbcb;

            foreach (DataRow Row in DT.Rows)
            {
                bool IsExist = NowPLASRows.Where(NRow => NRow["PLNNR"].ToString().Trim() == Row["PLNNR"].ToString().Trim() && NRow["PLNAL"].ToString().Trim() == Row["PLNAL"].ToString().Trim() && NRow["PLNKN"].ToString().Trim() == Row["PLNKN"].ToString().Trim()).Count() > 0;

                Query = string.Empty;

                if (!IsExist)
                    Query = @"Insert Into T_TSSAPPLAS (PLNNR,PLNAL,PLNKN,DATUV,VALID_TO,IsDelete) Values (@PLNNR,@PLNAL,@PLNKN,@DATUV,@VALID_TO,@IsDelete)";
                else
                    Query = @"Update T_TSSAPPLAS Set DATUV = @DATUV,VALID_TO = @VALID_TO,IsDelete = @IsDelete Where PLNNR = @PLNNR And PLNAL = @PLNAL And PLNKN = @PLNKN";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(Row["PLNNR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(Row["PLNAL"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(Row["PLNKN"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["DATUV"].copy(Row["DATUV"]));
                dbcb.appendParameter(Schema.Attributes["VALID_TO"].copy(Row["VALID_TO"]));
                dbcb.appendParameter(Schema.Attributes["IsDelete"].copy(Row["LOEKZ"].ToString().Trim() == "X" ? true : false));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();
        }

        /// <summary>
        /// 取得現有PLAS資料表
        /// </summary>
        /// <returns>現有PLAS資料表</returns>
        private static DataTable GetNowPLASData()
        {
            string Query = @"Select * From T_TSSAPPLAS";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            return CommonDB.ExecuteSelectQuery(dbcb);
        }

        /// <summary>
        /// 指定工廠代碼同步任務作業概觀活動資料
        /// </summary>
        /// <param name="WERKS">工廠代碼</param>
        /// <param name="PLNNR">群組碼</param>
        /// <param name="PLNAL">群組計數器</param>
        public static void SynchronizeData_PLPO(string WERKS, string PLNNR = "", string PLNAL = "")
        {
            string Query = @"Select 
                                PLPO.PLNNR,
                                PLPO.PLNKN,
                                PLPO.VORNR,
                                PLPO.LTXA1,
                                PLPO.ARBID,
                                CRHD.ARBPL,
                                CRHD.VERAN,
                                TC24.KTEXT As VERAN_KTEXT,
                                CRTX.KTEXT As ARBPL_KTEXT,
                                PLPO.AENNR,
                                PLPO.VGW01,
                                PLPO.VGW02,
                                PLPO.USR00
                                From PLPO 
                                Inner Join CRHD On PLPO.ARBID = CRHD.OBJID And PLPO.WERKS = CRHD.WERKS And CRHD.MANDT = PLPO.MANDT
                                Inner Join CRTX On PLPO.MANDT = CRTX.MANDT And CRHD.OBJTY = CRTX.OBJTY And CRHD.OBJID = CRTX.OBJID And CRTX.SPRAS = 'M'
                                Left Join TC24 On TC24.MANDT = CRHD.MANDT And TC24.WERKS = CRHD.WERKS And TC24.VERAN = CRHD.VERAN
                                Where PLPO.PLNKN in (
			                    Select 
			                    PLAS.PLNKN
			                    From PLAS
			                    Inner Join PLKO On (PLAS.PLNNR = PLKO.PLNNR And PLAS.PLNAL = PLKO.PLNAL And PLAS.MANDT = PLKO.MANDT)
			                    Where PLKO.MANDT = ? And PLKO.WERKS = ? ";

            HanaCommand Command = new HanaCommand();

            Command.Parameters.Add("MANDT_1", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS_1", WERKS.Trim());

            if (!string.IsNullOrEmpty(PLNNR))
            {
                Query += "And PLKO.PLNNR = ? ";
                Command.Parameters.Add("PLNNR1", PLNNR);
            }

            if (!string.IsNullOrEmpty(PLNAL))
            {
                Query += "And PLKO.PLNAL = ? ";
                Command.Parameters.Add("PLNAL", PLNAL);
            }

            Query += ") And PLPO.MANDT = ? And PLPO.WERKS = ? ";

            Command.Parameters.Add("MANDT_2", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS_2", WERKS.Trim());

            if (!string.IsNullOrEmpty(PLNAL))
            {
                Query += "And PLPO.PLNNR = ?";
                Command.Parameters.Add("PLNNR2", PLNNR);
            }

            Command.CommandText = Query + "Order By PLPO.PLNNR,PLPO.VORNR ";

            DataTable DT = SAP.GetSelectSAPData(Command);

            DataTable NowPLPODT = GetNowPLPOData();

            IEnumerable<DataRow> PLPORows = DT.AsEnumerable();

            IEnumerable<DataRow> NowPLPORows = NowPLPODT.AsEnumerable();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPPLPO"];

            ObjectSchema BaseRoutingSchema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

            DBAction DBA = new DBAction();

            DbCommandBuilder dbcb;

            var PLPO_List = PLPORows.AsEnumerable().GroupBy(g => new { PLNNR = g["PLNNR"].ToString().Trim(), PLNKN = g["PLNKN"].ToString().Trim() }).Select(Item => new { PLNNR = Item.Key.PLNNR, PLNKN = Item.Key.PLNKN });

            foreach (var Item in PLPO_List)
            {
                DataRow Row = GetPLPODataRow(Item.PLNNR, Item.PLNKN, PLPORows);

                bool IsExist = NowPLPORows.Where(NRow => NRow["PLNNR"].ToString().Trim() == Row["PLNNR"].ToString().Trim() && NRow["PLNKN"].ToString().Trim() == Row["PLNKN"].ToString().Trim()).Count() > 0;

                Query = string.Empty;

                if (!IsExist)
                    Query = @"Insert Into T_TSSAPPLPO (PLNNR,PLNKN,VORNR,LTXA1,ARBID,ARBPL,ARBPL_KTEXT,VERAN,VERAN_KTEXT,VGW01,VGW02,USR00) Values (@PLNNR,@PLNKN,@VORNR,@LTXA1,@ARBID,@ARBPL,@ARBPL_KTEXT,@VERAN,@VERAN_KTEXT,@VGW01,@VGW02,@USR00)";
                else
                    Query = @"Update T_TSSAPPLPO Set LTXA1 = @LTXA1, ARBID = @ARBID, ARBPL = @ARBPL, ARBPL_KTEXT = @ARBPL_KTEXT, VERAN = @VERAN, VERAN_KTEXT = @VERAN_KTEXT, VGW01 = @VGW01, VGW02 = @VGW02, USR00 = @USR00 Where PLNNR = @PLNNR And PLNKN = @PLNKN And VORNR = @VORNR";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(Row["PLNNR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(Row["PLNKN"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["VORNR"].copy(Row["VORNR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["LTXA1"].copy(Row["LTXA1"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["ARBID"].copy(Row["ARBID"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(Row["ARBPL"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["ARBPL_KTEXT"].copy(Row["ARBPL_KTEXT"].ToString().Trim())); 
                dbcb.appendParameter(Schema.Attributes["VERAN"].copy(Row["VERAN"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["VERAN_KTEXT"].copy(Row["VERAN_KTEXT"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["VGW01"].copy(Row["VGW01"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["VGW02"].copy(Row["VGW02"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["USR00"].copy(Row["USR00"].ToString().Trim()));

                DBA.AddCommandBuilder(dbcb);

                if (IsExist)
                {
                    Query = @"Update T_TSBaseRouting Set LTXA1 = @LTXA1,ARBID = @ARBID,ARBPL = @ARBPL,ARBPL_KTEXT = @ARBPL_KTEXT,VERAN = @VERAN,VERAN_KTEXT = @VERAN_KTEXT,VGW01 = @VGW01, VGW02 = @VGW02,USR00 = @USR00,VORNR = @VORNR  Where PLNNR = @PLNNR And PLNKN = @PLNKN And IsTSProcess = 0";

                    dbcb = new DbCommandBuilder(Query);

                    dbcb.appendParameter(BaseRoutingSchema.Attributes["PLNNR"].copy(Row["PLNNR"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["PLNKN"].copy(Row["PLNKN"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["LTXA1"].copy(Row["LTXA1"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["ARBID"].copy(Row["ARBID"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["ARBPL"].copy(Row["ARBPL"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["ARBPL_KTEXT"].copy(Row["ARBPL_KTEXT"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["VERAN"].copy(Row["VERAN"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["VERAN_KTEXT"].copy(Row["VERAN_KTEXT"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["VGW01"].copy(Row["VGW01"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["VGW02"].copy(Row["VGW02"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["USR00"].copy(Row["USR00"].ToString().Trim()));
                    dbcb.appendParameter(BaseRoutingSchema.Attributes["VORNR"].copy(Row["VORNR"].ToString().Trim()));

                    DBA.AddCommandBuilder(dbcb);
                }
            }

            DBA.Execute();
        }

        /// <summary>
        /// 指定作業群組碼、工作清單節點號碼得到真正的作業活動作業概觀資料(如果有AENNR就取這條Row當作寫入值，反之就只有一條Row)
        /// </summary>
        /// <param name="PLNNR">作業群組碼</param>
        /// <param name="PLNKN">工作清單節點號碼</param>
        /// <param name="PLPORows">途程活動作業概觀資料列</param>
        private static DataRow GetPLPODataRow(string PLNNR, string PLNKN, IEnumerable<DataRow> PLPORows)
        {
            DataRow ResultRow = PLPORows.Where(Row => Row["PLNNR"].ToString().Trim() == PLNNR && Row["PLNKN"].ToString().Trim() == PLNKN && !string.IsNullOrEmpty(Row["AENNR"].ToString().Trim())).FirstOrDefault();

            if (ResultRow == null)
                ResultRow = PLPORows.Where(Row => Row["PLNNR"].ToString().Trim() == PLNNR && Row["PLNKN"].ToString().Trim() == PLNKN).FirstOrDefault();

            return ResultRow;
        }

        /// <summary>
        /// 取得現有PLPO資料表
        /// </summary>
        /// <returns>現有PLPO資料表</returns>
        private static DataTable GetNowPLPOData()
        {
            string Query = @"Select * From T_TSSAPPLPO";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            return CommonDB.ExecuteSelectQuery(dbcb);
        }

        /// <summary>
        /// 指定工廠代碼同步任務作業概觀使用的物料資訊
        /// </summary>
        /// <param name="WERKS">工廠代碼</param>
        /// <param name="PLNNR">群組碼</param>
        /// <param name="PLNAL">群組計數器</param>
        public static void SynchronizeData_MAPL(string WERKS, string PLNNR = "", string PLNAL = "")
        {
            string Query = @"Select 
                            MAPL.MATNR,
                            MAKT.MAKTX,
                            MARA.ZEINR,
                            MARA.FERTH,
                            MAPL.PLNNR,
                            MAPL.PLNAL,
                            MAPL.LOEKZ,
                            MARC.DZEIT
                            From MAPL
                            Inner Join MARA On MAPL.MATNR = MARA.MATNR And MARA.MANDT = MAPL.MANDT 
                            Inner Join MAKT On MARA.MATNR = MAKT.MATNR And MAKT.SPRAS = 'M' And MAKT.MANDT = MAPL.MANDT
                            Inner Join MARC On MARC.MATNR = MARA.MATNR And MARC.MANDT = MARA.MANDT And MARC.WERKS = MAPL.WERKS
                            Where MAPL.MANDT = ? And MAPL.WERKS = ? ";

            HanaCommand Command = new HanaCommand();

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS", WERKS.Trim());

            if (!string.IsNullOrEmpty(PLNNR))
            {
                Query += "And MAPL.PLNNR = ? ";
                Command.Parameters.Add("PLNNR", PLNNR);
            }

            if (!string.IsNullOrEmpty(PLNAL))
            {
                Query += "And MAPL.PLNAL = ? ";
                Command.Parameters.Add("PLNAL", PLNAL);
            }

            Command.CommandText = Query + " Order By MAPL.PLNNR,MAPL.PLNAL,MAPL.MATNR ";

            DataTable DT = SAP.GetSelectSAPData(Command);

            DataTable NowMAPLDT = GetNowMAPLData();

            IEnumerable<DataRow> NowMAPLRows = NowMAPLDT.AsEnumerable();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPMAPL"];

            DBAction DBA = new DBAction();

            DbCommandBuilder dbcb;

            foreach (DataRow Row in DT.Rows)
            {
                bool IsExist = NowMAPLRows.Where(NRow => NRow["PLNNR"].ToString().Trim() == Row["PLNNR"].ToString().Trim() && NRow["PLNAL"].ToString().Trim() == Row["PLNAL"].ToString().Trim() && NRow["MATNR"].ToString().Trim() == Row["MATNR"].ToString().Trim()).Count() > 0;

                Query = string.Empty;

                if (!IsExist)
                    Query = @"Insert Into T_TSSAPMAPL (PLNNR,PLNAL,MATNR,MAKTX,ZEINR,FERTH,DZEIT,IsDelete) Values (@PLNNR,@PLNAL,@MATNR,@MAKTX,@ZEINR,@FERTH,@DZEIT,@IsDelete)";
                else
                    Query = @"Update T_TSSAPMAPL Set MAKTX = @MAKTX,ZEINR = @ZEINR,FERTH = @FERTH,DZEIT = @DZEIT,IsDelete = @IsDelete Where PLNNR = @PLNNR And PLNAL = @PLNAL And MATNR =@MATNR ";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(Row["PLNNR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(Row["PLNAL"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["MATNR"].copy(Row["MATNR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["MAKTX"].copy(Row["MAKTX"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["ZEINR"].copy(Row["ZEINR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["FERTH"].copy(Row["FERTH"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["DZEIT"].copy(Row["DZEIT"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["IsDelete"].copy(Row["LOEKZ"].ToString().Trim() == "X" ? true : false));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();
        }

        /// <summary>
        /// 取得現有MAPL資料表
        /// </summary>
        /// <returns>現有MAPL資料表</returns>
        private static DataTable GetNowMAPLData()
        {
            string Query = @"Select * From T_TSSAPMAPL";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            return CommonDB.ExecuteSelectQuery(dbcb);
        }
    }
}