using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketReWork : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected Util.TS.TicketType TicketType;

    protected int CurrProcessID;

    protected int RootProcessID;

    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            try
            {
                string TicketID = string.Empty;

                if (Request["TicketID"] != null)
                    TicketID = Request["TicketID"].Trim();

                if (string.IsNullOrEmpty(TicketID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

                HF_TicketID.Value = TicketID;

                LaodData();
            }
            catch (Exception ex)
            {
                Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LaodData()
    {
        LoadTicketInfo();

        DataTable RoutingDataTable = GetRoutingDataTable();

        List<DataRow> BeforeProcessDataRowList = new List<DataRow>();

        List<DataRow> AfterProcessDataRowList = new List<DataRow>();

        BeforeProcessDataRowList = RoutingDataTable.AsEnumerable().Where(Row => (int)Row["ProcessID"] < CurrProcessID).ToList();

        AfterProcessDataRowList = RoutingDataTable.AsEnumerable().Where(Row => (int)Row["ProcessID"] >= CurrProcessID).ToList();

        IEnumerable<DataColumn> Columns = RoutingDataTable.Columns.Cast<DataColumn>();

        List<string> ColumnList = Columns.Select(Column => Column.ColumnName).ToList();

        var colModel = ColumnList.Select(ColumnName => new
        {
            name = ColumnName,
            index = ColumnName,
            label = GetListLabel(ColumnName),
            hidden = GetIsHidden(ColumnName),
            width = GetWidth(ColumnName),
            align = GetAlign(ColumnName),
            sortable = false
        });

        var BeforeProcessData = new
        {
            colModel = colModel,
            Rows = BeforeProcessDataRowList.Select(Row => new
            {
                TicketID = Row["TicketID"].ToString().Trim(),
                ProcessID = Row["ProcessID"].ToString().Trim(),
                AUFPL = Row["AUFPL"].ToString().Trim(),
                APLZL = Row["APLZL"].ToString().Trim(),
                VORNR = Row["VORNR"].ToString().Trim(),
                LTXA1 = Row["LTXA1"].ToString().Trim(),
                ARBID = Row["ARBID"].ToString().Trim(),
                ARBPL = Row["ARBPL"].ToString().Trim(),
                IsEnd = ((bool)Row["IsEnd"]).ToStringValue()
            })
        };

        var AfterProcessData = new
        {
            colModel = colModel,
            Rows = AfterProcessDataRowList.Select(Row => new
            {
                TicketID = Row["TicketID"].ToString().Trim(),
                ProcessID = Row["ProcessID"].ToString().Trim(),
                AUFPL = Row["AUFPL"].ToString().Trim(),
                APLZL = Row["APLZL"].ToString().Trim(),
                VORNR = Row["VORNR"].ToString().Trim(),
                LTXA1 = Row["LTXA1"].ToString().Trim(),
                ARBID = Row["ARBID"].ToString().Trim(),
                ARBPL = Row["ARBPL"].ToString().Trim(),
                IsEnd = ((bool)Row["IsEnd"]).ToStringValue()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "ProcessKey", "<script>var ProcessKey='ProcessID'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "ProcessColumn", "<script>var JQGridProcessColumn=" + Newtonsoft.Json.JsonConvert.SerializeObject(colModel) + "</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "BeforeProcessData", "<script>var JQGridBeforeProcessData=" + Newtonsoft.Json.JsonConvert.SerializeObject(BeforeProcessData) + "</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "AfterProcessData", "<script>var JQGriAfterProcessData=" + Newtonsoft.Json.JsonConvert.SerializeObject(AfterProcessData) + "</script>");
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
            case "LTXA1":
                return "left";
            default:
                return "center";
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
            case "VORNR":
                return 80;
            case "ProcessID":
                return 60;
            default:
                return 500;
        }
    }

    /// <summary>
    /// 指定ColumnName得到是否顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ProcessID":
            case "VORNR":
            case "LTXA1":
                return false;
            default:
                return true;
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
            case "ProcessID":
                return (string)GetLocalResourceObject("Str_ColumnName1");
            case "VORNR":
                return (string)GetLocalResourceObject("Str_ColumnName2");
            case "LTXA1":
                return (string)GetLocalResourceObject("Str_ColumnName3");
            default:
                return ColumnName;
        }
    }

    /// <summary>
    /// 取得路由表
    /// </summary>
    /// <returns>取得路由表</returns>
    protected DataTable GetRoutingDataTable()
    {
        string Query = @"Select * From T_TSTicketRouting Where TicketID = @TicketID Order By ProcessID Asc";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        /* 
            如果當前工序已經超過根源返工單的工序單的時候就以一般流程卡為路由
            或者此張單是隔離單就以一般流程卡為路由
         */
        if ((CurrProcessID >= RootProcessID) && RootProcessID > 0)
            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_MainTicketID.Value));
        else if (TicketType == Util.TS.TicketType.Quarantine)
            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_MainTicketID.Value));
        else
            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value.Trim()));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 載入流程卡資料
    /// </summary>
    protected void LoadTicketInfo()
    {
        string Query = @"Select * From T_TSTicket Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return;

        TicketType = (Util.TS.TicketType)Enum.Parse(typeof(Util.TS.TicketType), DT.Rows[0]["TicketTypeID"].ToString().Trim());

        HF_AUFNR.Value = DT.Rows[0]["AUFNR"].ToString().Trim();
        HF_PLNBEZ.Value = DT.Rows[0]["PLNBEZ"].ToString().Trim();
        HF_ParentTicketID.Value = DT.Rows[0]["ParentTicketID"].ToString().Trim();
        HF_MainTicketID.Value = DT.Rows[0]["MainTicketID"].ToString().Trim();
        HF_ReWorkMainProcessID.Value = DT.Rows[0]["ReWorkMainProcessID"].ToString().Trim();

        RootProcessID = (int)DT.Rows[0]["ReWorkMainProcessID"];

        Query = @"Select Top 1 * From T_TSTicketRouting Where TicketID = @TicketID And IsEnd = 0 Order By ProcessID Asc";

        dbcb = new DbCommandBuilder(Query);

        Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 理論上不會找不到資料，如果有那就出大事了 */
        if (DT.Rows.Count < 1)
            return;

        HF_ProcessID.Value = DT.Rows[0]["ProcessID"].ToString().Trim();

        CurrProcessID = (int)DT.Rows[0]["ProcessID"];

        HF_AUFPL.Value = DT.Rows[0]["AUFPL"].ToString().Trim();

        HF_APLZL.Value = DT.Rows[0]["APLZL"].ToString().Trim();

        HF_VORNR.Value = DT.Rows[0]["VORNR"].ToString().Trim();

        HF_LTXA1.Value = DT.Rows[0]["LTXA1"].ToString().Trim();

        Query = @"Select * From T_TSTicketCurrStatus Where TicketID = @TicketID";

        dbcb = new DbCommandBuilder(Query);

        Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 理論上不會找不到資料，如果有那就出大事了 */
        if (DT.Rows.Count < 1)
            return;

        TB_Qty.Text = DT.Rows[0]["AllowQty"].ToString().Trim();

        HF_AllowQty.Value = DT.Rows[0]["AllowQty"].ToString().Trim();

        if (RootProcessID > 0)
        {
            /* 如果當前的工序是未到達源源頭開立的返工單就不允許再開立返工單。 */
            if ((CurrProcessID < RootProcessID))
                throw new Exception((string)GetLocalResourceObject("Str_Error_ProcessNotYetCompleted"));
        }
    }
}