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


public partial class TimeSheet_RPT_008 : System.Web.UI.Page
{
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\TimeSheet\ReportTemplate\");

    protected string ReportTemplateName = "RPT_008.docx";

    protected string TicketID = string.Empty;

    protected int ProcessID = -1;

    protected string DeviceID = string.Empty;

    protected string RPTBase64 = string.Empty;

    protected string BoxNo = string.Empty;

    protected bool IsRePrint = false;

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
                if (Request["BoxNo"] != null)
                    BoxNo = Request["BoxNo"].Trim();

                if (Request["IsRePrint"] != null)
                    IsRePrint = Request["IsRePrint"].ToBoolean();

                if (Request["TicketID"] != null)
                    TicketID = Request["TicketID"].Trim();

                if (Request["ProcessID"] != null)
                {
                    if (!int.TryParse(Request["ProcessID"].Trim(), out ProcessID))
                        ProcessID = -1;
                }

                if (Request["DeviceID"] != null)
                    DeviceID = Request["DeviceID"].Trim();

                if (string.IsNullOrEmpty(BoxNo))
                {
                    if (string.IsNullOrEmpty(TicketID))
                        throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));
                    if (ProcessID < 0)
                        throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_ProcessID"));
                    if (string.IsNullOrEmpty(DeviceID))
                        throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MachineID"));
                }

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
        DataTable TicketBox_DT = GetTicketAllBoxInfo();

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        string Query = string.Empty;

        if (string.IsNullOrEmpty(BoxNo))
        {
            Query = @"Select Top 1
                            TicketID,
                            SerialNo,
                            GoodQty,
                            FERTH,
                            TEXT1,
                            VERID,
                            (Select 
                                String_Agg(CHARG,'、') 
                                From 
                                (Select CHARG From 
                                 (
	                                (
		                                Select 
		                                Case 
			                                When IsNull(SEMIFINBATCH,'') = '' Then CHARG 			                             
			                                Else SEMIFINBATCH
		                                End As CHARG 
		                                From V_TSTicketResult 
		                                Where V_TSTicketResult.TicketID = @TicketID)
                                ) As CHARGResult Group By CHARG) As Result) As CHARG,
                            Case 
                                 When IsNull(Brand,'') = '' Then CINFO
                                 Else Brand
                            End As Brand, 
                            PackageQty,
                            Operator,
                            Base_Org.dbo.GetAccountWorkCode(Operator) As OperatorWorkCode,
                            (Select String_Agg(Base_Org.dbo.GetAccountWorkCode(T_TSTicketResultSecondOperator.SecondOperator),'、') From T_TSTicketResultSecondOperator Where T_TSTicketResultSecondOperator.TicketID = V_TSTicketResult.TicketID And T_TSTicketResultSecondOperator.ProcessID = V_TSTicketResult.ProcessID) As SecondOperatorWorkCode,
                            --(Select String_Agg(Base_Org.dbo.GetAccountName(T_TSTicketResultSecondOperator.SecondOperator),'、') From T_TSTicketResultSecondOperator Where T_TSTicketResultSecondOperator.TicketID = V_TSTicketResult.TicketID And T_TSTicketResultSecondOperator.ProcessID = V_TSTicketResult.ProcessID) As SecondOperatorName,
                            MachineID,
                            ReportTimeEnd
                            From V_TSTicketResult 
                            Inner Join T_TSDevice On V_TSTicketResult.DeviceID = T_TSDevice.DeviceID
                            Where TicketID = @TicketID And ProcessID = @ProcessID And V_TSTicketResult.DeviceID = @DeviceID
                            Order By CreateDate Desc";

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));
            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
        }
        else
        {
            string TicketsQuery = string.Empty;

            for (int i = 0; i < TicketBox_DT.Rows.Count; i++)
            {
                string ParameterName = "TicketID_" + i.ToString();

                if (i > 0)
                    TicketsQuery += @",@" + ParameterName;
                else
                    TicketsQuery += @"@" + ParameterName;

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketBox_DT.Rows[i]["TicketID"].ToString().Trim(), ParameterName));
            }

            Query = @"Select Top 1
                            TicketID,
                            SerialNo,
                            FERTH,
                            TEXT1,
                            VERID,
                            --如果类似Small只有SEMIFINBATCH，就取SEMIFINBATCH，如果球管只有CHARG就取CHARG，如果焊接的有CHARG和SEMIFINBATCH就取CHARG
                            (Select 
                                String_Agg(CHARG,'|') 
                                From 
                                (Select CHARG From 
                                 (
	                                (
		                                Select 
		                                Case 
			                                When IsNull(SEMIFINBATCH,'') = '' Then CHARG 
			                                Else SEMIFINBATCH
		                                End As CHARG 
		                                From V_TSTicketResult 
		                                Where V_TSTicketResult.TicketID In (" + TicketsQuery;

            Query += @"))
                                ) As CHARGResult Group By CHARG) As Result) As CHARG,
                             --当刻字号为空时，取原材料批号，如果焊接的有原材料的材料批号和半成品的材料批号的取原材料的材料批号
                            (Select 
								Top 1 String_Agg(Brand,'|')
								From (Select ProcessTypeID,
                                                Case When IsNull(Brand,'') = '' Then CINFO
                                                    Else Brand
                                                End As Brand 
                                            From V_TSTicketResult Where TicketID In (" + TicketsQuery;

            Query += @") Group By ProcessTypeID,Brand,CINFO) As TR Group By TR.ProcessTypeID Order By TR.ProcessTypeID Desc) As Brand,";

            Query += @"Base_Org.dbo.GetAccountWorkCode(Operator) As OperatorWorkCode,
            (Select String_Agg(Base_Org.dbo.GetAccountWorkCode(T_TSTicketResultSecondOperator.SecondOperator),'、') From T_TSTicketResultSecondOperator Where T_TSTicketResultSecondOperator.TicketID = V_TSTicketResult.TicketID And T_TSTicketResultSecondOperator.ProcessID = V_TSTicketResult.ProcessID) As SecondOperatorWorkCode,
            --(Select String_Agg(Base_Org.dbo.GetAccountName(T_TSTicketResultSecondOperator.SecondOperator),'、') From T_TSTicketResultSecondOperator Where T_TSTicketResultSecondOperator.TicketID = V_TSTicketResult.TicketID And T_TSTicketResultSecondOperator.ProcessID = V_TSTicketResult.ProcessID) As SecondOperatorName,
            MachineID,
            ReportTimeEnd
            From V_TSTicketResult 
            Inner Join T_TSDevice On V_TSTicketResult.DeviceID = T_TSDevice.DeviceID
            Where TicketID = @TicketID And ProcessID = @ProcessID And V_TSTicketResult.DeviceID = @DeviceID
            Order By CreateDate Desc";

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketBox_DT.Rows[0]["TicketID"].ToString().Trim()));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(TicketBox_DT.Rows[0]["ProcessID"].ToString().Trim()));
            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(TicketBox_DT.Rows[0]["DeviceID"].ToString().Trim()));
        }

        dbcb.CommandText = Query;

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        int PrintQty = 0;

        if (string.IsNullOrEmpty(BoxNo))
        {
            double GoodQty = Convert.ToDouble((int)DT.Rows[0]["GoodQty"]);

            double PackageQty = Convert.ToDouble((int)DT.Rows[0]["PackageQty"]);

            PrintQty = (int)Math.Ceiling(GoodQty / PackageQty);

            if (PrintQty < 0)
                PrintQty = 1;
        }
        else
            PrintQty = 1;

        //結果檔案資料流 List
        Dictionary<string, MemoryStream> ResultFileStream = new Dictionary<string, MemoryStream>();

        WR.LoadWordReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        DBAction DBA = new DBAction();

        Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        // 20240513 劉工決定，如果補印的話，箱標籤就在往下取號，不再沿用舊的。只有拚箱標籤繼續沿用(前端會傳箱號 + IsRePrint = true 進來)。
        //bool IsCreateBoxNo = (string.IsNullOrEmpty(BoxNo) && TicketBox_DT.Rows.Count < 1 || !IsRePrint);

        bool IsCreateBoxNo = string.IsNullOrEmpty(BoxNo);

        List<string> BoxNoValueList = new List<string>();

        for (int i = 0; i < PrintQty; i++)
        {
            //箱號
            string BoxNoValue = string.Empty;

            if (IsCreateBoxNo)
            {
                bool IsLoop = false;

                do
                {
                    BoxNoValue = BaseConfiguration.SerialObject[(short)26].取號();

                    if (!BoxNoValueList.Contains(BoxNoValue))
                    {
                        BoxNoValueList.Add(BoxNoValue);

                        IsLoop = false;
                    }
                    else
                        IsLoop = true;
                }
                while (IsLoop);

                Query = @"Insert Into T_WMProductBoxByTicket (BoxNo,TicketID,Qty,PackageQty,CreateAccountID) Values (@BoxNo,@TicketID,@Qty,@PackageQty,@CreateAccountID)";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNoValue));
                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
                dbcb.appendParameter(Schema.Attributes["Qty"].copy(((int)DT.Rows[0]["PackageQty"])));
                dbcb.appendParameter(Schema.Attributes["PackageQty"].copy((int)DT.Rows[0]["PackageQty"]));
                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy((int)DT.Rows[0]["Operator"]));

                DBA.AddCommandBuilder(dbcb);
            }
            else if (!string.IsNullOrEmpty(BoxNo))
                BoxNoValue = BoxNo;

            if (i > 0)
                WR.ReLoadWordReportTemplate();

            //箱號BarCode
            string BarcdoeData = BaseConfiguration.LoginUrl + "/TimeSheet/ViewPackageBox.aspx?A2=" + DT.Rows[0]["TicketID"].ToString().Trim() + "&A8=" + BoxNoValue;

            //QR Code 高寬度
            int PictureWidth = 50;
            int PictureHeight = 50;

            //箱號
            WR.WritDataToBookMark("BoxNo", BoxNoValue);

            //QR Code 高寬度
            WR.WritDataToBookMark("BoxNoBarCode", string.Empty, (Bitmap)Bitmap.FromStream(Util.QRCodeInfo.QRCodeGenerator(BarcdoeData, 0.6f, new Size(120, 120))), PictureWidth, PictureHeight);

            //WR.WritDataToBookMark("BoxNoBarCode", string.Empty, (Bitmap)Bitmap.FromStream(Util.QRCodeInfo.BarCodeGenerator(BoxNoValue, 0.6f, 35, Spire.Barcode.BarCodeType.Code39Extended, null, new Font("MingLiU", 28, FontStyle.Bold))), 120, 27);
            //零件號
            if (!string.IsNullOrEmpty(DT.Rows[0]["FERTH"].ToString().Trim()))
                WR.WritDataToBookMark("FERTH", string.Empty, (Bitmap)Bitmap.FromStream(Util.QRCodeInfo.BarCodeGenerator(DT.Rows[0]["FERTH"].ToString().Trim(), 0.6f, 35, Spire.Barcode.BarCodeType.Code39Extended, null, new Font("MingLiU", 28, FontStyle.Bold))), 120, 27);

            //刻字號和箱號
            if (!string.IsNullOrEmpty(DT.Rows[0]["Brand"].ToString().Trim()))
            {
                List<string> BrandList = DT.Rows[0]["Brand"].ToString().Trim().Split('|').ToList();

                string BrandValue = string.Empty;

                int Qty = 0;

                if (TicketBox_DT.Rows.Count > 0 && !IsCreateBoxNo)
                {
                    foreach (string Brand in BrandList)
                    {
                        Qty = TicketBox_DT.AsEnumerable().Where(Row => Row["Brand"].ToString().Trim() == Brand && Row["BoxNo"].ToString().Trim() == BoxNoValue).Sum(Row => (int)Row["Qty"]);

                        BrandValue += (!string.IsNullOrEmpty(BrandValue) ? "、" : string.Empty) + Brand;// + ((Qty < 1) ? string.Empty : " (" + Qty + ")");
                    }
                }
                else
                {
                    Qty = (int)DT.Rows[0]["PackageQty"];

                    BrandValue = DT.Rows[0]["Brand"].ToString().Trim();// + " (" + DT.Rows[0]["PackageQty"].ToString().Trim() + ")";
                }

                WR.WritDataToBookMark("Brand", BrandValue);

                WR.WritDataToBookMark("PackageQty", Qty.ToString());
            }

            // SAP批次號
            //if (!string.IsNullOrEmpty(DT.Rows[0]["CHARG"].ToString().Trim()))
            //{
            //    List<string> CHARGList = DT.Rows[0]["CHARG"].ToString().Trim().Split('|').ToList();

            //    string CHARGValue = string.Empty;

            //    if (TicketBox_DT.Rows.Count > 0 && !IsCreateBoxNo)
            //    {
            //        foreach (string CHARG in CHARGList)
            //        {
            //            var Qty = TicketBox_DT.AsEnumerable().Where(Row => Row["CHARG"].ToString().Trim() == CHARG && Row["BoxNo"].ToString().Trim() == BoxNoValue).Sum(Row => (int)Row["Qty"]);

            //            CHARGValue += (!string.IsNullOrEmpty(CHARGValue) ? "、" : string.Empty) + CHARG + ((Qty < 1) ? string.Empty : " (" + Qty + ")");
            //        }
            //    }
            //    else
            //        CHARGValue = DT.Rows[0]["CHARG"].ToString().Trim() + " (" + DT.Rows[0]["PackageQty"].ToString().Trim() + ")";

            //    WR.WritDataToBookMark("CHARG", CHARGValue);
            //}

            //流程卡
            WR.WritDataToBookMark("TicketID", DT.Rows[0]["TicketID"].ToString().Trim());
            //機台
            WR.WritDataToBookMark("MachineID", DT.Rows[0]["MachineID"].ToString().Trim());
            //生產版本
            WR.WritDataToBookMark("VERID", DT.Rows[0]["VERID"].ToString().Trim());
            //全檢人員
            string OperatorWorkCode = DT.Rows[0]["OperatorWorkCode"].ToString().Trim();

            if (!string.IsNullOrEmpty(DT.Rows[0]["SecondOperatorWorkCode"].ToString().Trim()))
                OperatorWorkCode += "、" + DT.Rows[0]["SecondOperatorWorkCode"].ToString().Trim();

            WR.WritDataToBookMark("Operator", OperatorWorkCode);
            //全檢日期
            WR.WritDataToBookMark("ReportTimeEnd", ((DateTime)DT.Rows[0]["ReportTimeEnd"]).ToCurrentUICultureStringTime());

            MemoryStream ms = new MemoryStream();

            WR.WriteToStream(ms, Spire.Doc.FileFormat.PDF);

            if (!ResultFileStream.Keys.Contains(BoxNoValue))
                ResultFileStream.Add(BoxNoValue, ms);
        }

        PdfDocumentBase PDFDoc = PdfDocument.MergeFiles(ResultFileStream.Values.ToArray());

        MemoryStream ResultMemoryStream = new MemoryStream();

        PDFDoc.Save(ResultMemoryStream);

        PDFDoc.Close();

        WR.TempDirectory.Delete(true);

        if (DBA.Count > 0)
            DBA.Execute();

        return ResultMemoryStream;
    }

    /// <summary>
    /// 取得流程卡所屬成品箱號資料表
    /// </summary>
    /// <returns>成品箱號資料表</returns>
    protected DataTable GetTicketAllBoxInfo()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Query = @"Select T_WMProductBoxByTicket.*,
                        (Select Top 1 ProcessID From V_TSTicketResult Where V_TSTicketResult.TicketID = T_WMProductBoxByTicket.TicketID Order By CreateDate Desc) As ProcessID,
                        (Select Top 1 DeviceID From V_TSTicketResult Where V_TSTicketResult.TicketID = T_WMProductBoxByTicket.TicketID Order By CreateDate Desc) As DeviceID,
                        (Select Top 1        
			              Case 
                            When IsNull(Brand,'') = '' Then CINFO
                        Else Brand
                        End As Brand 
                        From V_TSTicketResult Where V_TSTicketResult.TicketID = T_WMProductBoxByTicket.TicketID Order By CreateDate Desc) As Brand,
                        -- 如果类似Small只有SEMIFINBATCH，就取SEMIFINBATCH，如果球管只有CHARG就取CHARG，如果焊接的有CHARG和SEMIFINBATCH就取CHARG
                        (Select Top 1
							Case 
								When IsNull(SEMIFINBATCH,'') = '' Then CHARG 
			                    Else SEMIFINBATCH
		                     End As CHARG
						From V_TSTicketResult Where V_TSTicketResult.TicketID = T_WMProductBoxByTicket.TicketID Order By CreateDate Desc) As CHARG
                        From T_WMProductBoxByTicket ";

        if (string.IsNullOrEmpty(BoxNo))
        {
            Query += " Where T_WMProductBoxByTicket.TicketID = @TicketID Order By CreateDate Desc";

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        }
        else
        {
            Query += " Where T_WMProductBoxByTicket.BoxNo = @BoxNo Order By CreateDate Desc";

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));
        }

        dbcb.CommandText = Query;

        return CommonDB.ExecuteSelectQuery(dbcb);
    }
}