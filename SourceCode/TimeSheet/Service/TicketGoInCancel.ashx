<%@ WebHandler Language="C#" Class="TicketGoInCancel" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketGoInCancel : BasePage
{
    protected string TicketID = string.Empty;
    protected int ProcessID = 0;
    protected string DeviceID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            LaodData();

            CheckCancelRule();

            DBAction DBA = new DBAction();

            string Query = @"Delete T_TSTicketCurrStatus Where TicketID = @TicketID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

            if (IsChangeWorkStationStatus())
                DBA.AddCommandBuilder(Util.TS.GetChangeWorkStationStatusDBCB(DeviceID, Util.TS.WorkStationStatus.Idle, DateTime.Parse("1900/01/01")));

            DBA.Execute();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LaodData()
    {
        string Query = @"Select * From T_TSTicketCurrStatus Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_NoTicketCurrStatusData"));

        DeviceID = DT.Rows[0]["DeviceID"].ToString().Trim();

        ProcessID = (int)DT.Rows[0]["ProcessID"];
    }

    /// <summary>
    /// 檢查是否可以取消進工規則
    /// </summary>
    protected void CheckCancelRule()
    {
        string Query = @"Select Count(*) From T_TSTicket Where ParentTicketID = @ParentTicketID And CreateProcessID = @CreateProcessID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ParentTicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["CreateProcessID"].copy(ProcessID));

        /* 如果成立，代表此流程卡當前工序已有開出返工單或是隔離單， 因此不允許取消進工 */
        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_ParentTicketID"));
    }

    /// <summary>
    /// 因為有些機台可以允許同時多重報工，因此要在此檢查一下工單當前狀態是否還有相同設備在生產中，如果有就不變更狀態
    /// </summary>
    protected bool IsChangeWorkStationStatus()
    {
        string Query = @"Select Count(*) From T_TSTicketCurrStatus Where DeviceID = @DeviceID And TicketID <> @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        return (int)CommonDB.ExecuteScalar(dbcb) < 1;
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}