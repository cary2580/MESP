<%@ WebHandler Language="C#" Class="RPT_006" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_006 : BasePage
{
    protected DateTime CreateDateStart = DateTime.Now;
    protected DateTime CreateDateEnd = DateTime.Now;
    protected string AUFNR = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_006.xlsx";
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
                    CreateDateEnd = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["AUFNR"] != null)
                AUFNR = _context.Request["AUFNR"].Trim();

            if ((CreateDateEnd - CreateDateStart).TotalDays > 365)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_OverOneYear"));

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_006_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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

        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_006");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(CreateDateStart, "CreateDateStart"));

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(CreateDateEnd, "CreateDateEnd"));

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

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
            //叫修日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["CreateDate"]);
            ReportColumnIndex++;
            //工单号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            ReportColumnIndex++;
            //物料名稱
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MAKTX"].ToString().Trim();
            ReportColumnIndex++;
            //維修單號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MaintainID"].ToString().Trim();
            ReportColumnIndex++;
            //機台編號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineID"].ToString().Trim();
            ReportColumnIndex++;
            //機台位置
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineLocation"].ToString().Trim();
            ReportColumnIndex++;
            //是否報停
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (bool)Row["IsAlert"] ? (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") : (string)GetGlobalResourceObject("GlobalRes", "Str_No");
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //維修次數
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainCount"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //待修時間
            string WaitMinuteReportColumnName = GetColumnLetter(ReportColumnIndex);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["WaitMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //總維修機時
            string MaintainMinuteByMachineReportColumnName = GetColumnLetter(ReportColumnIndex);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainMinuteByMachine"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //總維修人時
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //QA检测时间
            string QACheckMinuteReportColumnName = GetColumnLetter(ReportColumnIndex);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["QACheckMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //PD检测时间
            string PDCheckMinuteReportColumnName = GetColumnLetter(ReportColumnIndex);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["PDCheckMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //总停机时间
            string currentFormula = WaitMinuteReportColumnName + ReportRowIndex.ToString() + "+" + MaintainMinuteByMachineReportColumnName + ReportRowIndex.ToString() + "+" + QACheckMinuteReportColumnName + ReportRowIndex.ToString() + "+" + PDCheckMinuteReportColumnName + ReportRowIndex.ToString();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TotalStopMinute"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Formula = currentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //維修人員
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["OperatorName"].ToString().Trim();
            ReportColumnIndex++;
            //維修組別
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["OperatorDeptName"].ToString().Trim();
            ReportColumnIndex++;
            //工序
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LTXA1"].ToString().Trim();
            ReportColumnIndex++;
            //故障代碼(初判)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["FaultNameByFirstTime"].ToString().Trim();
            ReportColumnIndex++;
            //故障代碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["FaultName"].ToString().Trim();
            ReportColumnIndex++;
            //維修過程簡要說明
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Remark1"].ToString().Trim();
            ReportColumnIndex++;
            //維修前說明
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Remark2"].ToString().Trim();
            ReportColumnIndex++;
            //維修後說明
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Remark3"].ToString().Trim();
            ReportColumnIndex++;
            //是否取消维修
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (bool)Row["IsCancel"] ? (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") : (string)GetGlobalResourceObject("GlobalRes", "Str_No");
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