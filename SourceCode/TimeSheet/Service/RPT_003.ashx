<%@ WebHandler Language="C#" Class="RPT_003" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_003 : BasePage
{
    protected DateTime ReportDateStart = DateTime.Parse("1900/01/01");
    protected DateTime ReportDateEnd = DateTime.Parse("1900/01/01");
    protected DateTime ApprovalTimeStart = DateTime.Parse("1900/01/01");
    protected DateTime ApprovalTimeEnd = DateTime.Parse("1900/01/01");
    protected DataSet ExportDataSet = new DataSet();
    protected string AUFNR = string.Empty;
    protected string Brand = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_003.xlsx";
    protected bool IsSAPReportType = false;

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

            if (_context.Request["ApprovalTimeStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["ApprovalTimeStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ApprovalTimeStart))
                    ApprovalTimeStart = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["ApprovalTimeEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["ApprovalTimeEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ApprovalTimeEnd))
                    ApprovalTimeEnd = DateTime.Parse("1900/01/01");
            }

            if (ApprovalTimeStart > ApprovalTimeEnd)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_StartTimeOverEndTime"));

            if (_context.Request["IsSAPReportType"] != null)
                IsSAPReportType = _context.Request["IsSAPReportType"].ToBoolean();

            if (_context.Request["AUFNR"] != null)
                AUFNR = _context.Request["AUFNR"].Trim();
            if (_context.Request["Brand"] != null)
                Brand = _context.Request["Brand"].Trim();

            if (!string.IsNullOrEmpty(AUFNR))
                AUFNR = Util.TS.ToAUFNR(AUFNR);

            LoadExportData();

            if (ExportDataSet.Tables.Count < 1 || ExportDataSet.Tables[0].Rows.Count < 1)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_003_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

            _context.Session.Add(GID, RI);

            ResponseSuccessData(new { Result = true, GUID = GID });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns>報表檔案路徑</returns>
    protected string WritToExcel()
    {
        if (!IsSAPReportType)
        {
            ReportTemplateName = "RPT_003_SummaryDataType.xlsx";

            return WritToExcelBySummaryDataType();
        }
        else
            return WritToExcelBySAPDataType();
    }

    /// <summary>
    /// 將資料寫入至XLS(SAP資料型式)
    /// </summary>
    /// <returns>報表檔案路徑</returns>
    protected string WritToExcelBySAPDataType()
    {
        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        Sheet = ExcelWorkBook.Worksheets["RPT"];

        int ReportRowIndex = 2;
        int ReportColumnIndex = 1;

        string WERKS = global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim();

        DataTable ExportDataTable = ExportDataSet.Tables[0];

        foreach (DataRow Row in ExportDataTable.Rows)
        {
            //工廠
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = WERKS;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //報工日期
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = ((DateTime)Row["ReportDate"]).ToDefaultString("yyyyMMdd");
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工單號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            ReportColumnIndex++;
            //順序
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = "0";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //作業號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VORNR"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //良品數
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["GoodQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //報廢數
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //返工數
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ReWorkQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //人時
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = Math.Round(double.Parse(Row["ResultMinuteForPersonnel"].ToString().Trim()), 0, MidpointRounding.AwayFromZero); /* 因為SAP匯入程式只收整數 ，理論上要從 SP_003 去修改，但是考量以後變化，就先以程式方式四捨五入方式進位處理 */
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //機時
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = Math.Round(double.Parse(Row["ResultMinute"].ToString().Trim()), 0, MidpointRounding.AwayFromZero); /* 因為SAP匯入程式只收整數 ，理論上要從 SP_003 去修改，但是考量以後變化，就先以程式方式四捨五入方式進位處理 */
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //差異原因
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ScrapReasonID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //確認內文
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = string.Empty;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            ReportColumnIndex++;
            //CINFO
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CINFO"].ToString().Trim();
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();

        return WriteToExcelFile(ReportTemplateName);
    }

    /// <summary>
    /// 將資料寫入至XLS(原始資料型式)
    /// </summary>
    /// <returns>報表檔案路徑</returns>
    protected string WritToExcelBySummaryDataType()
    {
        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        Sheet = ExcelWorkBook.Worksheets["RPT1"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        DataTable ExportDataTable = ExportDataSet.Tables[0];

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
            //報工日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
            ReportColumnIndex++;
            //工單號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            ReportColumnIndex++;
            //刻字號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Brand"].ToString().Trim();
            ReportColumnIndex++;
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            ReportColumnIndex++;
            //生產版本號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工序
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LTXA1"].ToString().Trim();
            ReportColumnIndex++;
            //作業號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VORNR"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //機台名稱
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineName"].ToString().Trim();
            ReportColumnIndex++;
            //班別
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["WorkShiftName"].ToString().Trim();
            ReportColumnIndex++;
            //良品數
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["GoodQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //報廢數
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //復判數
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ReWorkQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //報廢原因
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ScrapReasonID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //待修時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["WaitMaintainMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //維修時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //QA檢測時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainQACheckMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //PD檢測時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainPDCheckMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //待料時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["WaitMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //人時
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = Math.Round(double.Parse(Row["ResultMinuteOperator"].ToString().Trim()), 0, MidpointRounding.AwayFromZero);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //機時
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = Math.Round(double.Parse(Row["ResultMinute"].ToString().Trim()), 0, MidpointRounding.AwayFromZero);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();

        /* 明細表 */

        Sheet = ExcelWorkBook.Worksheets["RPT2"];

        ReportRowIndex = 1;
        ReportColumnIndex = 1;

        ExportDataTable = ExportDataSet.Tables[1];

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
            //報工日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
            ReportColumnIndex++;
            //進工日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportTimeStart"], true);
            ReportColumnIndex++;
            //出工日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportTimeEnd"], true);
            ReportColumnIndex++;
            //工單號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            ReportColumnIndex++;
            //刻字號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Brand"].ToString().Trim();
            ReportColumnIndex++;
            //流程卡號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TicketID"].ToString().Trim();
            ReportColumnIndex++;
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            ReportColumnIndex++;
            //生產版本號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工序
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LTXA1"].ToString().Trim();
            ReportColumnIndex++;
            //作業號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VORNR"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //機台名稱
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineName"].ToString().Trim();
            ReportColumnIndex++;
            //班別
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["WorkShiftName"].ToString().Trim();
            ReportColumnIndex++;
            //主要人時係數
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)Row["Coefficient"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //良品數
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["GoodQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //報廢數
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //復判數
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ReWorkQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //報廢原因
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ScrapReasonID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //待修時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["WaitMaintainMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //維修時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //QA檢測時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainQACheckMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //PD檢測時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainPDCheckMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //待料時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["WaitMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //人時
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = Math.Round(double.Parse(Row["ResultMinuteOperator"].ToString().Trim()), 0, MidpointRounding.AwayFromZero);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //延長人時
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = Math.Round(double.Parse(Row["ExtendResultMinuteOperator"].ToString().Trim()), 0, MidpointRounding.AwayFromZero);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //機時
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = Math.Round(double.Parse(Row["ResultMinute"].ToString().Trim()), 0, MidpointRounding.AwayFromZero);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //延長機時
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = Math.Round(double.Parse(Row["ExtendResultMinute"].ToString().Trim()), 0, MidpointRounding.AwayFromZero);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //主要操作員
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["OperatorName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();

        return WriteToExcelFile(ReportTemplateName);
    }

    /// <summary>
    /// 載入匯出資料
    /// </summary>
    protected void LoadExportData()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_003");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(ReportDateStart, "ReportDateStart"));

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(ReportDateEnd, "ReportDateEnd"));

        dbcb.appendParameter(Schema.Attributes["ApprovalTime"].copy(ApprovalTimeStart, "ApprovalTimeStart"));

        dbcb.appendParameter(Schema.Attributes["ApprovalTime"].copy(ApprovalTimeEnd, "ApprovalTimeEnd"));

        dbcb.appendParameter(Util.GetDataAccessAttribute("IsSAPReportType", "bit", 0, IsSAPReportType));

        dbcb.appendParameter(Util.GetDataAccessAttribute("AUFNR", "nvarchar", 50, AUFNR));

        dbcb.appendParameter(Util.GetDataAccessAttribute("Brand", "nvarchar", 50, Brand));

        ExportDataSet = CommonDB.ExecuteSelectQueryToDataSet(dbcb);
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}