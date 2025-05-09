using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_MATNRParameters : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        LoadData();
    }

    /// <summary>
    /// 加载物料资料
    /// </summary>
    private void LoadData()
    {
        string Query = @"Select 
                            '' As MATNRValue,
	                        MATNRResult.MATNR,
	                        MATNRResult.MAKTX,
	                        IsNull(T_TSMATNRParameters.HangPointQty,0) As HangPointQty,
                            (Select Top 1 LGOBE From T_SAPT001L Where T_SAPT001L.LGORT = T_TSMATNRParameters.ProductLGORT) As LGOBE,
                            IsNull(AUFNRStdWorkDay,0) As AUFNRStdWorkDay
                        From 
                        (Select MATNR,MAKTX From T_TSSAPMAPL Group By MATNR,MAKTX) As MATNRResult 
                        Left Join T_TSMATNRParameters On T_TSMATNRParameters.MATNR = MATNRResult.MATNR
                        Order By MATNR";

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
                classes = Column.ColumnName == "MATNR" ? BaseConfiguration.JQGridColumnClassesName : string.Empty,
            }),
            MATNRColumnName = "MATNRValue",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                MATNRValue = Row["MATNR"].ToString().Trim(),
                MATNR = Row["MATNR"].ToString().Trim(),
                MAKTX = Row["MAKTX"].ToString().Trim(),
                HangPointQty = Row["HangPointQty"].ToString().Trim(),
                LGOBE = Row["LGOBE"].ToString().Trim(),
                AUFNRStdWorkDay = Row["AUFNRStdWorkDay"].ToString().Trim(),
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
    }

    // <summary>
    // 指定ColumnName得到是否顯示
    // </summary>
    // <param name = "ColumnName" > DB ColumnName</param>
    // <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "MATNRValue":
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
            case "HangPointQty":
            case "LGOBE":
            case "AUFNRStdWorkDay":
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
            case "MAKTX":
                return 150;
            case "HangPointQty":
            case "LGOBE":
                return 80;
            default:
                return 100;
        }
    }

    // <summary>
    // 指定ColumnName得到顯示欄位名稱
    // </summary>
    // <param name = "ColumnName" > DB ColumnName</param>
    // <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "MATNR":
                return (string)GetLocalResourceObject("Str_ColumnName_MATNR");
            case "MAKTX":
                return (string)GetLocalResourceObject("Str_ColumnName_MAKTX");
            case "HangPointQty":
                return (string)GetLocalResourceObject("Str_ColumnName_HangPointQty");
            case "LGOBE":
                return (string)GetLocalResourceObject("Str_ColumnName_LGOBE");
            case "AUFNRStdWorkDay":
                return (string)GetLocalResourceObject("Str_ColumnName_AUFNRStdWorkDay");
            default:
                return ColumnName;
        }
    }

}