<%@ WebHandler Language="C#" Class="TicketMaintainPDCheckGoOut" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainPDCheckGoOut : BasePage
{
    protected string MaintainID = string.Empty;
    protected string TicketID = string.Empty;
    protected int ProcessID = 0;
    protected string DeviceID = string.Empty;
    protected string PDCheckAccountWorkCode = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["MaintainID"] != null)
                MaintainID = _context.Request["MaintainID"].Trim();

            if (_context.Request["PDCheckAccountWorkCode"] != null)
                PDCheckAccountWorkCode = _context.Request["PDCheckAccountWorkCode"].Trim();

            if (string.IsNullOrEmpty(MaintainID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MaintainID"));

            if (string.IsNullOrEmpty(PDCheckAccountWorkCode))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkCode"));

            AccountID = BaseConfiguration.GetAccountID(PDCheckAccountWorkCode);

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            //如果已經有了檢驗時間，就不允許再次產出檢驗時間
            if (IsHaveGoOutData())
                return;

            string Query = @"Update T_TSTicketMaintain Set IsEnd = 1,PDCheckTimeEnd = GetDate(),PDCheckMinute = Datediff(Minute,Case When Year(PDCheckTimeStart) < 1911 Then GetDate() Else PDCheckTimeStart End,GetDate()),PDCheckAccountID = @PDCheckAccountID Where MaintainID = @MaintainID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PDCheckAccountID"].copy(AccountID));

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            DBAction DBA = new DBAction();

            DBA.AddCommandBuilder(dbcb);

            Query = @"Select * From T_TSTicketCurrStatus Where TicketID = @TicketID And ProcessID = @ProcessID";

            Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

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

    /// <summary>
    /// 取得是否已經有檢驗結束資料
    /// </summary>
    /// <returns>是否已經有檢驗結束資料</returns>
    protected bool IsHaveGoOutData()
    {
        string Query = @"Select * From T_TSTicketMaintain Where MaintainID = @MaintainID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_NoMaintainData"));

        TicketID = DT.Rows[0]["TicketID"].ToString().Trim();

        ProcessID = (int)DT.Rows[0]["ProcessID"];

        DeviceID = DT.Rows[0]["DeviceID"].ToString().Trim();

        return (int)DT.Rows[0]["PDCheckMinute"] > 0;
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}