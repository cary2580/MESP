using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_RPT_015 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        HF_IsShowResultList.Value = false.ToStringValue();
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_015");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("Brand", "Nvarchar", 50, TB_Brand.Text.Trim()));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CINFO", "Nvarchar", 50, TB_CINFO.Text.Trim()));

        var CreateDateStart = string.IsNullOrEmpty(TB_CreateDateStart.Text.Trim()) ? string.Empty : DateTime.Parse(TB_CreateDateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture).ToDefaultString();

        dbcb.appendParameter(Util.GetDataAccessAttribute("CreateDateStart", "DateTime", 0, CreateDateStart));

        var CreateDateEnd = string.IsNullOrEmpty(TB_CreateDateEnd.Text.Trim()) ? string.Empty : DateTime.Parse(TB_CreateDateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture).ToDefaultString();

        dbcb.appendParameter(Util.GetDataAccessAttribute("CreateDateEnd", "DateTime", 0, CreateDateEnd));

        var AUFNRCloseDateTimeStart = string.IsNullOrEmpty(TB_AUFNRCloseDateTimeStart.Text.Trim()) ? string.Empty : DateTime.Parse(TB_AUFNRCloseDateTimeStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture).ToDefaultString();

        dbcb.appendParameter(Util.GetDataAccessAttribute("AUFNRCloseDateTimeStart", "DateTime", 0, AUFNRCloseDateTimeStart));

        var AUFNRCloseDateTimeEnd = string.IsNullOrEmpty(TB_AUFNRCloseDateTimeEnd.Text.Trim()) ? string.Empty : DateTime.Parse(TB_AUFNRCloseDateTimeEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture).ToDefaultString();

        dbcb.appendParameter(Util.GetDataAccessAttribute("AUFNRCloseDateTimeEnd", "DateTime", 0, AUFNRCloseDateTimeEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            BT_Search.Visible = false;

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_NoResultData"));

            return;
        }

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
                classes = Column.ColumnName == "AUFNR" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            AUFNRColumnName = (string)GetLocalResourceObject("Str_ColumnName_AUFNR"),
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                AUFNR = Row["AUFNR"].ToString().Trim(),
                StatusName = Row["StatusName"].ToString().Trim(),
                Brand = Row["Brand"].ToString().Trim(),
                CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureStringTime(),
                CreateAccountName = Row["CreateAccountName"].ToString().Trim(),
                MPAccountName = Row["MPAccountName"].ToString().Trim(),
                QAAccountName = Row["QAAccountName"].ToString().Trim(),
                //CHARG = Row["CHARG"].ToString().Trim(),
                CINFO = Row["CINFO"].ToString().Trim(),
                PSMNG = ((decimal)Row["PSMNG"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyTotal = ((int)Row["ScrapQtyTotal"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyS101 = ((int)Row["ScrapQtyS101"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyS102 = ((int)Row["ScrapQtyS102"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyS103 = ((int)Row["ScrapQtyS103"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyS104 = ((int)Row["ScrapQtyS104"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyS201 = ((int)Row["ScrapQtyS201"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyS202 = ((int)Row["ScrapQtyS202"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyS203 = ((int)Row["ScrapQtyS203"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyS204 = ((int)Row["ScrapQtyS204"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyS205 = ((int)Row["ScrapQtyS205"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyS206 = ((int)Row["ScrapQtyS206"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyS207 = ((int)Row["ScrapQtyS207"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                TEXT1 = Row["TEXT1"].ToString().Trim(),
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

        HF_IsShowResultList.Value = true.ToStringValue();
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
            case "ScrapRateTotal":
            case "ScrapRateS101":
            case "ScrapRateS102":
            case "ScrapRateS103":
            case "ScrapRateS104":
            case "ScrapRateS201":
            case "ScrapRateS202":
            case "ScrapRateS203":
            case "ScrapRateS204":
            case "ScrapRateS205":
            case "ScrapRateS206":
            case "ScrapRateS207":
            case "CHARG":
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
            case "AUFNR":
            case "CreateDate":
            case "StatusName":
                return "center";
            case "PSMNG":
            case "ScrapQtyTotal":
            case "ScrapQtyS101":
            case "ScrapQtyS102":
            case "ScrapQtyS103":
            case "ScrapQtyS104":
            case "ScrapQtyS201":
            case "ScrapQtyS202":
            case "ScrapQtyS203":
            case "ScrapQtyS204":
            case "ScrapQtyS205":
            case "ScrapQtyS206":
            case "ScrapQtyS207":
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
            case "AUFNR":
            case "CreateDate":
                return 140;
            case "Brand":
            case "CHARG":
            case "StatusName":
                return 120;
            case "PSMNG":
            case "ScrapQtyTotal":
            case "ScrapQtyS101":
            case "ScrapQtyS102":
            case "ScrapQtyS103":
            case "ScrapQtyS104":
            case "ScrapQtyS201":
            case "ScrapQtyS202":
            case "ScrapQtyS203":
            case "ScrapQtyS204":
            case "ScrapQtyS205":
            case "ScrapQtyS206":
            case "ScrapQtyS207":
                return 60;
            case "CINFO":
            case "CreateAccountName":
            case "MPAccountName":
            case "QAAccountName":
                return 100;
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
            case "AUFNR":
                return (string)GetLocalResourceObject("Str_ColumnName_AUFNR");
            case "Brand":
                return (string)GetLocalResourceObject("Str_ColumnName_Brand");
            case "StatusName":
                return (string)GetLocalResourceObject("Str_ColumnName_StatusName");
            case "CreateDate":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateDate");
            case "CreateAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateAccountName");
            case "MPAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_MPAccountName");
            case "QAAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_QAAccountName");
            case "CHARG":
                return (string)GetLocalResourceObject("Str_ColumnName_CHARG");
            case "CINFO":
                return (string)GetLocalResourceObject("Str_ColumnName_CINFO");
            case "PSMNG":
                return (string)GetLocalResourceObject("Str_ColumnName_PSMNG");
            case "ScrapQtyTotal":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyTotal");
            case "ScrapQtyS101":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyS101");
            case "ScrapQtyS102":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyS102");
            case "ScrapQtyS103":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyS103");
            case "ScrapQtyS104":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyS104");
            case "ScrapQtyS201":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyS201");
            case "ScrapQtyS202":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyS202");
            case "ScrapQtyS203":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyS203");
            case "ScrapQtyS204":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyS204");
            case "ScrapQtyS205":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyS205");
            case "ScrapQtyS206":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyS206");
            case "ScrapQtyS207":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyS207");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            default:
                return ColumnName;
        }
    }
}