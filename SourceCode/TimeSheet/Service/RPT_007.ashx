<%@ WebHandler Language="C#" Class="RPT_007" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_007 : BasePage
{
    protected DateTime CreateDateStart = DateTime.Now;
    protected DateTime CreateDateEnd = DateTime.Now;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_007.xlsx";
    protected DataTable ExportDataTable = new DataTable();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["CreateDateStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["CreateDateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out CreateDateStart))
                    CreateDateStart = DateTime.Now;
            }

            if (_context.Request["CreateDateEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["CreateDateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out CreateDateEnd))
                    CreateDateEnd = DateTime.Now;
            }

            if ((CreateDateEnd - CreateDateStart).TotalDays > 365)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_OverOneYear"));

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_007_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_007");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(CreateDateStart, "CreateDateStart"));

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(CreateDateEnd, "CreateDateEnd"));

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
            //開單日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["CreateDate"]);
            ReportColumnIndex++;
            //归属日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
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
            //报废原因
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ScrapReasonName"].ToString().Trim();
            ReportColumnIndex++;
            //缺陷代碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DefectID"].ToString().Trim();
            ReportColumnIndex++;
            //缺陷名稱
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DefectName"].ToString().Trim();
            ReportColumnIndex++;
            //數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Qty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //返工單號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TicketID"].ToString().Trim();
            ReportColumnIndex++;
            //開單製程
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LTXA1"].ToString().Trim();
            ReportColumnIndex++;
            //返工製程
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["FirstLTXA1"].ToString().Trim();
            ReportColumnIndex++;
            //原材料批號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CINFO"].ToString().Trim();
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
            //ED机台
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["EDMachineID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //備註
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Remark"].ToString().Trim();
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