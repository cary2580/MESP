<%@ WebHandler Language="C#" Class="TicketMaintainDelete" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainDelete : BasePage
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

            string Query = @"Select * From T_TSTicketMaintain Where MaintainID = @MaintainID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_NoMaintainData"));

            string DeviceID = DT.Rows[0]["DeviceID"].ToString().Trim();

            string TicketID = DT.Rows[0]["TicketID"].ToString().Trim();

            string ProcessID = DT.Rows[0]["ProcessID"].ToString().Trim();

            DBAction DBA = new DBAction();

            Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainFault"];

            Query = @"Delete T_TSTicketMaintain Where MaintainID = @MaintainID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketMaintainFault Where MaintainID = @MaintainID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketMaintainFaultByFirstTime Where MaintainID = @MaintainID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketMaintainMinute Where MaintainID = @MaintainID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Select * From T_TSTicketCurrStatus Where TicketID = @TicketID And ProcessID = @ProcessID";

            Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                DBA.AddCommandBuilder(Util.TS.GetChangeWorkStationStatusDBCB(DeviceID, Util.TS.WorkStationStatus.Idle, DateTime.Parse("1900/01/01")));
            else
            {
                int Operator = (int)DT.Rows[0]["Operator"];

                string WorkShiftID = DT.Rows[0]["WorkShiftID"].ToString().Trim();

                DateTime EntryTime = (DateTime)DT.Rows[0]["EntryTime"];

                DBA.AddCommandBuilder(Util.TS.GetChangeWorkStationStatusDBCB(DeviceID, Util.TS.WorkStationStatus.InMake, EntryTime, Operator, WorkShiftID));
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