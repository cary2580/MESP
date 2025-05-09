using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_ParametersByPower : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        string Query = @"Select * From T_TSParametersByPower Where Datediff(day,@ReportDateStart,ReportDate) >= 0 And Datediff(day,@ReportDateEnd,ReportDate) <= 0";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSParametersByPower"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(TB_ReportDateStart.Text, "ReportDateStart"));

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(TB_ReportDateEnd.Text, "ReportDateEnd"));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

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
                classes = Column.ColumnName == "ReportDate" ? BaseConfiguration.JQGridColumnClassesName : string.Empty,
            }),
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            ReportDateColumnName = (string)GetLocalResourceObject("Str_ColumnName_ReportDate"),
            ReportDateValueColumnName = "ReportDate",
            Rows = DT.AsEnumerable().Select(Row => new
            {
                ReportDate = ((DateTime)Row["ReportDate"]).ToCurrentUICultureString(),
                Power = Row["Power"].ToString().Trim(),
                ElectricCurrent = Row["ElectricCurrent"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

        HF_IsShowResultList.Value = true.ToStringValue();
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
            default:
                return 120;
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
            case "ReportDate":
                return (string)GetLocalResourceObject("Str_ColumnName_ReportDate");
            case "Power":
                return (string)GetLocalResourceObject("Str_ColumnName_Power");
            case "ElectricCurrent":
                return (string)GetLocalResourceObject("Str_ColumnName_ElectricCurrent");
            default:
                return ColumnName;
        }
    }
}