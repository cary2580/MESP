<%@ WebHandler Language="C#" Class="TicketMaintainCancel" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainCancel : BasePage
{
    protected string MaintainID = string.Empty;

    protected string Operator = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["MaintainID"] != null)
                MaintainID = _context.Request["MaintainID"].Trim();

            if (_context.Request["Operator"] != null)
                Operator = _context.Request["Operator"].Trim();

            if (string.IsNullOrEmpty(MaintainID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MaintainID"));
            if (string.IsNullOrEmpty(Operator))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_Operator"));

            AccountID = int.Parse(Operator);

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            string Query = @"Select * From T_TSTicketMaintainMinute Where MaintainID = @MaintainID And Operator = @Operator";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainMinute"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_NoMaintainData"));

            Query = @"Delete T_TSTicketMaintainMinute Where MaintainID = @MaintainID And Operator = @Operator";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

            CommonDB.ExecuteSingleCommand(dbcb);
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}