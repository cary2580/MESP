<%@ WebHandler Language="C#" Class="RPT_004" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Spire.Xls;

public class RPT_004 : BasePage
{
    protected DataSet ExportDataSet = new DataSet();
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_004.xlsx";
    protected DateTime CreatDateStart = DateTime.Parse("1900/01/01");
    protected DateTime CreatDateEnd = DateTime.Parse("1900/01/01");

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["CreatDateStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["CreatDateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out CreatDateStart))
                    CreatDateStart = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["CreatDateEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["CreatDateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out CreatDateEnd))
                    CreatDateEnd = DateTime.Parse("1900/01/01");
            }

            LoadExportDataSet();

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_004_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

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
        /* 先將有報工資料，並且工單尚未關結的工單再次更新一下狀態資料 */

        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Query = @"Select T_TSSAPAFKO.AUFNR
                        From T_TSTicket 
                        Inner Join T_TSTicketResult On T_TSTicket.TicketID = T_TSTicketResult.TicketID
                        Inner Join T_TSSAPAFKO On T_TSSAPAFKO.AUFNR = T_TSTicket.AUFNR
                        Where [STATUS] <> @CloseStatus And ((AUART in ('ZP21','ZR20') And [STATUS] in (@IssuedStatus,@InProcessStatus)) Or [STATUS] = @InProcessStatus) And Datediff(day,ApprovalTime,getdate()) > -1";

        Query += " Group By T_TSSAPAFKO.AUFNR";

        dbcb.CommandText = Query;

        dbcb.appendParameter(Util.GetDataAccessAttribute("CloseStatus", "nvarchar", 50, ((short)Util.TS.MOStatus.Closed).ToString()));
        dbcb.appendParameter(Util.GetDataAccessAttribute("IssuedStatus", "nvarchar", 50, ((short)Util.TS.MOStatus.Issued).ToString()));
        dbcb.appendParameter(Util.GetDataAccessAttribute("InProcessStatus", "nvarchar", 50, ((short)Util.TS.MOStatus.InProcess).ToString()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        var AUFNRList = DT.AsEnumerable().Select(Row => Row["AUFNR"].ToString().Trim()).ToList();

        //Synchronize_SAPData.MO.SynchronizeData_AFKO(AUFNRList);

        //Synchronize_SAPData.MO.SynchronizeData_JEST(AUFNRList);

        dbcb = new DbCommandBuilder("SP_TS_RPT_004");

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "Nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        dbcb.appendParameter(Util.GetDataAccessAttribute("GSTRPStart", "DateTime", 0, CreatDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("GSTRPEnd", "DateTime", 0, CreatDateEnd));

        dbcb.DbCommandType = CommandType.StoredProcedure;

        ExportDataSet = CommonDB.ExecuteSelectQueryToDataSet(dbcb);
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns></returns>
    protected string WritToExcel()
    {
        if (ExportDataSet.Tables.Count < 2)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

        DataTable MainTable = ExportDataSet.Tables[0];

        DataTable ProcessTable = ExportDataSet.Tables[1];

        DataTable NotEndTicket1 = ExportDataSet.Tables[2];

        DataTable NotEndTicket2 = ExportDataSet.Tables[3];

        DataTable NotEndTicket3 = ExportDataSet.Tables[4];

        if (MainTable.Rows.Count < 1 || ProcessTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        Sheet = ExcelWorkBook.Worksheets["RPT"];

        int MaxColumn = ProcessTable.AsEnumerable().GroupBy(Row => Row["AUFNR"].ToString().Trim()).Select(item => new { AUFNR = item.Key, DataRowCount = item.Count() }).Max(item => item.DataRowCount);

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;
        int LastReportColumnIndex = 1;

        //主表欄位
        for (int i = ReportColumnIndex; i < 18; i++)
        {
            Sheet.Range[ReportRowIndex, ReportColumnIndex, ReportRowIndex + 1, ReportColumnIndex].Merge();

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName" + ReportColumnIndex);

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

            ReportColumnIndex++;
        }

        //製程欄位
        for (int i = MaxColumn - 1; i >= 0; i--)
        {
            //製程編號
            Sheet.Range[ReportRowIndex, ReportColumnIndex, ReportRowIndex, ReportColumnIndex + 2].Merge();

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName18") + (i + 1).ToString();

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

            //良品數
            Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName20");

            Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

            ReportColumnIndex++;

            //報廢數
            Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName21");

            Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

            ReportColumnIndex++;

            //製程名稱
            Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Text = (string)GetLocalResourceObject("Str_ColumnName19");

            Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

            Sheet.Range[ReportRowIndex + 1, ReportColumnIndex].ColumnWidth = 16;

            ReportColumnIndex++;
        }

        LastReportColumnIndex = ReportColumnIndex - 1;

        /* 開始正式畫報表 */
        ReportRowIndex = 3;
        ReportColumnIndex = 1;

        foreach (DataRow Row in MainTable.Rows)
        {
            //工單號碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["AUFNR"].ToString().Trim();
            ReportColumnIndex++;
            //狀態
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["STATUS"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //投料日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["ReportDate"]);
            ReportColumnIndex++;
            //關閉日期
            SetReportDate(Sheet.Range[ReportRowIndex, ReportColumnIndex], (DateTime)Row["CloseDateTime"]);
            ReportColumnIndex++;
            //逾期天數
            int OverDays = (int)Row["OverDays"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = OverDays;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //物料代碼
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["PLNBEZ"].ToString().Trim();
            ReportColumnIndex++;
            //產品名稱
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["MAKTX"].ToString().Trim();
            ReportColumnIndex++;
            //生產版本
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = Row["VERID"].ToString().Trim();
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
            //工單總數量
            double PSMNG = double.Parse(Row["PSMNG"].ToString().Trim());
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = PSMNG;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //流程卡開單數量
            int TicketQty = (int)Row["TicketQty"];
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = TicketQty;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            if (TicketQty != PSMNG)
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;
            ReportColumnIndex++;
            //進倉數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = double.Parse(Row["WEMNG"].ToString().Trim());
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //總報廢數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = double.Parse(Row["ScrapQty"].ToString().Trim());
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //未交貨數量
            string currentFormula = "IF(J" + ReportRowIndex.ToString() + "-(K" + ReportRowIndex.ToString() + "+ L" + ReportRowIndex.ToString() + ") <0,0,J" + ReportRowIndex.ToString() + "-(K" + ReportRowIndex.ToString() + "+ L" + ReportRowIndex.ToString() + "))";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = currentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Formula = currentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;
            //工單完成率
            currentFormula = "(K" + ReportRowIndex.ToString() + "+ L" + ReportRowIndex.ToString() + ") / J" + ReportRowIndex.ToString() + "";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Value2 = currentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Formula = currentFormula;
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberFormat = "0.00%";
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

            double CompletionRate = double.Parse(ExcelWorkBook.CaculateFormulaValue(currentFormula).ToString().Trim());

            if (CompletionRate >= 0.998)
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Green;
            else if (CompletionRate < 0.998 && CompletionRate >= 0.99)
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.ColorTranslator.FromHtml("#DB8F00");
            else if (CompletionRate < 0.99 && OverDays > 0)
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;

            ReportColumnIndex++;

            //未進倉成品數量
            Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = double.Parse(Row["NotGoInWEMNG"].ToString().Trim());
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
            ReportColumnIndex++;

            //結批狀態
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = (bool)Row["IsPreClose"] ? (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_IsPreClose_True") : (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_IsPreClose_False");
            Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

            if ((bool)Row["IsPreClose"])
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.Font.Color = System.Drawing.Color.Red;
            ReportColumnIndex++;

            //未關結流程卡
            string NotEndTicket1Result = NotEndTicket1.AsEnumerable().Where(NotEndTicketRow => NotEndTicketRow["AUFNR"].ToString().Trim() == Row["AUFNR"].ToString().Trim()).Select(NotEndTicketRow => NotEndTicketRow["CodeName"].ToString().Trim() + "(" + (int)NotEndTicketRow["RC"] + GetLocalResourceObject("Str_TicketUnit") + "-" + (int)NotEndTicketRow["SumQty"] + GetLocalResourceObject("Str_TicketQty") + ")").FirstOrDefault();
            string NotEndTicket2Result = NotEndTicket2.AsEnumerable().Where(NotEndTicketRow => NotEndTicketRow["AUFNR"].ToString().Trim() == Row["AUFNR"].ToString().Trim()).Select(NotEndTicketRow => NotEndTicketRow["CodeName"].ToString().Trim() + "(" + (int)NotEndTicketRow["RC"] + GetLocalResourceObject("Str_TicketUnit") + "-" + (int)NotEndTicketRow["SumQty"] + GetLocalResourceObject("Str_TicketQty") + ")").FirstOrDefault();
            string NotEndTicket3Result = NotEndTicket3.AsEnumerable().Where(NotEndTicketRow => NotEndTicketRow["AUFNR"].ToString().Trim() == Row["AUFNR"].ToString().Trim()).Select(NotEndTicketRow => NotEndTicketRow["CodeName"].ToString().Trim() + "(" + (int)NotEndTicketRow["RC"] + GetLocalResourceObject("Str_TicketUnit") + "-" + (int)NotEndTicketRow["SumQty"] + GetLocalResourceObject("Str_TicketQty") + ")").FirstOrDefault();

            string NotEndTicketResult = string.Empty;

            if (!string.IsNullOrEmpty(NotEndTicket1Result))
                NotEndTicketResult = NotEndTicket1Result;

            if (!string.IsNullOrEmpty(NotEndTicket2Result))
            {
                if (!string.IsNullOrEmpty(NotEndTicketResult))
                    NotEndTicketResult += "、";
                NotEndTicketResult += NotEndTicket2Result;
            }

            if (!string.IsNullOrEmpty(NotEndTicket3Result))
            {
                if (!string.IsNullOrEmpty(NotEndTicketResult))
                    NotEndTicketResult += "、";
                NotEndTicketResult += NotEndTicket3Result;
            }

            Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = NotEndTicketResult;
            ReportColumnIndex++;

            //製程
            List<DataRow> PRows = ProcessTable.AsEnumerable().Where(PRow => PRow["AUFNR"].ToString().Trim() == Row["AUFNR"].ToString().Trim()).OrderByDescending(PRow => (int)PRow["ProcessID"]).ToList();

            foreach (DataRow PRow in PRows)
            {
                //良品數
                Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)PRow["GoodQty"];
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
                ReportColumnIndex++;
                //報廢數
                Sheet.Range[ReportRowIndex, ReportColumnIndex].NumberValue = (int)PRow["ScrapQty"];
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
                ReportColumnIndex++;
                //製程名稱
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Text = PRow["LTXA1"].ToString().Trim();
                Sheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
                ReportColumnIndex++;
            }

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        /* 結束正式畫報表 */
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