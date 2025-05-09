<%@ WebHandler Language="C#" Class="RPT_009" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_009 : BasePage
{
    protected DateTime ReportDateStart = DateTime.Parse("1900/01/01");
    protected DateTime ReportDateEnd = DateTime.Parse("1900/01/01");
    protected string MachineID = string.Empty;
    protected string DeviceID = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_009.xlsx";
    protected bool IsSumReportDate = false;
    protected bool IsChartDataType = false;
    protected DataSet ExportDataSet = new DataSet();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["IsSumReportDate"] != null)
                IsSumReportDate = _context.Request["IsSumReportDate"].ToBoolean();

            if (_context.Request["IsChartDataType"] != null)
                IsChartDataType = _context.Request["IsChartDataType"].ToBoolean();

            if (_context.Request["ReportDateStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["ReportDateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDateStart))
                    ReportDateStart = DateTime.Now;
            }

            if (_context.Request["ReportDateEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["ReportDateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDateEnd))
                    ReportDateEnd = DateTime.Now;
            }

            if (ReportDateStart.Year < 1911 || ReportDateEnd.Year < 1911)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if (_context.Request["MachineID"] != null)
                MachineID = _context.Request["MachineID"].Trim();

            if (!string.IsNullOrEmpty(MachineID))
            {
                DeviceID = Util.TS.GetDeviceID(MachineID);

                if (string.IsNullOrEmpty(DeviceID))
                    throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_DeviceID"));
            }

            if (IsChartDataType)
            {
                if (string.IsNullOrEmpty(DeviceID))
                    throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_DeviceID"));
            }

            LoadExportData();

            if (!IsChartDataType)
            {
                string SaveFullPath = WritToExcel();

                string GID = NewGuid;

                DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_009_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

                _context.Session.Add(GID, RI);

                ResponseSuccessData(new { Result = true, GUID = GID });
            }
            else
            {
                if (ExportDataSet.Tables[0].Rows.Count < 1)
                    throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

                ResponseSuccessData(new
                {
                    ChartTilte = ExportDataSet.Tables[0].Rows[0]["MachineName"].ToString().Trim(),
                    ChartValue = GetChartData(),
                    AverageValueKey = "AverageValue",
                    DateFormatter = System.Threading.Thread.CurrentThread.CurrentUICulture.Name.ToLower() == "pl" ? "DD.MM" : "MM/DD"
                }); ;
            }
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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_009");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateStart", "DateTime", 0, ReportDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateEnd", "DateTime", 0, ReportDateEnd));

        if (!string.IsNullOrEmpty(DeviceID))
            dbcb.appendParameter(Util.GetDataAccessAttribute("DeviceID", "Nvarchar", 50, DeviceID));

        if (!IsChartDataType)
            dbcb.appendParameter(Util.GetDataAccessAttribute("IsSumReportDate", "bit", 0, IsSumReportDate));

        ExportDataSet = CommonDB.ExecuteSelectQueryToDataSet(dbcb);
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns></returns>
    protected string WritToExcel()
    {
        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        WriteToRPT1();

        WriteToRPT2();

        WriteToRPT3();

        WriteToRPT4();

        WriteToRPT5();

        return WriteToExcelFile(ReportTemplateName);
    }

    /// <summary>
    /// 輸出RPT1
    /// </summary>
    protected void WriteToRPT1()
    {
        DataTable ExportDataTable = ExportDataSet.Tables[0];

        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        Sheet = ExcelWorkBook.Worksheets["RPT1"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataTable.Columns)
        {
            if ((string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataTable.Rows)
        {
            if (ExportDataTable.Columns.Contains("ReportDate"))
            {
                //日期
                SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
                ReportColumnIndex++;
            }

            //機台
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineName"].ToString().Trim();
            ReportColumnIndex++;
            //设备归属车间
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["SectionName"].ToString().Trim();
            ReportColumnIndex++;
            //稼動率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ActivationRate"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            if ((decimal)Row["ActivationRate"] > 1)
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;
            ReportColumnIndex++;
            //操作效率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["OperateRate"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            if ((decimal)Row["OperateRate"] > 1)
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;
            ReportColumnIndex++;
            //良率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["YieldRate"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            if ((decimal)Row["YieldRate"] > 1)
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;
            ReportColumnIndex++;
            //OEE
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["OEERate"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            if ((decimal)Row["OEERate"] > 1)
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 輸出RPT2
    /// </summary>
    protected void WriteToRPT2()
    {
        DataTable ExportDataTable = ExportDataSet.Tables[1];

        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        Sheet = ExcelWorkBook.Worksheets["RPT2"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataTable.Columns)
        {
            if ((string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataTable.Rows)
        {
            if (ExportDataTable.Columns.Contains("ReportDate"))
            {
                //日期
                SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
                ReportColumnIndex++;
            }
            //流程卡號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TicketID"].ToString().Trim();
            ReportColumnIndex++;
            //機台
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineName"].ToString().Trim();
            ReportColumnIndex++;
            //设备归属车间
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["SectionName"].ToString().Trim();
            ReportColumnIndex++;
            //良品數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["GoodQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //標準機器工時
            //worksheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["VGW02"];
            //worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
            //worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            //worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
            //ReportColumnIndex++;
            //良品數量 * 節拍後
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["GoodQtyVGW02"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //報工時間(扣除維修相關時間後)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ResultMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //維修時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //待維修時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["WaitMaintainMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //QA檢查時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainQACheckMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //PD檢查時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["MaintainPDCheckMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //待料時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["WaitMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //進工時間
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportTimeStart"], true);
            ReportColumnIndex++;
            //出工時間
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportTimeEnd"], true);
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 輸出RPT3
    /// </summary>
    protected void WriteToRPT3()
    {
        DataTable ExportDataTable = ExportDataSet.Tables[2];

        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        Sheet = ExcelWorkBook.Worksheets["RPT3"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataTable.Columns)
        {
            if ((string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataTable.Rows)
        {
            if (ExportDataTable.Columns.Contains("ReportDate"))
            {
                //日期
                SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
                ReportColumnIndex++;
            }
            //機台
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineName"].ToString().Trim();
            ReportColumnIndex++;
            //设备归属车间
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["SectionName"].ToString().Trim();
            ReportColumnIndex++;
            //ResultMinute
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ResultMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //實際工作時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ActualWorkMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //維修總時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["TotalMaintainMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //設備班會檢點時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["DeviceDailyWorkMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //維修待料總時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["TotalWaitMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //計畫工作時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["PlanWorkMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //稼動率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ActivationRate"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            if ((decimal)Row["ActivationRate"] > 1)
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 輸出RPT4
    /// </summary>
    protected void WriteToRPT4()
    {
        DataTable ExportDataTable = ExportDataSet.Tables[3];

        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        Sheet = ExcelWorkBook.Worksheets["RPT4"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataTable.Columns)
        {
            if ((string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataTable.Rows)
        {
            if (ExportDataTable.Columns.Contains("ReportDate"))
            {
                //日期
                SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
                ReportColumnIndex++;
            }
            //機台
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineName"].ToString().Trim();
            ReportColumnIndex++;
            //设备归属车间
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["SectionName"].ToString().Trim();
            ReportColumnIndex++;
            //良品數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["GoodQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //良品數量 * 節拍後
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["GoodQtyVGW02"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //實際工作時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ActualWorkMinute"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //操作效率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["OperateRate"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            if ((decimal)Row["OperateRate"] > 1)
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 輸出RPT5
    /// </summary>
    protected void WriteToRPT5()
    {
        DataTable ExportDataTable = ExportDataSet.Tables[4];

        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        Sheet = ExcelWorkBook.Worksheets["RPT5"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataTable.Columns)
        {
            if ((string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataTable.Rows)
        {
            if (ExportDataTable.Columns.Contains("ReportDate"))
            {
                //日期
                SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
                ReportColumnIndex++;
            }
            //機台
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineName"].ToString().Trim();
            ReportColumnIndex++;
            //设备归属车间
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["SectionName"].ToString().Trim();
            ReportColumnIndex++;
            //良品數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["GoodQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //總數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["TotalQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //良率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["YieldRate"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            if ((decimal)Row["YieldRate"] > 1)
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 取得圖表資料
    /// </summary>
    protected List<dynamic> GetChartData()
    {
        List<dynamic> Result = new List<dynamic>();

        List<dynamic> ActivationRateList = new List<dynamic>();
        List<dynamic> OperateRateList = new List<dynamic>();
        List<dynamic> YieldRateList = new List<dynamic>();
        List<dynamic> OEERateList = new List<dynamic>();

        DateTime JavaScriptDateTime = new DateTime(1970, 1, 1, 0, 0, 0);

        EnumerableRowCollection<DataRow> ReportRows = ExportDataSet.Tables[0].AsEnumerable();

        var ReportDateList = ReportRows.GroupBy(Row => Row["ReportDate"]).Select(item => item.Key).ToList();

        foreach (DateTime ReportDate in ReportDateList)
        {
            double xValue = (DateTime.Parse(ReportDate.ToDefaultString() + " 01:00:00").ToUniversalTime() - JavaScriptDateTime).TotalMilliseconds;

            dynamic ActivationRateValue = new System.Dynamic.ExpandoObject();
            ActivationRateValue.y = ReportRows.Where(Row => (DateTime)Row["ReportDate"] == ReportDate).Select(Row => (decimal)Row["ActivationRate"]).FirstOrDefault();
            ActivationRateValue.x = xValue;
            ActivationRateList.Add(ActivationRateValue);

            dynamic OperateRateValue = new System.Dynamic.ExpandoObject();
            OperateRateValue.y = ReportRows.Where(Row => (DateTime)Row["ReportDate"] == ReportDate).Select(Row => (decimal)Row["OperateRate"]).FirstOrDefault();
            OperateRateValue.x = xValue;
            OperateRateList.Add(OperateRateValue);

            dynamic YieldRateValue = new System.Dynamic.ExpandoObject();
            YieldRateValue.y = ReportRows.Where(Row => (DateTime)Row["ReportDate"] == ReportDate).Select(Row => (decimal)Row["YieldRate"]).FirstOrDefault();
            YieldRateValue.x = xValue;
            YieldRateList.Add(YieldRateValue);

            dynamic OEERateValue = new System.Dynamic.ExpandoObject();
            OEERateValue.y = ReportRows.Where(Row => (DateTime)Row["ReportDate"] == ReportDate).Select(Row => (decimal)Row["OEERate"]).FirstOrDefault();
            OEERateValue.x = xValue;
            OEERateList.Add(OEERateValue);
        }

        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_009");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateStart", "DateTime", 0, ReportDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateEnd", "DateTime", 0, ReportDateEnd));

        if (!string.IsNullOrEmpty(DeviceID))
            dbcb.appendParameter(Util.GetDataAccessAttribute("DeviceID", "Nvarchar", 50, DeviceID));

        dbcb.appendParameter(Util.GetDataAccessAttribute("IsSumReportDate", "bit", 0, true));

        ExportDataSet = CommonDB.ExecuteSelectQueryToDataSet(dbcb);

        DataTable ReporDataTable = ExportDataSet.Tables[0];

        var OEE = Util.ConvertToDynamic(new Util.ChartSeriesOption() { name = (string)GetLocalResourceObject("Str_ChartLineName_OEERate"), color = "#FF8F59", data = OEERateList });

        OEE.AverageValue = (decimal)ReporDataTable.Rows[0]["OEERate"];

        Result.Add(OEE);

        var Activation = Util.ConvertToDynamic(new Util.ChartSeriesOption() { name = (string)GetLocalResourceObject("Str_ChartLineName_ActivationRate"), color = "#A5A552", data = ActivationRateList });

        Activation.AverageValue = (decimal)ReporDataTable.Rows[0]["ActivationRate"];

        Result.Add(Activation);

        var Operate = Util.ConvertToDynamic(new Util.ChartSeriesOption() { name = (string)GetLocalResourceObject("Str_ChartLineName_OperateRate"), color = "#66B3FF", data = OperateRateList });

        Operate.AverageValue = (decimal)ReporDataTable.Rows[0]["OperateRate"];

        Result.Add(Operate);

        var Quality = Util.ConvertToDynamic(new Util.ChartSeriesOption() { name = (string)GetLocalResourceObject("Str_ChartLineName_YieldRate"), color = "#6FB7B7", data = YieldRateList });

        Quality.AverageValue = (decimal)ReporDataTable.Rows[0]["YieldRate"];

        Result.Add(Quality);

        return Result;
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}