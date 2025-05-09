<%@ WebHandler Language="C#" Class="TicketMaintainPDCheckGet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainPDCheckGet : BasePage
{
    protected string MaintainID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["MaintainID"] != null)
                MaintainID = _context.Request["MaintainID"].Trim();

            if (string.IsNullOrEmpty(MaintainID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MaintainID"));

            string Query = @"Select *,Base_Org.dbo.GetAccountName(PDCheckAccountID) As PDCheckAccountName,Base_Org.dbo.GetAccountWorkCode(PDCheckAccountID) As PDCheckAccountWorkCode From T_TSTicketMaintain Where MaintainID = @MaintainID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_NoMaintainData"));

            ResponseSuccessData(new
            {
                PDCheckTimeStart = ((DateTime)DT.Rows[0]["PDCheckTimeStart"]).ToCurrentUICultureStringTime(),
                PDCheckTimeEnd = ((DateTime)DT.Rows[0]["PDCheckTimeEnd"]).ToCurrentUICultureStringTime(),
                PDCheckMinute = DT.Rows[0]["PDCheckMinute"].ToString().Trim(),
                PDCheckAccountID = DT.Rows[0]["PDCheckAccountID"].ToString().Trim(),
                PDCheckAccountWorkCode = DT.Rows[0]["PDCheckAccountWorkCode"].ToString().Trim(),
                PDCheckAccountName = DT.Rows[0]["PDCheckAccountName"].ToString().Trim()
            });
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