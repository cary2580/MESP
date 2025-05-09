<%@ WebHandler Language="C#" Class="RPT_019" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_019 : BasePage
{
    protected DateTime ReportDateStart = DateTime.Parse("1900/01/01");
    protected DateTime ReportDateEnd = DateTime.Parse("1900/01/01");
    protected string MachineID = string.Empty;
    protected string OperatorWorkCode = string.Empty;
    protected string DeptID = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_019.xlsx";
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

            if (!string.IsNullOrEmpty(_context.Request["OperatorWorkCode"]))
                OperatorWorkCode = _context.Request["OperatorWorkCode"].Trim();

            if (!string.IsNullOrEmpty(_context.Request["MachineID"]))
                MachineID = _context.Request["MachineID"].Trim();

            if (!string.IsNullOrEmpty(_context.Request["DeptID"]))
                DeptID = _context.Request["DeptID"].Trim();

            if (ReportDateStart.Year <= 1911 && ReportDateEnd.Year <= 1911 && string.IsNullOrEmpty(OperatorWorkCode) && string.IsNullOrEmpty(MachineID) && string.IsNullOrEmpty(DeptID))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if ((ReportDateStart.Year > 1911 && ReportDateEnd.Year <= 1911) || (ReportDateStart.Year <= 1911 && ReportDateEnd.Year > 1911))
                throw new CustomException((string)GetLocalResourceObject("Str_Error_DateIsNullOrEmpty"));

            if (ReportDateEnd < ReportDateStart)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_019_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_019");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        if (ReportDateStart.Year > 1900)
            dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateStart", "DateTime", 0, ReportDateStart));

        if (ReportDateEnd.Year > 1900)
            dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateEnd", "DateTime", 0, ReportDateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("OperatorWorkCode", "Nvarchar", 50, OperatorWorkCode));

        dbcb.appendParameter(Util.GetDataAccessAttribute("MachineID", "Nvarchar", 50, MachineID));

        dbcb.appendParameter(Util.GetDataAccessAttribute("DeptID", "Nvarchar", 50, DeptID));

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
            //出工日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
            ReportColumnIndex++;
            //操作员工号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["OperatorWorkCode"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //操作员姓名
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["OperatorName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //部门名称
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DeptName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //生产版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            ReportColumnIndex++;
            //机台编号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工序
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LTXA1"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //计件计薪
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["PayrollType"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //良品数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["TotalQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
            ReportColumnIndex++;
            //是否为次要人员
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (bool)Row["IsSecondOperator"] ? (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") : (string)GetGlobalResourceObject("GlobalRes", "Str_No");
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //系数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)Row["Coefficient"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //系数后良品数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)Row["CoefficientAfterGoodQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "#,##0";
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