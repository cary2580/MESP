<%@ WebHandler Language="C#" Class="MOActivity" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class MOActivity : BasePage
{
    protected List<string> AUFNRList = new List<string>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["AUFNRList"] != null)
                AUFNRList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(_context.Request["AUFNRList"].Trim());

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

            string Query = @"Update T_TSSAPAFKO Set [STATUS] = @STATUS Where AUFNR = @AUFNR";

            DBAction DBA = new DBAction();

            foreach (string AUFNR in AUFNRList)
            {
                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(Util.TS.ToAUFNR(AUFNR)));

                dbcb.appendParameter(Schema.Attributes["STATUS"].copy(((short)Util.TS.MOStatus.InProcess).ToString()));

                DBA.AddCommandBuilder(dbcb);
            }

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