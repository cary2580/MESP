<%@ WebHandler Language="C#" Class="RPT_033" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_033 : BasePage
{
    protected DateTime TicketCreateDateStart = DateTime.Parse("1900/01/01");
    protected DateTime TicketCreateDateEnd = DateTime.Parse("1900/01/01");
    protected string MATNRVERID = string.Empty;
    protected string STATUS = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_033.xlsx";
    protected DataTable ResultDataTable = new DataTable();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["TicketCreateDateStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["TicketCreateDateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out TicketCreateDateStart))
                    TicketCreateDateStart = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["TicketCreateDateEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["TicketCreateDateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out TicketCreateDateEnd))
                    TicketCreateDateEnd = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["MATNRVERID"] != null)
                MATNRVERID = _context.Request["MATNRVERID"].Trim();

            if (_context.Request["IsViewOnlyEndAUFNR"] != null)
                STATUS = _context.Request["IsViewOnlyEndAUFNR"].Trim();

            if (string.IsNullOrEmpty(MATNRVERID))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_MATNRVERID"));

            if (TicketCreateDateStart.Year < 1911 || TicketCreateDateEnd.Year < 1911 || (TicketCreateDateEnd < TicketCreateDateStart))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            if ((TicketCreateDateEnd - TicketCreateDateStart).TotalDays > 180)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_Error_DateSelectOverHalfYear"));

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_033_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_033");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.Timeout = 60 * 10;

        dbcb.appendParameter(Util.GetDataAccessAttribute("TicketCreateDateStart", "DateTime", 0, TicketCreateDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("TicketCreateDateEnd", "DateTime", 0, TicketCreateDateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("MATNRVERID", "nvarchar", 90000, MATNRVERID));

        dbcb.appendParameter(Util.GetDataAccessAttribute("STATUS", "Nvarchar", 50, STATUS));

        dbcb.appendParameter(Util.GetDataAccessAttribute("General", "Nvarchar", 50, (short)Util.TS.TicketType.General));

        dbcb.appendParameter(Util.GetDataAccessAttribute("Rework", "Nvarchar", 50, (short)Util.TS.TicketType.Rework));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        ResultDataTable = CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns></returns>
    protected string WritToExcel()
    {
        if (ResultDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        Sheet = ExcelWorkBook.Worksheets["RPT"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ResultDataTable.Columns)
        {
            if (GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ResultDataTable.Rows)
        {
            //工单号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //流程卡开单日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["CreateDate"], true);
            ReportColumnIndex++;
            //生产版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            //工种
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ProcessTypeName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //1打头流程卡开始时间
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportTimeStart"], true);
            ReportColumnIndex++;
            //1打头流程卡最后一筐出工时间
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportTimeEnd"], true);
            ReportColumnIndex++;
            //标准结批时长（天）
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ProcessStandardDay"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //结批时间
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["BatchCloseDay"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

            if ((bool)Row["OverTime"])
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;

            ReportColumnIndex++;
            //3打头流程卡开始时间
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportTimeStartByReWork"], true);
            ReportColumnIndex++;
            //3打头流程卡最后一筐出工时间
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportTimeEndByReWork"], true);
            ReportColumnIndex++;
            //标准结批时长（天）
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ProcessReWorkStandardDay"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //3打头流程卡结批时间
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ReworkBatchCloseDay"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            if ((bool)Row["OverTimeReWork"])
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();


        return WriteToExcelFile(ReportTemplateName);
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}