<%@ WebHandler Language="C#" Class="TicketMaintainChangeResponsibleID" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Newtonsoft.Json;

public class TicketMaintainChangeResponsibleID : BasePage
{
    protected string TicketID = string.Empty;
    protected List<string> ResponsibleListID = new List<string>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            if (_context.Request["ResponsibleListID"] != null)
                ResponsibleListID = JsonConvert.DeserializeObject<List<string>>(_context.Request["ResponsibleListID"].Trim());

            string Query = @"Select * From T_TSTicketCurrStatus Where TicketID = @TicketID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_NoTicketCurrStatusRow"));

            string DeviceID = DT.Rows[0]["DeviceID"].ToString().Trim();

            DBAction DBA = new DBAction();

            Query = @"Delete T_TSTicketMaintainResponsibleCurr Where DeviceID = @DeviceID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainResponsibleCurr"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

            DBA.AddCommandBuilder(dbcb);

            foreach (string ResponsibleID in ResponsibleListID)
            {
                if (string.IsNullOrEmpty(ResponsibleID))
                    continue;

                Query = "Insert Into T_TSTicketMaintainResponsibleCurr (DeviceID,SerialNo,ResponsibleID) Values (@DeviceID,IsNull((Select Max(SerialNo) + 1 From T_TSTicketMaintainResponsibleCurr Where DeviceID = @DeviceID),1),@ResponsibleID)";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

                dbcb.appendParameter(Schema.Attributes["ResponsibleID"].copy(ResponsibleID));

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