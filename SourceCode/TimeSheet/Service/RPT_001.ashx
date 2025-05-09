<%@ WebHandler Language="C#" Class="RPT_001" %>

using System;
using System.Web;
using System.Web.UI;
using System.Drawing;
using System.Data;
using Spire.Pdf;
using DataAccess.Data;
using System.IO;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Linq;

public class RPT_001 : BasePage
{
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");
    protected string ReportTemplateName = "";
    protected List<string> TicketIDList;
    protected List<string> TicketTypeIDList;
    protected string AUFNR = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            //訂單編號
            if (_context.Request["AUFNR"] != null)
            {
                AUFNR = Util.TS.ToAUFNR(_context.Request["AUFNR"].Trim());

                //流程卡類型(如果沒有參數就只印一般流程卡)
                if (_context.Request["TicketTypeIDS"] != null)
                    TicketTypeIDList = JsonConvert.DeserializeObject<List<string>>(_context.Request["TicketTypeIDS"].Trim());
                else
                    TicketTypeIDList = new List<string>() { "1" };
            }

            //流程卡 List
            if (_context.Request["TicketID"] != null)
                TicketIDList = JsonConvert.DeserializeObject<List<string>>(_context.Request["TicketID"].Trim());

            if ((TicketIDList == null || TicketIDList.Count < 1) && string.IsNullOrEmpty(AUFNR))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_AUFNRTicketID"));

            //取得資料
            DataTable ResultDT = GetResultData();

            if (string.IsNullOrEmpty(ResultDT.Rows[0]["TicketPrintSize"].ToString().Trim()))
                ReportTemplateName = "RPT_001_0.docx";
            else
                ReportTemplateName = "RPT_001_" + ResultDT.Rows[0]["TicketPrintSize"].ToString().Trim() + ".docx";

            //載入報表範本，並開啟Word
            LoadWordReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

