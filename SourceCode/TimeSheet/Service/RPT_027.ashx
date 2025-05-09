<%@ WebHandler Language="C#" Class="RPT_027" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_027 : BasePage
{
    protected DataSet ExportDataSet = new DataSet();
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_027.xlsx";
    protected bool IsSynchronizeData = false;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["IsSynchronizeData"] != null)
                IsSynchronizeData = _context.Request["IsSynchronizeData"].ToBoolean();

            LoadExportDataSet();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_027_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

            _context.Session.Add(GID, RI);

            ResponseSuccessData(new { Result = true, GUID = GID });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }


    /// <summary>
    /// 載入匯出資料集
    /// </summary>
    protected void LoadExportDataSet()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        //if (IsSynchronizeData)
        //{
        //    /* 先將有報工資料，並且工單尚未關結的工單再次更新一下狀態資料 */
        //    string Query = @"Select T_TSSAPAFKO.AUFNR
        //                From T_TSTicket 
        //                Inner Join T_TSTicketResult On T_TSTicket.TicketID = T_TSTicketResult.TicketID
        //                Inner Join T_TSSAPAFKO On T_TSSAPAFKO.AUFNR = T_TSTicket.AUFNR
        //                Where [STATUS] <> @CloseStatus And ((AUART in ('ZP21','ZR20') And [STATUS] in (@IssuedStatus,@InProcessStatus)) Or [STATUS] = @InProcessStatus) And Datediff(day,ApprovalTime,getdate()) > -1";

        //    Query += " Group By T_TSSAPAFKO.AUFNR";

        //    dbcb.CommandText = Query;

        //    dbcb.appendParameter(Util.GetDataAccessAttribute("CloseStatus", "nvarchar", 50, ((short)Util.TS.MOStatus.Closed).ToString()));
        //    dbcb.appendParameter(Util.GetDataAccessAttribute("IssuedStatus", "nvarchar", 50, ((short)Util.TS.MOStatus.Issued).ToString()));
        //    dbcb.appendParameter(Util.GetDataAccessAttribute("InProcessStatus", "nvarchar", 50, ((short)Util.TS.MOStatus.InProcess).ToString()));

        //    DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        //    var AUFNRList = DT.AsEnumerable().Select(Row => Row["AUFNR"].ToString().Trim()).ToList();

        //    Synchronize_SAPData.MO.SynchronizeData_AFKO(AUFNRList);

        //    Synchronize_SAPData.MO.SynchronizeData_JEST(AUFNRList);
        //}

        dbcb = new DbCommandBuilder("SP_TS_RPT_027");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        ExportDataSet = CommonDB.ExecuteSelectQueryToDataSet(dbcb);
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns></returns>
    protected string WritToExcel()
    {
        if (ExportDataSet.Tables[0].Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

        DataTable ExportDataTable = ExportDataSet.Tables[0];

        DataTable ExportDataGroupByTable = ExportDataSet.Tables[1];

        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        Sheet = ExcelWorkBook.Worksheets["RPT1"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        foreach (DataColumn Column in ExportDataGroupByTable.Columns)
        {
            if ((string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName) == null)
                continue;

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName_" + Column.ColumnName);
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        ReportRowIndex = 2;
        ReportColumnIndex = 1;

        foreach (DataRow Row in ExportDataGroupByTable.Rows)
        {
            //工種
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["ProcessTypeName"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            ReportColumnIndex++;
            //生產版本號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Qty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        SetReportDefaultStyle();

        Sheet = ExcelWorkBook.Worksheets["RPT2"];

        ReportRowIndex = 1;
        ReportColumnIndex = 1;

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
            //工單號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            ReportColumnIndex++;
            //刻字號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["Brand"].ToString().Trim();
            ReportColumnIndex++;
            //投料日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportTimeEnd"]);
            ReportColumnIndex++;
            //物料代碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["PLNBEZ"].ToString().Trim();
            ReportColumnIndex++;
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["TEXT1"].ToString().Trim();
            ReportColumnIndex++;
            //生產版本號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //SAP批次號
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["CHARG"].ToString().Trim();
            ReportColumnIndex++;
            //工序
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VORNR"].ToString().Trim() + "-" + Row["LTXA1"].ToString().Trim();
            ReportColumnIndex++;
            //良品數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["GoodQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //報廢數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["ScrapQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)Row["Qty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //工單標準結案時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["AUFNRStdWorkDay"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //實際工單流轉時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["ActualDay"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //工單關結差異時間
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (double)(decimal)Row["DifferenceDay"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
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