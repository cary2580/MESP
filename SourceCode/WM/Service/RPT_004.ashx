<%@ WebHandler Language="C#" Class="RPT_004" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_004 : BasePage
{
    protected string PackingID = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\WM\ReportTemplate\");
    protected string ReportTemplateName = "RPT_004.xlsx";
    protected DataTable ResultDataTable = new DataTable();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["PackingID"] != null)
                PackingID = _context.Request["PackingID"].Trim();

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_004_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_WM_RPT_004");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("PackingID", "nvarchar", 50, PackingID));

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

        Sheet.Range[ReportRowIndex, ReportColumnIndex, ReportRowIndex, ReportColumnIndex + 8].Merge();

        ReportColumnIndex = 1;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PackingList");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PackingSendOutDate");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 2;

        if (!string.IsNullOrEmpty(ResultDataTable.Rows[0]["DeliveryDate"].ToString()))
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)ResultDataTable.Rows[0]["DeliveryDate"]);

        ReportColumnIndex = 3;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_MAKTX");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 4;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = ResultDataTable.Rows[0]["MAKTX"].ToString().Trim();
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 5;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_KDMAT");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 6;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = ResultDataTable.Rows[0]["KDMAT"].ToString().Trim();
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 7;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_KUNNR");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 8;

        Sheet.Range[ReportRowIndex, ReportColumnIndex, ReportRowIndex, ReportColumnIndex + 1].Merge();
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = ResultDataTable.Rows[0]["KUNNR"].ToString().Trim();

        ReportRowIndex = 3;
        ReportColumnIndex = 1;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PackingCreateDate");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 2;

        SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)ResultDataTable.Rows[0]["PackingCreateDate"]);

        ReportColumnIndex = 3;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PackingID");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 4;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = ResultDataTable.Rows[0]["PackingID"].ToString().Trim();

        ReportColumnIndex = 5;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PackingRemark");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 6;

        Sheet.Range[ReportRowIndex, ReportColumnIndex, ReportRowIndex, ReportColumnIndex + 3].Merge();
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = ResultDataTable.Rows[0]["Remark"].ToString().Trim();

        ReportRowIndex = 4;
        ReportColumnIndex = 1;

        foreach (DataColumn Column in ResultDataTable.Columns)
        {
            if (GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 5;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ResultDataTable.Rows)
        {
            //栈板号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["PalletNo"].ToString().Trim();
            ReportColumnIndex++;
            //箱號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["BoxNo"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //刻字号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Brand"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //原材料批次
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CINFO"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //SAP批次
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CHARG"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Qty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //进仓日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["CreateDate"]);
            ReportColumnIndex++;
            //最後報工歸屬日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["LastTicketReportDate"]);
            ReportColumnIndex++;
            //仓库
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LGOBE"].ToString().Trim();
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