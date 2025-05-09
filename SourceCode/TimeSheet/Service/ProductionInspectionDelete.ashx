<%@ WebHandler Language="C#" Class="ProductionInspectionDelete" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class ProductionInspectionDelete : BasePage
{
    protected string PIID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["PIID"] != null)
                PIID = _context.Request["PIID"].Trim();

            if (string.IsNullOrEmpty(PIID))
                throw new CustomException((string)GetLocalResourceObject("Str_Error_Empty_PIID"));

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspection"];

            string Query = @"Delete T_TSProductionInspectionNGItem Where PIID = @PIID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(PIID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSProductionInspection Where PIID = @PIID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(PIID));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

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