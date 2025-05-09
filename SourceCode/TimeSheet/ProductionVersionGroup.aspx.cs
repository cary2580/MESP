using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_ProductionVersionGroup : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        LoadData();
    }


    /// <summary>
    /// 載入生產版本群組列表
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select '' As PVGroupIDValue,PVGroupID,PVGroupName,SortID From T_TSProductionVersionGroup Group By PVGroupID,PVGroupName,SortID Order By SortID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

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
                classes = Column.ColumnName == "PVGroupID" ? BaseConfiguration.JQGridColumnClassesName : string.Empty,
            }),
            PVGroupIDColumnName = "PVGroupIDValue",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                PVGroupIDValue = Row["PVGroupID"].ToString().Trim(),
                PVGroupID = Row["PVGroupID"].ToString().Trim(),
                PVGroupName = Row["PVGroupName"].ToString().Trim(),
                SortID = Row["SortID"].ToString().Trim()
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
            case "PVGroupIDValue":
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
            case "PVGroupID":
            case "SortID":
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
            case "PVGroupID":
                return 60;
            case "SortID":
                return 40;
            default:
                return 250;
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
            case "PVGroupID":
                return (string)GetLocalResourceObject("Str_ColumnName_PVGroupID");
            case "PVGroupName":
                return (string)GetLocalResourceObject("Str_ColumnName_PVGroupName");
            case "SortID":
                return (string)GetLocalResourceObject("Str_ColumnName_SortID");
            default:
                return ColumnName;
        }
    }
}