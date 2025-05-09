<%@ WebHandler Language="C#" Class="RPT_035" %>

using System;
using System.Web;
using System.Web.UI;
using System.Drawing;
using System.Data;
using Spire.Pdf;
using DataAccess.Data.Schema;
using DataAccess.Data;
using System.IO;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Linq;

public class RPT_035 : BasePage
{
    protected string AUFNR = string.Empty;
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_035.docx";

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            //訂單編號
            if (_context.Request["AUFNR"] != null)
                AUFNR = Util.TS.ToAUFNR(_context.Request["AUFNR"].Trim());

            if (string.IsNullOrEmpty(AUFNR))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AUFNR"));

            //取得資料
            DataTable ResultDT = GetResultData();

            //載入報表範本，並開啟Word
            LoadWordReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

            //將資料寫入Word並取得最後的PDF路徑
            string SaveFullPath = WritToWord(ResultDT);

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "Ticket_" + DateTime.Now.ToString("yyMMddHHmmss") + ".pdf" };

            _context.Session.Add(GID, RI);

            ResponseSuccessData(new { Result = true, GUID = GID });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 傳入DataTable繪製Word，並回傳最後存檔PDF路徑
    /// </summary>
    /// <param name="DT">DataTable</param>
    /// <returns>最後存檔PDF路徑</returns>
    public string WritToWord(DataTable DT)
    {
        //新增一個暫存資料夾給最終的PDF使用
        DirectoryInfo DirPDFTemp = Util.GetTempDirectory();

        //最終的PDF路徑
        string FinalPDFPath = DirPDFTemp.FullName + @"\" + Path.GetFileNameWithoutExtension(ReportTemplateName) + ".pdf";

        //結果檔案資料流 List
        List<MemoryStream> ResultFileStream = new List<MemoryStream>();

        foreach (DataRow DR in DT.Rows)
        {
            string PDFName = Path.GetRandomFileName();

            string CurrentWordPath = WR.TempDirectory.FullName + @"\" + Path.GetFileNameWithoutExtension(PDFName) + ".pdf";

            //生產版本
            WR.WritDataToBookMark("TEXT1", DR["TEXT1"].ToString().Trim());
            //批次屬性
            WR.WritDataToBookMark("CINFO", DR["CINFO"].ToString().Trim());
            //數量
            WR.WritDataToBookMark("PSMNG", ((Decimal)DR["PSMNG"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture));
            //箱號BarCode
            WR.WritDataToBookMark("BarCode", string.Empty, (Bitmap)Bitmap.FromStream(Util.QRCodeInfo.BarCodeGenerator(DR["AUFNR"].ToString().Trim(), 0.6f, 70, Spire.Barcode.BarCodeType.Code39Extended, null, new Font("Arial", 48, FontStyle.Bold))), 320, 70);

            MemoryStream ResultStream = new MemoryStream();

            WriteToWordStream(ResultStream, Spire.Doc.FileFormat.PDF);

            ResultFileStream.Add(ResultStream);

            WR.ReLoadWordReportTemplate();
        }

        WR.WordDocument.Close();

        PdfDocumentBase PDFDoc = PdfDocument.MergeFiles(ResultFileStream.ToArray());

        PDFDoc.Save(FinalPDFPath, Spire.Pdf.FileFormat.PDF);

        PDFDoc.Close();

        WR.TempDirectory.Delete(true);

        return FinalPDFPath;
    }

    /// <summary>
    /// 取得資料
    /// </summary>
    /// <returns>DataTable</returns>
    protected DataTable GetResultData()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        string Query = @"Select Distinct TEXT1,CINFO,PSMNG,AUFNR From V_TSMORouting Where AUFNR = @AUFNR ";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

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