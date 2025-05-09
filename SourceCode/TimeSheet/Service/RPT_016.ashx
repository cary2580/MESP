<%@ WebHandler Language="C#" Class="RPT_016" %>

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
using Newtonsoft.Json;
using System.Linq;

public class RPT_016 : BasePage
{
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "RPT_016.docx";
    protected string TicketID = string.Empty;
    protected string TicketQuarantineGUID = string.Empty;

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

            DataTable DT = GetResultData();

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

            //載入報表範本，並開啟Word
            LoadWordReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

            //將資料寫入Word並取得最後的PDF路徑
            string SaveFullPath = WritToWord(DT);

            string GID = NewGuid;

            DownloadFileInfo RI;

            if (_context.Session[TicketQuarantineGUID] != null)
            {

                DownloadFileInfo DFI = _context.Session[TicketQuarantineGUID] as DownloadFileInfo;

                string[] files = new string[] { DFI.DownloadFileFullPath, SaveFullPath };

                PdfDocumentBase ResultPDF = PdfDocument.MergeFiles(files);

                //新增一個暫存資料夾給最終的PDF使用
                DirectoryInfo DirPDFTemp = Util.GetTempDirectory();

                //最終的PDF路徑
                string FinalPDFPath = DirPDFTemp.FullName + @"\" + Path.GetFileNameWithoutExtension(ReportTemplateName) + ".pdf";

                ResultPDF.Save(FinalPDFPath, FileFormat.PDF);

                ResultPDF.Close();

                Directory.Delete(Path.GetDirectoryName(SaveFullPath), true);

                if (!DFI.IsNoClearSession)
                    Session.Remove(TicketQuarantineGUID);

                if (DFI.IsDeleteDownloadFile)
                {
                    File.Delete(DFI.DownloadFileFullPath);

                    if (Directory.GetFiles(Path.GetDirectoryName(DFI.DownloadFileFullPath)).Length < 1)
                        Directory.Delete(Path.GetDirectoryName(DFI.DownloadFileFullPath), true);
                }

                RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = FinalPDFPath, SaveFileName = "RPT_016_" + DateTime.Now.ToString("yyMMddHHmmss") + ".pdf" };
            }
            else
                RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "RPT_016_" + DateTime.Now.ToString("yyMMddHHmmss") + ".pdf" };

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
        //流程卡
        WR.WritDataToBookMark("TicketID", DT.Rows[0]["TicketID"].ToString().Trim());
        //送檢數量
        WR.WritDataToBookMark("InspectionQty", DT.Rows[0]["InspectionQty"].ToString().Trim());
        //物料
        WR.WritDataToBookMark("PLNBEZ", DT.Rows[0]["PLNBEZ"].ToString().Trim());
        //生產版本
        WR.WritDataToBookMark("TEXT1", DT.Rows[0]["TEXT1"].ToString().Trim());
        //刻字號
        WR.WritDataToBookMark("Brand", DT.Rows[0]["Brand"].ToString().Trim());
        //圖號
        WR.WritDataToBookMark("ZEINR", DT.Rows[0]["ZEINR"].ToString().Trim());
        //零件號
        WR.WritDataToBookMark("FERTH", DT.Rows[0]["FERTH"].ToString().Trim());
        //SAP批次號
        WR.WritDataToBookMark("CHARG", DT.Rows[0]["CHARG"].ToString().Trim());
        //原材料批號
        WR.WritDataToBookMark("CINFO", DT.Rows[0]["CINFO"].ToString().Trim());
        //半成品批號
        WR.WritDataToBookMark("SEMIFINBATCH", DT.Rows[0]["SEMIFINBATCH"].ToString().Trim());
        //建立人員姓名
        WR.WritDataToBookMark("CreateAccountName", DT.Rows[0]["CreateAccountName"].ToString().Trim());
        //建立時間
        WR.WritDataToBookMark("CreateDate", ((DateTime)DT.Rows[0]["CreateDate"]).ToCurrentUICultureStringTime());
        //列印時間
        WR.WritDataToBookMark("PrintDate", ((DateTime)DT.Rows[0]["PrintDate"]).ToCurrentUICultureStringTime());

        //QR Code 資料
        string BarcdoeDate = BaseConfiguration.LoginUrl + "/TimeSheet/TicketLifeCycle.aspx?A1=" + DT.Rows[0]["AUFNR"].ToString().Trim() + "&A2=" + DT.Rows[0]["TicketID"].ToString().Trim() + "&A3=" + DT.Rows[0]["BoxID"].ToString().Trim();
        //QR Code
        WR.WritDataToBookMark("BarCode", string.Empty, (Bitmap)Bitmap.FromStream(Util.QRCodeInfo.QRCodeGenerator(BarcdoeDate, 0.6f, new Size(110, 110))), 110, 110);

        return WriteToWordFile(NewGuid, Spire.Doc.FileFormat.PDF);
    }

    /// <summary>
    /// 取得資料
    /// </summary>
    /// <returns>DataTable</returns>
    protected DataTable GetResultData()
    {
        string Query = @"Select Top 1
                                T_TSProductionInspection.AUFNR,
                                T_TSProductionInspection.TicketID,
                                (Select BoxID From T_TSTicket Where T_TSTicket.TicketID = T_TSProductionInspection.TicketID) As BoxID,
                                MR.TEXT1,
                                MR.CINFO,
                                MR.CHARG,
                                Brand,
                                MR.ZEINR,
								MR.FERTH,
								MR.PLNBEZ,
                                MR.SEMIFINBATCH,
                                T_TSProductionInspection.InspectionQty,
                                T_TSProductionInspection.CreateAccountID,
                                Base_Org.dbo.GetAccountName(T_TSProductionInspection.CreateAccountID) As CreateAccountName,
                                T_TSProductionInspection.CreateDate,
                                T_TSProductionInspection.InspectionResult,
                                (Select CodeName From T_Code Where T_Code.CodeType = 'TS_ProductionInspectionResult' And T_Code.UICulture = @UICulture And T_Code.CodeID = T_TSProductionInspection.InspectionResult) As InspectionResultName,
                                GetDate() As PrintDate
                            From T_TSProductionInspection
                            Inner Join (Select AUFNR,TEXT1,CINFO,CHARG,ZEINR,FERTH,PLNBEZ,SEMIFINBATCH From V_TSMORouting Group By AUFNR,TEXT1,CINFO,CHARG,ZEINR,FERTH,PLNBEZ,SEMIFINBATCH) As MR On MR.AUFNR = T_TSProductionInspection.AUFNR
                            Where T_TSProductionInspection.TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspection"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}