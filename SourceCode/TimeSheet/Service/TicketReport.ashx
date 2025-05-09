<%@ WebHandler Language="C#" Class="TicketReport" %>

using System;
using System.Web;
using System.Data;
using System.Linq;
using Newtonsoft.Json;
using System.Collections.Generic;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketReport : BasePage
{
    protected string TicketID = string.Empty;
    protected int ProcessID = 0;
    protected int AllowQty = 0;
    protected int GoodQty = 0;
    protected int ReWorkQty = 0;
    protected string AUFPL = string.Empty;
    protected string APLZL = string.Empty;
    protected string VORNR = string.Empty;
    protected string DeviceID = string.Empty;
    protected DateTime ReportTimeStart = DateTime.Parse("1900/01/01");
    protected DateTime ReportTimeEnd = DateTime.Parse("1900/01/01");
    protected int ReportMinute = 0;
    protected int WaitMaintainMinute = 0;
    protected int MaintainMinute = 0;
    protected int MaintainQACheckMinute = 0;
    protected int MaintainPDCheckMinute = 0;
    protected int ResultMinute = 0;
    protected int WaitMinute = 0;
    protected string Brand = string.Empty;
    protected string Operator = string.Empty;
    protected string WorkShiftID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (_context.Request["GoodQty"] != null)
            {
                if (!int.TryParse(_context.Request["GoodQty"].Trim(), out GoodQty))
                    GoodQty = 0;
            }

            if (_context.Request["ReWorkQty"] != null)
            {
                if (!int.TryParse(_context.Request["ReWorkQty"].Trim(), out ReWorkQty))
                    ReWorkQty = 0;
            }

            if (_context.Request["WaitMinute"] != null)
            {
                if (!int.TryParse(_context.Request["WaitMinute"].Trim(), out WaitMinute))
                    WaitMinute = 0;
            }

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_TicketID"));

            LoadTicketCurrStatus();

            if ((GoodQty + ReWorkQty) > AllowQty)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_OverReportQty") + "(" + AllowQty.ToString() + ")");

            DBAction DBA = new DBAction();

            string Query = @"Insert Into T_TSTicketResult (TicketID,ProcessID,SerialNo,AUFPL,APLZL,VORNR,DeviceID,GoodQty,ScrapQty,ReWorkQty,ReportDate,ReportTimeStart,ReportTimeEnd,ReportMinute,WaitMaintainMinute,MaintainMinute,MaintainQACheckMinute,MaintainPDCheckMinute,ResultMinute,
                        Coefficient,ResultMinuteMainOperator,WaitMinute,Brand,Operator,WorkShiftID)
                        Values (@TicketID,@ProcessID,IsNull((Select Max(SerialNo) + 1 From T_TSTicketResult Where TicketID = @TicketID And ProcessID = @ProcessID),1),@AUFPL,@APLZL,
                        @VORNR,@DeviceID,@GoodQty,0,@ReWorkQty,dbo.TS_GetReportDate(@ReportTimeEnd,@WorkShiftID),@ReportTimeStart,@ReportTimeEnd,@ReportMinute,@WaitMaintainMinute,@MaintainMinute,@MaintainQACheckMinute,@MaintainPDCheckMinute,@ResultMinute,@Coefficient,@ResultMinuteMainOperator,@WaitMinute,@Brand,@Operator,@WorkShiftID)";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));
            dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(AUFPL));
            dbcb.appendParameter(Schema.Attributes["APLZL"].copy(APLZL));
            dbcb.appendParameter(Schema.Attributes["VORNR"].copy(VORNR));
            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
            dbcb.appendParameter(Schema.Attributes["GoodQty"].copy(GoodQty));
            dbcb.appendParameter(Schema.Attributes["ReWorkQty"].copy(ReWorkQty));
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
            dbcb.appendParameter(Schema.Attributes["WaitMinute"].copy(WaitMinute));
            dbcb.appendParameter(Schema.Attributes["Brand"].copy(Brand));
            dbcb.appendParameter(Schema.Attributes["Operator"].copy(Operator));
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

            Query = @"Update T_TSTicketMaintain Set IsClose = 1 Where TicketID = @TicketID And ProcessID = @ProcessID And IsEnd = 1 And IsClose = 0";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketCurrStatus Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

            DBA.AddCommandBuilder(Util.TS.GetChangeWorkStationStatusDBCB(DeviceID, Util.TS.WorkStationStatus.Idle, DateTime.Parse("1900/01/01")));

            // 因為有機率會發生，進工後毫無生產，需要開立維修單。從此此張流程卡當班可能就完全沒生產。因此要讓它出工記下時間
            //if ((GoodQty + ReWorkQty) < 1)
            //    throw new Exception((string)GetLocalResourceObject("Str_Error_ReportQty"));

            bool HaveAwaitQty = ((GoodQty + ReWorkQty) < AllowQty);

            /* 如果成立，代表此工序已完成報工，因次要將此工序更新已結束狀態，反之還有待報工數量不能關閉路由 */
            if (!HaveAwaitQty)
            {
                Query = @"Update T_TSTicketRouting Set IsEnd = 1 Where TicketID = @TicketID And ProcessID = @ProcessID";

                dbcb = new DbCommandBuilder(Query);

                Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

                DBA.AddCommandBuilder(dbcb);

                bool TicketAllProcessEnd = Util.TS.IsTicketAllProcessEnd(TicketID, ProcessID.ToString());

                /* 如果成立，代表整張流程卡的工序都已經完成報工，因此要將流程卡的狀態更新為已結束 */
                if (TicketAllProcessEnd)
                {
                    Query = @"Update T_TSTicket Set IsEnd = 1 Where TicketID = @TicketID";

                    dbcb = new DbCommandBuilder(Query);

                    Schema = DBSchema.currentDB.Tables["T_TSTicket"];

                    dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                    DBA.AddCommandBuilder(dbcb);
                }
            }

            DBA.Execute();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 載入TicketCurrStatus
    /// </summary>
    protected void LoadTicketCurrStatus()
    {
        string Query = @"Select 
                ProcessID,
                AUFPL,
                APLZL,
                VORNR,
                DeviceID,
                EntryTime As ReportTimeStart,
                GetDate() As ReportTimeEnd,
                Datediff(Minute,EntryTime,GetDate()) As ReportMinute,
                IsNull((Select Sum(MaintainMinuteByMachine) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsEnd = 1 And IsClose = 0),0) As MaintainMinute,
                IsNull((Select Sum(QACheckMinute) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsEnd = 1 And IsClose = 0),0) As QACheckMinute,
                IsNull((Select Sum(PDCheckMinute) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsEnd = 1 And IsClose = 0),0) As PDCheckMinute,
                IsNull((Select Sum(WaitMinute) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsEnd = 1 And IsClose = 0),0) As WaitMinute,
                AllowQty,
                Brand,
                T_TSWorkShift.WorkShiftID,
                T_TSWorkShift.WorkShiftName,
                Operator,
                Base_Org.dbo.GetAccountName(Operator) As OperatorName
                From T_TSTicketCurrStatus Inner Join T_TSWorkShift On T_TSTicketCurrStatus.WorkShiftID = T_TSWorkShift.WorkShiftID
                Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_CurrStatusNoData"));

        ProcessID = (int)DT.Rows[0]["ProcessID"];

        Query = @"Select Count(*) From T_TSTicketMaintain Where TicketID = @TicketID And ProcessID = @ProcessID And IsEnd = 0";

        Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_MaintainNoEnd"));

        AUFPL = DT.Rows[0]["AUFPL"].ToString().Trim();
        APLZL = DT.Rows[0]["APLZL"].ToString().Trim();
        VORNR = DT.Rows[0]["VORNR"].ToString().Trim();
        DeviceID = DT.Rows[0]["DeviceID"].ToString().Trim();
        ReportTimeStart = (DateTime)DT.Rows[0]["ReportTimeStart"];
        ReportTimeEnd = (DateTime)DT.Rows[0]["ReportTimeEnd"];
        ReportMinute = (int)DT.Rows[0]["ReportMinute"];
        MaintainMinute = (int)DT.Rows[0]["MaintainMinute"];
        MaintainQACheckMinute = (int)DT.Rows[0]["QACheckMinute"];
        MaintainPDCheckMinute = (int)DT.Rows[0]["PDCheckMinute"];
        WaitMaintainMinute = (int)DT.Rows[0]["WaitMinute"];
        ResultMinute = ReportMinute - (WaitMinute + MaintainMinute + MaintainQACheckMinute + MaintainPDCheckMinute + WaitMaintainMinute);
        Brand = DT.Rows[0]["Brand"].ToString().Trim();
        WorkShiftID = DT.Rows[0]["WorkShiftID"].ToString().Trim();
        Operator = DT.Rows[0]["Operator"].ToString().Trim();
        AllowQty = (int)DT.Rows[0]["AllowQty"];
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}