<%@ WebHandler Language="C#" Class="RPT_037" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_037 : BasePage
{
    protected DateTime DateStart = DateTime.Parse("1900/01/01");
    protected DateTime DateEnd = DateTime.Parse("1900/01/01");
    protected string CategoryID = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_037.xlsx";
    protected DataSet ResultDataSet = new DataSet();

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

            if (_context.Request["CategoryID"] != null)
                CategoryID = _context.Request["CategoryID"].Trim();

            if (DateStart.Year < 1911 || DateEnd.Year < 1911 || (DateStart > DateEnd))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_037_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_037");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.Timeout = 60 * 10;

        dbcb.appendParameter(Util.GetDataAccessAttribute("IssueDateStart", "DateTime", 0, DateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("IssueDateEnd", "DateTime", 0, DateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CategoryID", "Nvarchar", 50, CategoryID));

        ResultDataSet = CommonDB.ExecuteSelectQueryToDataSet(dbcb);
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns></returns>
    protected string WritToExcel()
    {
        if (ResultDataSet.Tables[0].Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        if ((DateEnd - DateStart).TotalDays == 0)
            WritToExcelByOnlyDay();
        else
            WritToExceMultipleDay();

        return WriteToExcelFile(ReportTemplateName);
    }

    /// <summary>
    /// 將資料寫入至XLS(只有一天)
    /// </summary>
    /// <returns></returns>
    protected void WritToExcelByOnlyDay()
    {
        ExcelWorkBook.Worksheets["RPT2"].Remove();

        Sheet = ExcelWorkBook.Worksheets["RPT1"];

        Sheet.Name = "RPT_" + DateStart.ToDefaultString("yyMMdd");

        int ReportRowIndex = 3;
        int ReportColumnIndex = 1;

        DataTable WorkShiftTable = ResultDataSet.Tables[0];

        DataTable WorkShiftDeviceTable = ResultDataSet.Tables[1];

        DataTable IssueTable = ResultDataSet.Tables[2];

        DataTable UsageMinutesTable = ResultDataSet.Tables[3];

        DataTable OtherTable = ResultDataSet.Tables[4];

        Dictionary<string, int> IssueIDRowList = new Dictionary<string, int>();

        /* Issue 資料輸出 */
        foreach (DataRow Row in IssueTable.Rows)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["IssueName"].ToString().Trim();

            IssueIDRowList.Add(Row["IssueID"].ToString().Trim(), ReportRowIndex);

            ReportRowIndex++;
        }

        /* 班別設備資料輸出 */
        ReportRowIndex = 1;
        ReportColumnIndex = 2;

        int ReportDeviceRowIndex = 2;

        int ReportDeviceColumnIndex = 2;

        foreach (DataRow Row in WorkShiftTable.Rows)
        {
            ReportRowIndex = 1;

            var WorkShiftDeviceRows = WorkShiftDeviceTable.AsEnumerable().Where(WDRow => WDRow["WorkShiftID"].ToString().Trim() == Row["WorkShiftID"].ToString().Trim()).ToList();

            if (WorkShiftDeviceRows.Count < 1)
            {
                ReportColumnIndex++;

                continue;
            }

            int MergeColumnIndex = ReportColumnIndex + WorkShiftDeviceRows.Count;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["WorkShiftName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            Sheet.Range[ReportRowIndex, ReportColumnIndex, ReportRowIndex, MergeColumnIndex].Merge();

            foreach (DataRow DeviceRow in WorkShiftDeviceRows)
            {
                Sheet.Range[ReportDeviceRowIndex, ReportDeviceColumnIndex].Text = DeviceRow["MachineName"].ToString().Trim();
                Sheet.Range[ReportDeviceRowIndex, ReportDeviceColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

                ReportDeviceColumnIndex++;
            }

            Sheet.Range[ReportDeviceRowIndex, ReportDeviceColumnIndex].Text = (string)GetGlobalResourceObject("GlobalRes", "Str_SubTotal");
            Sheet.Range[ReportDeviceRowIndex, ReportDeviceColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

            ReportDeviceColumnIndex++;

            ReportColumnIndex = MergeColumnIndex + 1;
        }


        /* 班別設備資料的值輸出 */
        ReportRowIndex = 3;
        ReportColumnIndex = 2;

        foreach (string IssueID in IssueIDRowList.Keys)
        {
            int WorkShiftStartColumnIndex = 2;

            foreach (DataRow WorkShiftRow in WorkShiftTable.Rows)
            {
                var WorkShiftDeviceRows = WorkShiftDeviceTable.AsEnumerable().Where(WDRow => WDRow["WorkShiftID"].ToString().Trim() == WorkShiftRow["WorkShiftID"].ToString().Trim()).ToList();

                if (WorkShiftDeviceRows.Count < 1)
                {
                    ReportColumnIndex++;

                    continue;
                }

                string ColumnLetter = string.Empty;
                string CurrentFormula = string.Empty;

                foreach (DataRow DeviceRow in WorkShiftDeviceRows)
                {
                    int UsageMinutes = UsageMinutesTable.AsEnumerable().Where(UMTRow =>
                    UMTRow["WorkShiftID"].ToString().Trim() == DeviceRow["WorkShiftID"].ToString().Trim() &&
                    UMTRow["DeviceID"].ToString().Trim() == DeviceRow["DeviceID"].ToString().Trim() &&
                    UMTRow["IssueID"].ToString().Trim() == IssueID).Sum(UMTRow => (int)UMTRow["UsageMinutes"]);

                    Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = UsageMinutes;
                    Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

                    /* 班別設備彙總使用時間(下方) */
                    ColumnLetter = GetColumnLetter(ReportColumnIndex);
                    CurrentFormula = string.Format("Sum({0}3:{0}{1})", ColumnLetter, IssueIDRowList.Count + 2);
                    Sheet.Range[IssueIDRowList.Count + 3, ReportColumnIndex].Value2 = CurrentFormula;
                    Sheet.Range[IssueIDRowList.Count + 3, ReportColumnIndex].Formula = CurrentFormula;
                    Sheet.Range[IssueIDRowList.Count + 3, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
                    Sheet.Range[IssueIDRowList.Count + 3, ReportColumnIndex].Style.Color = System.Drawing.Color.LightGreen;

                    /* 班別設備彙總維修時間(下方) */
                    int WorkShiftDevicMaintainMinute = OtherTable.AsEnumerable().Where(OTRow => OTRow["WorkShiftID"].ToString().Trim() == DeviceRow["WorkShiftID"].ToString().Trim()
                    && OTRow["DeviceID"].ToString().Trim() == DeviceRow["DeviceID"].ToString().Trim()).Sum(OTRow => (int)OTRow["MaintainMinute"]);
                    Sheet.Range[IssueIDRowList.Count + 4, ReportColumnIndex].NumberValue = WorkShiftDevicMaintainMinute;
                    Sheet.Range[IssueIDRowList.Count + 4, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
                    Sheet.Range[IssueIDRowList.Count + 4, ReportColumnIndex].Style.Color = System.Drawing.Color.LightSalmon;

                    /* 班別設備彙總良品數(下方) */
                    int WorkShiftDevicGoodQty = OtherTable.AsEnumerable().Where(OTRow => OTRow["WorkShiftID"].ToString().Trim() == DeviceRow["WorkShiftID"].ToString().Trim()
                    && OTRow["DeviceID"].ToString().Trim() == DeviceRow["DeviceID"].ToString().Trim()).Sum(OTRow => (int)OTRow["GoodQty"]);
                    Sheet.Range[IssueIDRowList.Count + 5, ReportColumnIndex].NumberValue = WorkShiftDevicGoodQty;
                    Sheet.Range[IssueIDRowList.Count + 5, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
                    Sheet.Range[IssueIDRowList.Count + 5, ReportColumnIndex].Style.Color = System.Drawing.Color.LightGoldenrodYellow;

                    ReportColumnIndex++;
                }

                /* 班別設備問題彙總(底部右方) */
                string ColumnLetterStart = GetColumnLetter(WorkShiftStartColumnIndex);
                string ColumnLetterEnd = GetColumnLetter(ReportColumnIndex - 1);

                CurrentFormula = string.Format("Sum({0}{2}:{1}{2})", ColumnLetterStart, ColumnLetterEnd, ReportRowIndex);

                Sheet.Range[ReportRowIndex, ReportColumnIndex].Value2 = CurrentFormula;
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Formula = CurrentFormula;
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Color = System.Drawing.Color.LightSkyBlue;

                /* 班別設備彙總使用時間(底部右方) */
                CurrentFormula = string.Format("Sum({0}{2}:{1}{2})", ColumnLetterStart, ColumnLetterEnd, IssueIDRowList.Count + 3);
                Sheet.Range[IssueIDRowList.Count + 3, ReportColumnIndex].Value2 = CurrentFormula;
                Sheet.Range[IssueIDRowList.Count + 3, ReportColumnIndex].Formula = CurrentFormula;
                Sheet.Range[IssueIDRowList.Count + 3, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
                Sheet.Range[IssueIDRowList.Count + 3, ReportColumnIndex].Style.Color = System.Drawing.Color.LightGreen;

                /* 班別設備彙總維修時間(底部右方) */
                CurrentFormula = string.Format("Sum({0}{2}:{1}{2})", ColumnLetterStart, ColumnLetterEnd, IssueIDRowList.Count + 4);
                Sheet.Range[IssueIDRowList.Count + 4, ReportColumnIndex].Value2 = CurrentFormula;
                Sheet.Range[IssueIDRowList.Count + 4, ReportColumnIndex].Formula = CurrentFormula;
                Sheet.Range[IssueIDRowList.Count + 4, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
                Sheet.Range[IssueIDRowList.Count + 4, ReportColumnIndex].Style.Color = System.Drawing.Color.LightSalmon;

                /* 班別設備彙總良品數(底部右方) */
                CurrentFormula = string.Format("Sum({0}{2}:{1}{2})", ColumnLetterStart, ColumnLetterEnd, IssueIDRowList.Count + 5);
                Sheet.Range[IssueIDRowList.Count + 5, ReportColumnIndex].Value2 = CurrentFormula;
                Sheet.Range[IssueIDRowList.Count + 5, ReportColumnIndex].Formula = CurrentFormula;
                Sheet.Range[IssueIDRowList.Count + 5, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
                Sheet.Range[IssueIDRowList.Count + 5, ReportColumnIndex].Style.Color = System.Drawing.Color.LightGoldenrodYellow;

                ReportColumnIndex++;

                WorkShiftStartColumnIndex = ReportColumnIndex;
            }

            ReportColumnIndex = 2;
            ReportRowIndex++;
        }

        /* 班別設備彙總資料的 Title Text 輸出(底部) */
        ReportColumnIndex = 1;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("GlobalRes", "Str_SubTotal");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;

        Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_WorkShiftDeviceMaintainMinute");
        Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;

        Sheet.Range[ReportRowIndex + 2, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_WorkShiftDeviceGoodQty");
        Sheet.Range[ReportRowIndex + 2, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 將資料寫入至XLS(多天)
    /// </summary>
    /// <returns></returns>
    protected void WritToExceMultipleDay()
    {
        ExcelWorkBook.Worksheets["RPT1"].Remove();

        Sheet = ExcelWorkBook.Worksheets["RPT2"];

        Sheet.Name = "RPT_" + DateStart.ToDefaultString("yyMMdd") + "-" + DateEnd.ToDefaultString("yyMMdd");

        int ReportRowIndex = 2;
        int ReportColumnIndex = 1;

        DataTable DeviceTable = ResultDataSet.Tables[0];

        DataTable IssueTable = ResultDataSet.Tables[1];

        DataTable UsageMinutesTable = ResultDataSet.Tables[2];

        DataTable OtherTable = ResultDataSet.Tables[3];

        Dictionary<string, int> IssueIDRowList = new Dictionary<string, int>();

        foreach (DataRow Row in IssueTable.Rows)
        {
            //Issue Name
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["IssueName"].ToString().Trim();

            IssueIDRowList.Add(Row["IssueID"].ToString().Trim(), ReportRowIndex);

            ReportRowIndex++;
        }

        /* 設備資料輸出 */
        ReportRowIndex = 1;
        ReportColumnIndex = 2;
        foreach (DataRow Row in DeviceTable.Rows)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("GlobalRes", "Str_SubTotal");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        /* 資料的值輸出 */
        ReportRowIndex = 2;

        string ColumnLetter = string.Empty;
        string CurrentFormula = string.Empty;

        string ColumnLetterStart = GetColumnLetter(2);
        string ColumnLetterEnd = string.Empty;

        foreach (string IssueID in IssueIDRowList.Keys)
        {
            ReportColumnIndex = 2;

            foreach (DataRow DeviceRow in DeviceTable.Rows)
            {
                int UsageMinutes = UsageMinutesTable.AsEnumerable().Where(UMTRow => UMTRow["DeviceID"].ToString().Trim() == DeviceRow["DeviceID"].ToString().Trim() &&
                UMTRow["IssueID"].ToString().Trim() == IssueID).Sum(UMTRow => (int)UMTRow["UsageMinutes"]);

                Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = UsageMinutes;
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

                /* 設備彙總使用時間(下方) */
                ColumnLetter = GetColumnLetter(ReportColumnIndex);
                CurrentFormula = string.Format("Sum({0}2:{0}{1})", ColumnLetter, IssueIDRowList.Count + 1);
                Sheet.Range[IssueIDRowList.Count + 2, ReportColumnIndex].Value2 = CurrentFormula;
                Sheet.Range[IssueIDRowList.Count + 2, ReportColumnIndex].Formula = CurrentFormula;
                Sheet.Range[IssueIDRowList.Count + 2, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
                Sheet.Range[IssueIDRowList.Count + 2, ReportColumnIndex].Style.Color = System.Drawing.Color.LightGreen;

                /* 設備彙總維修時間(下方) */
                int DevicMaintainMinute = OtherTable.AsEnumerable().Where(OTRow => OTRow["DeviceID"].ToString().Trim() == DeviceRow["DeviceID"].ToString().Trim()).Sum(OTRow => (int)OTRow["MaintainMinute"]);
                Sheet.Range[IssueIDRowList.Count + 3, ReportColumnIndex].NumberValue = DevicMaintainMinute;
                Sheet.Range[IssueIDRowList.Count + 3, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
                Sheet.Range[IssueIDRowList.Count + 3, ReportColumnIndex].Style.Color = System.Drawing.Color.LightSalmon;

                /* 設備彙總良品數(下方) */
                int WorkShiftDevicGoodQty = OtherTable.AsEnumerable().Where(OTRow => OTRow["DeviceID"].ToString().Trim() == DeviceRow["DeviceID"].ToString().Trim()).Sum(OTRow => (int)OTRow["GoodQty"]);
                Sheet.Range[IssueIDRowList.Count + 4, ReportColumnIndex].NumberValue = WorkShiftDevicGoodQty;
                Sheet.Range[IssueIDRowList.Count + 4, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
                Sheet.Range[IssueIDRowList.Count + 4, ReportColumnIndex].Style.Color = System.Drawing.Color.LightGoldenrodYellow;

                ReportColumnIndex++;
            }

            /* 設備問題彙總(底部右方) */
            ColumnLetterEnd = GetColumnLetter(ReportColumnIndex - 1);

            CurrentFormula = string.Format("Sum({0}{2}:{1}{2})", ColumnLetterStart, ColumnLetterEnd, ReportRowIndex);

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Value2 = CurrentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Formula = CurrentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Color = System.Drawing.Color.LightSkyBlue;

            ReportColumnIndex++;
            ReportRowIndex++;
        }

        ReportColumnIndex--;
        ColumnLetterEnd = GetColumnLetter(ReportColumnIndex - 1);

        /* 設備問題彙總(底部右方) */
        CurrentFormula = string.Format("Sum({0}{2}:{1}{2})", ColumnLetterStart, ColumnLetterEnd, ReportRowIndex);
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Value2 = CurrentFormula;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Formula = CurrentFormula;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Color = System.Drawing.Color.LightGreen;

        /* 設備彙總維修時間(底部右方) */
        CurrentFormula = string.Format("Sum({0}{2}:{1}{2})", ColumnLetterStart, ColumnLetterEnd, ReportRowIndex + 1);
        Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Value2 = CurrentFormula;
        Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Formula = CurrentFormula;
        Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
        Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Style.Color = System.Drawing.Color.LightSalmon;

        /* 設備彙總良品(底部右方) */
        CurrentFormula = string.Format("Sum({0}{2}:{1}{2})", ColumnLetterStart, ColumnLetterEnd, ReportRowIndex + 2);
        Sheet.Range[ReportRowIndex + 2, ReportColumnIndex].Value2 = CurrentFormula;
        Sheet.Range[ReportRowIndex + 2, ReportColumnIndex].Formula = CurrentFormula;
        Sheet.Range[ReportRowIndex + 2, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
        Sheet.Range[ReportRowIndex + 2, ReportColumnIndex].Style.Color = System.Drawing.Color.LightGoldenrodYellow;

        /* 設備彙總資料的 Title Text 輸出(底部) */
        ReportColumnIndex = 1;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("GlobalRes", "Str_SubTotal");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;

        Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_WorkShiftDeviceMaintainMinute");
        Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;

        Sheet.Range[ReportRowIndex + 2, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_WorkShiftDeviceGoodQty");
        Sheet.Range[ReportRowIndex + 2, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;

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