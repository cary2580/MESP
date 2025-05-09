using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Drawing;
using System.IO;
using System.Data;
using DataAccess.Data;
using Spire.Xls;

public partial class WM_RPT_003 : System.Web.UI.Page
{
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\WM\ReportTemplate\");

    protected string ReportTemplateName = "RPT_003.xlsx";

    protected string PackingID = string.Empty;

    protected string RPTBase64 = string.Empty;

    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            try
            {
                if (Request["PackingID"] != null)
                    PackingID = Request["PackingID"].Trim();

                if (string.IsNullOrEmpty(PackingID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Empty_PackingID"));

                MemoryStream FileMemoryStream = CreateRPT();

                byte[] pdfBytes = FileMemoryStream.ToArray();

                string pdfBase64 = Convert.ToBase64String(pdfBytes);

                RPTBase64 = pdfBase64;
            }
            catch (Exception ex)
            {
                Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true, "window.close();");

                return;
            }
        }
    }

    /// <summary>
    /// 產生報表
    /// </summary>
    /// <returns>產生報表後的MemoryStream</returns>
    protected MemoryStream CreateRPT()
    {
        DataSet DS = GetResultData();

        DataTable DT = DS.Tables[0];

        DataTable DT1 = DS.Tables[1];

        ExcelReport ER = new ExcelReport();

        ER.LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        Worksheet worksheet = ER.ExcelWorkBook.Worksheets["RPT"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        CellStyle CellStyle = ER.ExcelWorkBook.Styles.Add(BaseConfiguration.NewGuid());
        CellStyle.Font.FontName = "微軟正黑體";
        CellStyle.Font.Size = 12;
        CellStyle.Borders[BordersLineType.EdgeLeft].LineStyle = LineStyleType.Thin;
        CellStyle.Borders[BordersLineType.EdgeRight].LineStyle = LineStyleType.Thin;
        CellStyle.Borders[BordersLineType.EdgeTop].LineStyle = LineStyleType.Thin;
        CellStyle.Borders[BordersLineType.EdgeBottom].LineStyle = LineStyleType.Thin;
        //领料单号语系名称
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PackingID");
        worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
        //领料单号
        ReportColumnIndex = 2;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = DT.Rows[0]["PackingID"].ToString().Trim();
        worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
        //栈板总PCS数量
        ReportColumnIndex = 6;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = DT.Rows[0]["TotalQty"].ToString().Trim();
        worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
        //QR Code 資料
        ReportColumnIndex = 8;
        string Qrcdoe = BaseConfiguration.LoginUrl + "/WM/PackingInfo.aspx?A8=" + DT.Rows[0]["PackingID"].ToString().Trim();
        ExcelPicture picture = worksheet.Pictures.Add(ReportRowIndex, ReportColumnIndex, (Bitmap)Bitmap.FromStream(Util.QRCodeInfo.QRCodeGenerator(Qrcdoe, 0.6f, new Size(120, 120))));
        picture.Width = 120;
        picture.Height = 120;
        picture.LeftColumnOffset = 250;
        picture.TopRowOffset = 35;
        picture.ResizeBehave = ResizeBehaveType.MoveAndResize;
        //物料名称
        ReportRowIndex = 2;
        ReportColumnIndex = 1;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_MAKTX");
        worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
        //物料名称
        ReportColumnIndex = 2;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = DT.Rows[0]["MAKTX"].ToString().Trim();
        worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
        //箱數
        ReportColumnIndex = 6;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = DT.Rows[0]["BoxNoCount"].ToString().Trim();
        worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
        ReportColumnIndex = 7;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BoxQty");
        worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
        worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

        List<string> PalletNoList = DT.Rows[0]["PalletNoList"].ToString().Trim().Split('|').ToList();

        ReportRowIndex = 4;
        ReportColumnIndex = 1;

        foreach (string PalletNo in PalletNoList)
        {
            worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PalletNo");
            worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
            worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
            worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

            worksheet.Range[ReportRowIndex, ReportColumnIndex + 1, ReportRowIndex, ReportColumnIndex + 9].Merge();

            worksheet.Range[ReportRowIndex, ReportColumnIndex + 1].Text = PalletNo;
            worksheet.Range[ReportRowIndex, ReportColumnIndex + 1].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
            worksheet.Range[ReportRowIndex, ReportColumnIndex + 1, ReportRowIndex, ReportColumnIndex + 9].Style = CellStyle;
            worksheet.Range[ReportRowIndex, ReportColumnIndex + 1].Style.HorizontalAlignment = HorizontalAlignType.Left;

            ReportRowIndex++;
            ReportColumnIndex = 1;
        }

        foreach (DataRow Row in DT1.Rows)
        {
            worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PalletNo");
            worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
            worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
            worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

            worksheet.Range[ReportRowIndex, ReportColumnIndex + 1, ReportRowIndex, ReportColumnIndex + 9].Merge();

            worksheet.Range[ReportRowIndex, ReportColumnIndex + 1].Text = Row["PalletNo"].ToString().Trim() + "*";
            worksheet.Range[ReportRowIndex, ReportColumnIndex + 1].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
            worksheet.Range[ReportRowIndex, ReportColumnIndex + 1, ReportRowIndex, ReportColumnIndex + 9].Style = CellStyle;
            worksheet.Range[ReportRowIndex, ReportColumnIndex + 1].Style.HorizontalAlignment = HorizontalAlignType.Left;

            ReportRowIndex++;
            ReportColumnIndex = 1;

            List<string> BoxNoList = Row["BoxNo"].ToString().Trim().Split('|').ToList();

            foreach (string BoxNo in BoxNoList)
            {
                worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BoxNo");
                worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
                worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
                worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;

                ReportColumnIndex = 1;

                worksheet.Range[ReportRowIndex, ReportColumnIndex + 1, ReportRowIndex, ReportColumnIndex + 9].Merge();

                worksheet.Range[ReportRowIndex, ReportColumnIndex + 1].Text = BoxNo;
                worksheet.Range[ReportRowIndex, ReportColumnIndex + 1].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
                worksheet.Range[ReportRowIndex, ReportColumnIndex + 1, ReportRowIndex, ReportColumnIndex + 9].Style = CellStyle;
                worksheet.Range[ReportRowIndex, ReportColumnIndex + 1].Style.HorizontalAlignment = HorizontalAlignType.Left;

                ReportRowIndex++;
                ReportColumnIndex = 1;
            }
        }

        MemoryStream ms = new MemoryStream();

        ER.WriteToStream(ms, Spire.Xls.FileFormat.PDF);

        return ms;
    }

    /// <summary>
    /// 取得資料
    /// </summary>
    protected DataSet GetResultData()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_WM_RPT_003");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("PackingID", "nvarchar", 50, PackingID));

        return CommonDB.ExecuteSelectQueryToDataSet(dbcb);
    }
}