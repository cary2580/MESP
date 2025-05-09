<%@ WebHandler Language="C#" Class="RPT_012" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_012 : BasePage
{
    protected DateTime DateStart = DateTime.Parse("1900/01/01");
    protected DateTime DateEnd = DateTime.Parse("1900/01/01");
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_012.xlsx";
    protected DataSet ExportDataSet = new DataSet();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["DateStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["DateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out DateStart))
                    DateStart = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["DateEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["DateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out DateEnd))
                    DateEnd = DateTime.Parse("1900/01/01");
            }

            // 如果都沒有傳入起訖日期，就預設抓當前30天資料(會沒有傳入的機率只有每天要背景發送郵件)
            if (DateStart.Year < 1911 && DateEnd.Year < 1911)
            {
                DateEnd = DateTime.Parse(DateTime.Now.ToDefaultString() + " 05:59:59");

                DateStart = DateTime.Parse(DateTime.Now.AddDays(-30).ToDefaultString() + " 06:00:00");
            }

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_012_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

            _context.Session.Add(GID, RI);

            ResponseSuccessData(new { Result = true, GUID = GID });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

    /// <summary>
    /// 載入匯出資料
    /// </summary>
    protected void LoadExportData()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_012");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportTimeStart", "DateTime", 0, DateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportTimeEnd", "DateTime", 0, DateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "Nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        ExportDataSet = CommonDB.ExecuteSelectQueryToDataSet(dbcb);
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns></returns>
    protected string WritToExcel()
    {
        if (ExportDataSet.Tables.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        WriteToExeclSheet1();

        WriteToExeclSheet2();

        WriteToExeclSheet3();

        return WriteToExcelFile(ReportTemplateName);
    }

    /// <summary>
    /// 將資料寫入Sheet1
    /// </summary>
    protected void WriteToExeclSheet1()
    {
        Sheet = ExcelWorkBook.Worksheets[0];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportTitleName_Sheet1");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportRowIndex = 2;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportCreateTileName") + " : " + DateTime.Now.ToCurrentUICultureString();
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;

        ReportRowIndex = 3;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportTimeTileName") + " : " + DateStart.ToCurrentUICultureStringTime() + "~" + DateEnd.ToCurrentUICultureStringTime();
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;

        ReportRowIndex = 4;
        ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataSet.Tables[0].Columns)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_Sheet1_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 5;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataSet.Tables[0].Rows)
        {
            //工作中心
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ARBPL"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            //工作中心負責人
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERAN"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            //工作中心負責人(描述)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERAN_KTEXT"].ToString().Trim();
            ReportColumnIndex++;

            //分母
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Denominator"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;

            //分子
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Molecular"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;

            //效率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["EfficiencyPercentage"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 將資料寫入Sheet2
    /// </summary>
    protected void WriteToExeclSheet2()
    {
        Sheet = ExcelWorkBook.Worksheets[1];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportTitleName_Sheet2");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportRowIndex = 2;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportCreateTileName") + " : " + DateTime.Now.ToCurrentUICultureString();
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;

        ReportRowIndex = 3;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportTimeTileName") + " : " + DateStart.ToCurrentUICultureStringTime() + "~" + DateEnd.ToCurrentUICultureStringTime();
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;

        ReportRowIndex = 4;
        ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataSet.Tables[1].Columns)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_Sheet2_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 5;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataSet.Tables[1].Rows)
        {
            //工作中心負責人
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERAN"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            //工作中心負責人(描述)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERAN_KTEXT"].ToString().Trim();
            ReportColumnIndex++;

            //分母
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Denominator"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;

            //分子
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Molecular"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;

            //效率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["EfficiencyPercentage"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 將資料寫入Sheet3
    /// </summary>
    protected void WriteToExeclSheet3()
    {
        Sheet = ExcelWorkBook.Worksheets[2];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataSet.Tables[2].Columns)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_Sheet3_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataSet.Tables[2].Rows)
        {
            //流程卡號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TicketID"].ToString().Trim();
            ReportColumnIndex++;

            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            ReportColumnIndex++;

            //途程
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["GroupCurr"].ToString().Trim();
            ReportColumnIndex++;

            //工序
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ProcessName"].ToString().Trim();
            ReportColumnIndex++;

            //工作中心
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ARBPL"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            //工作中心負責人
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERAN"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            //工作中心負責人(描述)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERAN_KTEXT"].ToString().Trim();
            ReportColumnIndex++;

            //執行作業時間(日)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)Row["ExecuteDay"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;

            //工種
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ProcessTypeName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            //執行工種作業時間(日)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)Row["ExecuteDayByProcessType"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;

            //作業標準值(日)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)Row["ProcessStandardDay"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;

            //執行工種是否逾期
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (bool)Row["IsExpired"] ? (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") : (string)GetGlobalResourceObject("GlobalRes", "Str_No");
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }
}