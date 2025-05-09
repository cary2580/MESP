<%@ WebHandler Language="C#" Class="WorkStationStatusSet" %>

using System;
using System.Web;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class WorkStationStatusSet : BasePage
{
    protected Util.TS.WorkStationStatus WorkStationStatus;
    protected string TicketID = string.Empty;
    protected string DeviceID = string.Empty;
    protected int Operator = 0;
    protected string WorkShiftID = string.Empty;
    protected DateTime EntryTime = DateTime.Now;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["WorkStationStatus"] != null)
                WorkStationStatus = (Util.TS.WorkStationStatus)Enum.Parse(typeof(Util.TS.WorkStationStatus), _context.Request["WorkStationStatus"].Trim());

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (_context.Request["DeviceID"] != null)
                DeviceID = _context.Request["DeviceID"].Trim();

            if (_context.Request["WorkShiftID"] != null)
                WorkShiftID = _context.Request["WorkShiftID"].Trim();

            if (!string.IsNullOrEmpty(TicketID))
            {
                string Query = @"Select * From T_TSTicketCurrStatus Where TicketID = @TicketID";

                ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

                if (DT.Rows.Count > 0)
                {
                    DeviceID = DT.Rows[0]["DeviceID"].ToString().Trim();

                    Operator = (int)DT.Rows[0]["Operator"];

                    WorkShiftID = DT.Rows[0]["WorkShiftID"].ToString().Trim();

                    EntryTime = (DateTime)DT.Rows[0]["EntryTime"];
                }
            }

            DBAction DBA = new DBAction();

            DBA.AddCommandBuilder(Util.TS.GetChangeWorkStationStatusDBCB(DeviceID, WorkStationStatus, EntryTime, Operator, WorkShiftID));

            if (WorkStationStatus == Util.TS.WorkStationStatus.InMake)
            {
                string Query = @"Delete T_TSTicketMaintainResponsibleCurr Where DeviceID = @DeviceID";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainResponsibleCurr"];

                dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

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