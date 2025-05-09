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
/// Synchronize_SAPData_AFKO 的摘要描述
/// </summary>
public partial class Synchronize_SAPData
{
    /// <summary>
    /// 同步工單資料
    /// </summary>
    [WebMethod]
    public void SynchronizeDataMO()
    {
        MO.SynchronizeDataMO();
    }

    /// <summary>
    /// 指定產工單編號同步資料
    /// </summary>
    /// <param name="AUFNR">生產工單編號</param>
    [WebMethod]
    public void SynchronizeDataMOByKey(string AUFNR)
    {
        MO.SynchronizeDataMO(AUFNR);
    }

    /// <summary>
    /// 同步工單批號屬性
    /// </summary>
    [WebMethod]
    public void SynchronizeData_AUFM()
    {
        string GUID = Util.TS.CreateSynchronizeDataLog("AUFM", string.Empty);

        MO.SynchronizeData_AUFM(new List<string>() { string.Empty });

        Util.TS.UpdateSynchronizeDataLog(GUID);
    }

    /// <summary>
    /// 同步元件屬性
    /// </summary>
    [WebMethod]
    public void SynchronizeData_RESB()
    {
        string GUID = Util.TS.CreateSynchronizeDataLog("RESB", string.Empty);

        MO.SynchronizeData_RESB(new List<string>() { string.Empty });

        Util.TS.UpdateSynchronizeDataLog(GUID);
    }


    public partial class MO
    {
        /// <summary>
        /// 指定生產工單編號同步資料
        /// </summary>
        /// <param name="AUFNR">生產工單編號</param>
        public static void SynchronizeDataMO(string AUFNR = "")
        {
            string GUID = Util.TS.CreateSynchronizeDataLog("AFKO", AUFNR);

            // AFKO
            SynchronizeData_AFKO(new List<string>() { AUFNR });

            Util.TS.UpdateSynchronizeDataLog(GUID);

            GUID = Util.TS.CreateSynchronizeDataLog("AFVC", AUFNR);

            // AFVC
            SynchronizeData_AFVC(new List<string>() { AUFNR });

            Util.TS.UpdateSynchronizeDataLog(GUID);

            GUID = Util.TS.CreateSynchronizeDataLog("JEST", AUFNR);
            // JEST
            SynchronizeData_JEST(new List<string>() { AUFNR });

            Util.TS.UpdateSynchronizeDataLog(GUID);

            //因為批次屬性取得需要較久的時間，就由開立流程卡之時候，再同步一次就好。因此工單的批次屬性值，如果沒有特別手動同步的話，就只會再開單之狀態下同步一次而已
            if (!string.IsNullOrEmpty(AUFNR))
            {
                GUID = Util.TS.CreateSynchronizeDataLog("AUFM", AUFNR);
                // AUFM
                SynchronizeData_AUFM(new List<string>() { AUFNR });

                Util.TS.UpdateSynchronizeDataLog(GUID);

                GUID = Util.TS.CreateSynchronizeDataLog("RESB", AUFNR);
                // RESB
                SynchronizeData_RESB(new List<string>() { AUFNR });

                Util.TS.UpdateSynchronizeDataLog(GUID);
            }

            Util.TS.DeleteSynchronizeDataLog();
        }
        /// <summary>
        /// 指定生產工單編號同步資料
        /// </summary>
        /// <param name="AUFNRList">生產工單編號清單</param>
        public static void SynchronizeData_AFKO(List<string> AUFNRList)
        {
            string Query = @"Select
	                            AFKO.AUFNR,
	                            '' As STATUS,
	                            AUFK.AUART,
	                            (Select TXT FROM T003P Where AUART = AUFK.AUART And Client = AFKO.MANDT And SPRAS = 'M') As AUARTNAME,
	                            (Select VERID From CKMLMV013 Where AUFNR = AFKO.AUFNR And MANDT = AFKO.MANDT) As VERID,
	                            AFKO.PLNBEZ,
                                AUFK.KTEXT,
	                            AFPO.PSMNG,
	                            AFPO.WEMNG,
	                            AFPO.MEINS,
	                            TO_TIMESTAMP(CONCAT(TO_VARCHAR (TO_DATE(AUFK.ERDAT), 'YYYY/MM/DD '),TO_VARCHAR (TO_TIME(AUFK.ERFZEIT), 'HH24:MI:ss'))) As ERDAT,
	                            AFKO.DISPO,
	                            TO_DATE(AFKO.FTRMI) As FTRMI,
	                            TO_TIMESTAMP(CONCAT(TO_VARCHAR (TO_DATE(AFKO.GSTRP), 'YYYY/MM/DD '),TO_VARCHAR (TO_TIME(AFKO.GSUZP), 'HH24:MI:ss'))) As GSTRP,
	                            TO_TIMESTAMP(CONCAT(TO_VARCHAR (TO_DATE(AFKO.GLTRP), 'YYYY/MM/DD '),TO_VARCHAR (TO_TIME(AFKO.GLUZP), 'HH24:MI:ss'))) As GLTRP,
	                            AUFK.OBJNR
	                    From AFKO
	                    Inner Join AFPO On AFKO.AUFNR = AFPO.AUFNR And AFKO.MANDT = AFPO.MANDT
	                    Inner Join AUFK On AFKO.AUFNR = AUFK.AUFNR And AFKO.MANDT = AUFK.MANDT
	                    Where AFKO.MANDT = ? And AUFK.WERKS = ? ";

            HanaCommand Command = new HanaCommand();

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());

            string QueryAUFNR = string.Empty;

            foreach (string AUFNR in AUFNRList)
            {
                if (string.IsNullOrEmpty(AUFNR))
                    continue;

                if (!string.IsNullOrEmpty(QueryAUFNR))
                    QueryAUFNR += ",";

                QueryAUFNR += "?";

                Command.Parameters.Add("AUFNR", Util.TS.ToAUFNR(AUFNR));
            }

            if (!string.IsNullOrEmpty(QueryAUFNR))
                Query += "And AFKO.AUFNR in (" + QueryAUFNR + ")";

