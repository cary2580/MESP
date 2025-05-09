using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
public partial class TimeSheet_FaultMappingList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        LoadData();
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select '' As FaultCategoryIDValue,*
                        From T_TSFaultCategory";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        string FaultCategoryIDColumnName = "FaultCategoryIDValue";
        string FaultCategoryNameColumnName = "FaultCategory";
        string LinkFaultMapping = "FaultCategoryID";
        string LinkFaultMappingPLNBEZColumnName = "FaultCategoryName";

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
                classes = Column.ColumnName == "FaultCategoryID" || Column.ColumnName == "FaultCategoryName" ? BaseConfiguration.JQGridColumnClassesName : string.Empty,
            }),
            FaultCategoryIDColumnName = FaultCategoryIDColumnName,
            FaultCategoryNameColumnName = FaultCategoryNameColumnName,
            LinkFaultMapping = LinkFaultMapping,
            LinkFaultMappingPLNBEZColumnName = LinkFaultMappingPLNBEZColumnName,
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                FaultCategoryIDValue = Row["FaultCategoryID"].ToString().ToBase64String(true),
                FaultCategoryID = Row["FaultCategoryID"].ToString().Trim(),
                FaultCategoryName = Row["FaultCategoryName"].ToString().Trim()
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
            case "FaultCategoryIDValue":
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
            case "FaultCategoryID":
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
            case "FaultCategoryID":
                return 80;
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
            case "FaultCategoryID":
                return (string)GetLocalResourceObject("Str_ColumnName_FaultCategoryID");
            case "FaultCategoryName":
                return (string)GetLocalResourceObject("Str_ColumnName_FaultCategoryName");
            default:
                return ColumnName;
        }
    }
}