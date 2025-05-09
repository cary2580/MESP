<%@ WebHandler Language="C#" Class="FaultGet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class FaultGet : BasePage
{
    protected string FaultCategoryID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["FaultCategoryID"] != null)
                FaultCategoryID = _context.Request["FaultCategoryID"].Trim();

            if (string.IsNullOrEmpty(FaultCategoryID))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_FaultCategoryID"));

            string Query = @"Select '' As FaultID,N'" + (string)GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText") + "' As FaultName Union All Select T_TSFault.FaultID,T_TSFault.FaultName From T_TSFault Inner Join T_TSFaultMapping On T_TSFault.FaultID = T_TSFaultMapping.FaultID Where T_TSFaultMapping.FaultCategoryID = @FaultCategoryID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultMapping"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(FaultCategoryID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            var ResponseData = DT.AsEnumerable().Select(Row => new { FaultID = Row["FaultID"].ToString().Trim(), FaultName = Row["FaultName"].ToString().Trim() });

            ResponseSuccessData(ResponseData);
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