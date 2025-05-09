<%@ WebHandler Language="C#" Class="TicketMaintainFinish" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainFinish : BasePage
{
    protected string MaintainID = string.Empty;
    protected string ParentMaintainID = string.Empty;
    protected bool IsConfirm = false;
    protected string ConfirmWorkCode = string.Empty;
    protected int ConfirmAccountID = -1;
    protected bool IsAlert = false;
    protected bool IsTrace = false;
    protected int TraceQty = 0;
    protected bool IsCancel = false;
    protected int TraceGoodQty = 0;
    protected int TraceNGQty = 0;
    protected bool IsModify = false;
    protected string ModifyWorkCode = string.Empty;
    protected int ModifyAccountID = -1;
    protected int TestQty1 = 0;
    protected int TestQty2 = 0;
    protected string TestTicketID = string.Empty;
    protected string Remark1 = string.Empty;
    protected string Remark2 = string.Empty;
    protected string Remark3 = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["MaintainID"] != null)
                MaintainID = _context.Request["MaintainID"].Trim();

            if (_context.Request["ParentMaintainID"] != null)
                ParentMaintainID = _context.Request["ParentMaintainID"].Trim();

            if (_context.Request["ModifyWorkCode"] != null)
                ModifyWorkCode = _context.Request["ModifyWorkCode"].Trim();

            if (_context.Request["IsModify"] != null)
                IsModify = _context.Request["IsModify"].ToBoolean();

            if (_context.Request["IsCancel"] != null)
                IsCancel = _context.Request["IsCancel"].ToBoolean();

            if (_context.Request["ConfirmWorkCode"] != null)
                ConfirmWorkCode = _context.Request["ConfirmWorkCode"].Trim();

            if (_context.Request["TraceGoodQty"] != null)
            {
                if (!int.TryParse(_context.Request["TraceGoodQty"].Trim(), out TraceGoodQty))
                    TraceGoodQty = 0;
            }

            if (_context.Request["TraceNGQty"] != null)
            {
                if (!int.TryParse(_context.Request["TraceNGQty"].Trim(), out TraceNGQty))
                    TraceNGQty = 0;
            }

            if (_context.Request["Remark1"] != null)
                Remark1 = _context.Request["Remark1"].Trim();
            if (_context.Request["Remark2"] != null)
                Remark2 = _context.Request["Remark2"].Trim();
            if (_context.Request["Remark3"] != null)
                Remark3 = _context.Request["Remark3"].Trim();

            if (!IsCancel)
            {
                if (string.IsNullOrEmpty(Remark1))
                    throw new CustomException((string)GetLocalResourceObject("Str_Empty_Remark1"));
                if (string.IsNullOrEmpty(Remark2))
                    throw new CustomException((string)GetLocalResourceObject("Str_Empty_Remark2"));
                if (string.IsNullOrEmpty(Remark3))
                    throw new CustomException((string)GetLocalResourceObject("Str_Empty_Remark3"));
            }

            if (_context.Request["IsConfirm"] == null || string.IsNullOrEmpty(_context.Request["IsConfirm"].Trim()))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_IsConfirm"));
            else
                IsConfirm = _context.Request["IsConfirm"].ToBoolean();

            if (_context.Request["IsAlert"] == null || string.IsNullOrEmpty(_context.Request["IsAlert"].Trim()))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_IsAlert"));
            else
                IsAlert = _context.Request["IsAlert"].ToBoolean();

            if (_context.Request["IsTrace"] == null || string.IsNullOrEmpty(_context.Request["IsTrace"].Trim()))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_IsTrace"));
            else
                IsTrace = _context.Request["IsTrace"].ToBoolean();

            if (_context.Request["TraceQty"] != null)
            {
                if (!int.TryParse(_context.Request["TraceQty"].Trim(), out TraceQty))
                    TraceQty = 0;
            }

            if (string.IsNullOrEmpty(MaintainID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MaintainID"));

            if (IsConfirm && string.IsNullOrEmpty(ConfirmWorkCode))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_ConfirmWorkCode"));

            ConfirmAccountID = BaseConfiguration.GetAccountID(ConfirmWorkCode);

            if (IsConfirm && (ConfirmAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(ConfirmAccountID)))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_ConfirmAccountID"));

            if (_context.Request["TestQty1"] != null)
            {
                if (!int.TryParse(_context.Request["TestQty1"].Trim(), out TestQty1))
                    TestQty1 = 0;
            }

            if (_context.Request["TestQty2"] != null)
            {
                if (!int.TryParse(_context.Request["TestQty2"].Trim(), out TestQty2))
                    TestQty2 = 0;
            }

            if (_context.Request["TestTicketID"] != null)
                TestTicketID = _context.Request["TestTicketID"].Trim();

            /* 如果都沒有填寫調機數量，就不需要填寫調機品對應流程卡號。反之如果有填寫，就得檢查是否有填寫調機品對應流程卡號，並且兩個流程卡工單號必須得一致 */
            if ((TestQty1 + TestQty2) > 0)
            {
                if (string.IsNullOrEmpty(TestTicketID))
                    throw new CustomException((string)GetLocalResourceObject("Str_Empty_TestTicketID"));

                if (!IsSameAUFNR())
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_TestTicketIDDifferent"));
            }
            else
                TestTicketID = string.Empty;

            if (IsModify)
            {
                if (string.IsNullOrEmpty(ModifyWorkCode))
                    throw new CustomException((string)GetLocalResourceObject("Str_Empty_ModifyWorkCode"));

                ModifyAccountID = BaseConfiguration.GetAccountID(ModifyWorkCode);

                if (ModifyAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(ModifyAccountID))
                    throw new CustomException((string)GetLocalResourceObject("Str_Empty_ModifyAccountID"));
            }

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

            if (!IsModify && !string.IsNullOrEmpty(ParentMaintainID))
                CheckParentMaintainID(TicketID, ProcessID);

            if (!IsCancel)
            {
                Query = @"Select Count(*) From T_TSTicketMaintainFault Where MaintainID = @MaintainID";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

                if ((int)CommonDB.ExecuteScalar(dbcb) < 1)
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_NoMaintainFault"));
            }

            Query = @"Select * From T_TSTicketMaintainMinute Where MaintainID = @MaintainID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.AsEnumerable().Where(Row => (int)Row["MaintainMinute"] < 1).Count() > 0)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_NoFinishMaintainMinute"));

            DateTime MinStartTime = DT.AsEnumerable().Min(Row => (DateTime)Row["MaintainStartTime"]);

            DateTime MaxEndTime = DT.AsEnumerable().Max(Row => (DateTime)Row["MaintainEndTime"]);

            DBAction DBA = new DBAction();

            dbcb = new DbCommandBuilder();

            Query = @"Update T_TSTicketMaintain Set ParentMaintainID = @ParentMaintainID,MaintainMinuteByMachine = @MaintainMinuteByMachine,MaintainMinute = (Select Sum(MaintainMinute) From T_TSTicketMaintainMinute Where MaintainID = @MaintainID),
                      IsConfirm = @IsConfirm,ConfirmAccountID = @ConfirmAccountID,IsAlert = @IsAlert,IsTrace = @IsTrace,TraceQty = @TraceQty,TraceGoodQty = @TraceGoodQty,TraceNGQty = @TraceNGQty,
                      TestQty1 = @TestQty1,TestQty2 = @TestQty2,TestTicketID = @TestTicketID,
                      Remark1 = @Remark1,Remark2 = @Remark2,Remark3 = @Remark3,IsCancel = @IsCancel";

            if (IsModify)
            {
                Query += ",ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID";

                dbcb.appendParameter(Schema.Attributes["ModifyAccountID"].copy(ModifyAccountID));
            }

            Query += " Where MaintainID = @MaintainID";

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["MaintainMinuteByMachine"].copy((MaxEndTime - MinStartTime).TotalMinutes));

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            dbcb.appendParameter(Schema.Attributes["ParentMaintainID"].copy(ParentMaintainID));

            dbcb.appendParameter(Schema.Attributes["IsConfirm"].copy(IsConfirm));

            dbcb.appendParameter(Schema.Attributes["ConfirmAccountID"].copy(ConfirmAccountID));

            dbcb.appendParameter(Schema.Attributes["IsAlert"].copy(IsAlert));

            dbcb.appendParameter(Schema.Attributes["IsTrace"].copy(IsTrace));

            dbcb.appendParameter(Schema.Attributes["TraceQty"].copy(TraceQty));

            dbcb.appendParameter(Schema.Attributes["TraceGoodQty"].copy(TraceGoodQty));

            dbcb.appendParameter(Schema.Attributes["TraceNGQty"].copy(TraceNGQty));

            dbcb.appendParameter(Schema.Attributes["TestQty1"].copy(TestQty1));

            dbcb.appendParameter(Schema.Attributes["TestQty2"].copy(TestQty2));

            dbcb.appendParameter(Schema.Attributes["TestTicketID"].copy(TestTicketID));

            dbcb.appendParameter(Schema.Attributes["Remark1"].copy(Remark1));

            dbcb.appendParameter(Schema.Attributes["Remark2"].copy(Remark2));

            dbcb.appendParameter(Schema.Attributes["Remark3"].copy(Remark3));

            dbcb.appendParameter(Schema.Attributes["IsCancel"].copy(IsCancel));

            DBA.AddCommandBuilder(dbcb);

            if (!IsCancel)
            {
                Query = @"Update T_TSDevice Set IsSuspension = @IsSuspension Where DeviceID = (Select DeviceID From T_TSTicketMaintain Where MaintainID = @MaintainID)";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

                dbcb.appendParameter(Schema.Attributes["IsAlert"].copy(IsAlert, "IsSuspension"));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 取得維修單所屬流程卡與調試品對應流程卡號是否為相同的工單號
    /// </summary>
    /// <returns>是否為相同的工單號</returns>
    protected bool IsSameAUFNR()
    {
        string Query = @"Select Top 1 AUFNR From T_TSTicket Where TicketID = (Select Top 1 TicketID From T_TSTicketMaintain Where MaintainID = @MaintainID)
                        Union All
                        Select Top 1 AUFNR From T_TSTicket Where TicketID = @TicketID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TestTicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 2)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_NoTestTicketIDRow"));

        return DT.Rows[0][0].ToString().Trim() == DT.Rows[1][0].ToString().Trim();
    }

    /// <summary>
    /// 檢查前次維修單號是否存在或是尚未完成維修
    /// </summary>
    /// <param name="TicketID">流程卡號</param>
    /// <param name="ProcessID">工序號</param>
    protected void CheckParentMaintainID(string TicketID, string ProcessID)
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

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}