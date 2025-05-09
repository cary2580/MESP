<%@ WebHandler Language="C#" Class="TicketQuarantineGet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketQuarantineGet : BasePage
{
    protected string TicketID = string.Empty;
    protected int Qty = 0;
    protected string MainTicketID = string.Empty;
    protected string ParentTicketID = string.Empty;
    protected string ParentTicketPath = string.Empty;
    protected int ProcessID = 0;
    protected DateTime CreateDate = DateTime.Now;
    protected string CreateAccountName = string.Empty;
    protected int ScrapQty = 0;
    protected int ReWorkMainProcessID = 0;
    protected string AUFNR = string.Empty;
    protected string PLNBEZ = string.Empty;
    protected string AUFPL = string.Empty;
    protected string APLZL = string.Empty;
    protected string VORNR = string.Empty;
    protected string LTXA1 = string.Empty;
    protected string ARBPL = string.Empty;
    protected string MOBatch = string.Empty;
    protected string RoutingName = string.Empty;
    protected string MAKTX = string.Empty;
    protected object ItemData = null;
    protected object FirstTimeItemData = null;
    protected int JudgmentAccount = 0;
    protected string JudgmentAccountWorkCode = string.Empty;
    protected bool IsJudgment = false;
    protected bool IsOnlyGetItemData = false;
    protected bool IsCheckTicketQuarantineFinish = true;
    protected bool IsGetFirstTimeItem = false;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (_context.Request["IsOnlyGetItemData"] != null)
            {
                if (!bool.TryParse(_context.Request["IsOnlyGetItemData"], out IsOnlyGetItemData))
                    IsOnlyGetItemData = false;
            }

            if (_context.Request["IsCheckTicketQuarantineFinish"] != null)
            {
                if (!bool.TryParse(_context.Request["IsCheckTicketQuarantineFinish"], out IsCheckTicketQuarantineFinish))
                    IsCheckTicketQuarantineFinish = true;
            }

            if (_context.Request["IsGetFirstTimeItem"] != null)
            {
                if (!bool.TryParse(_context.Request["IsGetFirstTimeItem"], out IsGetFirstTimeItem))
                    IsGetFirstTimeItem = false;
            }

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            if (!IsOnlyGetItemData)
            {
                LoadData();

                ResponseSuccessData(new
                {
                    TicketID = TicketID,
                    Qty = Qty,
                    MainTicketID = MainTicketID,
                    ParentTicketID = ParentTicketID,
                    ParentTicketPath = ParentTicketPath,
                    ProcessID = ProcessID,
                    CreateDate = CreateDate.ToCurrentUICultureStringTime(),
                    CreateAccountName = CreateAccountName,
                    ScrapQty = ScrapQty,
                    ReWorkMainProcessID = ReWorkMainProcessID,
                    RoutingName = RoutingName,
                    ProcessName = ProcessID + "-" + VORNR + "-" + LTXA1,
                    MOBatch = MOBatch,
                    MAKTX = MAKTX,
                    WaitReportQty = Qty - ScrapQty,
                    ARBPL = ARBPL,
                    ItemData = ItemData,
                    FirstTimeItemData = FirstTimeItemData,
                    JudgmentAccount = JudgmentAccount,
                    JudgmentAccountWorkCode = JudgmentAccountWorkCode,
                    IsJudgment = IsJudgment.ToStringValue()
                });
            }
            else
            {
                LoadItemData();

                ResponseSuccessData(new
                {
                    TicketID = TicketID,
                    ItemData = ItemData,
                    FirstTimeItemData = FirstTimeItemData
                });
            }
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    protected void LoadData()
    {
        string Query = @"Select
                        T_TSTicketQuarantineResult.Qty,
                        T_TSTicket.MainTicketID,
                        T_TSTicket.ParentTicketID,
                        T_TSTicketQuarantineResult.ProcessID,
                        T_TSTicket.CreateDate,
                        Base_Org.dbo.GetAccountName(T_TSTicket.CreateAccountID) As CreateAccountName,
                        T_TSTicketQuarantineResult.ScrapQty,
                        T_TSTicket.ReWorkMainProcessID,
                        T_TSTicket.AUFNR,
                        T_TSTicket.PLNBEZ,
                        T_TSTicketQuarantineResult.AUFPL,
                        T_TSTicketQuarantineResult.APLZL,
                        T_TSTicketQuarantineResult.VORNR,
                        T_TSTicketQuarantineResult.LTXA1,
                        T_TSTicketQuarantineResult.ARBPL,
                        T_TSTicketQuarantineResult.JudgmentAccount,
                        Base_Org.dbo.GetAccountWorkCode(T_TSTicketQuarantineResult.JudgmentAccount) As JudgmentAccountWorkCode,
                        T_TSTicketQuarantineResult.IsJudgment
                        From T_TSTicketQuarantineResult Inner Join T_TSTicket On T_TSTicketQuarantineResult.TicketID = T_TSTicket.TicketID
                        Where T_TSTicketQuarantineResult.TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_NoTicketQuarantineResultData"));

        IsJudgment = (bool)DT.Rows[0]["IsJudgment"];

        if (IsJudgment && IsCheckTicketQuarantineFinish)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketQuarantineFinish"));

        if (!DT.Rows[0].IsNull("JudgmentAccount"))
            JudgmentAccount = (int)DT.Rows[0]["JudgmentAccount"];

        JudgmentAccountWorkCode = DT.Rows[0]["JudgmentAccountWorkCode"].ToString().Trim();

        Qty = (int)DT.Rows[0]["Qty"];

        MainTicketID = DT.Rows[0]["MainTicketID"].ToString().Trim();

        ParentTicketID = DT.Rows[0]["ParentTicketID"].ToString().Trim();

        ProcessID = (int)DT.Rows[0]["ProcessID"];

        CreateDate = (DateTime)DT.Rows[0]["CreateDate"];

        CreateAccountName = DT.Rows[0]["CreateAccountName"].ToString().Trim();

        ScrapQty = (int)DT.Rows[0]["ScrapQty"];

        ReWorkMainProcessID = (int)DT.Rows[0]["ReWorkMainProcessID"];

        AUFNR = DT.Rows[0]["AUFNR"].ToString().Trim();

        PLNBEZ = DT.Rows[0]["PLNBEZ"].ToString().Trim();

        AUFPL = DT.Rows[0]["AUFPL"].ToString().Trim();

        APLZL = DT.Rows[0]["APLZL"].ToString().Trim();

        VORNR = DT.Rows[0]["VORNR"].ToString().Trim();

        LTXA1 = DT.Rows[0]["LTXA1"].ToString().Trim();

        ARBPL = DT.Rows[0]["ARBPL"].ToString().Trim();

        if (!string.IsNullOrEmpty(ParentTicketID))
        {
            Query = @"Select dbo.TS_GetParentTicketIDPath(@TicketID,@Delimiter)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Util.GetDataAccessAttribute("Delimiter", "nvarchar", 50, "/"));

            ParentTicketPath = CommonDB.ExecuteScalar(dbcb).ToString().Trim();
        }

        LoadMOInfo();

        LoadItemData();
    }

    /// <summary>
    /// 載入工單資訊
    /// </summary>
    protected void LoadMOInfo()
    {
        string Query = @"Select Top 1 CINFO,KTEXT,MAKTX From V_TSMORouting Where AUFNR = @AUFNR";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            MOBatch = DT.Rows[0]["CINFO"].ToString().Trim();
            RoutingName = DT.Rows[0]["KTEXT"].ToString().Trim();
            MAKTX = DT.Rows[0]["MAKTX"].ToString().Trim();
        }
    }

    /// <summary>
    /// 載入報廢結果資料
    /// </summary>
    protected void LoadItemData()
    {
        string Query = @"Select
                        SerialNo,
                        T_TSScrapReason.ScrapReasonName,
                        T_TSDefect.DefectID,
                        T_TSDefect.DefectName,
                        ScrapQty,
                        Base_Org.dbo.GetAccountName(JudgmentAccount) As JudgmentAccountName,
                        Remark
                        From T_TSTicketQuarantineResultItem 
                        Left Join T_TSScrapReason On T_TSTicketQuarantineResultItem.ScrapReasonID = T_TSScrapReason.ScrapReasonID
                        Left Join T_TSDefect On T_TSTicketQuarantineResultItem.DefectID = T_TSDefect.DefectID
                        Where TicketID = @TicketID
                        Order By SerialNo Asc";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResultItem"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        ItemData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = Column.ColumnName == "SerialNo" ? true : false
            }),
            SerialNoColumnName = "SerialNo",
            ScrapQtyColumnName = "ScrapQty",
            DefectNameColumnName = "DefectName",
            Rows = DT.AsEnumerable().Select(Row => new
            {
                SerialNo = Row["SerialNo"].ToString().Trim(),
                ScrapReasonName = Row["ScrapReasonName"].ToString().Trim(),
                DefectID = Row["DefectID"].ToString().Trim(),
                DefectName = Row["DefectName"].ToString().Trim(),
                ScrapQty = Row["ScrapQty"].ToString().Trim(),
                JudgmentAccountName = Row["JudgmentAccountName"].ToString().Trim(),
                Remark = Row["Remark"].ToString().Trim()
            })
        };

        if (IsGetFirstTimeItem)
            LoadFirstTimeItemData();
    }

    /// <summary>
    /// 指定ColumnName得到對齊方式
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>對齊方式</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ScrapQty":
            case "QuarantineQty":
            case "JudgmentAccountName":
                return "center";
            default:
                return "left";
        }
    }

    /// <summary>
    /// 指定ColumnName得到欄位寬度
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>欄位寬度</returns>
    protected int GetWidth(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ScrapQty":
            case "QuarantineQty":
            case "JudgmentAccountName":
                return 60;
            default:
                return 100;
        }
    }

    /// <summary>
    /// 指定ColumnName得到顯示欄位名稱
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ScrapTypeName":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapTypeName");
            case "ScrapReasonName":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapReasonName");
            case "DefectID":
                return (string)GetLocalResourceObject("Str_ColumnName_DefectID");
            case "DefectName":
                return (string)GetLocalResourceObject("Str_ColumnName_DefectName");
            case "ScrapQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQty");
            case "QuarantineQty":
                return (string)GetLocalResourceObject("Str_ColumnName_QuarantineQty");
            case "JudgmentAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_JudgmentAccountName");
            case "Remark":
                return (string)GetLocalResourceObject("Str_ColumnName_Remark");
            default:
                return ColumnName;
        }
    }

    /// <summary>
    /// 載入初判資料
    /// </summary>
    protected void LoadFirstTimeItemData()
    {
        string Query = @"Select 
                        DefectID,
                        (Select Top 1 Replace(Replace(DefectName, Char(13), ''), Char(10), '') From T_TSDefect Where T_TSDefect.DefectID = T_TSTicketQuarantineFirstTimeItem.DefectID) As DefectName,
                        ScrapQty As QuarantineQty
                        From T_TSTicketQuarantineFirstTimeItem 
                        Where TicketID = @TicketID
                        Order By SerialNo";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineFirstTimeItem"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        FirstTimeItemData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = Column.ColumnName == "SerialNo" ? true : false
            }),
            QuarantineQtyColumnName = "QuarantineQty",
            DefectNameColumnName = "DefectName",
            Rows = DT.AsEnumerable().Select(Row => new
            {
                DefectID = Row["DefectID"].ToString().Trim(),
                DefectName = Row["DefectName"].ToString().Trim(),
                QuarantineQty = Row["QuarantineQty"].ToString().Trim()
            })
        };
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}