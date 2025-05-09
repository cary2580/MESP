<%@ WebHandler Language="C#" Class="TicketReportDeleteByOtherProcess" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketReportDeleteByOtherProcess : BasePage
{
    protected List<DeleteObject> DeleteList = new List<DeleteObject>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["DeleteList"] != null)
                DeleteList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<DeleteObject>>(context.Request["DeleteList"].Trim());

            DBAction DBA = new DBAction();

            string Query = @"Delete T_TSTicketResultByOtherProcess Where TicketID = @TicketID And ProcessID = @ProcessID And SerialNo = @SerialNo";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResultByOtherProcess"];

            foreach (DeleteObject DO in DeleteList)
            {
                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(DO.TicketID));

                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(DO.ProcessID));

                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(DO.SerialNo));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    protected class DeleteObject
    {
        public string TicketID { get; set; }
        public string ProcessID { get; set; }
        public short SerialNo { get; set; }
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}