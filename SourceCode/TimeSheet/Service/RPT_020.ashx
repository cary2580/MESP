<%@ WebHandler Language="C#" Class="RPT_020" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_020 : BasePage
{
    protected DateTime ReportDateStart = DateTime.Parse("1900/01/01");
    protected DateTime ReportDateEnd = DateTime.Parse("1900/01/01");
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_020.xlsx";
    protected DataTable ExportDataTable = new DataTable();

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

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_020_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_020");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateStart", "DateTime", 0, ReportDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateEnd", "DateTime", 0, ReportDateEnd));

        ExportDataTable = CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns></returns>
    protected string WritToExcel()
    {
        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        Sheet = ExcelWorkBook.Worksheets["RPT"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataTable.Columns)
        {
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
            //课别
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["SectionName"].ToString().Trim();
            ReportColumnIndex++;
            //IIP时间
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)((decimal)Row["IIPHour"]);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //打样时间
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)((decimal)Row["SampleHour"]);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //转出工时
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)((decimal)Row["TransoutHours"]);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //最终出勤工时
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)((decimal)Row["FinalWorkHour"]);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //转出效率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["Transferoutefficiency"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.0%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();

        return WriteToExcelFile(ReportTemplateName);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}