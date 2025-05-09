<%@ WebHandler Language="C#" Class="RPT_005" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_005 : BasePage
{
    protected DateTime DateStart = DateTime.Now;
    protected DateTime DateEnd = DateTime.Now;
    protected string Brand = string.Empty;
    protected string CINFO = string.Empty;
    protected string AUFNR = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_005.xlsx";
    protected DataTable ExportDataTable = new DataTable();

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
                    DateEnd = DateTime.Parse("9999/01/01");
            }

            if (_context.Request["Brand"] != null)
                Brand = _context.Request["Brand"].Trim();

            if (_context.Request["CINFO"] != null)
                CINFO = _context.Request["CINFO"].Trim();

            if (_context.Request["AUFNR"] != null)
                AUFNR = _context.Request["AUFNR"].Trim();

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_005_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_005");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("DateStart", "DateTime", 0, DateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("DateEnd", "DateTime", 0, DateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("Brand", "Nvarchar", 50, Brand));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CINFO", "Nvarchar", 50, CINFO));

        dbcb.appendParameter(Util.GetDataAccessAttribute("AUFNR", "Nvarchar", 50, AUFNR));

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
            //报废日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
            ReportColumnIndex++;
            //工单号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            ReportColumnIndex++;
            //工单状态
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["StatusName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工单总数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)(decimal)Row["PSMNG"];
            ReportColumnIndex++;
            //工单已交货数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)(decimal)Row["WEMNG"];
            ReportColumnIndex++;
            //物料代碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["PLNBEZ"].ToString().Trim();
            ReportColumnIndex++;
            //物料名稱
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MAKTX"].ToString().Trim();
            ReportColumnIndex++;
            //供應商
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["RawMaterialVendorName"].ToString().Trim();
            ReportColumnIndex++;
            //報廢原因
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ScrapReasonName"].ToString().Trim();
            ReportColumnIndex++;
            //缺陷代碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DefectID"].ToString().Trim();
            ReportColumnIndex++;
            //缺陷名稱
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DefectName"].ToString().Trim();
            ReportColumnIndex++;
            //報廢數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //隔離單號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TicketID"].ToString().Trim();
            ReportColumnIndex++;
            //報廢製程
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LTXA1"].ToString().Trim();
            ReportColumnIndex++;
            //原材料批號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CINFO"].ToString().Trim();
            ReportColumnIndex++;
            //SAP批次号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CHARG"].ToString().Trim();
            ReportColumnIndex++;
            //刻字號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Brand"].ToString().Trim();
            ReportColumnIndex++;
            //生產版本號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            ReportColumnIndex++;
            //機台編號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //ED機台編號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["EDMachineID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //備註
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Remark"].ToString().Trim();
            ReportColumnIndex++;
            //判定人員
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["JudgmentAccountName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //開單人員
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CreateAccountName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
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