using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_ScrapReasonMappingDefect : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        string Query = @"Select '' As ScrapReasonIDValue,T_TSScrapReason.ScrapReasonID,'' As ScrapReasonNameValue,T_TSScrapReason.ScrapReasonName From T_TSScrapReason";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        string ScrapReasonIDColumnName = "ScrapReasonIDValue";
        string ScrapReasonNameColumnName = "ScrapReasonNameValue";

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
                classes = Column.ColumnName == "ScrapReasonID" ? BaseConfiguration.JQGridColumnClassesName : string.Empty,
            }),
            ScrapReasonIDColumnName,
            ScrapReasonNameColumnName,
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                ScrapReasonIDValue = Row["ScrapReasonID"].ToString().Trim(),
                ScrapReasonID = Row["ScrapReasonID"].ToString().Trim(),
                ScrapReasonNameValue = Row["ScrapReasonName"].ToString().ToBase64String(),
                ScrapReasonName = Row["ScrapReasonName"].ToString().Trim(),
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
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
            case "ScrapReasonID":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapReasonID");
            case "ScrapReasonName":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapReasonName");
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
            case "ScrapReasonID":
                return 40;
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
            case "ScrapReasonID":
                return "center";
            default:
                return "left";
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
            case "ScrapReasonIDValue":
            case "ScrapReasonNameValue":
                return true;
            default:
                return false;
        }
    }
}