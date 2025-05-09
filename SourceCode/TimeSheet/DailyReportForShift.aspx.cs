using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_DailyReportForShift : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        HF_IsShowResultList.Value = false.ToStringValue();
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        string Query = @"Select TEXT1,LTXA1,IsNull([WS01],0) As [WS01],IsNull([WS02],0) As [WS02],IsNull([WS03],0) As [WS03],IsNull([WS04],0) As [WS04],IsNull([WS05],0) As [WS05],
                        IsNull([WS01],0) + IsNull([WS02],0) + IsNull([WS03],0) + IsNull([WS04],0) + IsNull([WS05],0) As [TotalQty]
                        From 
                        (
	                        Select WorkShiftID,TEXT1,ProcessID,LTXA1,GoodQty From V_TSTicketResult
	                        Where ReportDate >= @ReportDateStart And ReportDate <= @ReportDateEnd And IsNull(Approver,-1) >= @Approver And GoodQty > 0
                        ) As ResultTable
                        Pivot
                        (
	                        Sum(GoodQty)
	                        For WorkShiftID In ([WS01],[WS02],[WS03],[WS04],[WS05])
                        ) As PivotTable
                        Order By ProcessID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(DateTime.Parse(TB_ReportDateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "ReportDateStart"));

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(DateTime.Parse(TB_ReportDateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "ReportDateEnd"));

        dbcb.appendParameter(Schema.Attributes["Approver"].copy(DDL_IsApproved.SelectedValue.ToBoolean() ? 0 : -1));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DataTable WorkShift = CommonDB.ExecuteSelectQuery(@"Select * From V_TSWorkShift");

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        Dictionary<string, string> NumberFormats = new Dictionary<string, string>();

        NumberFormats.Add("WS01", "N0");
        NumberFormats.Add("WS02", "N0");
        NumberFormats.Add("WS03", "N0");
        NumberFormats.Add("WS04", "N0");
        NumberFormats.Add("WS05", "N0");
        NumberFormats.Add("TotalQty", "N0");

        IList<Dictionary<string, string>> Rows = DT.ToDictionary(null, NumberFormats);

        var ResponseData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName, WorkShift),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName)
            }),
            ProcessNameColumnName = "LTXA1",
            WS01ColumnName = "WS01",
            WS02ColumnName = "WS02",
            WS03ColumnName = "WS03",
            WS04ColumnName = "WS04",
            WS05ColumnName = "WS05",
            TotalQtyColumnName = "TotalQty",
            Rows = Rows
        };

        HF_IsShowResultList.Value = true.ToStringValue();

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowFooterRowValue", "<script>var IsShowFooterRowValue='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");
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
    /// 指定ColumnName得到對齊方式
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>對齊方式</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "TEXT1":
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
            case "TEXT1":
                return 110;
            case "LTXA1":
                return 60;
            default:
                return 100;
        }

    }

    /// <summary>
    /// 指定ColumnName得到顯示欄位名稱
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <param name="WorkShift">班別資料表</param>
    /// <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName, DataTable WorkShift)
    {
        switch (ColumnName)
        {
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            case "LTXA1":
                return (string)GetLocalResourceObject("Str_ColumnName_LTXA1");
            case "TotalQty":
                return (string)GetLocalResourceObject("Str_ColumnName_TotalQty");
            default:
                string WorkShiftName = WorkShift.AsEnumerable().Where(Row => Row["WorkShiftID"].ToString().Trim() == ColumnName).Select(Row => Row["WorkShiftName"].ToString().Trim()).FirstOrDefault();
                return string.IsNullOrEmpty(WorkShiftName) ? ColumnName : WorkShiftName;
        }
    }
}