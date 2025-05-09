<%@ WebHandler Language="C#" Class="TicketResultDelete" %>

using System;
using System.Web;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketResultDelete : BasePage
{
    protected string TicketID = string.Empty;
    protected int ProcessID = 0;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            if (_context.Request["ProcessID"] != null)
            {
                if (!int.TryParse(_context.Request["ProcessID"].Trim(), out ProcessID))
                    ProcessID = 0;
            }

            if (ProcessID < 1)
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_ProcessID"));

            CheckDeleteRule();

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

            string Query = @"Delete T_TSTicketResult Where TicketID = @TicketID And ProcessID >= @ProcessID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketResultSecondOperator Where TicketID = @TicketID And ProcessID >= @ProcessID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Update T_TSTicketRouting Set IsEnd = 0 Where TicketID = @TicketID And ProcessID >= @ProcessID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Update T_TSTicket Set IsEnd = 0 Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 檢查是否可以刪除報工結果資料的規格
    /// </summary>
    protected void CheckDeleteRule()
    {
        string Query = @"Select Count(*) From dbo.TS_GetFullSubTicket(@TicketID,0) Where CreateProcessID >= @CreateProcessID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["CreateProcessID"].copy(ProcessID));

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_HaveSubTicketID"));

        Query = @"Select Count(*) From T_TSTicketMaintain Where TicketID = @TicketID And ProcessID >= @ProcessID";

        Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_HaveMaintainData"));

        Query = @"Select Count(*) From T_TSTicketCurrStatus Where TicketID = @TicketID";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_InCurrStatus"));
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}