            //將資料寫入Word並取得最後的PDF路徑
            string SaveFullPath = WritToWord(ResultDT);

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "Ticket_" + DateTime.Now.ToString("yyMMddHHmmss") + ".pdf" };

            _context.Session.Add(GID, RI);

            ResponseSuccessData(new { Result = true, GUID = GID, IsQuarantineTicketType = (TicketTypeIDList.Count == 1 && (Util.TS.TicketType)Enum.Parse(typeof(Util.TS.TicketType), TicketTypeIDList[0]) == Util.TS.TicketType.Quarantine).ToStringValue() });
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

        var TicketList = DT.AsEnumerable().GroupBy(Row => new { TicketID = Row["TicketID"].ToString().Trim(), BoxID = Row["BoxID"].ToString().Trim() }).Select(Item => new { TicketID = Item.Key.TicketID, BoxID = Item.Key.BoxID }).ToList();

        for (int i = 0; i < TicketList.Count; i++)
        {
            var TicketRoutingRows = DT.AsEnumerable().Where(Row => Row["TicketID"].ToString().Trim() == TicketList[i].TicketID.ToString().Trim() && Row["BoxID"].ToString().Trim() == TicketList[i].BoxID.ToString().Trim()).ToList();

            for (int j = 0; j < TicketRoutingRows.Count; j++)
            {
                if (j == 0)
                {
                    //物料
                    WR.WritDataToBookMark("PLNBEZ", TicketRoutingRows[j]["PLNBEZ"].ToString().TrimStart('0'));
                    //流程卡
                    WR.WritDataToBookMark("TicketID", TicketRoutingRows[j]["TicketID"].ToString().Trim());
                    //開單數量
                    WR.WritDataToBookMark("TicketQty", ((int)TicketRoutingRows[j]["Qty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture));
                    //流程卡序號
                    if (!TicketRoutingRows[j].IsNull("TicketSerialNo"))
                        WR.WritDataToBookMark("TicketSerialNo", ((int)TicketRoutingRows[j]["TicketSerialNo"]).ToString("000"));
                    //圖號
                    WR.WritDataToBookMark("ZEINR", TicketRoutingRows[j]["ZEINR"].ToString().Trim());
                    //批次屬性
                    WR.WritDataToBookMark("CINFO", TicketRoutingRows[j]["CINFO"].ToString().Trim());
                    //半成品批号
                    WR.WritDataToBookMark("SEMIFINBATCH", TicketRoutingRows[j]["SEMIFINBATCH"].ToString().Trim());
                    //批次號
                    WR.WritDataToBookMark("CHARG", TicketRoutingRows[j]["CHARG"].ToString().Trim());
                    //零件號
                    WR.WritDataToBookMark("FERTH", TicketRoutingRows[j]["FERTH"].ToString().Trim());
                    //生產版本
                    WR.WritDataToBookMark("TEXT1", TicketRoutingRows[j]["TEXT1"].ToString().Trim());
                    if (i == 0)
                    {
                        //流程卡類型
                        if ((Util.TS.TicketType)Enum.Parse(typeof(Util.TS.TicketType), TicketRoutingRows[j]["TicketTypeID"].ToString().Trim()) != Util.TS.TicketType.General)
                            WR.WritDataToBookMark("TicketType", " (" + TicketRoutingRows[j]["CodeName"].ToString().Trim() + TicketRoutingRows[j]["ReworkCountString"].ToString().Trim() + ")");
                    }

                    //質檢員簽名欄位
                    if ((Util.TS.TicketType)Enum.Parse(typeof(Util.TS.TicketType), TicketRoutingRows[j]["TicketTypeID"].ToString().Trim()) != Util.TS.TicketType.Quarantine)
                    {
                        //質檢員簽名欄位移除
                        Spire.Doc.Table table = WR.WordDocument.Sections[0].Tables[0] as Spire.Doc.Table;

                        table.Rows.Remove(table.LastRow);
                    }

                    //QR Code 資料
                    string BarcdoeData = BaseConfiguration.LoginUrl + "/TimeSheet/TicketLifeCycle.aspx?A1=" + TicketRoutingRows[j]["AUFNR"].ToString().Trim() + "&A2=" + TicketRoutingRows[j]["TicketID"].ToString().Trim() + "&A3=" + TicketRoutingRows[j]["BoxID"].ToString().Trim();
                    //QR Code
                    int PictureWidth = 60;
                    int PictureHeight = 60;

                    if (string.IsNullOrEmpty(TicketRoutingRows[j]["TicketPrintSize"].ToString().Trim()) || TicketRoutingRows[j]["TicketPrintSize"].ToString().Trim() == "0")
                    {
                        PictureWidth = 75;
                        PictureHeight = 75;
                    }

                    WR.WritDataToBookMark("BarCode", string.Empty, (Bitmap)Bitmap.FromStream(Util.QRCodeInfo.QRCodeGenerator(BarcdoeData, 0.6f, new Size(120, 120))), PictureWidth, PictureHeight);
                    //刻字號
                    WR.WritDataToBookMark("Brand", TicketRoutingRows[j]["Brand"].ToString().Trim());
                    //建立人員姓名
                    WR.WritDataToBookMark("CreateAccountName", TicketRoutingRows[j]["CreateAccountName"].ToString().Trim());
                    //建立時間
                    WR.WritDataToBookMark("CreateDate", ((DateTime)TicketRoutingRows[j]["CreateDate"]).ToCurrentUICultureStringTime());
                    //列印時間
                    WR.WritDataToBookMark("PrintDate", ((DateTime)TicketRoutingRows[j]["PrintDate"]).ToCurrentUICultureStringTime());
                }

                //製程
                WR.WritDataToBookMark("LTXA1_" + j.ToString(), TicketRoutingRows[j]["ProcessID"].ToString().Trim() + "-" + TicketRoutingRows[j]["VORNR"].ToString().Trim() + "：" + TicketRoutingRows[j]["LTXA1"].ToString().Trim());
            }

            MemoryStream ResultStream = new MemoryStream();

            WriteToWordStream(ResultStream, Spire.Doc.FileFormat.PDF);

            ResultFileStream.Add(ResultStream);

            WR.ReLoadWordReportTemplate();
        }

        PdfDocumentBase PDFDoc = PdfDocument.MergeFiles(ResultFileStream.ToArray());

        PDFDoc.Save(FinalPDFPath, FileFormat.PDF);

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

        string Query = @"Select Distinct
                                T_TSTicket.TicketID,
                                T_TSTicket.TicketTypeID,
                                Case
                                    When T_TSTicket.TicketTypeID <> @TicketTypeID Then ''
                                    Else Convert(Nvarchar(50),(Select Count(*) From dbo.TS_GetFullParentTicket(T_TSTicket.TicketID,1) Where TicketTypeID = @TicketTypeID))
                                End As ReworkCountString,
                                T_TSTicket.BoxID,
                                T_TSTicket.Qty,
                                T_TSTicket.PLNBEZ,
                                T_TSTicket.AUFNR,
                                T_TSTicket.TicketSerialNo,
		                        T_TSTicketRouting.AUFPL,
		                        T_TSTicketRouting.APLZL,
	                            V_TSMORouting.ZEINR,
                                V_TSMORouting.CINFO,
                                V_TSMORouting.SEMIFINBATCH,
	                            V_TSMORouting.FERTH,
	                            V_TSMORouting.TEXT1,
	                            Case When IsNull(T_TSTicket.ReWorkMainProcessID,'') <> '' And (T_TSTicket.ReWorkMainProcessID = T_TSTicketRouting.ProcessID) Then '*' + T_TSTicketRouting.LTXA1 Else T_TSTicketRouting.LTXA1 End As LTXA1,
		                        V_TSMORouting.PLNNR,
		                        V_TSMORouting.PLNAL,
		                        V_TSMORouting.PLNKN,
		                        V_TSMORouting.VORNR,
                                T_Code.CodeName,
		                        V_TSMORouting.TicketPrintSize,
                                Base_Org.dbo.GetAccountName(CreateAccountID) As CreateAccountName,
                                T_TSTicket.CreateDate,
								T_TSTicketRouting.ProcessID,
                                V_TSMORouting.CHARG,
                                GetDate() As PrintDate,
                                (Select Top 1 Brand From T_TSTicketResult Where (T_TSTicketResult.TicketID = T_TSTicket.ParentTicketID Or T_TSTicketResult.TicketID = T_TSTicket.TicketID) And IsNull(Brand,'') <> '' Order By ProcessID,SerialNo Desc) As Brand
                                From T_TSTicket
                                Inner Join T_TSTicketRouting On T_TSTicket.TicketID = T_TSTicketRouting.TicketID
                                Inner Join V_TSMORouting On T_TSTicket.AUFNR = V_TSMORouting.AUFNR And T_TSTicketRouting.AUFPL = V_TSMORouting.AUFPL And T_TSTicketRouting.APLZL = V_TSMORouting.APLZL
                                Inner Join T_Code On T_TSTicket.TicketTypeID = T_Code.CodeID And T_Code.CodeType='TS_TicketType' And T_Code.UICulture = @UICulture ";

        string Condition = string.Empty;

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "Nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        dbcb.appendParameter(Util.GetDataAccessAttribute("TicketTypeID", "Nvarchar", 50, (short)Util.TS.TicketType.Rework));

        if (!string.IsNullOrEmpty(AUFNR))
        {
            Condition += " And T_TSTicket.AUFNR = @AUFNR ";

            dbcb.appendParameter(Util.GetDataAccessAttribute("AUFNR", "Nvarchar", 50, AUFNR));

            Condition += " And T_TSTicket.TicketTypeID in(";

            for (int i = 0; i < TicketTypeIDList.Count; i++)
            {
                string Parameter = "TicketTypeID_" + i.ToString();

                Condition += i < 1 ? "@" + Parameter : ",@" + Parameter;

                dbcb.appendParameter(Util.GetDataAccessAttribute(Parameter, "Nvarchar", 50, TicketTypeIDList[i]));
            }

            Condition += ")";
        }
        else if (TicketIDList.Count > 0)
        {
            Condition += " And T_TSTicket.TicketID in(";

            for (int i = 0; i < TicketIDList.Count; i++)
            {
                string Parameter = "TicketID_" + i.ToString();

                Condition += i < 1 ? "@" + Parameter : ",@" + Parameter;

                dbcb.appendParameter(Util.GetDataAccessAttribute(Parameter, "Nvarchar", 50, TicketIDList[i]));
            }

            Condition += ")";
        }

        if (Condition.Length > 0)
            Condition = " Where " + Condition.Substring(4, Condition.Length - 4);

        if (!string.IsNullOrEmpty(Condition))
            Query += Condition;

        Query += " Order By T_TSTicket.TicketID,T_TSTicket.TicketTypeID,T_TSTicket.BoxID,T_TSTicketRouting.ProcessID ";

        dbcb.CommandText = Query;

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        if (TicketTypeIDList == null && DT.Rows.Count > 0)
            TicketTypeIDList = new List<string>() { DT.Rows[0]["TicketTypeID"].ToString() };

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