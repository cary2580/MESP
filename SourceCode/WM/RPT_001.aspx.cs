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
using DataAccess.Data.Schema;
using Spire.Pdf;


public partial class WM_RPT_001 : System.Web.UI.Page
{
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\WM\ReportTemplate\");

    protected string ReportTemplateName = "RPT_001.docx";

    protected string PalletNo = string.Empty;

    protected string RPTBase64 = string.Empty;

    protected WordReport WR = new WordReport();

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
                if (Request["PalletNo"] != null)
                    PalletNo = Request["PalletNo"].Trim();

                if (string.IsNullOrEmpty(PalletNo))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Empty_PalletNo"));

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
        DataTable DT = GetResultData();

        WR.LoadWordReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        //栈板号
        WR.WritDataToBookMark("PalletNo", DT.Rows[0]["PalletNo"].ToString().Trim());
        //栈板总数量
        WR.WritDataToBookMark("Qty", DT.Rows[0]["Qty"].ToString().Trim());
        //物料名称
        WR.WritDataToBookMark("MAKTX", DT.Rows[0]["MAKTX"].ToString().Trim());
        //刻字号/Sap批次号
        WR.WritDataToBookMark("BrandArray", DT.Rows[0]["BrandArray"].ToString().Trim());
        //刻字号/Sap批次号
        if(!string.IsNullOrEmpty(DT.Rows[0]["LocationName"].ToString().Trim()))
        WR.WritDataToBookMark("LocationName", DT.Rows[0]["LocationName"].ToString().Trim());
        //QR Code 資料
        string QrcdoeDate = BaseConfiguration.LoginUrl + "/WM/PalletLifeCycle.aspx?A7=" + DT.Rows[0]["PalletNo"].ToString().Trim();
        //QR Code
        WR.WritDataToBookMark("QRCode", string.Empty, (Bitmap)Bitmap.FromStream(Util.QRCodeInfo.QRCodeGenerator(QrcdoeDate, 0.6f, new Size(110, 110))), 110, 110);

        MemoryStream ms = new MemoryStream();

        WR.WriteToStream(ms, Spire.Doc.FileFormat.PDF);

        return ms;
    }

    /// <summary>
    /// 取得資料
    /// </summary>
    /// <returns>DataTable</returns>
    protected DataTable GetResultData()
    {
        string Query = @"Select 
	                        T_WMProductPallet.PalletNo,
	                        T_WMProductPallet.Qty,
	                        T_WMProductPallet.MAKTX,
                            T_WMDeliveryLocation.LocationName,
	                        Stuff((Select '、' + Brand 
			                        From
			                        (
				                        Select 
						                        Brand ,
						                        Sum(T_WMProductBoxBrand.Qty) As Qty
				                        From T_WMProductBox 
				                        Inner Join T_WMProductPallet On T_WMProductPallet.PalletNo = T_WMProductBox.PalletNo
				                        Inner Join T_WMProductBoxBrand On T_WMProductBoxBrand.BoxNo = T_WMProductBox.BoxNo
				                        Where T_WMProductPallet.PalletNo = @PalletNo
				                        Group By Brand
			                        ) As Result
			                        Order By Result.Qty Desc
		                        For Xml Path ('') ),1,1,'') As BrandArray
                        From 
                        T_WMProductPallet Left Join T_WMDeliveryLocation On T_WMDeliveryLocation.LocationID = T_WMProductPallet.DeliveryLocationID
                        Where PalletNo = @PalletNo";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPallet"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }
}