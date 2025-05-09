<%@ WebHandler Language="C#" Class="TicketQuarantineSetItem" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketQuarantineSetItem : BasePage
{
    protected bool IsFinish = false;
    protected string TicketID = string.Empty;
    protected int Qty = 0;
    protected string ScrapReason = string.Empty;
    protected string DefectID = string.Empty;
    protected string Remark = string.Empty;
    protected string JudgmentWorkCode = string.Empty;

    protected int AllowQty = 0;
    protected int TicketQty = 0;
    protected int ScrapQty = 0;
    protected int ProcessID = 0;
    protected int ReWorkMainProcessID = 0;
    protected int CreateAccountID = 0;
    protected string ParentTicketID = string.Empty;
    protected string AUFPL = string.Empty;
    protected string APLZL = string.Empty;
    protected string VORNR = string.Empty;
    protected string DeviceID = string.Empty;
    protected string Brand = string.Empty;
    protected string WorkShiftID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["IsFinish"] != null)
            {
                if (!bool.TryParse(_context.Request["IsFinish"].Trim(), out IsFinish))
                    IsFinish = false;
            }

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();
            if (_context.Request["ScrapQty"] != null)
            {
                if (!int.TryParse(_context.Request["ScrapQty"].Trim(), out Qty))
                    Qty = 0;
            }

            if (_context.Request["ScrapReason"] != null)
                ScrapReason = _context.Request["ScrapReason"].Trim();
            if (_context.Request["DefectID"] != null)
                DefectID = _context.Request["DefectID"].Trim();
            if (_context.Request["Remark"] != null)
                Remark = _context.Request["Remark"].Trim();
            if (_context.Request["JudgmentWorkCode"] != null)
                JudgmentWorkCode = _context.Request["JudgmentWorkCode"].Trim();

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            if (!IsFinish)
            {
                if (string.IsNullOrEmpty(ScrapReason))
                    throw new CustomException((string)GetLocalResourceObject("Str_Empty_ScrapReason"));
                if (string.IsNullOrEmpty(DefectID))
                    throw new CustomException((string)GetLocalResourceObject("Str_Empty_DefectID"));
                if (Qty < 1)
                    throw new CustomException((string)GetLocalResourceObject("Str_Empty_ScrapQty"));
            }

            LoadData();

            DBAction DBA = new DBAction();

            ObjectSchema Schema;

            DbCommandBuilder dbcb = new DbCommandBuilder();

            string Query = string.Empty;

            if (!IsFinish)
            {
                Query = @"Insert Into T_TSTicketQuarantineResultItem (TicketID,SerialNo,ScrapReasonID,DefectID,ScrapQty,Remark,JudgmentAccount) Values (@TicketID,(Select IsNull(Max(SerialNo) + 1,1) From T_TSTicketQuarantineResultItem Where TicketID = @TicketID),@ScrapReasonID,@DefectID,@ScrapQty,@Remark,@JudgmentAccount)";

                dbcb = new DbCommandBuilder(Query);

                Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResultItem"];

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                dbcb.appendParameter(Schema.Attributes["ScrapReasonID"].copy(ScrapReason));

                dbcb.appendParameter(Schema.Attributes["DefectID"].copy(DefectID));

                dbcb.appendParameter(Schema.Attributes["ScrapQty"].copy(Qty));

                dbcb.appendParameter(Schema.Attributes["Remark"].copy(Remark));

                dbcb.appendParameter(Schema.Attributes["JudgmentAccount"].copy(AccountID));

                DBA.AddCommandBuilder(dbcb);
            }

            Query = @"Update T_TSTicketQuarantineResult Set ScrapQty = @ScrapQty ";

            int NewScrapQty = ScrapQty + Qty;

            /* 剩餘量 */
            int LastQty = TicketQty - NewScrapQty;

            Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResult"];

            dbcb = new DbCommandBuilder();

            bool IsJudgment = false;

            //是否要自動判定完成隔離單
            bool IsEnableAutoJudgmentForTicketQuarantine = System.Configuration.ConfigurationManager.AppSettings["IsEnableAutoJudgmentForTicketQuarantine"].ToBoolean();

            if (IsFinish)
                IsEnableAutoJudgmentForTicketQuarantine = true;

            /* 因為已經沒有剩餘量了，就關閉隔離單 */
            if ((LastQty < 1 || IsFinish) && IsEnableAutoJudgmentForTicketQuarantine)
            {
                if (NewScrapQty > 0)
                    AddInsertTicketResultDBCB(DBA, NewScrapQty, LastQty);

                Query += ",JudgmentAccount = @JudgmentAccount,IsJudgment = 1 ";

                dbcb.appendParameter(Schema.Attributes["JudgmentAccount"].copy(AccountID));

                IsJudgment = true;
            }

            dbcb.CommandText = Query += " Where TicketID = @TicketID";

            dbcb.appendParameter(Schema.Attributes["ScrapQty"].copy(NewScrapQty));

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            ResponseSuccessData(new { IsJudgment = IsJudgment.ToStringValue() });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 指定BDA、報廢數得到新增隔離單判定完成寫入到結果表語法，如果沒有剩餘數量的話，就把此隔離單所有工序結束並關閉並此隔離單
    /// </summary>
    /// <param name="DBA">DBA</param>
    /// <param name="NewScrapQty">報廢數量</param>
    /// <param name="LastQty">剩餘數量</param>
    protected void AddInsertTicketResultDBCB(DBAction DBA, int NewScrapQty, int LastQty)
    {
        string Query = @"Insert Into T_TSTicketResult (TicketID,ProcessID,SerialNo,AUFPL,APLZL,VORNR,DeviceID,GoodQty,ScrapQty,ReWorkQty,ReportDate,ReportTimeStart,ReportTimeEnd,ReportMinute,MaintainMinute,MaintainQACheckMinute,MaintainPDCheckMinute,ResultMinute,ResultMinuteMainOperator,WaitMaintainMinute,WaitMinute,Brand,Operator,WorkShiftID,Approver,ApprovalTime)
                                                Values (@TicketID,@ProcessID,(Select IsNull(Max(SerialNo) + 1,1) From T_TSTicketResult Where TicketID = @TicketID),@AUFPL,@APLZL,@VORNR,@DeviceID,@GoodQty,@ScrapQty,@ReWorkQty,dbo.TS_GetReportDate(GetDate(),@WorkShiftID),GetDate(),GetDate(),0,0,0,0,0,0,0,0,@Brand,@Operator,@WorkShiftID,@Approver,GetDate())";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

        dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(AUFPL));
        dbcb.appendParameter(Schema.Attributes["APLZL"].copy(APLZL));
        dbcb.appendParameter(Schema.Attributes["VORNR"].copy(VORNR));
        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
        dbcb.appendParameter(Schema.Attributes["GoodQty"].copy(0));
        dbcb.appendParameter(Schema.Attributes["ScrapQty"].copy(NewScrapQty));
        dbcb.appendParameter(Schema.Attributes["ReWorkQty"].copy(0));
        dbcb.appendParameter(Schema.Attributes["Brand"].copy(Brand));
        dbcb.appendParameter(Schema.Attributes["Operator"].copy(CreateAccountID));
        dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(WorkShiftID));
        dbcb.appendParameter(Schema.Attributes["Approver"].copy(AccountID));

        DBA.AddCommandBuilder(dbcb);

        /* 還有剩餘數量，所以就讓剩餘數量繼續可以往下報工 */
        if (LastQty > 0)
            return;

        Query = @"Update T_TSTicketRouting Set IsEnd = 1 Where TicketID = @TicketID";

        Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DBA.AddCommandBuilder(dbcb);

        Query = @"Update T_TSTicket Set IsEnd = 1 Where TicketID = @TicketID";

        Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DBA.AddCommandBuilder(dbcb);
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select * From T_TSTicketQuarantineResult Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_NoTicketQuarantineResultData"));

        if ((bool)DT.Rows[0]["IsJudgment"])
            throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketQuarantineFinish"));

        TicketQty = (int)DT.Rows[0]["Qty"];

        ScrapQty = (int)DT.Rows[0]["ScrapQty"];

        AUFPL = DT.Rows[0]["AUFPL"].ToString().Trim();

        APLZL = DT.Rows[0]["APLZL"].ToString().Trim();

        VORNR = DT.Rows[0]["VORNR"].ToString().Trim();

        DeviceID = DT.Rows[0]["DeviceID"].ToString().Trim();

        Brand = DT.Rows[0]["Brand"].ToString().Trim();

        WorkShiftID = DT.Rows[0]["WorkShiftID"].ToString().Trim();

        AllowQty = TicketQty - ScrapQty;

        if (!IsFinish && (AllowQty - Qty < 0))
            throw new CustomException((string)GetLocalResourceObject("Str_Error_OverAllowQty"));

        ProcessID = (int)DT.Rows[0]["ProcessID"];

        Query = @"Select * From T_TSTicket Where TicketID = @TicketID";

        Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 照理說不會找不到資料，如果是找不到資料，那就出大事了 */
        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_NoTicketQuarantineResultData"));

        ReWorkMainProcessID = (int)DT.Rows[0]["ReWorkMainProcessID"];

        CreateAccountID = (int)DT.Rows[0]["CreateAccountID"];

        ParentTicketID = DT.Rows[0]["ParentTicketID"].ToString().Trim();

        AccountID = BaseConfiguration.GetAccountID(JudgmentWorkCode);

        if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}