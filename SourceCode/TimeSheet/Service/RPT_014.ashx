<%@ WebHandler Language="C#" Class="RPT_014" %>

using System;
using System.Web;
using System.Web.UI;
using System.Drawing;
using System.Data;
using Spire.Pdf;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.IO;
using System.Collections.Generic;

public class RPT_014 : BasePage
{
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_014.docx";
    protected string TicketQuarantineGUID = string.Empty;
    protected string TicketID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (_context.Request["TicketQuarantineGUID"] != null)
                TicketQuarantineGUID = _context.Request["TicketQuarantineGUID"].Trim();

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            if (string.IsNullOrEmpty(TicketQuarantineGUID))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_TicketQuarantineGUID"));

            //取得流程卡資料
            DataTable ResultDT = GetTicketData();

            DataTable DefectDT = GetDefectData();

            if (ResultDT.Rows.Count > 0 && DefectDT.Rows.Count > 0)
            {
                //載入報表範本，並開啟Word
                LoadWordReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

                //將資料寫入Word並產生PDF
                string QuarantineInfoFullPath = WritToWord(ResultDT, DefectDT);

                if (_context.Session[TicketQuarantineGUID] == null)
                    throw new CustomException((string)GetLocalResourceObject("Str_Empty_TicketQuarantineGUID"));

                DownloadFileInfo DFI = _context.Session[TicketQuarantineGUID] as DownloadFileInfo;

                string[] files = new string[] { DFI.DownloadFileFullPath, QuarantineInfoFullPath };

                PdfDocumentBase ResultPDF = PdfDocument.MergeFiles(files);

                //新增一個暫存資料夾給最終的PDF使用
                DirectoryInfo DirPDFTemp = Util.GetTempDirectory();

                //最終的PDF路徑
                string FinalPDFPath = DirPDFTemp.FullName + @"\" + Path.GetFileNameWithoutExtension(ReportTemplateName) + ".pdf";

                ResultPDF.Save(FinalPDFPath, FileFormat.PDF);

                ResultPDF.Close();

                Directory.Delete(Path.GetDirectoryName(QuarantineInfoFullPath), true);

                if (!DFI.IsNoClearSession)
                    Session.Remove(TicketQuarantineGUID);

                if (DFI.IsDeleteDownloadFile)
                {
                    File.Delete(DFI.DownloadFileFullPath);

                    if (Directory.GetFiles(Path.GetDirectoryName(DFI.DownloadFileFullPath)).Length < 1)
                        Directory.Delete(Path.GetDirectoryName(DFI.DownloadFileFullPath), true);
                }

                string GID = NewGuid;

                DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = FinalPDFPath, SaveFileName = "Ticket_" + DateTime.Now.ToString("yyMMddHHmmss") + ".pdf" };

                _context.Session.Add(GID, RI);

