<%@ WebHandler Language="C#" Class="TicketMaintainFaultDelete" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainFaultDelete : BasePage
{
    protected string MaintainID = string.Empty;

    protected List<FaultObject> FaultList = new List<FaultObject>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["MaintainID"] != null)
                MaintainID = _context.Request["MaintainID"].Trim();
            if (_context.Request["FaultList"] != null)
                FaultList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<FaultObject>>(context.Request["FaultList"].Trim());

            if (string.IsNullOrEmpty(MaintainID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MaintainID"));

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainFault"];

            foreach (FaultObject FO in FaultList)
            {
                string Query = @"Delete T_TSTicketMaintainFault Where MaintainID = @MaintainID And FaultCategoryID = @FaultCategoryID And FaultID = @FaultID";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));
                dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(FO.FaultCategoryID));
                dbcb.appendParameter(Schema.Attributes["FaultID"].copy(FO.FaultID));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    protected class FaultObject
    {
        public string FaultCategoryID { get; set; }
        public string FaultID { get; set; }
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}