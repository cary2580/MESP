<%@ WebHandler Language="C#" Class="RPT_015" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;


public class RPT_015 : BasePage
{
    protected DateTime CreateDateStart = DateTime.Parse("1900/01/01");
    protected DateTime CreateDateEnd = DateTime.Parse("1900/01/01");
    protected DateTime AUFNRCloseDateTimeStart = DateTime.Parse("1900/01/01");
    protected DateTime AUFNRCloseDateTimeEnd = DateTime.Parse("1900/01/01");
    protected string Brand = string.Empty;
    protected string CINFO = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_015.xlsx";
    protected DataTable ExportDataTable = new DataTable();

    public override void ProcessRequest(HttpContext context)
    {

        try
        {
            base.processRequest(context);

            if (_context.Request["CreateDateStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["CreateDateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out CreateDateStart))
                    CreateDateStart = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["CreateDateEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["CreateDateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out CreateDateEnd))
                    CreateDateEnd = DateTime.Parse("9999/01/01");
            }

            if (_context.Request["AUFNRCloseDateTimeStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["AUFNRCloseDateTimeStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out AUFNRCloseDateTimeStart))
                    AUFNRCloseDateTimeStart = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["AUFNRCloseDateTimeEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["AUFNRCloseDateTimeEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out AUFNRCloseDateTimeEnd))
                    AUFNRCloseDateTimeEnd = DateTime.Parse("9999/01/01");
            }

            if (_context.Request["Brand"] != null)
                Brand = _context.Request["Brand"].Trim();

            if (_context.Request["CINFO"] != null)
                CINFO = _context.Request["CINFO"].Trim();

            if (CreateDateStart > CreateDateEnd)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            if (AUFNRCloseDateTimeStart > AUFNRCloseDateTimeEnd)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_015_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_015");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("Brand", "Nvarchar", 50, Brand));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CINFO", "Nvarchar", 50, CINFO));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CreateDateStart", "DateTime", 0, CreateDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CreateDateEnd", "DateTime", 0, CreateDateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("AUFNRCloseDateTimeStart", "DateTime", 0, AUFNRCloseDateTimeStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("AUFNRCloseDateTimeEnd", "DateTime", 0, AUFNRCloseDateTimeEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

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
            //工单号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工单状态
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["StatusName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //刻字号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Brand"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            //刻字号建立日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["CreateDate"], true);
            ReportColumnIndex++;
            //刻字號設定人
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CreateAccountName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            //刻字號設定班長
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MPAccountName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            //刻字號設定QA
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["QAAccountName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            ////SAP批次号
            //worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CHARG"].ToString().Trim();
            //worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
            //worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            //ReportColumnIndex++;
            //材料批号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CINFO"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            //工单总产量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)(decimal)Row["PSMNG"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //报废总数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyTotal"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //总报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateTotal"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //机加工制程报废
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyS101"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //机加工制程报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateS101"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //ED制程报废
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyS102"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //ED制程报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateS102"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //EP制程报废
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyS103"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //EP制程报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateS103"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //原材料报废
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyS104"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //原材料废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateS104"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //PD领用报废
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyS201"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //PD领用报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateS201"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //RD领用报废
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyS202"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //RD领用报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateS202"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //MPS领用报废
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyS203"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //MPS领用报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateS203"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //QA领用报废
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyS204"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //QA领用报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateS204"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //SD领用报废
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyS205"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //SD领用报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateS205"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //仓库报废领用报废
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyS206"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //仓库报废领用报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateS206"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //仓库报废领用报废
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyS207"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //仓库报废领用报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRateS207"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //生产版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();

        return WriteToExcelFile(ReportTemplateName);
    }

}