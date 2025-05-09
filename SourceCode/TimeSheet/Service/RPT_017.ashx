<%@ WebHandler Language="C#" Class="RPT_017" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_017 : BasePage
{
    protected string ProcessTypeID = string.Empty;
    protected DateTime ReportDateStart = DateTime.Parse("1900/01/01");
    protected DateTime ReportDateEnd = DateTime.Parse("1900/01/01");
    protected bool IsApprovered = true;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName1 = "RPT_017.xlsx";
    protected string ReportTemplateName2 = "RPT_017_1.xlsx";
    protected DataTable ExportDataTable = new DataTable();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["ProcessTypeID"] != null)
                ProcessTypeID = _context.Request["ProcessTypeID"].Trim();

            IsApprovered = _context.Request["IsApprovered"].ToBoolean();

            if (string.IsNullOrEmpty(ProcessTypeID))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_ProcessTypeID"));

            if (_context.Request["ReportDateStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["ReportDateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDateStart))
                    ReportDateStart = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["ReportDateEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["ReportDateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDateEnd))
                    ReportDateEnd = DateTime.Parse("1900/01/01");
            }

            if ((ReportDateStart.Year > 1911 && ReportDateEnd.Year < 1911) || (ReportDateStart.Year < 1911 && ReportDateEnd.Year > 1911) || (ReportDateEnd < ReportDateStart))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_017_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

            _context.Session.Add(GID, RI);

            ResponseSuccessData(new { Result = true, GUID = GID });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 載入匯出資料
    /// </summary>
    protected void LoadExportData()
    {
        if (ReportDateStart.Year < 1911 && ReportDateEnd.Year < 1911)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_017");

            dbcb.DbCommandType = CommandType.StoredProcedure;

            dbcb.appendParameter(Util.GetDataAccessAttribute("ProcessTypeID", "Int", 0, ProcessTypeID));

            dbcb.appendParameter(Util.GetDataAccessAttribute("IsApprovered", "bit", 0, IsApprovered));

            ExportDataTable = CommonDB.ExecuteSelectQuery(dbcb);
        }
        else
        {
            string Query = @"Select * From T_TSInProcessQtyLog Where ReportDate >= @ReportDateStart And ReportDate <= @ReportDateEnd And ProcessTypeID = @ProcessTypeID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSInProcessQtyLog"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(ReportDateStart, "ReportDateStart"));

            dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(ReportDateEnd, "ReportDateEnd"));

            dbcb.appendParameter(Schema.Attributes["ProcessTypeID"].copy(ProcessTypeID));

            ExportDataTable = CommonDB.ExecuteSelectQuery(dbcb);
        }
    }


    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns>報表位置路徑</returns>
    protected string WritToExcel()
    {
        if (ReportDateStart.Year < 1911 && ReportDateEnd.Year < 1911)
            return WritToExcelByCurrent();
        else
            return WritToExcelByLog();
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns>報表位置路徑</returns>
    protected string WritToExcelByLog()
    {
        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName2);

        Sheet = ExcelWorkBook.Worksheets["RPT001"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataTable.Columns)
        {
            if (GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataTable.Rows)
        {
            //報工歸屬日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
            ReportColumnIndex++;
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            //过滤工种前一天的末工序产量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["OP3"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //过滤工种最后一个工序的良品数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["OP0"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //下个工种第一个工序的良品数+报废数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["OP1"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //在制品结存数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["InProcessQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //下个工种最后一个个工序的良品数+报废数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["OP2"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //下工种中间数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["NextProcessTypeMidQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //是否需要电泳
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (bool)Row["IsNeedEDProcess"] ? (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") : (string)GetGlobalResourceObject("GlobalRes", "Str_No");
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //是否需要电镀
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (bool)Row["IsNeedEPProcess"] ? (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") : (string)GetGlobalResourceObject("GlobalRes", "Str_No");
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();

        var ReportDateList = ExportDataTable.AsEnumerable().GroupBy(Row => (DateTime)Row["ReportDate"]).Select(item => item.Key).ToList();

        Sheet = ExcelWorkBook.Worksheets["RPT002"];

        ReportRowIndex = 1;
        ReportColumnIndex = 1;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_ReportDate");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
        ReportColumnIndex++;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_InProcessQty");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
        ReportColumnIndex++;

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DateTime ReportDate in ReportDateList)
        {
            var InProcessQty = ExportDataTable.AsEnumerable().Where(Row => (DateTime)Row["ReportDate"] == ReportDate && (bool)Row["IsNeedEDProcess"]).Sum(Row => (int)Row["InProcessQty"]);

            //報工歸屬日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], ReportDate);
            ReportColumnIndex++;
            //在制品结存数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = InProcessQty;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();

        return WriteToExcelFile(ReportTemplateName2);
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns>報表位置路徑</returns>
    protected string WritToExcelByCurrent()
    {
        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName1);

        Sheet = ExcelWorkBook.Worksheets["RPT"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataTable.Columns)
        {
            if (GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataTable.Rows)
        {
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            //过滤工种前一天的末工序产量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["OP3"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //过滤工种最后一个工序的良品数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["OP0"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //下个工种第一个工序的良品数+报废数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["OP1"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //在制品结存数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["InProcessQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";

            if ((bool)Row["IsOverDoubleOP3"])
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Color = System.Drawing.Color.Yellow;

            ReportColumnIndex++;
            //下个工种最后一个个工序的良品数+报废数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["OP2"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //下工种中间数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["NextProcessTypeMidQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //是否需要电泳
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (bool)Row["IsNeedEDProcess"] ? (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") : (string)GetGlobalResourceObject("GlobalRes", "Str_No");
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //是否需要电镀
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (bool)Row["IsNeedEPProcess"] ? (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") : (string)GetGlobalResourceObject("GlobalRes", "Str_No");
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();

        return WriteToExcelFile(ReportTemplateName1);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}