<%@ WebHandler Language="C#" Class="TicketMaintainFaultAdd" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainFaultAdd : BasePage
{
    protected string MaintainID = string.Empty;
    protected string FaultCategoryID = string.Empty;
    protected string FaultID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["MaintainID"] != null)
                MaintainID = _context.Request["MaintainID"].Trim();
            if (_context.Request["FaultCategoryID"] != null)
                FaultCategoryID = _context.Request["FaultCategoryID"].Trim();
            if (_context.Request["FaultID"] != null)
                FaultID = _context.Request["FaultID"].Trim();

            if (string.IsNullOrEmpty(MaintainID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MaintainID"));
            if (string.IsNullOrEmpty(FaultCategoryID))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_FaultCategoryID"));
            if (string.IsNullOrEmpty(FaultID))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_FaultID"));

            string Query = @"Select Count(*) From T_TSTicketMaintainFault Where MaintainID = @MaintainID And FaultCategoryID = @FaultCategoryID And FaultID = @FaultID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainFault"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));
            dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(FaultCategoryID));
            dbcb.appendParameter(Schema.Attributes["FaultID"].copy(FaultID));

            if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_FaultRepeat"));

            Query = @"Insert Into T_TSTicketMaintainFault (MaintainID,FaultCategoryID,FaultID) Values (@MaintainID,@FaultCategoryID,@FaultID)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));
            dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(FaultCategoryID));
            dbcb.appendParameter(Schema.Attributes["FaultID"].copy(FaultID));

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