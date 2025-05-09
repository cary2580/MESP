<%@ WebHandler Language="C#" Class="RPT_002" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_002 : BasePage
{
    protected DateTime CreateDateStart = DateTime.Parse("1900/01/01");
    protected DateTime CreateDateEnd = DateTime.Parse("1900/01/01");
    protected string CreatePalletWorkCode = string.Empty;
    protected int CreateAccountID = -1;
    protected string MAKTX = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\WM\ReportTemplate\");
    protected string ReportTemplateName = "RPT_002.xlsx";
    protected DataSet ExportDataSet = new DataSet();

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

            if (!string.IsNullOrEmpty(_context.Request["CreatePalletWorkCode"]))
            {
                CreatePalletWorkCode = _context.Request["CreatePalletWorkCode"].Trim();

                CreateAccountID = BaseConfiguration.GetAccountID(CreatePalletWorkCode);

                if (CreateAccountID < 1)
                    throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));
            }

            if (!string.IsNullOrEmpty(_context.Request["MAKTX"]))
            {
                MAKTX = _context.Request["MAKTX"].Trim();
            }

            if (CreateDateStart.Year < 1911 || CreateDateEnd.Year < 1911 || (CreateDateEnd < CreateDateStart))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"));

            if ((CreateDateEnd - CreateDateStart).TotalDays > 30)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_DateSelectOverThirtyDay"));

            LoadExportData();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_002_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_WM_RPT_002");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("CreateDateStart", "DateTime", 0, CreateDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CreateDateEnd", "DateTime", 0, CreateDateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CreateAccountID", "int", 0, CreateAccountID));

        dbcb.appendParameter(Util.GetDataAccessAttribute("MAKTX", "nvarchar", 50, MAKTX));

        ExportDataSet = CommonDB.ExecuteSelectQueryToDataSet(dbcb);
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns></returns>
    protected string WritToExcel()
    {
        DataTable ExportDataTable = ExportDataSet.Tables[0];

        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        RPT001(ExportDataTable);

        ExportDataTable = ExportDataSet.Tables[1];

        RPT002(ExportDataTable);

        return WriteToExcelFile(ReportTemplateName);
    }

    /// <summary>
    /// 指定資料表將資料寫入至XLS的RPT002
    /// </summary>
    protected void RPT001(DataTable ExportDataTable)
    {
        Sheet = ExcelWorkBook.Worksheets["RPT001"];

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
            //異動類型
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MoveType"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //憑證類型
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DocType"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //群組號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["GroupNo"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工單/採購訂單號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //行項目
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ItemNo"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
            ReportColumnIndex++;
            //入庫數量(輔助數量)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Qty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //單位ID(輔助單位)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["PCS"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //計量單位數量(雙單位用，非必填)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["PCSQty"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //計量單位(雙單位用，非必填)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["PCS1"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //儲存地點ID
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LGORT"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //物料號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MATNR"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //憑證日期(YYYYMMDD)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CreateDate1"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //過賬日期(YYYYMMDD)
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CreateDate2"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //庫存類型ID
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["StockType"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //行項目備註
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ItemNoRemark"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //備註1
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Remark"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //批次號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Batch"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //呆滯日期
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["INDATE"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //刻字號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Brand"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //溶解番號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DISSCO"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //製令批號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CINFO"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //序號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["PalletNo"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();
    }

    /// <summary>
    /// 指定資料表將資料寫入至XLS的RPT002
    /// </summary>
    protected void RPT002(DataTable ExportDataTable)
    {
        Sheet = ExcelWorkBook.Worksheets["RPT002"];

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
            //栈板号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["PalletNo"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //儲存地點ID
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["LGORT"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //物料號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MATNR"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工單号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //箱号
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["BoxNo"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //刻字號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Brand"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //入庫數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Qty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //製令批號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CINFO"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //出货日期
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DeliveryDate"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //出货数量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DeliveryQty"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //出货地点
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["DeliveryLocation"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //最后报工日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["LastReportDate"]);
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