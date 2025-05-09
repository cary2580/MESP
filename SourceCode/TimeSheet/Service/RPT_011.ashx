<%@ WebHandler Language="C#" Class="RPT_011" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_011 : BasePage
{
    protected DateTime DateStart = DateTime.Parse("1900/01/01");
    protected DateTime DateEnd = DateTime.Parse("1900/01/01");
    protected string ProcessTypeID = string.Empty;
    protected string ProcessTypeName = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_011.xlsx";
    protected DataSet ExportDataSet = new DataSet();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["DateStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["DateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out DateStart))
                    DateStart = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["DateEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["DateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out DateEnd))
                    DateEnd = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["ProcessTypeID"] != null)
                ProcessTypeID = _context.Request["ProcessTypeID"].Trim();

            if (string.IsNullOrEmpty(ProcessTypeID))
                throw new CustomException((string)GetLocalResourceObject("Str_Error_ProcessTypeID"));

            if ((DateEnd < DateStart) || DateEnd.Year < 1911 || DateStart.Year < 1911)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            if ((DateEnd - DateStart).TotalDays > 31)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_OverOneMonth"));

            ProcessTypeName = LoadProcessTypeName();

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_011_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_011");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("ProcessTypeID", "Int", 0, ProcessTypeID));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportTimeStart", "DateTime", 0, DateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportTimeEnd", "DateTime", 0, DateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        ExportDataSet = CommonDB.ExecuteSelectQueryToDataSet(dbcb);
    }

    /// <summary>
    /// 捞出ProcessTypeName
    /// </summary>
    /// <returns>回传工种名称</returns>
    protected string LoadProcessTypeName()
    {
        String Query = "Select CodeName From T_Code Where CodeType = 'TS_ProcessTypeID' And CodeID = @CodeID And UICulture = @UICulture";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Code"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["CodeID"].copy(ProcessTypeID));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        return CommonDB.ExecuteScalar(dbcb).ToString().Trim();
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
    /// 将返工得资料写入至XLS的RPT001
    /// </summary>
    /// <returns></returns>
    protected void WriteToExeclRPT001()
    {
        Sheet = ExcelWorkBook.Worksheets["RPT001"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        ReportColumnIndex = 8;

        Sheet.Range[ReportRowIndex, ReportRowIndex, ReportRowIndex, ReportColumnIndex].Merge();

        ReportColumnIndex = 1;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_TitleRPT001");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;

        ReportColumnIndex = 8;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_QueryConditions");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 2;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportTimeStart");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 3;

        SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], DateStart);
        ReportColumnIndex = 4;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportTimeEnd");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 5;

        SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], DateEnd);

        ReportColumnIndex = 6;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_ProcessTypeName");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 7;
        Sheet.Range[ReportRowIndex, ReportColumnIndex, ReportRowIndex, ReportColumnIndex + 1].Merge();

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = ProcessTypeName;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 8;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportRowIndex = 3;
        ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataSet.Tables[0].Columns)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 4;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataSet.Tables[0].Rows)
        {
            //物料代码
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MATNR"].ToString().Trim();
            ReportColumnIndex++;
            //物料说明
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MAKTX"].ToString().Trim();
            ReportColumnIndex++;
            //总产量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["TotalQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //物料总产量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["TotalQtyByMNTNR"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //缺陷名称
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DefectName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //缺陷名称对应返工数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["DefectQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工种类型
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ProcessTypeName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //返工率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ReWorkRate"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 将报废得资料写入至XLS的RPT002
    /// </summary>
    /// <returns></returns>
    protected void WriteToExeclRPT002()
    {
        Sheet = ExcelWorkBook.Worksheets["RPT002"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        ReportColumnIndex = 9;
        Sheet.Range[ReportRowIndex, ReportRowIndex, ReportRowIndex, ReportColumnIndex].Merge();

        ReportColumnIndex = 1;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_TitleRPT002");

        ReportColumnIndex = 9;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_QueryConditions");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 2;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportTimeStart");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 3;
        SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], DateStart);

        ReportColumnIndex = 4;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportTimeEnd");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 5;
        SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], DateEnd);

        ReportColumnIndex = 6;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_ProcessTypeName");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 7;
        Sheet.Range[ReportRowIndex, ReportColumnIndex, ReportRowIndex, ReportColumnIndex + 2].Merge();

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = ProcessTypeName;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 8;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 9;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportRowIndex = 3;
        ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataSet.Tables[1].Columns)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 4;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataSet.Tables[1].Rows)
        {
            //物料代码
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MATNR"].ToString().Trim();
            ReportColumnIndex++;
            //物料说明
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MAKTX"].ToString().Trim();
            ReportColumnIndex++;
            //总产量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["TotalQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //物料总产量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["TotalQtyByMNTNR"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRate"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //报废原因
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ScrapReasonName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //报废原因对应报废数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyByScrapReasonName"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //缺陷名称
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DefectName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //缺陷名称对应报废数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQtyDetailQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 将未判定明细资料写入至XLS的RPT003
    /// </summary>
    /// <returns></returns>
    protected void WriteToExeclRPT003()
    {
        Sheet = ExcelWorkBook.Worksheets["RPT003"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        ReportColumnIndex = 7;
        Sheet.Range[ReportRowIndex, ReportRowIndex, ReportRowIndex, ReportColumnIndex].Merge();

        ReportColumnIndex = 1;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_TitleRPT003");

        ReportColumnIndex = 7;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_QueryConditions");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 2;

        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportTimeStart");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 3;
        SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], DateStart);

        ReportColumnIndex = 4;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ReportTimeEnd");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 5;
        SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], DateEnd);

        ReportColumnIndex = 6;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_ProcessTypeName");
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 7;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = ProcessTypeName;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportColumnIndex = 7;
        Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        ReportRowIndex = 3;
        ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataSet.Tables[2].Columns)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 4;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataSet.Tables[2].Rows)
        {
            //物料代码
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MATNR"].ToString().Trim();
            ReportColumnIndex++;
            //物料说明
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MAKTX"].ToString().Trim();
            ReportColumnIndex++;
            //总产量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["TotalQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //物料总产量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["TotalQtyByMNTNR"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //报废率
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ScrapRate"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //缺陷名称
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DefectName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //未判定数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["NotJudgmentQty"];
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