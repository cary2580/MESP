using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_DailyReportForProduction : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
        {
            TB_DateStart.Text = DateTime.Now.ToCurrentUICultureString();

            TB_DateEnd.Text = DateTime.Now.ToCurrentUICultureString();

            DataTable DT = Util.GetCodeTypeData("TS_ProcessTypeID");

            DDL_ProcessType.DataValueField = "CodeID";

            DDL_ProcessType.DataTextField = "CodeName";

            DDL_ProcessType.DataSource = DT;

            DDL_ProcessType.DataBind();

            DDL_ProcessType.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
        }

        HF_IsShowResultList.Value = false.ToStringValue();
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_GetDailyReportForProduction");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        //因為生產OEE是以07:20當作換日線，所以必須要根據使用者選擇的期間設定，起始日期以當天早上07:20，迄止
        DateTime DateStart = DateTime.Parse(TB_DateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture);

        DateTime DateEnd = DateTime.Parse(TB_DateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture);

        dbcb.appendParameter(Util.GetDataAccessAttribute("DateStart", "DateTime", 0, DateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("DateEnd", "DateTime", 0, DateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("PVGroupName", "Nvarchar", 50, TB_PVGroupName.Text.Trim()));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ProcessTypeID", "Nvarchar", 50, DDL_ProcessType.SelectedValue));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "Nvarchar", 50, Master.LangCookie));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        List<DataRow> Rows = DT.AsEnumerable().ToList();

        if (DDL_IsViewOnlyAchieve.SelectedIndex > 0)
            Rows = Rows.Where(Row => (bool)Row["IsAchieve"] == DDL_IsViewOnlyAchieve.SelectedValue.ToBoolean()).ToList();
        if (DDL_IsViewHaveRemark.SelectedIndex > 0)
            Rows = Rows.Where(Row => DDL_IsViewHaveRemark.SelectedValue.ToBoolean() ? !string.IsNullOrEmpty(Row["Remark"].ToString().Trim()) : string.IsNullOrEmpty(Row["Remark"].ToString().Trim())).ToList();

        var ResponseData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName),
                searchoptions = GetSearchOptions(Column.ColumnName, Rows),
                classes = Column.ColumnName == "Remark" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            FilterSelectColumnNames = new string[] { "PVGroupName" },
            TaskDateTimeColumnName = "TaskDateTime",
            PVGroupIDColumnName = "PVGroupID",
            ProcessTypeIDColumnName = "ProcessTypeID",
            ProcessTypeNameColumnName = "ProcessTypeName",
            TaskQtyColumnName = "TaskQtyNew",
            GoodQtyColumnName = "GoodQty",
            DifferenceQtyColumnName = "DifferenceQty",
            ACCTaskQtyByMonthColumnName = "ACCTaskQtyByMonth",
            ACCTaskQtyColumnName = "ACCTaskQty",
            ACCGoodQtyColumnName = "ACCGoodQty",
            ACCDifferenceQtyColumnName = "ACCDifferenceQty",
            RemarkColumnName = "Remark",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = Rows.Select(Row => new
            {
                TaskDateTime = ((DateTime)Row["TaskDateTime"]).ToCurrentUICultureString(),
                PVGroupID = Row["PVGroupID"].ToString().Trim(),
                PVGroupName = Row["PVGroupName"].ToString().Trim(),
                ProcessTypeID = Row["ProcessTypeID"].ToString().Trim(),
                ProcessTypeName = Row["ProcessTypeName"].ToString().Trim(),
                TaskQty = ((int)Row["TaskQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                TaskQtyNew = ((int)Row["TaskQtyNew"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                GoodQty = ((int)Row["GoodQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                DifferenceQty = ((int)Row["DifferenceQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                IsAchieve = (bool)Row["IsAchieve"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                ACCTaskQtyByMonth = ((int)Row["ACCTaskQtyByMonth"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ACCTaskQty = ((int)Row["ACCTaskQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ACCGoodQty = ((int)Row["ACCGoodQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ACCDifferenceQty = ((int)Row["ACCDifferenceQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                Remark = Row["Remark"].ToString().Trim()
            })
        };

        //Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowPagerSearchValue", "<script>var IsShowPagerSearchValue='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowFooterRowValue", "<script>var IsShowFooterRowValue='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

        HF_IsShowResultList.Value = true.ToStringValue();
    }

    /// <summary>
    /// 指定欄位名取得搜尋選項
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <param name="Rows">資料列</param>
    /// <returns>搜尋選項</returns>
    protected dynamic GetSearchOptions(string ColumnName, List<DataRow> Rows)
    {
        dynamic StatusSearchOptions = new System.Dynamic.ExpandoObject();

        switch (ColumnName)
        {
            case "IsAchieve":
                StatusSearchOptions.sopt = new string[] { "cn", "nc" };
                return StatusSearchOptions;
            case "PVGroupName":
                var List = Rows.GroupBy(Row => Row[ColumnName].ToString().Trim()).Select(item => item.Key).ToList();
                List<string> Itmes = new List<string>();
                foreach (string item in List)
                {
                    if (!string.IsNullOrEmpty(item))
                        Itmes.Add(item + ":" + item);
                }
                StatusSearchOptions.value = string.Join(";", Itmes);
                StatusSearchOptions.multiple = true;
                return StatusSearchOptions;
            default:
                return null;
        }
    }

    /// <summary>
    /// 指定ColumnName得到是否影藏
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否影藏</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "PVGroupID":
            case "ProcessTypeID":
            case "SortID":
            case "TaskQty":
                return true;
            default:
                return false;
        }
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
            case "TaskDateTime":
            case "PVGroupID":
            case "ProcessTypeName":
            case "IsAchieve":
                return "center";
            case "TaskQtyNew":
            case "GoodQty":
            case "DifferenceQty":
            case "ACCTaskQtyByMonth":
            case "ACCTaskQty":
            case "ACCGoodQty":
            case "ACCDifferenceQty":
                return "right";
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
            case "TaskDateTime":
                return 80;
            case "PVGroupID":
            case "PVGroupName":
                return 190;
            case "TaskQtyNew":
            case "GoodQty":
            case "DifferenceQty":
            case "ACCTaskQtyByMonth":
            case "ACCTaskQty":
            case "ACCGoodQty":
            case "ACCDifferenceQty":
                return 80;
            case "IsAchieve":
                return 70;
            case "ProcessTypeName":
                return 60;
            default:
                return 150;
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
            case "TaskDateTime":
                return (string)GetLocalResourceObject("Str_ColumnName_TaskDateTime");
            case "PVGroupID":
                return (string)GetLocalResourceObject("Str_ColumnName_PVGroupID");
            case "PVGroupName":
                return (string)GetLocalResourceObject("Str_ColumnName_PVGroupName");
            case "ProcessTypeName":
                return (string)GetLocalResourceObject("Str_ColumnName_ProcessTypeName");
            case "TaskQtyNew":
                return (string)GetLocalResourceObject("Str_ColumnName_TaskQty");
            case "GoodQty":
                return (string)GetLocalResourceObject("Str_ColumnName_GoodQty");
            case "DifferenceQty":
                return (string)GetLocalResourceObject("Str_ColumnName_DifferenceQty");
            case "IsAchieve":
                return (string)GetLocalResourceObject("Str_ColumnName_IsAchieve");
            case "ACCTaskQtyByMonth":
                return (string)GetLocalResourceObject("Str_ColumnName_ACCTaskQtyByMonth");
            case "ACCTaskQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ACCTaskQty");
            case "ACCGoodQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ACCGoodQty");
            case "ACCDifferenceQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ACCDifferenceQty");
            case "Remark":
                return (string)GetLocalResourceObject("Str_ColumnName_Remark");
            default:
                return ColumnName;
        }
    }
}