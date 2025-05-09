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
    protected DateTime DeliveryDateStart = DateTime.Parse("1900/01/01");
    protected DateTime DeliveryDateEnd = DateTime.Parse("1900/01/01");
    protected string KUNNR = string.Empty;
    protected string Brand = string.Empty;
    protected string MAKTX = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\WM\ReportTemplate\");
    protected string ReportTemplateName = "RPT_005.xlsx";
    protected DataTable ExportDataTable = new DataTable();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["DeliveryDateStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["DeliveryDateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out DeliveryDateStart))
                    DeliveryDateStart = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["DeliveryDateEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["DeliveryDateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out DeliveryDateEnd))
                    DeliveryDateEnd = DateTime.Parse("1900/01/01");
            }

            if (DeliveryDateStart.Year < 1911 || DeliveryDateEnd.Year < 1911 || (DeliveryDateEnd < DeliveryDateStart))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            if ((DeliveryDateEnd - DeliveryDateStart).TotalDays > 30)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_DateSelectOverThirtyDay"));

            if (_context.Request["KUNNR"] != null)
                KUNNR = _context.Request["KUNNR"].Trim();
            if (_context.Request["Brand"] != null)
                Brand = _context.Request["Brand"].Trim();
            if (_context.Request["MAKTX"] != null)
                MAKTX = _context.Request["MAKTX"].Trim();

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_WM_RPT_005");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("DeliveryDateStart", "DateTime", 0, DeliveryDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("DeliveryDateEnd", "DateTime", 0, DeliveryDateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("KUNNR", "nvarchar", 50, KUNNR));

        dbcb.appendParameter(Util.GetDataAccessAttribute("Brand", "nvarchar", 50, Brand));

        dbcb.appendParameter(Util.GetDataAccessAttribute("MAKTX", "nvarchar", 50, MAKTX));

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
            //請求交貨日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["DeliveryDate"]);
            ReportColumnIndex++;
            //物料名稱
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MAKTX"].ToString().Trim();
            ReportColumnIndex++;
            //零件號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["FERTH"].ToString().Trim();
            ReportColumnIndex++;
            //刻字號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Brand"].ToString().Trim();
            ReportColumnIndex++;
            //原材料批號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CINFO"].ToString().Trim();
            ReportColumnIndex++;
            //SAP批號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CHARG"].ToString().Trim();
            ReportColumnIndex++;
            //數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Qty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //進倉日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["CreateDate"]);
            ReportColumnIndex++;
            //客戶號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["KUNNR"].ToString().Trim();
            ReportColumnIndex++;
            //領料單號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["PackingID"].ToString().Trim();
            ReportColumnIndex++;
            //備註
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Remark"].ToString().Trim();
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