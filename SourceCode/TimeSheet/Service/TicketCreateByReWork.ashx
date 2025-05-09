<%@ WebHandler Language="C#" Class="TicketCreateByReWork" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketCreateByReWork : BasePage
{
    protected string TicketID = string.Empty;
    protected string AUFNR = string.Empty;
    protected List<string> ProcessID_List = new List<string>();
    protected List<DefectObject> DefectID_List = new List<DefectObject>();
    protected int Qty = 0;
    protected string MainTicketID = string.Empty;
    protected string PLNBEZ = string.Empty;
    protected int ReWorkMainProcessID = 0;
    protected int ProcessID = 0;
    protected string AUFPL = string.Empty;
    protected string APLZL = string.Empty;
    protected string VORNR = string.Empty;
    protected string DeviceID = string.Empty;
    protected DateTime ReportTimeStart = DateTime.Now;
    protected DateTime ReportTimeEnd = DateTime.Now;
    protected int ReportMinute = 0;
    protected int MaintainMinute = 0;
    protected int WaitMaintainMinute = 0;
    protected int MaintainQACheckMinute = 0;
    protected int MaintainPDCheckMinute = 0;
    protected int ResultMinute = 0;
    protected string Brand = string.Empty;
    protected string WorkShiftID = string.Empty;
    protected int AllowQty = 0;
    protected string NewTicketID = string.Empty;
    protected int TicketSerialNo;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();
            if (_context.Request["Qty"] != null)
            {
                if (!int.TryParse(_context.Request["Qty"].Trim(), out Qty))
                    Qty = 0;
            }

            if (_context.Request["ProcessIDS"] != null)
                ProcessID_List = JsonConvert.DeserializeObject<List<string>>(_context.Request["ProcessIDS"].Trim());
            if (_context.Request["DefectIDs"] != null)
                DefectID_List = JsonConvert.DeserializeObject<List<DefectObject>>(_context.Request["DefectIDs"].Trim());

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));
            if (ProcessID_List.Count < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_ProcessID"));
            if (Qty < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_Qty"));

            LaodTicket();

            if ((Qty > AllowQty) || Qty == 0)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_Qty"));

            if (DefectID_List.Sum(DO => DO.DefectQty) != Qty)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_DefectQtyNotTheSameQty"));

            DataTable RoutingTable = GetRoutingTable();

            string BoxID = GetNextBoxID();

            DBAction DBA = new DBAction();

            string Query = @"Insert Into T_TSTicket (TicketID,TicketTypeID,BoxID,ParentTicketID,MainTicketID,AUFNR,TicketSerialNo,PLNBEZ,Qty,CreateProcessID,ReWorkMainProcessID,CreateAccountID) 
                                                 Values (@TicketID,@TicketTypeID,@BoxID,@ParentTicketID,@MainTicketID,@AUFNR,@TicketSerialNo,@PLNBEZ,@Qty,@CreateProcessID,@ReWorkMainProcessID,@CreateAccountID)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            string TicketTypeID = ((short)Util.TS.TicketType.Rework).ToString();

            NewTicketID = AUFNR + "-" + TicketTypeID + BoxID;

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(NewTicketID));
            dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(TicketTypeID));
            dbcb.appendParameter(Schema.Attributes["BoxID"].copy(BoxID));
            dbcb.appendParameter(Schema.Attributes["ParentTicketID"].copy(TicketID));
            dbcb.appendParameter(Schema.Attributes["MainTicketID"].copy(string.IsNullOrEmpty(MainTicketID) ? TicketID : MainTicketID));
            dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));
            dbcb.appendParameter(Schema.Attributes["TicketSerialNo"].copy(TicketSerialNo));
            dbcb.appendParameter(Schema.Attributes["PLNBEZ"].copy(PLNBEZ));
            dbcb.appendParameter(Schema.Attributes["PLNBEZ"].copy(PLNBEZ));
            dbcb.appendParameter(Schema.Attributes["CreateProcessID"].copy(ProcessID));
            dbcb.appendParameter(Schema.Attributes["Qty"].copy(Qty));
            /* 如果有最源頭的返工單開立點，將以最源頭的返工單開立點為主，反正就已這張單的當前工序當作開立點。這很重要，因為後續報工取良品或是返工品的判斷將依照這個欄位判斷 */
            if (ReWorkMainProcessID > 0)
            {
                /* 如果當前的工序是未到達源源頭開立的返工單就不允許再開立返工單。 */
                if (ProcessID < ReWorkMainProcessID)
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_ProcessNotYetCompleted"));
            }

            /* 如果成立的話，代表當前的工序已經到達了先前有開立的返工單源頭工序，因此這時候再開出的話，就以現在這個工序當作源頭 */
            if (ProcessID >= ReWorkMainProcessID)
                dbcb.appendParameter(Schema.Attributes["ReWorkMainProcessID"].copy(ProcessID));
            else
                dbcb.appendParameter(Schema.Attributes["ReWorkMainProcessID"].copy(ReWorkMainProcessID));
            /******************************************************************************************************************************************************************/
            dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));

            DBA.AddCommandBuilder(dbcb);

            foreach (DefectObject DO in DefectID_List)
            {
                Query = @"Insert Into T_TSTicketReworkDefect (TicketID,DefectID,Qty) Values (@TicketID,@DefectID,@Qty)";

                dbcb = new DbCommandBuilder(Query);

                Schema = DBSchema.currentDB.Tables["T_TSTicketReworkDefect"];

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(NewTicketID));
                dbcb.appendParameter(Schema.Attributes["DefectID"].copy(DO.DefectID));
                dbcb.appendParameter(Schema.Attributes["Qty"].copy(DO.DefectQty));

                DBA.AddCommandBuilder(dbcb);
            }

            foreach (DataRow Row in RoutingTable.Rows)
            {
                Query = @"Insert Into T_TSTicketRouting (TicketID,ProcessID,AUFPL,APLZL,VORNR,LTXA1,ARBID,ARBPL,DeviceGroupID) Values (@TicketID,@ProcessID,@AUFPL,@APLZL,@VORNR,@LTXA1,@ARBID,@ARBPL,@DeviceGroupID)";

                dbcb = new DbCommandBuilder(Query);

                Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(NewTicketID));
                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(Row["ProcessID"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(Row["AUFPL"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["APLZL"].copy(Row["APLZL"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["VORNR"].copy(Row["VORNR"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["LTXA1"].copy(Row["LTXA1"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["ARBID"].copy(Row["ARBID"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(Row["ARBPL"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(Row["DeviceGroupID"].ToString().Trim()));

                DBA.AddCommandBuilder(dbcb);
            }

            int NewAllowQty = AllowQty - Qty;

            /* 如果成立。代表此工序的報工數量已經被扣完了，因此就得結算數量 */
            if (NewAllowQty < 1)
            {
                /* 將當前的工序回報結算 */
                Query = @"Insert Into T_TSTicketResult (TicketID,ProcessID,SerialNo,AUFPL,APLZL,VORNR,DeviceID,GoodQty,ScrapQty,ReWorkQty,ReportDate,ReportTimeStart,ReportTimeEnd,ReportMinute,WaitMaintainMinute,MaintainMinute,MaintainQACheckMinute,MaintainPDCheckMinute,ResultMinute,Coefficient,ResultMinuteMainOperator,WaitMinute,Brand,Operator,WorkShiftID)
                        Values (@TicketID,@ProcessID,IsNull((Select Max(SerialNo) + 1 From T_TSTicketResult Where TicketID = @TicketID And ProcessID = @ProcessID),1),@AUFPL,@APLZL,
                        @VORNR,@DeviceID,@GoodQty,@ScrapQty,@ReWorkQty,dbo.TS_GetReportDate(@ReportTimeEnd,@WorkShiftID),@ReportTimeStart,@ReportTimeEnd,@ReportMinute,@WaitMaintainMinute,@MaintainMinute,@MaintainQACheckMinute,@MaintainPDCheckMinute,@ResultMinute,@Coefficient,@ResultMinuteMainOperator,@WaitMinute,@Brand,@Operator,@WorkShiftID)";

                Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));
                dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(AUFPL));
                dbcb.appendParameter(Schema.Attributes["APLZL"].copy(APLZL));
                dbcb.appendParameter(Schema.Attributes["VORNR"].copy(VORNR));
                dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
                /* 因為全數都拿去開立返工單了，所以結算數量都是0。等到開立出的返工單結算之時，就判斷是在良品還是返工數回報 */
                dbcb.appendParameter(Schema.Attributes["GoodQty"].copy(0));
                dbcb.appendParameter(Schema.Attributes["ScrapQty"].copy(0));
                dbcb.appendParameter(Schema.Attributes["ReWorkQty"].copy(0));
                dbcb.appendParameter(Schema.Attributes["ReportTimeStart"].copy(ReportTimeStart));
                dbcb.appendParameter(Schema.Attributes["ReportTimeEnd"].copy(ReportTimeEnd));
                dbcb.appendParameter(Schema.Attributes["ReportMinute"].copy(ReportMinute));
                dbcb.appendParameter(Schema.Attributes["WaitMaintainMinute"].copy(WaitMaintainMinute));
                dbcb.appendParameter(Schema.Attributes["MaintainMinute"].copy(MaintainMinute));
                dbcb.appendParameter(Schema.Attributes["MaintainQACheckMinute"].copy(MaintainQACheckMinute));
                dbcb.appendParameter(Schema.Attributes["MaintainPDCheckMinute"].copy(MaintainPDCheckMinute));
                dbcb.appendParameter(Schema.Attributes["ResultMinute"].copy(ResultMinute));

                double Coefficient = 1;

                if (_context.Request.Cookies["TS_Coefficient"] != null)
                {
                    if (!double.TryParse(_context.Request.Cookies["TS_Coefficient"].Value, out Coefficient))
                        Coefficient = 1;
                }

                dbcb.appendParameter(Schema.Attributes["Coefficient"].copy(Coefficient));
                dbcb.appendParameter(Schema.Attributes["ResultMinuteMainOperator"].copy(ResultMinute * Coefficient));

                dbcb.appendParameter(Schema.Attributes["WaitMinute"].copy(0));
                dbcb.appendParameter(Schema.Attributes["Brand"].copy(Brand));
                dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));
                dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(WorkShiftID));

                DBA.AddCommandBuilder(dbcb);

                if (_context.Request.Cookies["TS_SecondInfo"] != null && !string.IsNullOrEmpty(_context.Request.Cookies["TS_SecondInfo"].Value))
                {
                    List<Util.TS.LoginInfo> SecondInfoList = JsonConvert.DeserializeObject<List<Util.TS.LoginInfo>>(_context.Request.Cookies["TS_SecondInfo"].Value);

                    Schema = DBSchema.currentDB.Tables["T_TSTicketResultSecondOperator"];

                    foreach (Util.TS.LoginInfo LI in SecondInfoList)
                    {
                        Query = @"Insert Into T_TSTicketResultSecondOperator (TicketID,ProcessID,SerialNo,SecondOperator,Coefficient,ResultMinute) Values (@TicketID,@ProcessID,IsNull((Select Max(SerialNo) From T_TSTicketResult Where TicketID = @TicketID And ProcessID = @ProcessID),1),@SecondOperator,@Coefficient,@ResultMinute)";

                        dbcb = new DbCommandBuilder(Query);

                        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
                        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));
                        dbcb.appendParameter(Schema.Attributes["SecondOperator"].copy(LI.AccountID));
                        dbcb.appendParameter(Schema.Attributes["Coefficient"].copy(LI.Coefficient));
                        dbcb.appendParameter(Schema.Attributes["ResultMinute"].copy((int)(ResultMinute * LI.Coefficient)));

                        DBA.AddCommandBuilder(dbcb);
                    }
                }

                /* 將此流程卡當前狀態清除 */
                Query = @"Delete T_TSTicketCurrStatus Where TicketID = @TicketID";

                dbcb = new DbCommandBuilder(Query);

                Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                DBA.AddCommandBuilder(dbcb);

                /* 將當前的工序更新為已結束狀態 */
                Query = @"Update T_TSTicketRouting Set IsEnd = 1 Where TicketID = @TicketID And ProcessID = @ProcessID";

                dbcb = new DbCommandBuilder(Query);

                Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

                DBA.AddCommandBuilder(dbcb);

                int ResultQty = GetResultQty();

                /* 因為開立返工單前並未有報工良品數據，可以將此單後續工序完全結束 */
                if (ResultQty < 1)
                {
                    /* 將後面的工序更新為已結束狀態 */
                    Query = @"Update T_TSTicketRouting Set IsEnd = 1 Where TicketID = @TicketID And ProcessID > @ProcessID";

                    dbcb = new DbCommandBuilder(Query);

                    Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

                    dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                    dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

                    DBA.AddCommandBuilder(dbcb);
                }

                /* 如果全部工序以全部結束，就把流程卡也結束 */
                Query = @"Update T_TSTicket Set IsEnd = Case When (Select Count(*) From T_TSTicketRouting Where TicketID = @TicketID And IsEnd = 0) > 0 Then 0 Else 1 End Where TicketID = @TicketID";

                dbcb = new DbCommandBuilder(Query);

                Schema = DBSchema.currentDB.Tables["T_TSTicket"];

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                DBA.AddCommandBuilder(dbcb);

                DBA.AddCommandBuilder(Util.TS.GetChangeWorkStationStatusDBCB(DeviceID, Util.TS.WorkStationStatus.Idle, DateTime.Parse("1900/01/01")));
            }
            else
            {
                /* 代表開立出的返工單數，還有剩餘待報工數量，因此要將當前的允許可報工數量修改 */

                Query = @"Update T_TSTicketCurrStatus Set AllowQty = @AllowQty Where TicketID = @TicketID";

                dbcb = new DbCommandBuilder(Query);

                Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

                dbcb.appendParameter(Schema.Attributes["AllowQty"].copy(NewAllowQty));

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            ResponseSuccessData(new { NewTicketID = NewTicketID, NewAllowQty = NewAllowQty });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 取得下一個返工單框號
    /// </summary>
    /// <returns>下一個返工單框號</returns>
    protected string GetNextBoxID()
    {
        string Query = @"Select IsNull(Max(Convert(int,BoxID) + 1),1) From T_TSTicket Where AUFNR = @AUFNR And TicketTypeID = @TicketTypeID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.Rework).ToString()));

        return ((int)CommonDB.ExecuteScalar(dbcb)).ToString("000").Trim();
    }

    /// <summary>
    /// 依照ProcessID_List取得路由表
    /// </summary>
    /// <returns>路由表</returns>
    protected DataTable GetRoutingTable()
    {
        string Query = @"Select * From T_TSTicketRouting Where TicketID = @TicketID And ProcessID In (";

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

        for (int i = 0; i < ProcessID_List.Count; i++)
        {
            string Parameter = "TicketID_" + i.ToString();

            Query += i < 1 ? "@" + Parameter : ",@" + Parameter;

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID_List[i], Parameter));
        }

        Query += ") Order By ProcessID Asc";

        dbcb.CommandText = Query;

        /* 因為返工單滿足了開立點，所以以主單的路由重新開立 */
        if (string.IsNullOrEmpty(MainTicketID))
            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        else
            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(MainTicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 再次檢查工序是否在活動中。應該是要 Group By APLZL 但先偷懶 */
        foreach (DataRow Row in DT.Rows)
        {
            string TargetAPLZL = Row["APLZL"].ToString().Trim();

            CheckProcessIsActivity(TargetAPLZL);
        }

        return DT;
    }

    /// <summary>
    /// 指定目標APLZL檢查工序是否活動中
    /// </summary>
    /// <param name="TargetAPLZL">目標APLZL</param>
    protected void CheckProcessIsActivity(string TargetAPLZL)
    {
        string Query = @"Select Top 1 * From T_TSSAPAFVC Where AUFPL = @AUFPL And APLZL = @APLZL";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFVC"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(AUFPL));

        dbcb.appendParameter(Schema.Attributes["APLZL"].copy(TargetAPLZL));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 如果成立的話，代表此工單是有指定途程的 */
        if (DT.Rows.Count > 0)
        {
            string PLNNR = DT.Rows[0]["PLNNR"].ToString().Trim();

            string PLNAL = DT.Rows[0]["PLNAL"].ToString().Trim();

            string PLNKN = DT.Rows[0]["PLNKN"].ToString().Trim();

            string VORNR = DT.Rows[0]["VORNR"].ToString().Trim();

            string LTXA1 = DT.Rows[0]["LTXA1"].ToString().Trim();

            /* 如果成立的話，代表此工單是有指定途程的，因此要再檢查此工序是否活動中 */
            if (!string.IsNullOrEmpty(PLNNR) && !string.IsNullOrEmpty(PLNAL) && !string.IsNullOrEmpty(PLNKN))
            {
                bool IsActivity = Util.TS.MOProcessIsActivity(PLNNR, PLNAL, PLNKN);

                /* 如果成立的話，代表此工序不在途程的活動中 */
                if (!IsActivity)
                    throw new CustomException(string.Format((string)GetLocalResourceObject("Str_Error_RoutingNotActive"), PLNNR, PLNAL, VORNR + "-" + LTXA1));
            }
        }
    }

    /// <summary>
    /// 載入流程卡資訊
    /// </summary>
    protected void LaodTicket()
    {
        string Query = @"Select * From T_TSTicket Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 理論上不會找不到資料，如果有那就出大事了 */
        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Empty_Ticket"));

        if ((bool)DT.Rows[0]["IsEnd"])
            throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketEnd"));

        AUFNR = DT.Rows[0]["AUFNR"].ToString().Trim();

        TicketSerialNo = (int)DT.Rows[0]["TicketSerialNo"];

        MainTicketID = DT.Rows[0]["MainTicketID"].ToString().Trim();

        PLNBEZ = DT.Rows[0]["PLNBEZ"].ToString().Trim();

        /* 有可能是返工單的返工單或是隔離單的返工單，因此要記住最源頭的返工單開立點。後續報工的算法跟這個欄位判斷有關係，千萬不能錯 */
        ReWorkMainProcessID = (int)DT.Rows[0]["ReWorkMainProcessID"];
        /****************************************************************************************************************************/

        Query = @"Select T_TSTicketCurrStatus.*,
                GetDate() As ReportTimeEnd,
                Datediff(Minute,EntryTime,GetDate()) As ReportMinute,
                IsNull((Select Sum(MaintainMinuteByMachine) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsClose = 0),0) As MaintainMinute,
                IsNull((Select Sum(WaitMinute) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsClose = 0),0) As WaitMinute,
                IsNull((Select Sum(QACheckMinute) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsEnd = 1 And IsClose = 0),0) As MaintainQACheckMinute,
                IsNull((Select Sum(PDCheckMinute) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsEnd = 1 And IsClose = 0),0) As MaintainPDCheckMinute,
                T_TSWorkShift.WorkShiftID
                From T_TSTicketCurrStatus Inner Join T_TSWorkShift On T_TSTicketCurrStatus.WorkShiftID = T_TSWorkShift.WorkShiftID Where TicketID = @TicketID";

        Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 理論上不會找不到資料，如果有那就出大事了 */
        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Empty_Ticket"));

        ProcessID = (int)DT.Rows[0]["ProcessID"];

        AUFPL = DT.Rows[0]["AUFPL"].ToString().Trim();

        APLZL = DT.Rows[0]["APLZL"].ToString().Trim();

        VORNR = DT.Rows[0]["VORNR"].ToString().Trim();

        DeviceID = DT.Rows[0]["DeviceID"].ToString().Trim();

        ReportTimeStart = (DateTime)DT.Rows[0]["EntryTime"];

        ReportTimeEnd = (DateTime)DT.Rows[0]["ReportTimeEnd"];

        ReportMinute = (int)DT.Rows[0]["ReportMinute"];

        MaintainMinute = (int)DT.Rows[0]["MaintainMinute"];

        WaitMaintainMinute = (int)DT.Rows[0]["WaitMinute"];

        MaintainQACheckMinute = (int)DT.Rows[0]["MaintainQACheckMinute"];

        MaintainPDCheckMinute = (int)DT.Rows[0]["MaintainPDCheckMinute"];

        ResultMinute = ReportMinute - (WaitMaintainMinute + MaintainMinute + MaintainQACheckMinute + MaintainPDCheckMinute);

        Brand = DT.Rows[0]["Brand"].ToString().Trim();

        WorkShiftID = DT.Rows[0]["WorkShiftID"].ToString().Trim();

        AllowQty = (int)DT.Rows[0]["AllowQty"];

        AccountID = (int)DT.Rows[0]["Operator"];
    }

    /// <summary>
    /// 取得當前工序是有報工良品數量
    /// </summary>
    protected int GetResultQty()
    {
        string Query = @"Select IsNull(Sum(GoodQty),0) From T_TSTicketResult Where TicketID = @TicketID And ProcessID = @ProcessID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

        return (int)CommonDB.ExecuteScalar(dbcb);
    }

    protected class DefectObject
    {
        public string DefectID = string.Empty;
        public int DefectQty = 0;
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}