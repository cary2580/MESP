<%@ WebHandler Language="C#" Class="TicketCreateByAUFNR" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketCreateByAUFNR : BasePage
{
    protected string AUFNR = string.Empty;
    protected string MachineID = string.Empty;
    protected new string WorkCode = string.Empty;
    protected int TicketBox = 0;
    protected int TicketBoxQty = 0;
    protected int LastTicketBoxQty = 0;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["AUFNR"] != null)
                AUFNR = Util.TS.ToAUFNR(_context.Request["AUFNR"].Trim());
            if (_context.Request["MachineID"] != null)
                MachineID = _context.Request["MachineID"].Trim();
            if (_context.Request["WorkCode"] != null)
                WorkCode = _context.Request["WorkCode"].Trim();

            if (_context.Request["TicketBox"] != null)
            {
                if (!int.TryParse(_context.Request["TicketBox"].Trim(), out TicketBox))
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketBox"));
            }

            if (_context.Request["TicketBoxQty"] != null)
            {
                if (!int.TryParse(_context.Request["TicketBoxQty"].Trim(), out TicketBoxQty))
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketBoxQty"));
            }

            if (_context.Request["LastTicketBoxQty"] != null)
            {
                if (!int.TryParse(_context.Request["LastTicketBoxQty"].Trim(), out LastTicketBoxQty))
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_LastTicketBoxQty"));
            }

            if (string.IsNullOrEmpty(AUFNR))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_AUFNR"));
            if (TicketBox < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketBox"));
            if (TicketBoxQty < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketBoxQty"));

            /*  如果工單已經生成過流程卡，就不允許創建 */
            if (Util.TS.MOTicketIsExist(AUFNR))
                throw new CustomException((string)GetLocalResourceObject("Str_Exist_AUFNR"));

            DataTable DT = GetMOData();

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_AUFNR"));

            DataRow FirstRow = DT.Rows[0];

            /* 生管決議不需要卡控，讓開單的數量可以大於工單數量
            //int TotalTicketBoxQty = TicketBox * TicketBoxQty;
            //工單總數量
            //string PSMNG = FirstRow["PSMNG"].ToString().Trim();
            //double PSMNG_Double = 0;
            //工單已交貨數量
            //string WEMNG = FirstRow["WEMNG"].ToString().Trim();
            //double WEMNG_Double = 0;

            //if (!double.TryParse(PSMNG, out PSMNG_Double))
            //PSMNG_Double = 0;
            //if (!double.TryParse(WEMNG, out WEMNG_Double))
            //WEMNG_Double = 0;

            //if (TotalTicketBoxQty > (int)(PSMNG_Double - WEMNG_Double))
            //throw new CustomException((string)GetLocalResourceObject("Str_Error_OverMOQty"));
            */

            ////工單開始日期
            //DateTime GSTRP = (DateTime)FirstRow["GSTRP"];
            ////工單結束日期
            //DateTime GLTRP = (DateTime)FirstRow["GLTRP"];

            //DateTime CurrDate = DateTime.Now;

            //if (CurrDate < GSTRP)
            //    throw new CustomException(string.Format((string)GetLocalResourceObject("Str_Error_NotStartDate"), GSTRP.ToDefaultStringTime()));
            //if (CurrDate > GLTRP)
            //    throw new CustomException(string.Format((string)GetLocalResourceObject("Str_Error_NotEndDate"), GLTRP.ToDefaultStringTime()));

            string AUART = FirstRow["AUART"].ToString().Trim();
            string STATUS = FirstRow["STATUS"].ToString().Trim();
            string PLNNR = FirstRow["PLNNR"].ToString().Trim();
            string PLNAL = FirstRow["PLNAL"].ToString().Trim();
            string PLNBEZ = FirstRow["PLNBEZ"].ToString().Trim();
            string VERID = FirstRow["VERID"].ToString().Trim();

            Util.TS.MOStatus MOStatus = (Util.TS.MOStatus)Enum.Parse(typeof(Util.TS.MOStatus), STATUS);

            if (MOStatus == Util.TS.MOStatus.Issued && AUART != "ZP21")
                /* 系统上线初，除了試產無料號(ZP21)、輔助製程工單(ZR20)、試產有料號工單(ZP20)可以允許不發料，就可以產生流程卡 */
                /* 240711,与潘素平确认，輔助製程工單(ZR20)、試產有料號工單(ZP20)，需要加卡控发料才能打印*/
                throw new CustomException((string)GetLocalResourceObject("Str_Error_MOStatus0"));
            else if (MOStatus == Util.TS.MOStatus.Closed)
                /*  I0045 = TECO、技術完成(技术性完成)
                    I0076 = DLID(标记)、刪除旗標(删除标记)
                    I0046 = CLSD(结算)、已關閉(已结算) 
                */
                throw new CustomException((string)GetLocalResourceObject("Str_Error_MOStatus2"));

            //因為MOWaitInfo.ashx有同步過一次，效能考量就不再同步一次
            ///*  避免工單剛剛在SAP開立，但是尚未同步過來。因此確保一下，還是同步一次 */
            //if (!string.IsNullOrEmpty(PLNNR) && !string.IsNullOrEmpty(PLNAL))
            //    Synchronize_SAPData.Routing.SynchronizeDataRouting(PLNNR, PLNAL);

            ///*  避免工單剛剛在SAP開立，但是尚未同步過來。因此確保一下，還是同步一次 */
            //if (!string.IsNullOrEmpty(PLNBEZ) && !string.IsNullOrEmpty(VERID))
            //    Synchronize_SAPData.PV.SynchronizeDataProductionVersion(PLNBEZ, VERID);

            DataTable BaseRouting = new DataTable();

            /* 如果有路由群組碼和計數器就還要再去檢查該路由是否活動中。有些工單是沒有路由的所以就不用檢查，因為可能是試產工單。  */
            // 如果是輔助製程工單也不套用群組計數器(ZR20)
            if (!string.IsNullOrEmpty(PLNNR) && !string.IsNullOrEmpty(PLNAL) && AUART != "ZR20")
            {
                /* 有指定群組和計數器，Check每个工序对应的工种是否有维护，有工序没维护的就报错提示*/
                ProcessTypeIDIsEmpty(PLNNR, PLNAL);

                DataTable ProcessActivity = GetMOProcessActivity(PLNNR, PLNAL);

                foreach (DataRow Row in DT.Rows)
                {
                    string PLNKN = Row["PLNKN"].ToString().Trim();
                    string LTXA1 = Row["LTXA1"].ToString().Trim();

                    if (ProcessActivity.AsEnumerable().Where(PARow => PARow["PLNKN"].ToString().Trim() == PLNKN).Count() < 1)
                        throw new CustomException((string)GetLocalResourceObject("Str_Error_OperationUnActivity") + "(" + LTXA1 + ")");
                }

                /* 有指定群組和計數器，就得檢查此設備是不是第一道工序 */
                DataRow DeviceRow = Util.TS.GetDeviceRow(MachineID);

                if (DeviceRow == null)
                    throw new CustomException((string)GetLocalResourceObject("Str_Empty_DeviceRow"));

                if (!(bool)DeviceRow["IsFirstProcess"])
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_DeviceNotFirstProcess"));

                BaseRouting = GetBaseRouting(PLNNR, PLNAL);

                if (BaseRouting.Rows.Count < 1)
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_BaseRoutingNoRow"));

                var NoDeviceGroupIDList = BaseRouting.AsEnumerable().Where(Row => string.IsNullOrEmpty(Row["DeviceGroupID"].ToString().Trim())).Select(Row => Row["ProcessID"].ToString().Trim() + "-" + Row["VORNR"].ToString().Trim() + "-" + Row["LTXA1"].ToString().Trim());

                if (NoDeviceGroupIDList.Count() > 0)
                    throw new CustomException(string.Format((string)GetLocalResourceObject("Str_Error_BaseRoutingNoDeviceGroupID"), PLNNR, PLNAL) + string.Join("<br>", NoDeviceGroupIDList));

                /*  因為BaseRouting並沒有AUFPL、APLZL資料，因此要將 V_TSMORouting 的這兩個資賦予值 */
                IEnumerable<DataRow> MORoutingRows = DT.AsEnumerable();

                foreach (DataRow Row in BaseRouting.Rows)
                {
                    string PLNKN = Row["PLNKN"].ToString().Trim();

                    var MRR = MORoutingRows.Where(MORoutingRow => MORoutingRow["PLNNR"].ToString().Trim() == PLNNR && MORoutingRow["PLNAL"].ToString().Trim() == PLNAL && MORoutingRow["PLNKN"].ToString().Trim() == PLNKN).FirstOrDefault();

                    /* 照理說不會錯誤，但如果找不到代表，基礎路由表有設置錯誤  */
                    if (MRR == null)
                        throw new CustomException((string)GetLocalResourceObject("Str_Error_ProcessNull") + "<br>PLNNR : " + PLNNR + "<br>PLNAL : " + PLNAL + "<br>PLNKN : " + PLNKN);

                    Row["AUFPL"] = MRR["AUFPL"].ToString().Trim();
                    Row["APLZL"] = MRR["APLZL"].ToString().Trim();
                }
            }
            else
            {
                DataTable BRDT = new DataTable();

                //輔助製程工單，因為開單時候，可以剃除不要的工序。因此去找 BaseRouting 所有工序
                if (AUART == "ZR20")
                    BRDT = GetBaseRouting(PLNNR, PLNAL, false);

                BaseRouting.Columns.Add("ProcessID", typeof(int));
                BaseRouting.Columns.Add("AUFPL");
                BaseRouting.Columns.Add("APLZL");
                BaseRouting.Columns.Add("VORNR");
                BaseRouting.Columns.Add("LTXA1");
                BaseRouting.Columns.Add("ARBID");
                BaseRouting.Columns.Add("ARBPL");
                BaseRouting.Columns.Add("DeviceGroupID");

                int ProcessID = 0;

                for (int i = 0; i < DT.Rows.Count; i++)
                {
                    DataRow NewRow = BaseRouting.NewRow();

                    string DeviceGroupID = string.Empty;

                    ProcessID++;

                    if (AUART == "ZR20")
                    {
                        string PLNKN = DT.Rows[i]["PLNKN"].ToString().Trim();

                        var BR = BRDT.AsEnumerable().Where(MORoutingRow => MORoutingRow["PLNNR"].ToString().Trim() == PLNNR && MORoutingRow["PLNAL"].ToString().Trim() == PLNAL && MORoutingRow["PLNKN"].ToString().Trim() == PLNKN).Select(MORoutingRow => new { DeviceGroupID = MORoutingRow["DeviceGroupID"].ToString().Trim(), IsOutputResultMinuteForMan = (bool)MORoutingRow["IsOutputResultMinuteForMan"] }).LastOrDefault();

                        /* 照理說不會錯誤，但如果找不到代表，基礎路由表有設置錯誤  */
                        if (BR == null || BR.IsOutputResultMinuteForMan && string.IsNullOrEmpty(BR.DeviceGroupID))
                            throw new CustomException((string)GetLocalResourceObject("Str_Error_ProcessNull") + "<br>PLNNR : " + PLNNR + "<br>PLNAL : " + PLNAL + "<br>PLNKN : " + PLNKN);
                        else if (!BR.IsOutputResultMinuteForMan)
                        {
                            //ProcessID--;
                            continue; //如果不需要人時，就不需要報工，所以這道工序就不需要加入到 T_TSTicketRouting 
                        }
                        else
                            DeviceGroupID = BR.DeviceGroupID;
                    }

                    NewRow["ProcessID"] = ProcessID;
                    NewRow["AUFPL"] = DT.Rows[i]["AUFPL"].ToString().Trim();
                    NewRow["APLZL"] = DT.Rows[i]["APLZL"].ToString().Trim();
                    NewRow["VORNR"] = DT.Rows[i]["VORNR"].ToString().Trim();
                    NewRow["LTXA1"] = DT.Rows[i]["LTXA1"].ToString().Trim();
                    NewRow["ARBID"] = DT.Rows[i]["ARBID"].ToString().Trim();
                    NewRow["ARBPL"] = DT.Rows[i]["ARBPL"].ToString().Trim();
                    NewRow["DeviceGroupID"] = DeviceGroupID;

                    BaseRouting.Rows.Add(NewRow);
                }
            }

            // 如果是量產工單，其中有一道製程的工作中心是 RD001 的話也不允許開單 (240814 潘素萍提出修改)
            if (AUART == "ZM20" && BaseRouting.AsEnumerable().Where(Row => Row["ARBPL"].ToString().Trim() == "RD001").Count() > 0)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_ARBPL"));

            int AccountID = BaseConfiguration.GetAccountID(WorkCode);

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            DBAction DBA = new DBAction();

            string TicketTypeID = ((short)Util.TS.TicketType.General).ToString();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            for (int i = 0; i < TicketBox; i++)
            {
                string BoxID = (i + 1).ToString("000");

                string TicketID = AUFNR + "-" + TicketTypeID + BoxID;

                string Query = @"Insert Into T_TSTicket (TicketID,TicketTypeID,BoxID,ParentTicketID,MainTicketID,AUFNR,TicketSerialNo,PLNBEZ,Qty,CreateAccountID) 
                                                Values (@TicketID,@TicketTypeID,@BoxID,'','',@AUFNR,@TicketSerialNo,@PLNBEZ,@Qty,@CreateAccountID)";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
                dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(TicketTypeID));
                dbcb.appendParameter(Schema.Attributes["BoxID"].copy(BoxID));
                dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));
                dbcb.appendParameter(Schema.Attributes["TicketSerialNo"].copy(0));
                dbcb.appendParameter(Schema.Attributes["PLNBEZ"].copy(PLNBEZ));
                dbcb.appendParameter(Schema.Attributes["Qty"].copy(TicketBoxQty));
                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));

                DBA.AddCommandBuilder(dbcb);

                AddCreateTicketRouting(TicketID, BaseRouting, DBA);
            }

            dbcb = new DbCommandBuilder("SP_TS_SetTicketSerialNo");

            dbcb.DbCommandType = CommandType.StoredProcedure;

            dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

            DBA.AddCommandBuilder(dbcb);

            if (LastTicketBoxQty > 0)
            {
                string LastTicketID = AUFNR + "-" + TicketTypeID + TicketBox.ToString("000");

                string Query = "Update T_TSTicket Set Qty = @Qty Where TicketID = @TicketID";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(LastTicketID));

                dbcb.appendParameter(Schema.Attributes["Qty"].copy(LastTicketBoxQty));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            // 先不需要回寫SAP數量
            //Sap.Data.Hana.HanaCommand ResultCommand = null;

            /* 因為會跨DB執行異動，因此要注意，只有一方錯誤了就Rollback，反之Commit */
            //try
            //{
            //    Sap.Data.Hana.HanaCommand Command = new Sap.Data.Hana.HanaCommand("Update AFPO Set PSMNG = ? Where AUFNR = ? And MANDT = ?");

            //    Command.Parameters.Add("PSMNG", TicketBox * TicketBoxQty);
            //    Command.Parameters.Add("AUFNR", AUFNR);
            //    Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());

            //    Sap.Data.Hana.HanaCommand Command2 = new Sap.Data.Hana.HanaCommand("Update AFKO Set GAMNG = ? Where AUFNR = ? And MANDT = ?");

            //    Command2.Parameters.Add("GAMNG", TicketBox * TicketBoxQty);
            //    Command2.Parameters.Add("AUFNR", AUFNR);
            //    Command2.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());

            //    SAP.ExecuteMultiCommand(new List<Sap.Data.Hana.HanaCommand>() { Command, Command2 }, out ResultCommand);

            //    DBA.ExecuteWithoutCommit();

            //    if (ResultCommand != null)
            //        ResultCommand.Transaction.Commit();

            //    DBA.Commit();
            //}
            //catch (Exception ex)
            //{
            //    if (ResultCommand != null)
            //        ResultCommand.Transaction.Rollback();

            //    DBA.RollBack();

            //    throw ex;
            //}
            //finally
            //{
            //    if (ResultCommand != null)
            //        ResultCommand.Connection.Close();
            //}
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    ///  指定流程卡號、基礎路由資料表、DBA加入產生指令
    /// </summary>
    /// <param name="TicketID">流程卡號</param>
    /// <param name="DT">基礎路由資料表</param>
    /// <param name="DBA">DBA</param>
    protected void AddCreateTicketRouting(string TicketID, DataTable DT, DBAction DBA)
    {
        IEnumerable<DataRow> Rows = DT.AsEnumerable().OrderBy(Row => (int)Row["ProcessID"]);

        foreach (DataRow Row in Rows)
        {
            string Query = @"Insert Into T_TSTicketRouting (TicketID,ProcessID,AUFPL,APLZL,VORNR,LTXA1,ARBID,ARBPL,DeviceGroupID) Values (@TicketID,@ProcessID,@AUFPL,@APLZL,@VORNR,@LTXA1,@ARBID,@ARBPL,@DeviceGroupID)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy((int)Row["ProcessID"]));
            dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(Row["AUFPL"].ToString().Trim()));
            dbcb.appendParameter(Schema.Attributes["APLZL"].copy(Row["APLZL"].ToString().Trim()));
            dbcb.appendParameter(Schema.Attributes["VORNR"].copy(Row["VORNR"].ToString().Trim()));
            dbcb.appendParameter(Schema.Attributes["LTXA1"].copy(Row["LTXA1"].ToString().Trim()));
            dbcb.appendParameter(Schema.Attributes["ARBID"].copy(Row["ARBID"].ToString().Trim()));
            dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(Row["ARBPL"].ToString().Trim()));
            dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(Row["DeviceGroupID"].ToString().Trim()));

            DBA.AddCommandBuilder(dbcb);
        }
    }

    /// <summary>
    /// 取得工單基本資料
    /// </summary>
    /// <returns></returns>
    private DataTable GetMOData()
    {
        string Query = @"Select * From V_TSMORouting Where AUFNR = @AUFNR Order By PLNNR,VORNR";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// Check群组中工序对应工种有没有维护好，任何一个工序未维护工种就报错
    /// </summary>
    /// <param name="PLNNR">群组码</param>
    /// <param name="PLNAL">计数器</param>
    protected void ProcessTypeIDIsEmpty(string PLNNR, string PLNAL)
    {
        string Query = @"Select Count(*) From T_TSBaseRouting Where PLNNR = @PLNNR And PLNAL = @PLNAL And IsNull(ProcessTypeID,'') = ''";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(PLNNR.Trim()));

        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(PLNAL.Trim()));

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new Exception((string)GetLocalResourceObject("Str_Error_HaveProcessTypeIDEmpty"));
    }

    /// <summary>
    /// 指定群組碼和群組計數器取得報工系統基礎路由表
    /// </summary>
    /// <param name="PLNNR">途程群組碼</param>
    /// <param name="PLNAL">途程計數器</param>
    /// <param name="IsOutputResultMinuteForMan">是否只要輸出SAP人時</param>
    /// <returns>報工系統基礎路由表</returns>
    protected DataTable GetBaseRouting(string PLNNR, string PLNAL, bool IsOutputResultMinuteForMan = true)
    {
        string Query = @"Select T_TSBaseRouting.*,'' As AUFPL,'' As APLZL ,T_TSProcessDeviceGroup.DeviceGroupID
                        From T_TSBaseRouting 
                        Inner Join T_TSProcessDeviceGroup On T_TSBaseRouting.PLNNR = T_TSProcessDeviceGroup.PLNNR And T_TSBaseRouting.PLNAL = T_TSProcessDeviceGroup.PLNAL And T_TSBaseRouting.PLNKN = T_TSProcessDeviceGroup.PLNKN And T_TSBaseRouting.ProcessID = T_TSProcessDeviceGroup.ProcessID
                        Where T_TSBaseRouting.PLNNR = @PLNNR And T_TSBaseRouting.PLNAL = @PLNAL ";

        if (IsOutputResultMinuteForMan)
        {
            Query += @"  And T_TSBaseRouting.IsOutputResultMinuteForMan = 1  /*只需要人時報工的部分才需要報工。目前只有機時不需要用人時的只有ED這道工序*/
                        Order By T_TSBaseRouting.ProcessID Asc";
        }
        else
            Query += @" Order By T_TSBaseRouting.VORNR Asc";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(PLNNR.Trim()));

        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(PLNAL.Trim()));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 指定群組和計數器取得訂單途程啟用中工序資料表
    /// </summary>
    /// <returns>訂單途程啟用中工序資料表</returns>
    protected DataTable GetMOProcessActivity(string PLNNR, string PLNAL)
    {
        string Query = @"Select * From V_TSProcessActivity Where PLNNR = @PLNNR And PLNAL = @PLNAL";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPPLAS"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(PLNNR.Trim()));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(PLNAL.Trim()));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}