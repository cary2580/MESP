<%@ WebHandler Language="C#" Class="LableScanDelete" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class LableScanDelete : BasePage
{
    protected List<string> ScanList = new List<string>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["ScanKeyS"] != null)
                ScanList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(_context.Request["ScanKeyS"].Trim());

            string Query = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            foreach (string ScanKey in ScanList)
            {
                Query = @"Update T_TSLableScan Set StatusID = @StatusID Where ScanKey = @ScanKey";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["StatusID"].copy(((short)Util.TS.LableScanStatus.CancelLable).ToString()));
                    
                dbcb.appendParameter(Schema.Attributes["ScanKey"].copy(ScanKey));

                CommonDB.ExecuteSingleCommand(dbcb);
            }
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