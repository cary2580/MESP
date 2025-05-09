using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_ProductionVersionSelect : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (Request["DivID"] != null)
                HF_DivID.Value = Request["DivID"].Trim();

            DataTable DT = LoadData();

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
                }),
                MATNRColumnName = "MATNR",
                VERIDColumnName = "VERID",
                TEXT1ColumnName = "TEXT1",
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    MATNR = Row["MATNR"].ToString().Trim(),
                    VERID = Row["VERID"].ToString().Trim(),
                    TEXT1 = Row["TEXT1"].ToString().Trim()
                })
            };

            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelect", "<script>var IsMultiSelectValue='" + true.ToStringValue() + "';</script>");

            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

            Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

            Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true, "parent.$(\"#" + HF_DivID.Value + "\" ).dialog(\"close\");");
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
            case "MATNR":
                return (string)GetLocalResourceObject("Str_ColumnName_MATNR");
            case "VERID":
                return (string)GetLocalResourceObject("Str_ColumnName_VERID");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
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
            case "MATNR":
                return 60;
            case "VERID":
                return 40;
            default:
                return 150;
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
            case "VERID":
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
            default:
                return false;
        }
    }
    /// <summary>
    /// 載入資料
    /// </summary>
    /// <returns></returns>
    private DataTable LoadData()
    {
        string Query = @"Select MATNR,VERID,TEXT1 From T_TSSAPMKAL
                        Where IsLock = 0 And Datediff(Day,ADATU,GetDate()) > 0 And Datediff(Day,GetDate(),BDATU) > 0
                        Order By MATNR";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        return CommonDB.ExecuteSelectQuery(dbcb);
    }
}