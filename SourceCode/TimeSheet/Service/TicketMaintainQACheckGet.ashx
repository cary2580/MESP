<%@ WebHandler Language="C#" Class="TicketMaintainQACheckGet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainQACheckGet : BasePage
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

            string Query = @"Select *,Base_Org.dbo.GetAccountName(QACheckAccountID) As QACheckAccountName,Base_Org.dbo.GetAccountWorkCode(QACheckAccountID) As QACheckAccountWorkCode From T_TSTicketMaintain Where MaintainID = @MaintainID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_NoMaintainData"));

            ResponseSuccessData(new
            {
                QACheckTimeStart = ((DateTime)DT.Rows[0]["QACheckTimeStart"]).ToCurrentUICultureStringTime(),
                QACheckTimeEnd = ((DateTime)DT.Rows[0]["QACheckTimeEnd"]).ToCurrentUICultureStringTime(),
                QACheckMinute = DT.Rows[0]["QACheckMinute"].ToString().Trim(),
                QACheckAccountID = DT.Rows[0]["QACheckAccountID"].ToString().Trim(),
                QACheckAccountWorkCode = DT.Rows[0]["QACheckAccountWorkCode"].ToString().Trim(),
                QACheckAccountName = DT.Rows[0]["QACheckAccountName"].ToString().Trim()
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