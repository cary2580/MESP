<%@ WebHandler Language="C#" Class="RPT_023" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_023 : BasePage
{
    protected DateTime ReportDateStart = DateTime.Parse("1900/01/01");
    protected DateTime ReportDateEnd = DateTime.Parse("1900/01/01");
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_023.xlsx";
    protected DataSet ExportDataSet = new DataSet();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

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

            if ((ReportDateEnd < ReportDateStart) || ReportDateEnd.Year < 1911 || ReportDateStart.Year < 1911)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_023_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_023");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateStart", "DateTime", 0, ReportDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateEnd", "DateTime", 0, ReportDateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("EDProcessFirstDeviceID", "Nvarchar", 1000, System.Configuration.ConfigurationManager.AppSettings["EDProcessFirstDeviceID"]));

        ExportDataSet = CommonDB.ExecuteSelectQueryToDataSet(dbcb);
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns></returns>
    protected string WritToExcel()
    {
        if (ExportDataSet.Tables[0].Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        WriteToRPT1();

        WriteToRPT2();

        WriteToRPT3();

        return WriteToExcelFile(ReportTemplateName);
    }

    /// <summary>
    /// 輸出RPT1
    /// </summary>
    protected void WriteToRPT1()
    {
        DataTable ExportDataTable = ExportDataSet.Tables[0];

        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        Sheet = ExcelWorkBook.Worksheets["RPT1"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataTable.Columns)
        {
            if ((string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataTable.Rows)
        {
            //日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
            ReportColumnIndex++;
            //流程卡號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TicketID"].ToString().Trim();
            ReportColumnIndex++;
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            ReportColumnIndex++;
            //設備編號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //分母
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Denominator"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //分子
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Numerator"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //直通率
            string currentFormula = "F" + ReportRowIndex.ToString() + "/E" + ReportRowIndex.ToString() + "";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Value2 = currentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Formula = currentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";

            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 輸出RPT2
    /// </summary>
    protected void WriteToRPT2()
    {
        DataTable ExportDataTable = ExportDataSet.Tables[1];

        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        Sheet = ExcelWorkBook.Worksheets["RPT2"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataTable.Columns)
        {
            if ((string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataTable.Rows)
        {
            //設備編號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //分母
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Denominator"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //分子
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Numerator"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //直通率
            string currentFormula = "C" + ReportRowIndex.ToString() + "/B" + ReportRowIndex.ToString() + "";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Value2 = currentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Formula = currentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 輸出RPT3
    /// </summary>
    protected void WriteToRPT3()
    {
        DataTable ExportDataTable = ExportDataSet.Tables[2];

        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        Sheet = ExcelWorkBook.Worksheets["RPT3"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataTable.Columns)
        {
            if ((string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataTable.Rows)
        {
            //工單號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            ReportColumnIndex++;
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            ReportColumnIndex++;
            //分母
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Denominator"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //分子
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Numerator"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //直通率
            string currentFormula = "D" + ReportRowIndex.ToString() + "/C" + ReportRowIndex.ToString() + "";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Value2 = currentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Formula = currentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}