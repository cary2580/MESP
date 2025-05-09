<%@ WebHandler Language="C#" Class="RPT_032" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_032 : BasePage
{
    protected DateTime ReportDate = DateTime.Parse("1900/01/01");
    protected DateTime ReportDateStart = DateTime.Parse("1900/01/01");
    protected DateTime ReportDateEnd = DateTime.Parse("1900/01/01");
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_032.xlsx";
    protected DataSet ExportDataSet = new DataSet();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["ReportMonths"] != null)
            {
                if (!DateTime.TryParse(_context.Request["ReportMonths"].Trim() + "/01", out ReportDate))
                    ReportDate = DateTime.Parse("1900/01/01");
            }

            if (ReportDate.Year < 1911)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            ReportDateStart = ReportDate.AddMonths(-1).AddDays(25);

            ReportDateEnd = ReportDate.AddDays(24);

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_032_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_032");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateStart", "DateTime", 0, ReportDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateEnd", "DateTime", 0, ReportDateEnd));

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

        WriteToExeclRPT001();

        WriteToExeclRPT002();

        WriteToExeclRPT003();

        return WriteToExcelFile(ReportTemplateName);
    }

    /// <summary>
    /// 将按人员汇总得资料写入至XLS的RPT001
    /// </summary>
    protected void WriteToExeclRPT001()
    {
        Sheet = ExcelWorkBook.Worksheets["RPT001"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataSet.Tables[0].Columns)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataSet.Tables[0].Rows)
        {
            //部门名称
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DeptFullName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            //员工工号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["OperatorWorkCode"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //员工姓名
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["OperatorName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //人时
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ResultMinuteByOperator"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 将按人员工作中心汇总得资料写入至XLS的RPT002
    /// </summary>
    protected void WriteToExeclRPT002()
    {
        Sheet = ExcelWorkBook.Worksheets["RPT002"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataSet.Tables[1].Columns)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataSet.Tables[1].Rows)
        {
            //工作中心ID
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ARBPL"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工作中心说明
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ARBPL_KTEXT"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            //部门名称
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DeptFullName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            //员工工号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["OperatorWorkCode"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //员工姓名
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["OperatorName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //人时
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ResultMinuteByOperatorAndARBPL"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 将班长技术员对应工作中心占比写入至XLS的RPT003
    /// </summary>
    protected void WriteToExeclRPT003()
    {
        Sheet = ExcelWorkBook.Worksheets["RPT003"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataSet.Tables[2].Columns)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataSet.Tables[2].Rows)
        {
            //员工工号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["OperatorWorkCode"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //员工姓名
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["OperatorName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工作中心ID
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ARBPL"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工作中心说明
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ARBPL_KTEXT"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            // 员工工作中心占比
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["OperatorQtyRate"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
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