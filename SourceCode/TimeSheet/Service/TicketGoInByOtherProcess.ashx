<%@ WebHandler Language="C#" Class="TicketGoInByOtherProcess" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketGoInByOtherProcess : BasePage
{
    protected string TicketID = string.Empty;
    protected string ProcessID = string.Empty;
    protected new string WorkCode = string.Empty;
    protected new int AccountID = -1;
    protected string ParentTicketID = string.Empty;
    protected int CreateQty = 0;
    protected int AllowQty = 0;
    protected Util.TS.TicketType TT = Util.TS.TicketType.General;
    protected string Brand = string.Empty;
    protected string TEXT1 = string.Empty;
    protected bool IsEnd = false;

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

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            if (string.IsNullOrEmpty(ProcessID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_ProcessID"));

            AccountID = BaseConfiguration.GetAccountID(WorkCode);

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            LoadTicketInfo();

            if (IsEnd)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketEnd"));

            if (TT != Util.TS.TicketType.Rework)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketType"));

            IsTicketOverQty();

            if (AllowQty < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_AllowQty"));

            ResponseSuccessData(new
            {
                TicketID = TicketID,
                AllowQty = AllowQty,
                Brand = Brand,
                TEXT1 = TEXT1
            });
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

            Query = @"Select IsNull(Sum(Qty),0) From T_TSTicketResultByOtherProcess Where TicketID = @TicketID And ProcessID = @ProcessID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            Qty = (int)CommonDB.ExecuteScalar(dbcb);
        }

        TEXT1 = Util.TS.GetTEXT1(TicketID);

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