            if (string.IsNullOrEmpty(QueryAUFNR))
            {
                Query += " And (DAYS_BETWEEN(AUFK.ERDAT,CURRENT_DATE)) < ? ";

                /* 只同步工單建立日期參數天數內 */
                Command.Parameters.Add("ERDAT", BaseConfiguration.SynchronizeSAPMODataMaxDays);
            }

            Command.CommandText = Query + " Order By AFKO.AUFNR ";

            DataTable DT = SAP.GetSelectSAPData(Command);

            DataTable DT_CurrentAFKO = GetNowAFKOData();

            IEnumerable<DataRow> NowAFKORows = DT_CurrentAFKO.AsEnumerable();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

            foreach (DataRow Row in DT.Rows)
            {
                bool IsExists = NowAFKORows.Where(NRow => NRow["AUFNR"].ToString().Trim() == Row["AUFNR"].ToString().Trim()).Count() > 0;

                Query = string.Empty;

                DbCommandBuilder dbcb = new DbCommandBuilder();

                if (IsExists)
                {
                    Query = @"Update T_TSSAPAFKO Set AUART = @AUART,AUARTNAME = @AUARTNAME,VERID = @VERID,
                            PLNBEZ = @PLNBEZ,KTEXT = @KTEXT,PSMNG = @PSMNG,WEMNG = @WEMNG,MEINS = @MEINS,
                            ERDAT = @ERDAT,DISPO = @DISPO,FTRMI = @FTRMI,GSTRP = @GSTRP,GLTRP = @GLTRP,OBJNR = @OBJNR
                            Where AUFNR = @AUFNR;";
                }
                else
                {
                    Query = @"Insert Into T_TSSAPAFKO (AUFNR,STATUS,AUART,AUARTNAME,VERID,PLNBEZ,KTEXT,PSMNG,WEMNG,MEINS,ERDAT,DISPO,FTRMI,GSTRP,GLTRP,OBJNR)
                            Values (@AUFNR,@STATUS,@AUART,@AUARTNAME,@VERID,@PLNBEZ,@KTEXT,@PSMNG,@WEMNG,@MEINS,@ERDAT,@DISPO,@FTRMI,@GSTRP,@GLTRP,@OBJNR);";

                    dbcb.appendParameter(Schema.Attributes["STATUS"].copy(Row["STATUS"].ToString().Trim()));
                }

                dbcb.CommandText = Query;

                dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(Row["AUFNR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["AUART"].copy(Row["AUART"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["AUARTNAME"].copy(Row["AUARTNAME"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["VERID"].copy(Row["VERID"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["PLNBEZ"].copy(Row["PLNBEZ"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["KTEXT"].copy(Row["KTEXT"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["PSMNG"].copy(Row["PSMNG"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["WEMNG"].copy(Row["WEMNG"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["MEINS"].copy(Row["MEINS"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["ERDAT"].copy(Row["ERDAT"] == DBNull.Value ? DateTime.Parse("1900/01/01") : Row["ERDAT"]));
                dbcb.appendParameter(Schema.Attributes["DISPO"].copy(Row["DISPO"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["FTRMI"].copy(Row["FTRMI"] == DBNull.Value ? DateTime.Parse("1900/01/01") : Row["FTRMI"]));
                dbcb.appendParameter(Schema.Attributes["GSTRP"].copy(Row["GSTRP"] == DBNull.Value ? DateTime.Parse("1900/01/01") : Row["GSTRP"]));
                dbcb.appendParameter(Schema.Attributes["GLTRP"].copy(Row["GLTRP"] == DBNull.Value ? DateTime.Parse("1900/01/01") : Row["GLTRP"]));
                dbcb.appendParameter(Schema.Attributes["OBJNR"].copy(Row["OBJNR"].ToString().Trim()));

                CommonDB.ExecuteSingleCommand(dbcb);
            }
        }

        /// <summary>
        /// 指定生產工單編號同步作業資料
        /// </summary>
        /// <param name="AUFNRList">生產工單編號清單</param>
        public static void SynchronizeData_AFVC(List<string> AUFNRList)
        {
            string Query = @"Select 
                            AFKO.AUFNR,
                            AFVC.AUFPL,
                            AFVC.APLZL,
                            AFVC.PLNNR,
                            AFVC.PLNAL,
                            AFVC.PLNKN,
                            AFVC.VORNR,
                            AFVC.ARBID,
                            (Select ARBPL From CRHD Where OBJID = AFVC.ARBID And MANDT = AFVC.MANDT And WERKS = AFVC.WERKS) As ARBPL,
                            AFVC.LTXA1
                            From AFKO
                            Inner Join AUFK On AFKO.AUFNR = AUFK.AUFNR And AFKO.MANDT = AUFK.MANDT
                            Inner Join AFVC On AFVC.AUFPL = AFKO.AUFPL And AFVC.MANDT = AFKO.MANDT
                            Where AFVC.MANDT = ? And AFVC.WERKS = ? ";

            HanaCommand Command = new HanaCommand();

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());

            string QueryAUFNR = string.Empty;

            foreach (string AUFNR in AUFNRList)
            {
                if (string.IsNullOrEmpty(AUFNR))
                    continue;

                if (!string.IsNullOrEmpty(QueryAUFNR))
                    QueryAUFNR += ",";

                QueryAUFNR += "?";

                Command.Parameters.Add("AUFNR", Util.TS.ToAUFNR(AUFNR));
            }

            if (!string.IsNullOrEmpty(QueryAUFNR))
                Query += "And AFKO.AUFNR in (" + QueryAUFNR + ")";

            if (string.IsNullOrEmpty(QueryAUFNR))
            {
                Query += " And (DAYS_BETWEEN(AUFK.ERDAT,CURRENT_DATE)) < ? ";

                /* 只同步工單建立日期參數天數內 */
                Command.Parameters.Add("ERDAT", BaseConfiguration.SynchronizeSAPMODataMaxDays);
            }

            Command.CommandText = Query + " Order By AFVC.AUFPL,AFVC.VORNR ";

            DataTable DT = SAP.GetSelectSAPData(Command);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFVC"];

            var AUFPLList = DT.AsEnumerable().GroupBy(Row => Row["AUFPL"].ToString().Trim()).Select(item => item.Key).ToList();

            foreach (string AUFPL in AUFPLList)
            {
                DBAction DBA = new DBAction();

                DbCommandBuilder dbcb = new DbCommandBuilder(@"Delete T_TSSAPAFVC Where AUFPL = @AUFPL");

                dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(AUFPL));

                DBA.AddCommandBuilder(dbcb);

                List<DataRow> Rows = DT.AsEnumerable().Where(Row => Row["AUFPL"].ToString().Trim() == AUFPL).ToList();

                foreach (DataRow Row in Rows)
                {
                    Query = @"Insert Into T_TSSAPAFVC (AUFPL,APLZL,AUFNR,PLNNR,PLNAL,PLNKN,VORNR,ARBID,ARBPL,LTXA1) Values (@AUFPL,@APLZL,@AUFNR,@PLNNR,@PLNAL,@PLNKN,@VORNR,@ARBID,@ARBPL,@LTXA1)";

                    dbcb = new DbCommandBuilder(Query);

                    dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(Row["AUFPL"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["APLZL"].copy(Row["APLZL"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(Row["AUFNR"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(Row["PLNNR"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(Row["PLNAL"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(Row["PLNKN"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["VORNR"].copy(Row["VORNR"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["ARBID"].copy(Row["ARBID"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(Row["ARBPL"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["LTXA1"].copy(Row["LTXA1"].ToString().Trim()));

                    DBA.AddCommandBuilder(dbcb);
                }

                DBA.Execute();
            }
        }

        /// <summary>
        /// 指定生產工單編號同步工單狀態資料
        /// </summary>
        /// <param name="AUFNRList">生產工單編號清單</param>
        public static void SynchronizeData_JEST(List<string> AUFNRList)
        {
            string Query = @"Select
	                            JEST.OBJNR,
                                row_number() OVER (partition by JEST.OBJNR) As SerialNo,
                                STAT,
	                            Case
	                            	When (Select TXT30 From TJ02T Where TJ02T.ISTAT = JEST.STAT And TJ02T.SPRAS = 'M') <> '' Then (Select TXT30 From TJ02T Where TJ02T.ISTAT = JEST.STAT And TJ02T.SPRAS = 'M')
	                            	When (Select TXT30 From TJ30T Where TJ30T.ESTAT = JEST.STAT And TJ30T.MANDT = JEST.MANDT And TJ30T.SPRAS = 'M' And STSMA = 'ZPP_STAU') <> '' Then (Select TXT30 From TJ30T Where TJ30T.ESTAT = JEST.STAT And TJ30T.MANDT = JEST.MANDT And TJ30T.SPRAS = 'M' And TJ30T.STSMA = 'ZPP_STAU')
	                            	Else ''
	                            End As TXT30,
                                (Select Sum(ENMNG) From RESB Where RESB.MANDT = AUFK.MANDT And RESB.WERKS = AUFK.WERKS And RESB.AUFNR = AUFK.AUFNR) As ENMNG --工單元件領料數量
                             From JEST
                             Inner Join AUFK On AUFK.MANDT = JEST.MANDT And AUFK.OBJNR = JEST.OBJNR
                             Where JEST.OBJNR In (
	                            Select 
		                            AUFK.OBJNR
	                            From AFKO
	                        Inner Join AFPO On AFKO.AUFNR = AFPO.AUFNR And AFKO.MANDT = AFPO.MANDT
	                        Inner Join AUFK On AFKO.AUFNR = AUFK.AUFNR And AFKO.MANDT = AUFK.MANDT
	                        Where AFKO.MANDT = ? And AUFK.WERKS = ? ";

            HanaCommand Command = new HanaCommand();

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());

            string QueryAUFNR = string.Empty;

            foreach (string AUFNR in AUFNRList)
            {
                if (string.IsNullOrEmpty(AUFNR))
                    continue;

                if (!string.IsNullOrEmpty(QueryAUFNR))
                    QueryAUFNR += ",";

                QueryAUFNR += "?";

                Command.Parameters.Add("AUFNR", Util.TS.ToAUFNR(AUFNR));
            }

            if (!string.IsNullOrEmpty(QueryAUFNR))
                Query += "And AFKO.AUFNR in (" + QueryAUFNR + ")";

            if (string.IsNullOrEmpty(QueryAUFNR))
            {
                Query += " And (DAYS_BETWEEN(AUFK.ERDAT,CURRENT_DATE)) < ? ";

                /* 只同步工單建立日期參數天數內 */
                Command.Parameters.Add("ERDAT", BaseConfiguration.SynchronizeSAPMODataMaxDays);
            }

            Query += @") And JEST.MANDT = ? And JEST.INACT = '' Order By OBJNR,SerialNo";

            Command.Parameters.Add("JEST.MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());

            Command.CommandText = Query;

            DataTable DT = SAP.GetSelectSAPData(Command);

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPJEST"];

            Query = @"Create Table [#TempJEST] (
	                [OBJNR] [nvarchar](50) NOT NULL,
	                [SerialNo] [smallint] NOT NULL,
	                [STAT] [nvarchar](50) NOT NULL,
                    [TXT30] [nvarchar](50) NOT NULL,
                    [ENMNG] [Float] NOT NULL,
                    CONSTRAINT [PK_JEST] PRIMARY KEY CLUSTERED 
                    (
	                    [OBJNR] ASC,
	                    [SerialNo] ASC
                    )   WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
                    ) ON [PRIMARY]";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            DBA.AddCommandBuilder(dbcb);

            foreach (DataRow Row in DT.Rows)
            {
                Query = @"Insert Into #TempJEST (OBJNR,SERIALNO,STAT,TXT30,ENMNG) Values (@OBJNR,@SERIALNO,@STAT,@TXT30,@ENMNG);";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["OBJNR"].copy(Row["OBJNR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["SERIALNO"].copy(Row["SERIALNO"]));
                dbcb.appendParameter(Schema.Attributes["STAT"].copy(Row["STAT"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["TXT30"].copy(Row["TXT30"].ToString().Trim()));
                dbcb.appendParameter(Util.GetDataAccessAttribute("ENMNG", "Float", 0, Row["ENMNG"].ToString().Trim()));

                DBA.AddCommandBuilder(dbcb);
            }

            Query = @"Delete T_TSSAPJEST Where OBJNR in (Select OBJNR From #TempJEST Group By OBJNR)";

            dbcb = new DbCommandBuilder(Query);

            DBA.AddCommandBuilder(dbcb);

            Query = @"Insert Into T_TSSAPJEST Select OBJNR,SERIALNO,STAT,TXT30 From #TempJEST";

            dbcb = new DbCommandBuilder(Query);

            DBA.AddCommandBuilder(dbcb);

            /*
                I0045 = TECO、技術完成(技术性完成)
                I0076 = DLID(标记)、刪除旗標(删除标记)
                I0046 = CLSD(结算)、已關閉(已结算)
                I0321 = GMPS、已過帳物料異動(货物移动已过账) + 工單元件中所有物料領料數量加總起來必須大於0。這樣才算是真正有發料出去
            */

            dbcb = new DbCommandBuilder();

            Query = @"Update T_TSSAPAFKO Set [STATUS] = 
                    Case
	                    When(Select Count(*) From T_TSSAPJEST Where STAT in ('I0045','I0076','I0046') And T_TSSAPJEST.OBJNR = T_TSSAPAFKO.OBJNR) > 0 Then '2'
	                    When(Select Count(*) From T_TSSAPJEST Where STAT in ('I0321') And T_TSSAPJEST.OBJNR = T_TSSAPAFKO.OBJNR) > 0 And (Select Sum(ENMNG) From #TempJEST Where #TempJEST.OBJNR = T_TSSAPAFKO.OBJNR) > 0 Then '1'
	                    Else '0'
                    End,
					CloseDateTime = 
					Case
						When(Select Count(*) From T_TSSAPJEST Where STAT in ('I0045','I0076','I0046') And T_TSSAPJEST.OBJNR = T_TSSAPAFKO.OBJNR) > 0 And CloseDateTime Is Null Then GetDate()
						When (Select Count(*) From T_TSSAPJEST Where STAT in ('I0045','I0076','I0046') And T_TSSAPJEST.OBJNR = T_TSSAPAFKO.OBJNR) > 0 And CloseDateTime Is Not Null Then CloseDateTime
						Else Null
					End";

            Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

            QueryAUFNR = string.Empty;

            for (int i = 0; i < AUFNRList.Count; i++)
            {
                if (string.IsNullOrEmpty(AUFNRList[i]))
                    continue;

                if (string.IsNullOrEmpty(QueryAUFNR))
                    QueryAUFNR += " Where AUFNR in (";

                string ParameterName = "AUFNR_" + i.ToString();

                if (i > 0)
                    QueryAUFNR += ",";

                QueryAUFNR += "@" + ParameterName;

                dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(Util.TS.ToAUFNR(AUFNRList[i]), ParameterName));
            }

            if (!string.IsNullOrEmpty(QueryAUFNR))
                QueryAUFNR += ")";

            dbcb.CommandText = Query + QueryAUFNR;

            DBA.AddCommandBuilder(dbcb);

            Query = @"Drop Table #TempJEST";

            dbcb = new DbCommandBuilder(Query);

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();
        }

        /// <summary>
        /// 指定生產工單編號同步工單批號屬性
        /// </summary>
        /// <param name="AUFNRList">生產工單編號清單</param>
        public static void SynchronizeData_AUFM(List<string> AUFNRList)
        {
            string Query = @"Select 
	                            AUFM.AUFNR,
	                            row_number() OVER (partition by AUFM.WERKS,AUFM.AUFNR,AUFM.MATNR) As SerialNo,
	                            AUFM.MBLNR,
	                            AUFM.ZEILE,
	                            AUFM.MATNR,
	                            AUFM.CHARG,
                                (Select MTART From MARA Where MARA.MANDT = AFKO.MANDT And MARA.MATNR = AUFM.MATNR) As MTART,
                                (Select Name1 From (Select LFA1.Name1,row_number() OVER (partition by LFA1.LIFNR) AS SerialNo From LFA1 Inner Join MATDOC On LFA1.MANDT = MATDOC.MANDT And LFA1.LIFNR = MATDOC.LIFNR 
                                Where MATDOC.MANDT = AUFM.MANDT And MATDOC.WERKS = AUFM.WERKS And MATDOC.MATNR = AUFM.MATNR And MATDOC.CHARG = AUFM.CHARG And MATDOC.BWART = '321' And MATDOC.LIFNR <> '') Where SerialNo = 1) AS VendorName
                            From AUFM
                            Inner Join AFKO On AFKO.AUFNR = AUFM.AUFNR And AFKO.MANDT = AUFM.MANDT
                            Inner Join AUFK On AFKO.AUFNR = AUFK.AUFNR And AFKO.MANDT = AUFK.MANDT
	                        Where AFKO.MANDT = ? And AUFM.WERKS = ? And AUFM.BWART = '261' /* 只抓異動類型261(發料的就好) */ And AUFM.CHARG <> '' ";

            HanaCommand Command = new HanaCommand();

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());

            string QueryAUFNR = string.Empty;

            foreach (string AUFNR in AUFNRList)
            {
                if (string.IsNullOrEmpty(AUFNR))
                    continue;

                if (!string.IsNullOrEmpty(QueryAUFNR))
                    QueryAUFNR += ",";

                QueryAUFNR += "?";

                Command.Parameters.Add("AUFNR", Util.TS.ToAUFNR(AUFNR));
            }

            if (!string.IsNullOrEmpty(QueryAUFNR))
                Query += "And AFKO.AUFNR in (" + QueryAUFNR + ")";

            if (string.IsNullOrEmpty(QueryAUFNR))
            {
                Query += " And (DAYS_BETWEEN(AUFK.ERDAT,CURRENT_DATE)) < ? ";

                /* 只同步工單建立日期參數天數內 */
                Command.Parameters.Add("ERDAT", BaseConfiguration.SynchronizeSAPMODataMaxDays);
            }

            Query += " Order By AUFM.WERKS,AUFM.AUFNR,AUFM.MBLNR ";

            Command.CommandText = Query;

            DataTable DT = SAP.GetSelectSAPData(Command);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAUFM"];

            var CurrentAUFNRList = DT.AsEnumerable().GroupBy(Row => Row["AUFNR"].ToString().Trim()).Select(Itme => Itme.Key).ToList();

            foreach (string CurrentAUFNR in CurrentAUFNRList)
            {
                DBAction DBA = new DBAction();

                DbCommandBuilder dbcb = new DbCommandBuilder("Delete From T_TSSAPAUFM Where AUFNR = @AUFNR");

                dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(CurrentAUFNR));

                DBA.AddCommandBuilder(dbcb);

                List<DataRow> Rows = DT.AsEnumerable().Where(Row => Row["AUFNR"].ToString().Trim() == CurrentAUFNR).ToList();

                foreach (DataRow Row in Rows)
                {
                    Query = @"Insert Into T_TSSAPAUFM (AUFNR,MATNR,SerialNo,MTART,MBLNR,ZEILE,VendorName,CHARG,CINFO,BATCH,SEMIFINBATCH) Values (@AUFNR,@MATNR,@SerialNo,@MTART,@MBLNR,@ZEILE,@VendorName,@CHARG,@CINFO,@BATCH,@SEMIFINBATCH);";

                    dbcb = new DbCommandBuilder(Query);

                    //批次屬性資訊
                    string CINFO = string.Empty;
                    //製令批號
                    string BATCH = string.Empty;
                    //半成品批號
                    string SEMIFINBATCH = string.Empty;

                    if (!string.IsNullOrEmpty(Row["MATNR"].ToString().Trim()))
                    {
                        //DataTable DT_BAPIBATCHINFO = GetBAPI_BATCHINFO(Row["MATNR"].ToString().Trim(), global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim(), Row["CHARG"].ToString().Trim(), Row["AUFNR"].ToString().Trim());

                        //if (DT_BAPIBATCHINFO.Rows.Count > 0)
                        //{
                        //    CINFO = DT_BAPIBATCHINFO.Rows[0]["CINFO"].ToString().Trim();

                        //    BATCH = DT_BAPIBATCHINFO.Rows[0]["BATCH"].ToString().Trim();

                        //    SEMIFINBATCH = DT_BAPIBATCHINFO.Rows[0]["SEMIFINBATCH"].ToString().Trim();
                        //}

                        DataTable DT_BatchInfo = GetBatchInfo(Row["MATNR"].ToString().Trim(), Row["CHARG"].ToString().Trim());

                        if (DT_BatchInfo.Rows.Count > 0)
                        {
                            BATCH = DT_BatchInfo.AsEnumerable().Where(BRow => BRow["ATNAM"].ToString().Trim() == "BATCH").Select(BRow => BRow["ATWRT"].ToString().Trim()).FirstOrDefault();

                            SEMIFINBATCH = DT_BatchInfo.AsEnumerable().Where(BRow => BRow["ATNAM"].ToString().Trim() == "SEMIFINBATCH").Select(BRow => BRow["ATWRT"].ToString().Trim()).FirstOrDefault();

                            CINFO = string.Join("、", DT_BatchInfo.AsEnumerable().Select(BRow => BRow["ATBEZ"].ToString().Trim() + ":" + BRow["ATWRT"].ToString().Trim()).ToList());

                            //如果半成品批號是空白，還須要再找一下有沒有 FINBATCH(APDC/NBD成品批號)。因為會發生客退料後發料生產檢驗
                            if (string.IsNullOrEmpty(SEMIFINBATCH))
                                SEMIFINBATCH = DT_BatchInfo.AsEnumerable().Where(BRow => BRow["ATNAM"].ToString().Trim() == "FINBATCH").Select(BRow => BRow["ATWRT"].ToString().Trim()).FirstOrDefault();

                            //如果是半成品還要再試著去找有沒有原材料批號。如果是客退品再試著去找有沒有原材料批號
                            if (!string.IsNullOrEmpty(SEMIFINBATCH) && (DT_BatchInfo.Rows[0]["CLASS"].ToString().Trim() == "SEMIFINISHGOOD" || DT_BatchInfo.AsEnumerable().Where(BRow => BRow["CLASS"].ToString().Trim() == "FINISHGOOD").Count() > 0))
                            {
                                //因為有可能這個半品批次屬性值也是批次號，所以再嘗試去拿一次屬性值。必須要拿到BOM裡面(包含下階層)的物料號碼
                                string MATNR = string.Empty;

                                DataTable MATNR_DT = GetBatchUseMATNR(SEMIFINBATCH);

                                /* 
                                   如果只有抓到一筆原物料號，就直接取用。反之就得去呼叫RFC拿到BOM裡面真正的物料。
                                   因為曾經發生過發錯料，導致抓到兩筆原物料。導致無法真正判斷出找到原物料號
                                */
                                if (MATNR_DT.Rows.Count == 1)
                                    MATNR = MATNR_DT.Rows[0]["MATNR"].ToString().Trim();
                                else if (MATNR_DT.Rows.Count > 0)
                                {
                                    string DATUV = GetBOMDATUV(Row["AUFNR"].ToString().Trim());

                                    if (!string.IsNullOrEmpty(DATUV))
                                    {
                                        /*  只能呼叫RFC拿到BOM的階層資料 */

                                        SAPBAPI.RfcParameter[] RPA =  {
                                            new SAPBAPI.RfcParameter { Key = "CAPID", Value = "PP01" },
                                            new SAPBAPI.RfcParameter { Key = "DATUV", Value = DATUV },
                                            new SAPBAPI.RfcParameter { Key = "MEHRS", Value = "X" },
                                            new SAPBAPI.RfcParameter { Key = "MTNRV", Value = Row["MATNR"].ToString().Trim() },
                                            new SAPBAPI.RfcParameter { Key = "WERKS", Value = global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim() }
                                        };

                                        SAPBAPI.GetRfcData GRD = new SAPBAPI.GetRfcData();

                                        DataTable BOM_DT = GRD.GetData("CS_BOM_EXPL_MAT_V2_RFC", "STB", RPA);

                                        var MATNR_List = MATNR_DT.AsEnumerable().Select(MATNRRow => MATNRRow["MATNR"].ToString().Trim()).ToList();

                                        /* 如果有比對到，才能去以這個物料去拿到原料的批次屬性*/
                                        MATNR = BOM_DT.AsEnumerable().Where(BomRow => MATNR_List.Contains(BomRow["IDNRK"].ToString().Trim())).Select(BomRow => BomRow["IDNRK"].ToString().Trim()).FirstOrDefault();
                                    }
                                }

                                if (!string.IsNullOrEmpty(MATNR))
                                {
                                    DT_BatchInfo = GetBatchInfo(MATNR, SEMIFINBATCH);

                                    //如果成立代表有拿到真正的半成品屬性值(最原始的原料批號)，所以替換掉
                                    if (DT_BatchInfo.Rows.Count > 0)
                                    {
                                        //因為最原始的批次屬性是 【制令批號】
                                        string NewBATCH = DT_BatchInfo.AsEnumerable().Where(BRow => BRow["ATNAM"].ToString().Trim() == "BATCH").Select(BRow => BRow["ATWRT"].ToString().Trim()).FirstOrDefault();

                                        if (!string.IsNullOrEmpty(NewBATCH))
                                        {
                                            BATCH = NewBATCH;

                                            CINFO = string.Join("、", DT_BatchInfo.AsEnumerable().Select(BRow => BRow["ATBEZ"].ToString().Trim() + ":" + BRow["ATWRT"].ToString().Trim()).ToList());
                                        }
                                    }
                                }
                            }
                        }
                    }

                    dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(Row["AUFNR"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["MATNR"].copy(Row["MATNR"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["MTART"].copy(Row["MTART"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["SERIALNO"].copy(Row["SERIALNO"]));
                    dbcb.appendParameter(Schema.Attributes["MBLNR"].copy(Row["MBLNR"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["ZEILE"].copy(Row["ZEILE"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["VendorName"].copy(Row["VendorName"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["CHARG"].copy(Row["CHARG"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["CINFO"].copy(string.IsNullOrEmpty(CINFO) ? string.Empty : CINFO));
                    dbcb.appendParameter(Schema.Attributes["BATCH"].copy(string.IsNullOrEmpty(BATCH) ? string.Empty : BATCH));
                    dbcb.appendParameter(Schema.Attributes["SEMIFINBATCH"].copy(string.IsNullOrEmpty(SEMIFINBATCH) ? string.Empty : SEMIFINBATCH));

                    DBA.AddCommandBuilder(dbcb);
                }

                DBA.Execute();
            }
        }

        /// <summary>
        /// 指定生產工單編號同步元件屬性
        /// </summary>
        /// <param name="AUFNRList">生產工單編號清單</param>
        public static void SynchronizeData_RESB(List<string> AUFNRList)
        {
            string Query = @"Select RSNUM,RSPOS,RESB.AUFNR,MATNR,CHARG,                     
                            (Select Name1 From (Select LFA1.Name1,row_number() OVER (partition by LFA1.LIFNR) AS SerialNo From LFA1 Inner Join MATDOC On LFA1.MANDT = MATDOC.MANDT And LFA1.LIFNR = MATDOC.LIFNR 
	                        Where MATDOC.MANDT = RESB.MANDT And MATDOC.WERKS = RESB.WERKS And MATDOC.MATNR = RESB.MATNR And MATDOC.CHARG = RESB.CHARG And MATDOC.BWART = '321' And MATDOC.LIFNR <> '' )
	                        Where SerialNo = 1) AS VendorName
                            From RESB
                            Inner Join AUFK On AUFK.AUFNR = RESB.AUFNR And AUFK.MANDT = RESB.MANDT
                            Where RESB.MANDT = ? And RESB.WERKS = ? And CHARG <> '' ";

            HanaCommand Command = new HanaCommand();

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());

            string QueryAUFNR = string.Empty;

            foreach (string AUFNR in AUFNRList)
            {
                if (string.IsNullOrEmpty(AUFNR))
                    continue;

                if (!string.IsNullOrEmpty(QueryAUFNR))
                    QueryAUFNR += ",";

                QueryAUFNR += "?";

                Command.Parameters.Add("AUFNR", Util.TS.ToAUFNR(AUFNR));
            }

            if (!string.IsNullOrEmpty(QueryAUFNR))
                Query += "And RESB.AUFNR in (" + QueryAUFNR + ")";

            if (string.IsNullOrEmpty(QueryAUFNR))
            {
                Query += " And (DAYS_BETWEEN(AUFK.ERDAT,CURRENT_DATE)) < ? ";

                /* 只同步工單建立日期參數天數內 */
                Command.Parameters.Add("ERDAT", BaseConfiguration.SynchronizeSAPMODataMaxDays);
            }

            Query += " Order By RESB.AUFNR,RESB.RSPOS,RESB.MATNR,RESB.WERKS ";

            Command.CommandText = Query;

            DataTable DT = SAP.GetSelectSAPData(Command);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPRESB"];

            var CurrentAUFNRList = DT.AsEnumerable().GroupBy(Row => Row["AUFNR"].ToString().Trim()).Select(Itme => Itme.Key).ToList();

            foreach (string CurrentAUFNR in CurrentAUFNRList)
            {
                DBAction DBA = new DBAction();

                DbCommandBuilder dbcb = new DbCommandBuilder("Delete From T_TSSAPRESB Where AUFNR = @AUFNR");

                dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(CurrentAUFNR));

                DBA.AddCommandBuilder(dbcb);

                List<DataRow> Rows = DT.AsEnumerable().Where(Row => Row["AUFNR"].ToString().Trim() == CurrentAUFNR).ToList();

                foreach (DataRow Row in Rows)
                {
                    Query = @"Insert Into T_TSSAPRESB (RSNUM,RSPOS,AUFNR,MATNR,VendorName,CHARG,CINFO,BATCH,SEMIFINBATCH) Values (@RSNUM,@RSPOS,@AUFNR,@MATNR,@VendorName,@CHARG,@CINFO,@BATCH,@SEMIFINBATCH)";

                    dbcb = new DbCommandBuilder(Query);

                    //批次屬性資訊
                    string CINFO = string.Empty;
                    //製令批號
                    string BATCH = string.Empty;
                    //半成品批號
                    string SEMIFINBATCH = string.Empty;

                    if (!string.IsNullOrEmpty(Row["MATNR"].ToString().Trim()))
                    {
                        //DataTable DT_BAPIBATCHINFO = GetBAPI_BATCHINFO(Row["MATNR"].ToString().Trim(), global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim(), Row["CHARG"].ToString().Trim(), Row["AUFNR"].ToString().Trim());

                        //if (DT_BAPIBATCHINFO.Rows.Count > 0)
                        //{
                        //    CINFO = DT_BAPIBATCHINFO.Rows[0]["CINFO"].ToString().Trim();

                        //    BATCH = DT_BAPIBATCHINFO.Rows[0]["BATCH"].ToString().Trim();

                        //    SEMIFINBATCH = DT_BAPIBATCHINFO.Rows[0]["SEMIFINBATCH"].ToString().Trim();
                        //}

                        DataTable DT_BatchInfo = GetBatchInfo(Row["MATNR"].ToString().Trim(), Row["CHARG"].ToString().Trim());

                        if (DT_BatchInfo.Rows.Count > 0)
                        {
                            BATCH = DT_BatchInfo.AsEnumerable().Where(BRow => BRow["ATNAM"].ToString().Trim() == "BATCH").Select(BRow => BRow["ATWRT"].ToString().Trim()).FirstOrDefault();

                            SEMIFINBATCH = DT_BatchInfo.AsEnumerable().Where(BRow => BRow["ATNAM"].ToString().Trim() == "SEMIFINBATCH").Select(BRow => BRow["ATWRT"].ToString().Trim()).FirstOrDefault();

                            CINFO = string.Join("、", DT_BatchInfo.AsEnumerable().Select(BRow => BRow["ATBEZ"].ToString().Trim() + ":" + BRow["ATWRT"].ToString().Trim()).ToList());

                            //如果是半成品還要再試著去找有沒有批號
                            if (!string.IsNullOrEmpty(SEMIFINBATCH) && DT_BatchInfo.Rows[0]["CLASS"].ToString().Trim() == "SEMIFINISHGOOD")
                            {
                                //因為有可能這個半品批次屬性值也是批次號，所以再嘗試去拿一次屬性值
                                string MATNR = string.Empty;

                                DataTable MATNR_DT = GetBatchUseMATNR(SEMIFINBATCH);

                                /* 
                                   如果只有抓到一筆原物料號，就直接取用。反之就得去呼叫RFC拿到BOM裡面真正的物料。
                                   因為曾經發生過發錯料，導致抓到兩筆原物料。導致無法真正判斷出找到原物料號
                                */
                                if (MATNR_DT.Rows.Count == 1)
                                    MATNR = MATNR_DT.Rows[0]["MATNR"].ToString().Trim();
                                else if (MATNR_DT.Rows.Count > 0)
                                {
                                    string DATUV = GetBOMDATUV(Row["AUFNR"].ToString().Trim());

                                    if (!string.IsNullOrEmpty(DATUV))
                                    {
                                        /*  只能呼叫RFC拿到BOM的階層資料 */

                                        SAPBAPI.RfcParameter[] RPA =  {
                                            new SAPBAPI.RfcParameter { Key = "CAPID", Value = "PP01" },
                                            new SAPBAPI.RfcParameter { Key = "DATUV", Value = DATUV },
                                            new SAPBAPI.RfcParameter { Key = "MEHRS", Value = "X" },
                                            new SAPBAPI.RfcParameter { Key = "MTNRV", Value = Row["MATNR"].ToString().Trim() },
                                            new SAPBAPI.RfcParameter { Key = "WERKS", Value = global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim() }
                                        };

                                        SAPBAPI.GetRfcData GRD = new SAPBAPI.GetRfcData();

                                        DataTable BOM_DT = GRD.GetData("CS_BOM_EXPL_MAT_V2_RFC", "STB", RPA);

                                        var MATNR_List = MATNR_DT.AsEnumerable().Select(MATNRRow => MATNRRow["MATNR"].ToString().Trim()).ToList();

                                        /* 如果有比對到，才能去以這個物料去拿到原料的批次屬性*/
                                        MATNR = BOM_DT.AsEnumerable().Where(BomRow => MATNR_List.Contains(BomRow["IDNRK"].ToString().Trim())).Select(BomRow => BomRow["IDNRK"].ToString().Trim()).FirstOrDefault();
                                    }
                                }

                                if (!string.IsNullOrEmpty(MATNR))
                                {
                                    DT_BatchInfo = GetBatchInfo(MATNR, SEMIFINBATCH);

                                    //如果成立代表有拿到真正的半成品屬性值(最原始的原料批號)，所以替換掉
                                    if (DT_BatchInfo.Rows.Count > 0)
                                    {
                                        //因為最原始的批次屬性是 【制令批號】
                                        string NewBATCH = DT_BatchInfo.AsEnumerable().Where(BRow => BRow["ATNAM"].ToString().Trim() == "BATCH").Select(BRow => BRow["ATWRT"].ToString().Trim()).FirstOrDefault();

                                        if (!string.IsNullOrEmpty(NewBATCH))
                                        {
                                            BATCH = NewBATCH;

                                            CINFO = string.Join("、", DT_BatchInfo.AsEnumerable().Select(BRow => BRow["ATBEZ"].ToString().Trim() + ":" + BRow["ATWRT"].ToString().Trim()).ToList());
                                        }
                                    }
                                }
                            }
                        }
                    }

                    dbcb.appendParameter(Schema.Attributes["RSNUM"].copy(Row["RSNUM"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["RSPOS"].copy(Row["RSPOS"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(Row["AUFNR"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["MATNR"].copy(Row["MATNR"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["VendorName"].copy(Row["VendorName"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["CHARG"].copy(Row["CHARG"].ToString().Trim()));
                    dbcb.appendParameter(Schema.Attributes["CINFO"].copy(string.IsNullOrEmpty(CINFO) ? string.Empty : CINFO));
                    dbcb.appendParameter(Schema.Attributes["BATCH"].copy(string.IsNullOrEmpty(BATCH) ? string.Empty : BATCH));
                    dbcb.appendParameter(Schema.Attributes["SEMIFINBATCH"].copy(string.IsNullOrEmpty(SEMIFINBATCH) ? string.Empty : SEMIFINBATCH));

                    DBA.AddCommandBuilder(dbcb);
                }

                DBA.Execute();
            }
        }

        /// <summary>
        /// 輸入物料編碼、工廠、批次號、工單編號呼叫BAPI回傳物料批次屬性資料表
        /// </summary>
        /// <param name="MATNR">物料編碼</param>
        /// <param name="WERKS">工廠</param>
        /// <param name="CHARG">批次號</param>
        /// <param name="AUFNR">工單編號</param>
        /// <returns>回傳物料批次屬性資料表</returns>
        private static DataTable GetBAPI_BATCHINFO(string MATNR, string WERKS, string CHARG, string AUFNR)
        {
            SAPBAPI.RfcParameter[] RPA =  {
                new SAPBAPI.RfcParameter { Key = "MATNR", Value = MATNR },
                new SAPBAPI.RfcParameter { Key = "WERKS", Value = WERKS },
                new SAPBAPI.RfcParameter { Key = "CHARG", Value = CHARG },
                new SAPBAPI.RfcParameter { Key = "AUFNR", Value = AUFNR }
            };

            SAPBAPI.GetRfcData GRD = new SAPBAPI.GetRfcData();

            return GRD.GetData("Z_TIMESHEET_GETBATCHINFO", "RZTIMESHEETCHINFO", RPA);
        }

        /// <summary>
        /// 指定物料和批次號取得批次屬性值資料表
        /// </summary>
        /// <param name="MATNR">物料號</param>
        /// <param name="CHARG">批次號</param>
        /// <returns>批次屬性值資料表</returns>
        protected static DataTable GetBatchInfo(string MATNR, string CHARG)
        {
            string Query = @"Select 
	                        KLAH.CLASS,
	                        CABNT.ATBEZ,
                            CABN.ATNAM,
	                        MCH1.CHARG,
	                        AUSP.ATWRT
	                        From AUSP 
	                        Inner Join MCH1 On MCH1.CUOBJ_BM = AUSP.OBJEK And MCH1.MANDT = AUSP.MANDT
	                        Inner Join CABN On CABN.ATINN = AUSP.ATINN And CABN.MANDT = AUSP.MANDT
	                        Inner Join CABNT On CABNT.ATINN = CABN.ATINN And CABNT.MANDT = CABN.MANDT
	                        Inner Join KSSK On KSSK.OBJEK = AUSP.OBJEK And KSSK.MANDT = AUSP.MANDT
	                        Inner Join KLAH On KLAH.CLINT = KSSK.CLINT And KLAH.MANDT = KSSK.MANDT
	                        Where KLAH.KLART = '023' And AUSP.ATWRT <> '' And MCH1.MANDT = ? And MCH1.CHARG = ? And MCH1.MATNR = ? 
                            Order By CABN.ATNAM,AUSP.ATWRT";

            HanaCommand Command = new HanaCommand(Query);

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("CHARG", CHARG);
            Command.Parameters.Add("MATNR", MATNR);

            return SAP.GetSelectSAPData(Command);
        }

        /// <summary>
        /// 指定SAP批次號得到該批次號使用在哪些物料號(只取原料的物料號)
        /// </summary>
        /// <param name="CHARG">批次號</param>
        /// <returns>物料號</returns>
        protected static DataTable GetBatchUseMATNR(string CHARG)
        {
            string Query = @"Select MCH1.MATNR,T134T.MTART,T134T.MTBEZ From MCH1 
                            Inner Join MARA On MARA.MANDT = MCH1.MANDT And MARA.MATNR = MCH1.MATNR
                            Left Join T134T On T134T.MANDT = MCH1.MANDT And T134T.MTART = MARA.MTART And T134T.SPRAS = 'M'
                            Where MCH1.MANDT = ? And CHARG = ? And MARA.MTART = 'ZRH1'  -- ZRH1 = 原料
                            Order By MCH1.MATNR";

            HanaCommand Command = new HanaCommand(Query);

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("CHARG", CHARG);

            return SAP.GetSelectSAPData(Command);
        }

        /// <summary>
        /// 指定工單號得到BOM的生效日期
        /// </summary>
        /// <param name="AUFNR">工單號</param>
        /// <returns>BOM的生效日期</returns>
        protected static string GetBOMDATUV(string AUFNR)
        {
            string Query = @"Select Top 1 STKO.DATUV
                            From CAUFV Inner Join STKO On STKO.MANDT = CAUFV.MANDT And STKO.STLTY = CAUFV.STLTY And STKO.STLNR = CAUFV.STLNR And STKO.STLAL = CAUFV.STLAL
                            Where CAUFV.MANDT = ? And CAUFV.AUFNR = ? ";

            HanaCommand Command = new HanaCommand(Query);
            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("AUFNR", AUFNR);


            DataTable Result = SAP.GetSelectSAPData(Command);

            if (Result.Rows.Count > 0)
                return Result.Rows[0]["DATUV"].ToString().Trim();
            else
                return string.Empty;
        }

        /// <summary>
        /// 取得現有AFKO資料表
        /// </summary>
        /// <returns>現有AFKO資料表</returns>
        private static DataTable GetNowAFKOData()
        {
            string Query = @"Select * From T_TSSAPAFKO";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            return CommonDB.ExecuteSelectQuery(dbcb);
        }
    }
}