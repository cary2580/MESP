<%@ WebHandler Language="C#" Class="TicketReportByOtherProcess" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketReportByOtherProcess : BasePage
{
    protected string TicketID = string.Empty;
    protected short SerialNo = 0;
    protected string ProcessID = string.Empty;
    protected new string WorkCode = string.Empty;
    protected new int AccountID = -1;
    protected string ParentTicketID = string.Empty;
    protected int Qty = 0;
    protected int CreateQty = 0;
    protected int AllowQty = 0;
    protected Util.TS.TicketType TT = Util.TS.TicketType.General;
    protected string Brand = string.Empty;
    protected bool IsEnd = false;
    protected string WorkShiftID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();
            if (_context.Request["ProcessID"] != null)
                ProcessID = _context.Request["ProcessID"].Trim();
            if (_context.Request["WorkCode"] != null)
                WorkCode = _context.Request["WorkCode"].Trim();
            if (_context.Request["WorkShiftID"] != null)
                WorkShiftID = _context.Request["WorkShiftID"].Trim();
            if (_context.Request["Qty"] != null && !int.TryParse(_context.Request["Qty"], out Qty))
                Qty = 0;
            if (_context.Request["SerialNo"] != null && !short.TryParse(_context.Request["SerialNo"], out SerialNo))
                SerialNo = 0;

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            if (string.IsNullOrEmpty(ProcessID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_ProcessID"));

            if (string.IsNullOrEmpty(WorkShiftID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkShiftID"));

            AccountID = BaseConfiguration.GetAccountID(WorkCode);

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            LoadTicketInfo();

            if (SerialNo < 1 && IsEnd)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketEnd"));

            if (TT != Util.TS.TicketType.Rework)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketType"));

            IsTicketOverQty();

            if (AllowQty < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_AllowQty"));

            if (Qty > AllowQty)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_AllowQtyOverQty"));

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResultByOtherProcess"];

            if (SerialNo < 1)
            {
                string Query = @"Insert Into T_TSTicketResultByOtherProcess (TicketID,ProcessID,SerialNo,Qty,ReportDate,Brand,Operator,WorkShiftID) Values (@TicketID,@ProcessID,
                                (Select IsNull(Max(SerialNo),0) + 1 From T_TSTicketResultByOtherProcess Where TicketID = @TicketID And ProcessID = @ProcessID),
                                @Qty,dbo.TS_GetReportDate(GetDate(),@WorkShiftID),@Brand,@Operator,@WorkShiftID)";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

                dbcb.appendParameter(Schema.Attributes["Qty"].copy(Qty));

                dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(WorkShiftID));

                dbcb.appendParameter(Schema.Attributes["Brand"].copy(Brand));

                dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

                DBA.AddCommandBuilder(dbcb);
            }
            else
            {
                string Query = @"Update T_TSTicketResultByOtherProcess Set Qty = @Qty,WorkShiftID = @WorkShiftID Where TicketID = @TicketID And ProcessID = @ProcessID And SerialNo = @SerialNo";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

                dbcb.appendParameter(Schema.Attributes["Qty"].copy(Qty));

                dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(WorkShiftID));

                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(SerialNo));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 載入流程卡資訊
    /// </summary>
    protected void LoadTicketInfo()
    {
        string Query = @"Select * From T_TSTicket Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_TicketID"));

        TT = (Util.TS.TicketType)Enum.Parse(typeof(Util.TS.TicketType), DT.Rows[0]["TicketTypeID"].ToString().Trim());

        ParentTicketID = DT.Rows[0]["ParentTicketID"].ToString().Trim();

        CreateQty = (int)DT.Rows[0]["Qty"];

        IsEnd = (bool)DT.Rows[0]["IsEnd"];
    }

    /// <summary>
    /// 檢查流程卡是否同工序中是否已超過開單數量
    /// </summary>
    protected void IsTicketOverQty()
    {
        string Query = @"Select Top 1 * From T_TSTicketResultByOtherProcess Where TicketID = @TicketID And ProcessID = @ProcessID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResultByOtherProcess"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        int Qty = 0;

        if (DT.Rows.Count > 0)
        {
            Brand = DT.Rows[0]["Brand"].ToString().Trim();

            dbcb = new DbCommandBuilder();

            Query = @"Select IsNull(Sum(Qty),0) From T_TSTicketResultByOtherProcess Where TicketID = @TicketID And ProcessID = @ProcessID";

            if (SerialNo > 0)
            {
                Query += " And SerialNo <> @SerialNo";

                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(SerialNo));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            Qty = (int)CommonDB.ExecuteScalar(dbcb);
        }

        Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        Query = @"Select Top 1 ProcessID,Brand From T_TSTicketResult Where TicketID = @TicketID Order By ProcessID Desc";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        int PreviousProcessID = 0;

        int PreviousQty = 0;

        if (DT.Rows.Count > 0)
        {
            PreviousProcessID = (int)DT.Rows[0]["ProcessID"];

            Brand = DT.Rows[0]["Brand"].ToString().Trim();
        }

        if (PreviousProcessID > 0)
        {
            Query = @"Select IsNull(Sum(GoodQty),0) + IsNull(Sum(ReWorkQty),0) As Qty From T_TSTicketResult Where TicketID = @TicketID And ProcessID = @ProcessID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(PreviousProcessID));

            DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count > 0)
                PreviousQty = (int)DT.Rows[0]["Qty"];
        }

        if (PreviousQty < 1)
            AllowQty = CreateQty - Qty;
        else
            AllowQty = PreviousQty - Qty;
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}