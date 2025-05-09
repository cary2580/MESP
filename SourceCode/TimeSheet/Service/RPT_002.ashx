<%@ WebHandler Language="C#" Class="RPT_002" %>

using System;
using System.Web;
using System.Web.UI;
using System.Drawing;
using System.Data;
using Spire.Doc;
using Spire.Doc.Documents;
using Spire.Doc.Fields;
using Spire.Pdf;
using Spire.Pdf.Graphics;
using DataAccess.Data;
using System.IO;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Linq;

public class RPT_002 : BasePage
{
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_002.docx";
    protected string MachineID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            //機台編號
            if (_context.Request["MachineID"] != null)
                MachineID = _context.Request["MachineID"].Trim();

            if (string.IsNullOrEmpty(MachineID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MachineID"));

            //取得資料
            DataTable ResultDT = GetResultData();

            //載入報表範本，並開啟Word
            LoadWordReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

            //將資料寫入Word並取得最後的PDF路徑
            string SaveFullPath = WritToWord(ResultDT);

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "Device_" + DateTime.Now.ToString("yyMMddHHmmss") + ".pdf" };

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

            //機台編號標題
            WR.WritDataToBookMark("MachineIDTitle", (string)GetLocalResourceObject("MachineIDTitle"));
            //機台編號
            WR.WritDataToBookMark("MachineID", DR["MachineID"].ToString().Trim());
            //機台名稱標題
            WR.WritDataToBookMark("MachineNameTitle", (string)GetLocalResourceObject("MachineNameTitle"));
            //機台名稱
            WR.WritDataToBookMark("MachineName", DR["MachineName"].ToString().Trim());
            //QR Code 資料
            string BarcdoeDate = BaseConfiguration.LoginUrl + "/TimeSheet/?A5=" + DR["MachineID"].ToString().Trim();
            //QR Code
            WR.WritDataToBookMark("BarCode", string.Empty, (Bitmap)Bitmap.FromStream(Util.QRCodeInfo.QRCodeGenerator(BarcdoeDate, 1f, new Size(120, 120))), 120, 120);

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
        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Query = @"Select MachineID,
                                MachineName
                         From T_TSDevice ";

        string Condition = string.Empty;

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "Nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        Condition += " Where MachineID = @MachineID ";

        dbcb.appendParameter(Util.GetDataAccessAttribute("MachineID", "Nvarchar", 50, MachineID));

        Query += Condition;

        dbcb.CommandText = Query;

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        return DT;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}