                ResponseSuccessData(new { Result = true, GUID = GID });
            }
            else
                ResponseSuccessData(new { Result = true, GUID = TicketQuarantineGUID });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 傳入DataTable繪製Word，並回傳最後存檔PDF路徑
    /// </summary>
    /// <param name="DT">隔離單資料</param>
    /// <param name="DefectDT">初判資料</param>
    /// <returns>最後存檔PDF路徑</returns>
    public string WritToWord(DataTable DT, DataTable DefectDT)
    {
        //結果檔案資料流 List
        List<MemoryStream> ResultFileStream = new List<MemoryStream>();

        //物料
        WR.WritDataToBookMark("PLNBEZ", DT.Rows[0]["PLNBEZ"].ToString().Trim());
        //流程卡
        WR.WritDataToBookMark("TicketID", DT.Rows[0]["TicketID"].ToString().Trim());
        //開單數量
        WR.WritDataToBookMark("TicketQty", ((int)DT.Rows[0]["Qty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture));
        //生產版本
        WR.WritDataToBookMark("TEXT1", DT.Rows[0]["TEXT1"].ToString().Trim());
        //半成品批号
        WR.WritDataToBookMark("SEMIFINBATCH", DT.Rows[0]["SEMIFINBATCH"].ToString().Trim());
        //零件號
        WR.WritDataToBookMark("FERTH", DT.Rows[0]["FERTH"].ToString().Trim());
        //圖號
        WR.WritDataToBookMark("ZEINR", DT.Rows[0]["ZEINR"].ToString().Trim());
        //批次屬性
        WR.WritDataToBookMark("CINFO", DT.Rows[0]["CINFO"].ToString().Trim());
        //批次號
        WR.WritDataToBookMark("CHARG", DT.Rows[0]["CHARG"].ToString().Trim());
        //刻字號
        WR.WritDataToBookMark("Brand", DT.Rows[0]["Brand"].ToString().Trim());
        //建立人員姓名
        WR.WritDataToBookMark("CreateAccountName", DT.Rows[0]["CreateAccountName"].ToString().Trim());
        //建立時間
        WR.WritDataToBookMark("CreateDate", ((DateTime)DT.Rows[0]["CreateDate"]).ToCurrentUICultureStringTime());
        //列印時間
        WR.WritDataToBookMark("PrintDate", ((DateTime)DT.Rows[0]["PrintDate"]).ToCurrentUICultureStringTime());

        for (int i = 0; i < DefectDT.Rows.Count; i++)
        {
            //不良現象
            WR.WritDataToBookMark("QuarantineInfo_" + i.ToString() + "_DefectName", DefectDT.Rows[i]["DefectName"].ToString().Trim());
            //隔離數量
            WR.WritDataToBookMark("QuarantineInfo_" + i.ToString() + "_QuarantineQty", DefectDT.Rows[i]["ScrapQty"].ToString().Trim());
            //備註
            WR.WritDataToBookMark("QuarantineInfo_" + i.ToString() + "_DefectID", DefectDT.Rows[i]["DefectID"].ToString().Trim());
        }

        return WriteToWordFile(NewGuid, Spire.Doc.FileFormat.PDF);
    }

    /// <summary>
    /// 取得隔離初判資料
    /// </summary>
    /// <returns>隔離初判資料</returns>
    protected DataTable GetDefectData()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineFirstTimeItem"];

        string Query = @"Select 
                        DefectID,
                        (Select Top 1 Replace(Replace(DefectName, Char(13), ''), Char(10), '') From T_TSDefect Where T_TSDefect.DefectID = T_TSTicketQuarantineFirstTimeItem.DefectID) As DefectName,
                        ScrapQty
                        From T_TSTicketQuarantineFirstTimeItem 
                        Where TicketID = @TicketID
                        Order By SerialNo";

        dbcb.CommandText = Query;

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 取得流程卡資料
    /// </summary>
    /// <returns>流程卡資料表</returns>
    protected DataTable GetTicketData()
    {
        string Query = @"Select 
	                        T_TSTicket.PLNBEZ,
	                        T_TSTicket.TicketID,
	                        T_TSTicket.Qty,
	                        V_TSMORouting.TEXT1,
                            V_TSMORouting.SEMIFINBATCH,
	                        V_TSMORouting.FERTH,
                            V_TSMORouting.ZEINR,
	                        V_TSMORouting.CINFO,
	                        V_TSMORouting.CHARG,
	                        (Select Top 1 Brand From T_TSTicketResult Where (T_TSTicketResult.TicketID = T_TSTicket.ParentTicketID Or T_TSTicketResult.TicketID = T_TSTicket.TicketID) And IsNull(Brand,'') <> '' Order By ProcessID,SerialNo Desc) As Brand,
	                        Base_Org.dbo.GetAccountName(CreateAccountID) As CreateAccountName,
	                        T_TSTicket.CreateDate,
	                        GetDate() As PrintDate
                        From T_TSTicketQuarantineResult
                        Inner Join T_TSTicket On T_TSTicket.TicketID = T_TSTicketQuarantineResult.TicketID
                        Inner Join V_TSMORouting On T_TSTicket.AUFNR = V_TSMORouting.AUFNR And T_TSTicketQuarantineResult.AUFPL = V_TSMORouting.AUFPL And T_TSTicketQuarantineResult.APLZL = V_TSMORouting.APLZL
                        Where T_TSTicket.TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        return DT;
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}