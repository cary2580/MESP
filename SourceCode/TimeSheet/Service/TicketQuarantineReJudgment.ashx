<%@ WebHandler Language="C#" Class="TicketQuarantineReJudgment" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketQuarantineReJudgment : BasePage
{
    protected string TicketID = string.Empty;
    protected List<string> SubTicketIDList = new List<string>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            CheckReJudgmentRule();

            DBAction DBA = new DBAction();

            DeleteSubTicket(DBA);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            string Query = @"Update T_TSTicketRouting Set IsEnd = 0 Where TicketID = @TicketID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketReworkDefect Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketResultSecondOperator Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketResult Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketQuarantineResultItem Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Update T_TSTicketQuarantineResult Set ScrapQty = 0,JudgmentAccount = Null,IsJudgment = 0 Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Update T_TSTicket Set IsEnd = 0 Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

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

    /// <summary>
    /// 指定DBA產生刪除子流程指令
    /// </summary>
    /// <param name="DBA">DBA</param>
    protected void DeleteSubTicket(DBAction DBA)
    {
        foreach (string SubTicketID in SubTicketIDList)
        {
            string Query = @"Delete T_TSTicketRouting Where TicketID = @TicketID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(SubTicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketReworkDefect Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(SubTicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketResultSecondOperator Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(SubTicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketResult Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(SubTicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketQuarantineResultItem Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(SubTicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketQuarantineResult Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(SubTicketID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicket Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(SubTicketID));

            DBA.AddCommandBuilder(dbcb);
        }
    }

    /// <summary>
    /// 檢查是否可以重新判定
    /// </summary>
    protected void CheckReJudgmentRule()
    {
        string Query = @"Select IsJudgment From T_TSTicketQuarantineResult Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        if (!(bool)CommonDB.ExecuteScalar(dbcb))
            throw new CustomException((string)GetLocalResourceObject("Str_Error_QuarantineResultJudgmentNotFinish"));

        CheckMO();

        CheckTicket();
    }

    /// <summary>
    /// 檢查工單是否合規可以重新判定
    /// </summary>
    protected void CheckMO()
    {
        string Query = @"Select * From T_TSSAPAFKO Where AUFNR In (Select AUFNR From T_TSTicket Where TicketID = @TicketID)";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_NoMOData"));

        string STATUS = DT.Rows[0]["STATUS"].ToString().Trim();

        Util.TS.MOStatus MOStatus = (Util.TS.MOStatus)Enum.Parse(typeof(Util.TS.MOStatus), STATUS);

        if (MOStatus != Util.TS.MOStatus.InProcess)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_MOStatus"));
    }

    /// <summary>
    /// 檢查此流程卡是否合規可以重新判定
    /// </summary>
    protected void CheckTicket()
    {
        string Query = @"Select * From dbo.TS_GetFullSubTicket(@TicketID,1)";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        foreach (DataRow Row in DT.Rows)
        {
            string SubTicketID = Row["TicketID"].ToString().Trim();

            if (TicketID != SubTicketID && !SubTicketIDList.Contains(SubTicketID))
                SubTicketIDList.Add(SubTicketID);

            if (IsHaveTicketResultData(SubTicketID))
                throw new CustomException(string.Format((string)GetLocalResourceObject("Str_Error_HaveTicketResultData"), SubTicketID));

            if (IsHaveMaintainData(SubTicketID))
                throw new CustomException(string.Format((string)GetLocalResourceObject("Str_Error_HaveTicketMaintainData"), SubTicketID));

            if (IsGoInCurrStatus(SubTicketID))
                throw new CustomException(string.Format((string)GetLocalResourceObject("Str_Error_HaveTicketGoInCurrStatus"), SubTicketID));
        }
    }

    /// <summary>
    /// 指定流程卡號得到是否有報工資料
    /// </summary>
    /// <param name="TargetTicketID">流程卡號</param>
    /// <returns>是否有報工資料</returns>
    protected bool IsHaveTicketResultData(string TargetTicketID)
    {
        string Query = @"Select IsNull(Sum(GoodQty + ReWorkQty),0) From T_TSTicketResult Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TargetTicketID));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 指定流程卡號得到是否有維修單資料
    /// </summary>
    /// <param name="TargetTicketID">流程卡號</param>
    /// <returns>是否有維修單資料</returns>
    protected bool IsHaveMaintainData(string TargetTicketID)
    {
        string Query = @"Select Count(*) From T_TSTicketMaintain Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TargetTicketID));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 指定流程卡號得到是否此正在進工當中
    /// </summary>
    /// <param name="TargetTicketID">流程卡號</param>
    /// <returns>是否此正在進工當中</returns>
    protected bool IsGoInCurrStatus(string TargetTicketID)
    {
        string Query = @"Select Count(*) From T_TSTicketCurrStatus Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TargetTicketID));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

}