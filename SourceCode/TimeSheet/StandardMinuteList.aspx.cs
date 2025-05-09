using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_StandardMinuteList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        string Query = @"Select '' As ARBPLValue,* From T_TSStandardMinute";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        string ARBPLColumnName = "ARBPLValue";

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
                classes = Column.ColumnName == "ARBPL" ? BaseConfiguration.JQGridColumnClassesName : string.Empty,
            }),
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            ARBPLColumnName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                ARBPLValue = Row["ARBPL"].ToString().Trim(),
                ARBPL = Row["ARBPL"].ToString().Trim(),
                KTEXT = Row["KTEXT"].ToString().Trim(),
                IsResultMinute = (bool)Row["IsResultMinute"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                IsResultMinuteForPersonnel = (bool)Row["IsResultMinuteForPersonnel"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
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
            case "ARBPLValue":
                return true;
            default:
                return false;
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
            case "ARBPL":
                return (string)GetLocalResourceObject("Str_ColumnName_ARBPL");
            case "KTEXT":
                return (string)GetLocalResourceObject("Str_ColumnName_KTEXT");
            case "IsResultMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_IsResultMinute");
            case "IsResultMinuteForPersonnel":
                return (string)GetLocalResourceObject("Str_ColumnName_IsResultMinuteForPersonnel");
            default:
                return ColumnName;
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
            case "IsResultMinute":
            case "IsResultMinuteForPersonnel":
                return 80;
            default:
                return 250;
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
            case "ARBPL":
            case "IsResultMinute":
            case "IsResultMinuteForPersonnel":
                return "center";
            default:
                return "left";
        }
    }
}