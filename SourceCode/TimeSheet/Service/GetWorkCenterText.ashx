<%@ WebHandler Language="C#" Class="GetWorkCenterText" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using Sap.Data.Hana;

public class GetWorkCenterText : BasePage
{
    protected string ARBPL = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["ARBPL"] != null)
                ARBPL = _context.Request["ARBPL"].Trim();

            if (string.IsNullOrEmpty(ARBPL))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_ARBPL"));

            string Query = @"Select CRHD.ARBPL,CRTX.KTEXT
                            From CRHD Inner Join CRTX On CRHD.MANDT = CRTX.MANDT And CRHD.OBJTY = CRTX.OBJTY And CRHD.OBJID = CRTX.OBJID
                            Where CRHD.MANDT = ? And WERKS = ? And CRHD.ARBPL = ?";

            HanaCommand Command = new HanaCommand(Query);

            Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
            Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());
            Command.Parameters.Add("ARBPL", ARBPL);

            DataTable DT = SAP.GetSelectSAPData(Command);

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_ARBPLRow"));

            ResponseSuccessData(new { KTEXT = DT.Rows[0]["KTEXT"].ToString().Trim() });

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