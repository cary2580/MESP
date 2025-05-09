<%@ WebHandler Language="C#" Class="RPT_031" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_031 : BasePage
{
    protected DateTime ReportDateStart = DateTime.Parse("1900/01/01");
    protected DateTime ReportDateEnd = DateTime.Parse("1900/01/01");
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_031.xlsx";
    protected DataTable ResultDataTable = new DataTable();

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

            if (ReportDateStart.Year < 1911 || ReportDateEnd.Year < 1911 || (ReportDateEnd < ReportDateStart))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            if ((ReportDateEnd - ReportDateStart).TotalDays > 180)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_Error_DateSelectOverHalfYear"));

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_031_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_031");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateStart", "DateTime", 0, ReportDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateEnd", "DateTime", 0, ReportDateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UseTEXT", "nvarchar", 50, (string)GetLocalResourceObject("Str_UseTEXT")));

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

        ReportRowIndex = 1;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ResultDataTable.Rows)
        {
            //工種
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ProcessTypeName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["GoodQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
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