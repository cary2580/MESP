<%@ WebHandler Language="C#" Class="TicketMaintainGoIn" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Newtonsoft.Json;

public class TicketMaintainGoIn : BasePage
{
    protected string TicketID = string.Empty;
    protected int ProcessID = 0;
    protected string OperatorWorkCode = string.Empty;
    protected string MaintainID = string.Empty;
    protected string ParentMaintainID = string.Empty;
    protected DateTime WaitTimeStart = DateTime.Now;
    protected List<FirstTimeMaintainFault> FirstTimeMaintainFaultList = new List<FirstTimeMaintainFault>();
    protected List<string> ResponsibleListID = new List<string>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (_context.Request["ParentMaintainID"] != null)
                ParentMaintainID = _context.Request["ParentMaintainID"].Trim();

            if (_context.Request["OperatorWorkCode"] != null)
                OperatorWorkCode = _context.Request["OperatorWorkCode"].Trim();

            if (_context.Request["WaitTimeStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["WaitTimeStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out WaitTimeStart))
                    WaitTimeStart = DateTime.Now;
            }

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));
            if (string.IsNullOrEmpty(OperatorWorkCode))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_Operator"));

            if (_context.Request["FirstTimeMaintainFaultList"] != null)
                FirstTimeMaintainFaultList = JsonConvert.DeserializeObject<List<FirstTimeMaintainFault>>(_context.Request["FirstTimeMaintainFaultList"].Trim());

            if (_context.Request["ResponsibleListID"] != null)
                ResponsibleListID = JsonConvert.DeserializeObject<List<string>>(_context.Request["ResponsibleListID"].Trim());

            string Query = @"Select * From T_TSTicketCurrStatus Where TicketID = @TicketID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_NoTicketCurrStatusRow"));

            ProcessID = (int)DT.Rows[0]["ProcessID"];

            string AUFPL = DT.Rows[0]["AUFPL"].ToString().Trim();

            string APLZL = DT.Rows[0]["APLZL"].ToString().Trim();

            string VORNR = DT.Rows[0]["VORNR"].ToString().Trim();

            string DeviceID = DT.Rows[0]["DeviceID"].ToString().Trim();

            string WorkShiftID = DT.Rows[0]["WorkShiftID"].ToString().Trim();

            AccountID = BaseConfiguration.GetAccountID(OperatorWorkCode);

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            //230710 廠長決議不在卡控。讓維修員可以同時間開出維修單來。
            //CheckOperatorCanGoIn();

            Query = @"Select * From T_TSTicketMaintain Where TicketID = @TicketID And ProcessID = @ProcessID And IsEnd = 0";

            Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            DT = CommonDB.ExecuteSelectQuery(dbcb);

            DateTime WaitTimeEnd = DateTime.Now;

            DBAction DBA = new DBAction();

            if (DT.Rows.Count > 0)
            {
                MaintainID = DT.Rows[0]["MaintainID"].ToString().Trim();

                WaitTimeEnd = (DateTime)DT.Rows[0]["WaitTimeEnd"];

                Query = @"Select Count(*) From T_TSTicketMaintainMinute Where MaintainID = @MaintainID And Operator = @Operator";

                Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainMinute"];

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

                dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

                if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_OperatorRepeat"));
            }
            else
            {
                MaintainID = BaseConfiguration.SerialObject[(short)20].取號();

                Query = @"Insert Into T_TSTicketMaintain (MaintainID,ParentMaintainID,TicketID,ProcessID,AUFPL,APLZL,VORNR,DeviceID,WaitTimeStart,WaitTimeEnd,WaitMinute,TestTicketID,Remark1,Remark2,Remark3) Values (@MaintainID,@ParentMaintainID,@TicketID,@ProcessID,@AUFPL,@APLZL,@VORNR,@DeviceID,@WaitTimeStart,@WaitTimeEnd,@WaitMinute,'','','','')";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));
                dbcb.appendParameter(Schema.Attributes["ParentMaintainID"].copy(ParentMaintainID));
                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));
                dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(AUFPL));
                dbcb.appendParameter(Schema.Attributes["APLZL"].copy(APLZL));
                dbcb.appendParameter(Schema.Attributes["VORNR"].copy(VORNR));
                dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
                dbcb.appendParameter(Schema.Attributes["WaitTimeStart"].copy(WaitTimeStart));
                dbcb.appendParameter(Schema.Attributes["WaitTimeEnd"].copy(WaitTimeEnd));
                dbcb.appendParameter(Schema.Attributes["WaitMinute"].copy((WaitTimeEnd - WaitTimeStart).TotalMinutes));

                DBA.AddCommandBuilder(dbcb);

                foreach (FirstTimeMaintainFault FTMF in FirstTimeMaintainFaultList)
                {
                    Query = @"Insert Into T_TSTicketMaintainFaultByFirstTime (MaintainID,FaultCategoryID,FaultID) Values (@MaintainID,@FaultCategoryID,@FaultID)";

                    Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainFaultByFirstTime"];

                    dbcb = new DbCommandBuilder(Query);

                    dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

                    dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(FTMF.FaultCategoryID));

                    dbcb.appendParameter(Schema.Attributes["FaultID"].copy(FTMF.FaultID));

                    DBA.AddCommandBuilder(dbcb);
                }

                foreach (string ResponsibleID in ResponsibleListID)
                {
                    if (string.IsNullOrEmpty(ResponsibleID))
                        continue;

                    Query = "Insert Into T_TSTicketMaintainResponsible (MaintainID,SerialNo,ResponsibleID) Values (@MaintainID,IsNull((Select Max(SerialNo) + 1 From T_TSTicketMaintainResponsible Where MaintainID = @MaintainID),1),@ResponsibleID)";

                    Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainResponsible"];

                    dbcb = new DbCommandBuilder(Query);

                    dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

                    dbcb.appendParameter(Schema.Attributes["ResponsibleID"].copy(ResponsibleID));

                    DBA.AddCommandBuilder(dbcb);
                }
            }

            if (!string.IsNullOrEmpty(ParentMaintainID))
                CheckParentMaintainID();

            Query = @"Insert Into T_TSTicketMaintainMinute (MaintainID,Operator) Values (@MaintainID,@Operator)";

            Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainMinute"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketMaintainResponsibleCurr Where DeviceID = @DeviceID";

            Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainResponsibleCurr"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

            DBA.AddCommandBuilder(dbcb);

            DBA.AddCommandBuilder(Util.TS.GetChangeWorkStationStatusDBCB(DeviceID, Util.TS.WorkStationStatus.InMaintain, DateTime.Now, AccountID, WorkShiftID));

            DBA.Execute();

            ResponseSuccessData(new { MaintainID = MaintainID, ProcessID = ProcessID, AUFPL = AUFPL, APLZL = APLZL, VORNR = VORNR, DeviceID = DeviceID, WaitTimeEnd = WaitTimeEnd.ToCurrentUICultureStringTime() });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 檢查維修人員是否可以維修
    /// </summary>
    protected void CheckOperatorCanGoIn()
    {
        string Query = @"Select Count(T_TSTicketMaintain.MaintainID) From T_TSTicketMaintain Inner Join T_TSTicketMaintainMinute On T_TSTicketMaintain.MaintainID = T_TSTicketMaintainMinute.MaintainID
                         Where T_TSTicketMaintainMinute.Operator = @Operator And T_TSTicketMaintain.IsEnd = 0";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainMinute"];

        dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_OperatorNotFinish"));
    }

    /// <summary>
    /// 檢查前次維修單號是否存在或是尚未完成維修
    /// </summary>
    protected void CheckParentMaintainID()
    {
        string Query = @"Select * From T_TSTicketMaintain Where MaintainID = @MaintainID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(ParentMaintainID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_NoParentMaintainIDRow"));
        else if (!(bool)DT.Rows[0]["IsEnd"])
            throw new CustomException((string)GetLocalResourceObject("Str_Error_ParentMaintainIDNotEnd"));

        if ((DT.Rows[0]["TicketID"].ToString().Trim() + "_" + DT.Rows[0]["ProcessID"].ToString().Trim()) != TicketID + "_" + ProcessID)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_ParentMaintainIDDifferentTicketID"));

        Query = @"Select Count(*) From T_TSTicketMaintain Where ParentMaintainID = @ParentMaintainID And MaintainID <> @MaintainID";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ParentMaintainID"].copy(ParentMaintainID));

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_ParentMaintainIDRepeatUse"));
    }

    public class FirstTimeMaintainFault
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