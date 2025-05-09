<%@ WebHandler Language="C#" Class="RPT_021" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_021 : BasePage
{
    protected DateTime ScanTimeStart = DateTime.Parse("1900/01/01");
    protected DateTime ScanTimeEnd = DateTime.Parse("1900/01/01");
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_021.xlsx";
    protected string NormalStatusIDList = string.Empty;
    protected string CancelStatusIDList = string.Empty;
    protected DataSet ExportDataSet = new DataSet();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["ScanTimeStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["ScanTimeStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ScanTimeStart))
                    ScanTimeStart = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["ScanTimeEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["ScanTimeEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ScanTimeEnd))
                    ScanTimeEnd = DateTime.Parse("1900/01/01");
            }

            if (ScanTimeStart.Year < 1911 || ScanTimeEnd.Year < 1911 || (ScanTimeEnd < ScanTimeStart))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            if ((ScanTimeEnd - ScanTimeStart).TotalDays > 180)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_OverHalfYear"));

            //正常和备用条码List
            List<short> NormalStatusID = new List<short>();

            NormalStatusID.Add((short)Util.TS.LableScanStatus.NormalLable);

            NormalStatusID.Add((short)Util.TS.LableScanStatus.StandbyLable);

            NormalStatusIDList = string.Join("|", NormalStatusID);

            //作废和多余条码List
            List<short> CancelStatusID = new List<short>();

            CancelStatusID.Add((short)Util.TS.LableScanStatus.CancelLable);

            CancelStatusID.Add((short)Util.TS.LableScanStatus.ExcessiveLable);

            CancelStatusIDList = string.Join("|", CancelStatusID);

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_021_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_021");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("ScanTimeStart", "DateTime", 0, ScanTimeStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ScanTimeEnd", "DateTime", 0, ScanTimeEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        dbcb.appendParameter(Util.GetDataAccessAttribute("NormalStatusIDList", "nvarchar", 50, NormalStatusIDList));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CancelStatusIDList", "nvarchar", 50, CancelStatusIDList));

        dbcb.appendParameter(Util.GetDataAccessAttribute("NormalStatusID", "nvarchar", 50, ((short)Util.TS.LableScanStatus.NormalLable).ToString()));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CancelStatusID", "nvarchar", 50, ((short)Util.TS.LableScanStatus.CancelLable).ToString()));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ExcessiveStatusID", "nvarchar", 50, ((short)Util.TS.LableScanStatus.ExcessiveLable).ToString()));

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
    /// 将汇总得资料写入至XLS的RPT001
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
            //领用数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["TotalLableIDQty"];
            ReportColumnIndex++;
            //耗用数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["NormalAndStandByLableIDQty"];
            ReportColumnIndex++;
            //报废数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["CancelAndExcessiveLableIDQty"];
            ReportColumnIndex++;
            //标签扫描条码起始
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["FirstLableID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //标签扫描条码迄止
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LastLableID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //成品箱数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["BoxNoQty"];
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 将分类汇总得资料写入至XLS的RPT002
    /// </summary>
    protected void WriteToExeclRPT002()
    {
        Sheet = ExcelWorkBook.Worksheets["RPT002"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataSet.Tables[1].Columns)
        {
            if (GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataSet.Tables[1].Rows)
        {
            //扫描归属日期
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ScanTimeByDay"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //机台编号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //生产版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //班别
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["WorkShiftName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //正常条码数量（Status = 1 Or Status = 3）
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["NormalAndStandLableIDQtyByClass"];
            ReportColumnIndex++;
            //标签扫描条码起始(Status = 1的第一个条码)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["FirstLableIDByClass"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //标签扫描条码迄止(Status = 1的最后一个条码)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LastLableIDByClass"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //报废条码（Status = 2的条码分类汇总）
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["CancelLableIDQtyByClass"];
            ReportColumnIndex++;
            //多余条码（Status = 4的条码分类汇总）
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ExcessiveLableIDQtyByClass"];
            ReportColumnIndex++;
            //成品箱数
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["BoxNoQtyByClass"];
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 将明细得资料写入至XLS的RPT003
    /// </summary>
    protected void WriteToExeclRPT003()
    {
        Sheet = ExcelWorkBook.Worksheets["RPT003"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataSet.Tables[2].Columns)
        {
            if (GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataSet.Tables[2].Rows)
        {
            //扫描日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ScanTime"], true);
            ReportColumnIndex++;
            //扫描归属日期
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ScanTimeByDay"].ToString().Trim();
            ReportColumnIndex++;
            //机台编号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MachineID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //箱号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["BoxNo"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //生产版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //标签条码
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LableID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //条码状态
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CodeName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //替换条码
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ChildLableID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

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