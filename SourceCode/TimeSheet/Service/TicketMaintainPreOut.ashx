<%@ WebHandler Language="C#" Class="TicketMaintainPreOut" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainPreOut : BasePage
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
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkCode"));

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

            DateTime MaintainStartTime = (DateTime)DT.Rows[0]["MaintainStartTime"];

            DateTime MaintainEndTime = DateTime.Now;

            double MaintainMinute = (MaintainEndTime - MaintainStartTime).TotalMinutes;

            if ((int)MaintainMinute < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_MaintainTimeToShort"));

            Query = @"Update T_TSTicketMaintainMinute Set MaintainEndTime = @MaintainEndTime,MaintainMinute = @MaintainMinute Where MaintainID = @MaintainID And Operator = @Operator";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainEndTime"].copy(MaintainEndTime));

            dbcb.appendParameter(Schema.Attributes["MaintainMinute"].copy(MaintainMinute));

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