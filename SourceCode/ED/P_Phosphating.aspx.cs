using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;


public partial class ED_P_Phosphating : System.Web.UI.Page
{
    /// <summary>
    /// 目前寫死，因此這個值必須要跟T_Code的ChemicalAdding對的上
    /// </summary>
    protected string CACategoryID1 = "CA6";
    /// <summary>
    /// 目前寫死，因此這個值必須要跟T_Code的ChemicalAdding對的上
    /// </summary>
    protected string CACategoryID2 = "CA7";

    protected string DivID = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["PDate"] != null && !string.IsNullOrEmpty(Request["PDate"].ToString()))
                TB_PDate.Text = Request["PDate"].ToString().ToStringFromBase64();
            else if (Request["PID"] != null && !string.IsNullOrEmpty(Request["PID"].ToString()))
                HF_PID.Value = Request["PID"].ToString();
            else
            {
                Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_EmptyPDateOrPIDAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }

            LoadChemicalAddingTitle();

            LoadPrametersRemark();

            LoadDDLData();

            LoadData();
        }

        BT_Delete.Visible = !(string.IsNullOrEmpty(HF_PID.Value));
    }

    protected void LoadChemicalAddingTitle()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select CodeID,CodeName From T_Code Where CodeType = 'ChemicalAdding' And CodeID in (Select item From Base_Org.dbo.Split(@CodeID,'|')) And UICulture = @UICulture");

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CodeID", "nvarchar", 10000, CACategoryID1 + "|" + CACategoryID2));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        string ChemicalAdding_HeadText = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_ChemicalAdding_HeadText");

        DataRow CA1Row = DT.AsEnumerable().Where(Row => Row["CodeID"].ToString().Trim() == CACategoryID1).FirstOrDefault();

        DataRow CA2Row = DT.AsEnumerable().Where(Row => Row["CodeID"].ToString().Trim() == CACategoryID2).FirstOrDefault();

        CA1_Title.Text = ChemicalAdding_HeadText;

        CA2_Title.Text = ChemicalAdding_HeadText;

        if (CA1Row != null)
            CA1_Title.Text += "-" + CA1Row["CodeName"].ToString().Trim();
        if (CA2Row != null)
            CA2_Title.Text += "-" + CA2Row["CodeName"].ToString().Trim();
    }
    protected void LoadDDLData()
    {
        Util.ED.LaodWorkClass(DDL_WorkClass);

        Util.ED.LoadProductionLine(DDL_PLID);
    }
    protected void LoadPrametersRemark()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select * From T_EDPStandardValue Where PrametersID in (Select item From Base_Org.dbo.Split(@Prameters,'|'))");

        dbcb.appendParameter(Util.GetDataAccessAttribute("Prameters", "nvarchar", 10000, "EDP81|EDP82|EDP83|EDP84|EDP85|EDP86"));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DataRow EDP81Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP81").FirstOrDefault();

        DataRow EDP82Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP82").FirstOrDefault();

        DataRow EDP83Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP83").FirstOrDefault();

        DataRow EDP84Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP84").FirstOrDefault();

        DataRow EDP85Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP85").FirstOrDefault();

        DataRow EDP86Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP86").FirstOrDefault();

        string PHRemark1 = (string)GetLocalResourceObject("Str_ED_P_PHRemark1");
        string PHRemark2 = (string)GetLocalResourceObject("Str_ED_P_PHRemark2");

        string TemperatureRemark1 = (string)GetLocalResourceObject("Str_ED_P_Temperature_Remark1");
        string TemperatureRemark2 = (string)GetLocalResourceObject("Str_ED_P_Temperature_Remark2");
        string TemperatureRemark3 = (string)GetLocalResourceObject("Str_ED_P_Temperature_Remark3");
        string TemperatureRemark4 = (string)GetLocalResourceObject("Str_ED_P_Temperature_Remark4");

        string ProcessSecondRemark = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_ProcessSecondRemark");

        string FreeAcid1Remark1 = (string)GetLocalResourceObject("Str_ED_P_FreeAcidRemark1");
        string FreeAcid1Remark2 = (string)GetLocalResourceObject("Str_ED_P_FreeAcidRemark2");
        string FreeAcid1Remark3 = (string)GetLocalResourceObject("Str_ED_P_FreeAcidRemark3");
        string FreeAcid1Remark4 = (string)GetLocalResourceObject("Str_ED_P_FreeAcidRemark4");
        string FreeAcid1Remark5 = (string)GetLocalResourceObject("Str_ED_P_FreeAcidRemark5");
        string FreeAcid1Remark6 = (string)GetLocalResourceObject("Str_ED_P_FreeAcidRemark6");
        string FreeAcid1Remark7 = (string)GetLocalResourceObject("Str_ED_P_FreeAcidRemark7");
        string FreeAcid1Remark8 = (string)GetLocalResourceObject("Str_ED_P_FreeAcidRemark8");

        string TotalAcidityRemark1 = (string)GetLocalResourceObject("Str_ED_P_TotalAcidityRemark1");
        string TotalAcidityRemark2 = (string)GetLocalResourceObject("Str_ED_P_TotalAcidityRemark2");
        string TotalAcidityRemark3 = (string)GetLocalResourceObject("Str_ED_P_TotalAcidityRemark3");
        string TotalAcidityRemark4 = (string)GetLocalResourceObject("Str_ED_P_TotalAcidityRemark4");
        string TotalAcidityRemark5 = (string)GetLocalResourceObject("Str_ED_P_TotalAcidityRemark5");
        string TotalAcidityRemark6 = (string)GetLocalResourceObject("Str_ED_P_TotalAcidityRemark6");
        string TotalAcidityRemark7 = (string)GetLocalResourceObject("Str_ED_P_TotalAcidityRemark7");
        string TotalAcidityRemark8 = (string)GetLocalResourceObject("Str_ED_P_TotalAcidityRemark8");

        string PromotionPointRemark1 = (string)GetLocalResourceObject("Str_ED_P_PromotionPointRemark1");
        string PromotionPointRemark2 = (string)GetLocalResourceObject("Str_ED_P_PromotionPointRemark2");
        string PromotionPointRemark3 = (string)GetLocalResourceObject("Str_ED_P_PromotionPointRemark3");
        string PromotionPointRemark4 = (string)GetLocalResourceObject("Str_ED_P_PromotionPointRemark4");
        string PromotionPointRemark5 = (string)GetLocalResourceObject("Str_ED_P_PromotionPointRemark5");
        string PromotionPointRemark6 = (string)GetLocalResourceObject("Str_ED_P_PromotionPointRemark6");
        string PromotionPointRemark7 = (string)GetLocalResourceObject("Str_ED_P_PromotionPointRemark7");
        string PromotionPointRemark8 = (string)GetLocalResourceObject("Str_ED_P_PromotionPointRemark8");

        if (EDP81Row != null)
        {
            string MaxValue = ((decimal)EDP81Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP81Row["MinValue"]).ToString("0.##");

            TB_PHValue1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PHValue2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue2.Attributes.Add("data-MumberTypeMinValue", MinValue);

            PHRemark1 = string.Format(PHRemark1, MaxValue, MinValue);
            PHRemark2 = string.Format(PHRemark2, MaxValue, MinValue);
        }

        if (EDP82Row != null)
        {
            string MaxValue = ((decimal)EDP82Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP82Row["MinValue"]).ToString("0.##");

            TB_Temperature1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Temperature1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_Temperature2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Temperature2.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_Temperature3.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Temperature3.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_Temperature4.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Temperature4.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TemperatureRemark1 = string.Format(TemperatureRemark1, MaxValue, MinValue);
            TemperatureRemark2 = string.Format(TemperatureRemark2, MaxValue, MinValue);
            TemperatureRemark3 = string.Format(TemperatureRemark3, MaxValue, MinValue);
            TemperatureRemark4 = string.Format(TemperatureRemark4, MaxValue, MinValue);
        }

        if (EDP83Row != null)
        {
            string MaxValue = ((decimal)EDP83Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP83Row["MinValue"]).ToString("0.##");

            TB_ProcessSecond.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecond.Attributes.Add("data-MumberTypeMinValue", MinValue);

            ProcessSecondRemark = string.Format(ProcessSecondRemark, MaxValue, MinValue);
        }

        if (EDP84Row != null)
        {
            string MaxValue = ((decimal)EDP84Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP84Row["MinValue"]).ToString("0.##");

            TB_FreeAcid1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_FreeAcid1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_FreeAcid2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_FreeAcid2.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_FreeAcid3.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_FreeAcid3.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_FreeAcid4.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_FreeAcid4.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_FreeAcid5.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_FreeAcid5.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_FreeAcid6.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_FreeAcid6.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_FreeAcid7.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_FreeAcid7.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_FreeAcid8.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_FreeAcid8.Attributes.Add("data-MumberTypeMinValue", MinValue);

            FreeAcid1Remark1 = string.Format(FreeAcid1Remark1, MaxValue, MinValue);
            FreeAcid1Remark2 = string.Format(FreeAcid1Remark2, MaxValue, MinValue);
            FreeAcid1Remark3 = string.Format(FreeAcid1Remark3, MaxValue, MinValue);
            FreeAcid1Remark4 = string.Format(FreeAcid1Remark4, MaxValue, MinValue);
            FreeAcid1Remark5 = string.Format(FreeAcid1Remark5, MaxValue, MinValue);
            FreeAcid1Remark6 = string.Format(FreeAcid1Remark6, MaxValue, MinValue);
            FreeAcid1Remark7 = string.Format(FreeAcid1Remark7, MaxValue, MinValue);
            FreeAcid1Remark8 = string.Format(FreeAcid1Remark8, MaxValue, MinValue);
        }

        if (EDP85Row != null)
        {
            string MaxValue = ((decimal)EDP85Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP85Row["MinValue"]).ToString("0.##");

            TB_TotalAcidity1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_TotalAcidity1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_TotalAcidity2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_TotalAcidity2.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_TotalAcidity3.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_TotalAcidity3.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_TotalAcidity4.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_TotalAcidity4.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_TotalAcidity5.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_TotalAcidity5.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_TotalAcidity6.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_TotalAcidity6.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_TotalAcidity7.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_TotalAcidity7.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_TotalAcidity8.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_TotalAcidity8.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TotalAcidityRemark1 = string.Format(TotalAcidityRemark1, MaxValue, MinValue);
            TotalAcidityRemark2 = string.Format(TotalAcidityRemark2, MaxValue, MinValue);
            TotalAcidityRemark3 = string.Format(TotalAcidityRemark3, MaxValue, MinValue);
            TotalAcidityRemark4 = string.Format(TotalAcidityRemark4, MaxValue, MinValue);
            TotalAcidityRemark5 = string.Format(TotalAcidityRemark5, MaxValue, MinValue);
            TotalAcidityRemark6 = string.Format(TotalAcidityRemark6, MaxValue, MinValue);
            TotalAcidityRemark7 = string.Format(TotalAcidityRemark7, MaxValue, MinValue);
            TotalAcidityRemark8 = string.Format(TotalAcidityRemark8, MaxValue, MinValue);
        }

        if (EDP86Row != null)
        {
            string MaxValue = ((decimal)EDP86Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP86Row["MinValue"]).ToString("0.##");

            TB_PromotionPoint1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PromotionPoint1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PromotionPoint2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PromotionPoint2.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PromotionPoint3.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PromotionPoint3.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PromotionPoint4.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PromotionPoint4.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PromotionPoint5.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PromotionPoint5.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PromotionPoint6.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PromotionPoint6.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PromotionPoint7.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PromotionPoint7.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PromotionPoint8.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PromotionPoint8.Attributes.Add("data-MumberTypeMinValue", MinValue);

            PromotionPointRemark1 = string.Format(PromotionPointRemark1, MaxValue, MinValue);
            PromotionPointRemark2 = string.Format(PromotionPointRemark2, MaxValue, MinValue);
            PromotionPointRemark3 = string.Format(PromotionPointRemark3, MaxValue, MinValue);
            PromotionPointRemark4 = string.Format(PromotionPointRemark4, MaxValue, MinValue);
            PromotionPointRemark5 = string.Format(PromotionPointRemark5, MaxValue, MinValue);
            PromotionPointRemark6 = string.Format(PromotionPointRemark6, MaxValue, MinValue);
            PromotionPointRemark7 = string.Format(PromotionPointRemark7, MaxValue, MinValue);
            PromotionPointRemark8 = string.Format(PromotionPointRemark8, MaxValue, MinValue);
        }

        TB_PHValue1.Attributes.Add("title", PHRemark1);

        TB_PHValue2.Attributes.Add("title", PHRemark2);

        TB_Temperature1.Attributes.Add("title", TemperatureRemark1);

        TB_Temperature2.Attributes.Add("title", TemperatureRemark2);

        TB_Temperature3.Attributes.Add("title", TemperatureRemark3);

        TB_Temperature4.Attributes.Add("title", TemperatureRemark4);

        TB_ProcessSecond.Attributes.Add("title", ProcessSecondRemark);

        TB_FreeAcid1.Attributes.Add("title", FreeAcid1Remark1);

        TB_FreeAcid2.Attributes.Add("title", FreeAcid1Remark2);

        TB_FreeAcid3.Attributes.Add("title", FreeAcid1Remark3);

        TB_FreeAcid4.Attributes.Add("title", FreeAcid1Remark4);

        TB_FreeAcid5.Attributes.Add("title", FreeAcid1Remark5);

        TB_FreeAcid6.Attributes.Add("title", FreeAcid1Remark6);

        TB_FreeAcid7.Attributes.Add("title", FreeAcid1Remark7);

        TB_FreeAcid8.Attributes.Add("title", FreeAcid1Remark8);

        TB_TotalAcidity1.Attributes.Add("title", TotalAcidityRemark1);

        TB_TotalAcidity2.Attributes.Add("title", TotalAcidityRemark2);

        TB_TotalAcidity3.Attributes.Add("title", TotalAcidityRemark3);

        TB_TotalAcidity4.Attributes.Add("title", TotalAcidityRemark4);

        TB_TotalAcidity5.Attributes.Add("title", TotalAcidityRemark5);

        TB_TotalAcidity6.Attributes.Add("title", TotalAcidityRemark6);

        TB_TotalAcidity7.Attributes.Add("title", TotalAcidityRemark7);

        TB_TotalAcidity8.Attributes.Add("title", TotalAcidityRemark8);

        TB_PromotionPoint1.Attributes.Add("title", PromotionPointRemark1);

        TB_PromotionPoint2.Attributes.Add("title", PromotionPointRemark2);

        TB_PromotionPoint3.Attributes.Add("title", PromotionPointRemark3);

        TB_PromotionPoint4.Attributes.Add("title", PromotionPointRemark4);

        TB_PromotionPoint5.Attributes.Add("title", PromotionPointRemark5);

        TB_PromotionPoint6.Attributes.Add("title", PromotionPointRemark6);

        TB_PromotionPoint7.Attributes.Add("title", PromotionPointRemark7);

        TB_PromotionPoint8.Attributes.Add("title", PromotionPointRemark8);

        L_PHValue1.Text += "1";

        L_PHValue2.Text += "2";

        L_Temperature1.Text += "1";

        L_Temperature2.Text += "2";

        L_Temperature3.Text += "3";

        L_Temperature4.Text += "4";

        L_FreeAcid1.Text += "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_FreeAcid2.Text += "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

        L_FreeAcid3.Text += "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_FreeAcid4.Text += "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

        L_FreeAcid5.Text += "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_FreeAcid6.Text += "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

        L_FreeAcid7.Text += "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_FreeAcid8.Text += "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

        L_TotalAcidity1.Text += "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_TotalAcidity2.Text += "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

        L_TotalAcidity3.Text += "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_TotalAcidity4.Text += "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

        L_TotalAcidity5.Text += "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_TotalAcidity6.Text += "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

        L_TotalAcidity7.Text += "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_TotalAcidity8.Text += "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

        L_PromotionPoint1.Text += "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_PromotionPoint2.Text += "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

        L_PromotionPoint3.Text += "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_PromotionPoint4.Text += "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

        L_PromotionPoint5.Text += "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_PromotionPoint6.Text += "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

        L_PromotionPoint7.Text += "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

        L_PromotionPoint8.Text += "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

    }

    protected void LoadData()
    {
        if (string.IsNullOrEmpty(HF_PID.Value))
            return;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPPhosphating"];

        string Query = "Select *,Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName From T_EDPPhosphating Where PID = @PID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PID"].copy(HF_PID.Value.ToStringFromBase64()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return;

        DataRow Row = DT.Rows[0];

        TB_PDate.Text = ((DateTime)Row["PDate"]).ToCurrentUICultureString();

        DDL_WorkClass.SelectedValue = Row["WorkClassID"].ToString().Trim();

        DDL_PLID.SelectedValue = Row["PLID"].ToString().Trim();

        decimal PHValue1 = (decimal)Row["PHValue1"];

        if (PHValue1 > -1)
            TB_PHValue1.Text = PHValue1.ToString();

        decimal PHValue2 = (decimal)Row["PHValue2"];

        if (PHValue2 > -1)
            TB_PHValue2.Text = PHValue2.ToString();

        int ProcessSecond = (int)Row["ProcessSecond"];

        if (ProcessSecond > -1)
            TB_ProcessSecond.Text = ProcessSecond.ToString();

        decimal Temperature1 = (decimal)Row["Temperature1"];

        if (Temperature1 > -1)
            TB_Temperature1.Text = Temperature1.ToString();

        decimal Temperature2 = (decimal)Row["Temperature2"];

        if (Temperature2 > -1)
            TB_Temperature2.Text = Temperature2.ToString();

        decimal Temperature3 = (decimal)Row["Temperature3"];

        if (Temperature3 > -1)
            TB_Temperature3.Text = Temperature3.ToString();

        decimal Temperature4 = (decimal)Row["Temperature4"];

        if (Temperature4 > -1)
            TB_Temperature4.Text = Temperature4.ToString();

        decimal FreeAcid1 = (decimal)Row["FreeAcid1"];

        if (FreeAcid1 > -1)
            TB_FreeAcid1.Text = FreeAcid1.ToString();

        decimal FreeAcid2 = (decimal)Row["FreeAcid2"];

        if (FreeAcid2 > -1)
            TB_FreeAcid2.Text = FreeAcid2.ToString();

        decimal FreeAcid3 = (decimal)Row["FreeAcid3"];

        if (FreeAcid3 > -1)
            TB_FreeAcid3.Text = FreeAcid3.ToString();

        decimal FreeAcid4 = (decimal)Row["FreeAcid4"];

        if (FreeAcid4 > -1)
            TB_FreeAcid4.Text = FreeAcid4.ToString();

        decimal FreeAcid5 = (decimal)Row["FreeAcid5"];

        if (FreeAcid5 > -1)
            TB_FreeAcid5.Text = FreeAcid5.ToString();

        decimal FreeAcid6 = (decimal)Row["FreeAcid6"];

        if (FreeAcid6 > -1)
            TB_FreeAcid6.Text = FreeAcid6.ToString();

        decimal FreeAcid7 = (decimal)Row["FreeAcid7"];

        if (FreeAcid7 > -1)
            TB_FreeAcid7.Text = FreeAcid7.ToString();

        decimal FreeAcid8 = (decimal)Row["FreeAcid8"];

        if (FreeAcid8 > -1)
            TB_FreeAcid8.Text = FreeAcid8.ToString();

        decimal TotalAcidity1 = (decimal)Row["TotalAcidity1"];

        if (TotalAcidity1 > -1)
            TB_TotalAcidity1.Text = TotalAcidity1.ToString();

        decimal TotalAcidity2 = (decimal)Row["TotalAcidity2"];

        if (TotalAcidity2 > -1)
            TB_TotalAcidity2.Text = TotalAcidity2.ToString();

        decimal TotalAcidity3 = (decimal)Row["TotalAcidity3"];

        if (TotalAcidity3 > -1)
            TB_TotalAcidity3.Text = TotalAcidity3.ToString();

        decimal TotalAcidity4 = (decimal)Row["TotalAcidity4"];

        if (TotalAcidity4 > -1)
            TB_TotalAcidity4.Text = TotalAcidity4.ToString();

        decimal TotalAcidity5 = (decimal)Row["TotalAcidity5"];

        if (TotalAcidity5 > -1)
            TB_TotalAcidity5.Text = TotalAcidity5.ToString();

        decimal TotalAcidity6 = (decimal)Row["TotalAcidity6"];

        if (TotalAcidity6 > -1)
            TB_TotalAcidity6.Text = TotalAcidity6.ToString();

        decimal TotalAcidity7 = (decimal)Row["TotalAcidity7"];

        if (TotalAcidity7 > -1)
            TB_TotalAcidity7.Text = TotalAcidity7.ToString();

        decimal TotalAcidity8 = (decimal)Row["TotalAcidity8"];

        if (TotalAcidity8 > -1)
            TB_TotalAcidity8.Text = TotalAcidity8.ToString();

        decimal PromotionPoint1 = (decimal)Row["PromotionPoint1"];

        if (PromotionPoint1 > -1)
            TB_PromotionPoint1.Text = PromotionPoint1.ToString();

        decimal PromotionPoint2 = (decimal)Row["PromotionPoint2"];

        if (PromotionPoint2 > -1)
            TB_PromotionPoint2.Text = PromotionPoint2.ToString();

        decimal PromotionPoint3 = (decimal)Row["PromotionPoint3"];

        if (PromotionPoint3 > -1)
            TB_PromotionPoint3.Text = PromotionPoint3.ToString();

        decimal PromotionPoint4 = (decimal)Row["PromotionPoint4"];

        if (PromotionPoint4 > -1)
            TB_PromotionPoint4.Text = PromotionPoint4.ToString();

        decimal PromotionPoint5 = (decimal)Row["PromotionPoint5"];

        if (PromotionPoint5 > -1)
            TB_PromotionPoint5.Text = PromotionPoint5.ToString();

        decimal PromotionPoint6 = (decimal)Row["PromotionPoint6"];

        if (PromotionPoint6 > -1)
            TB_PromotionPoint6.Text = PromotionPoint6.ToString();

        decimal PromotionPoint7 = (decimal)Row["PromotionPoint7"];

        if (PromotionPoint7 > -1)
            TB_PromotionPoint7.Text = PromotionPoint7.ToString();

        decimal PromotionPoint8 = (decimal)Row["PromotionPoint8"];

        if (PromotionPoint8 > -1)
            TB_PromotionPoint8.Text = PromotionPoint8.ToString();

        TB_Remark.Text = Row["Remark"].ToString().Trim();

        WUC_DataCreateInfo.SetControlData(Row);

        Query = "Select * From T_EDChemicalAdding Where PID = @PID Order By SerialNo Asc";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PID"].copy(HF_PID.Value.ToStringFromBase64()));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        foreach (DataRow R in DT.Rows)
        {
            if (R["CategoryID"].ToString().Trim() == CACategoryID1)
            {
                if ((short)R["SerialNo"] == 1)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA1_AddDateTime1.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA1_Qty1.Text = Qty.ToString();

                    TB_CA1_LotNumber1.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 2)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA1_AddDateTime2.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA1_Qty2.Text = Qty.ToString();

                    TB_CA1_LotNumber2.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 3)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA1_AddDateTime3.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA1_Qty3.Text = Qty.ToString();

                    TB_CA1_LotNumber3.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 4)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA1_AddDateTime4.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA1_Qty4.Text = Qty.ToString();

                    TB_CA1_LotNumber4.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 5)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA1_AddDateTime5.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA1_Qty5.Text = Qty.ToString();

                    TB_CA1_LotNumber5.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
            }

            if (R["CategoryID"].ToString().Trim() == CACategoryID2)
            {
                if ((short)R["SerialNo"] == 1)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA2_AddDateTime1.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA2_Qty1.Text = Qty.ToString();

                    TB_CA2_LotNumber1.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 2)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA2_AddDateTime2.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA2_Qty2.Text = Qty.ToString();

                    TB_CA2_LotNumber2.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 3)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA2_AddDateTime3.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA2_Qty3.Text = Qty.ToString();

                    TB_CA2_LotNumber3.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 4)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA2_AddDateTime4.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA2_Qty4.Text = Qty.ToString();

                    TB_CA2_LotNumber4.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 5)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA2_AddDateTime5.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA2_Qty5.Text = Qty.ToString();

                    TB_CA2_LotNumber5.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
            }

        }
    }


    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            string Query = string.Empty;

            string PID = string.Empty;

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPPhosphating"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            DateTime PDate = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_PDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out PDate))
                PDate = DateTime.Parse("1900/01/01");

            if (PDate.Year < 1911)
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if (string.IsNullOrEmpty(DDL_WorkClass.SelectedValue) || string.IsNullOrEmpty(DDL_PLID.SelectedValue))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            // 至少要輸入一個參數
            if (string.IsNullOrEmpty(TB_PHValue1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PHValue2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Temperature1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Temperature2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Temperature3.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Temperature4.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecond.Text.Trim()) &&
                string.IsNullOrEmpty(TB_FreeAcid1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_FreeAcid2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_FreeAcid3.Text.Trim()) &&
                string.IsNullOrEmpty(TB_FreeAcid4.Text.Trim()) &&
                string.IsNullOrEmpty(TB_FreeAcid5.Text.Trim()) &&
                string.IsNullOrEmpty(TB_FreeAcid6.Text.Trim()) &&
                string.IsNullOrEmpty(TB_FreeAcid7.Text.Trim()) &&
                string.IsNullOrEmpty(TB_FreeAcid8.Text.Trim()) &&
                string.IsNullOrEmpty(TB_TotalAcidity1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_TotalAcidity2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_TotalAcidity3.Text.Trim()) &&
                string.IsNullOrEmpty(TB_TotalAcidity4.Text.Trim()) &&
                string.IsNullOrEmpty(TB_TotalAcidity5.Text.Trim()) &&
                string.IsNullOrEmpty(TB_TotalAcidity6.Text.Trim()) &&
                string.IsNullOrEmpty(TB_TotalAcidity7.Text.Trim()) &&
                string.IsNullOrEmpty(TB_TotalAcidity8.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PromotionPoint1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PromotionPoint2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PromotionPoint3.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PromotionPoint4.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PromotionPoint5.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PromotionPoint6.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PromotionPoint7.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PromotionPoint8.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));

            if (string.IsNullOrEmpty(HF_PID.Value))
            {
                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Insert Into T_EDPPhosphating(PID,PDate,WorkClassID,PLID,PHValue1,PHValue2,Temperature1,Temperature2,Temperature3,Temperature4,ProcessSecond
                          ,FreeAcid1,FreeAcid2,FreeAcid3,FreeAcid4,FreeAcid5,FreeAcid6,FreeAcid7,FreeAcid8
                          ,TotalAcidity1,TotalAcidity2,TotalAcidity3,TotalAcidity4,TotalAcidity5,TotalAcidity6,TotalAcidity7,TotalAcidity8
                          ,PromotionPoint1,PromotionPoint2,PromotionPoint3,PromotionPoint4,PromotionPoint5,PromotionPoint6,PromotionPoint7,PromotionPoint8
                          ,Remark,CreateAccountID) 
                          Values (@PID,@PDate,@WorkClassID,@PLID,@PHValue1,@PHValue2,@Temperature1,@Temperature2,@Temperature3,@Temperature4,@ProcessSecond
                          ,@FreeAcid1,@FreeAcid2,@FreeAcid3,@FreeAcid4,@FreeAcid5,@FreeAcid6,@FreeAcid7,@FreeAcid8
                          ,@TotalAcidity1,@TotalAcidity2,@TotalAcidity3,@TotalAcidity4,@TotalAcidity5,@TotalAcidity6,@TotalAcidity7,@TotalAcidity8
                          ,@PromotionPoint1,@PromotionPoint2,@PromotionPoint3,@PromotionPoint4,@PromotionPoint5,@PromotionPoint6,@PromotionPoint7,@PromotionPoint8
                          ,@Remark,@CreateAccountID)";

                PID = BaseConfiguration.SerialObject[(short)8].取號();

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));

            }
            else
            {
                PID = HF_PID.Value.ToStringFromBase64();

                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue, PID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Update T_EDPPhosphating Set PDate = @PDate,WorkClassID = @WorkClassID,PLID = @PLID,PHValue1=@PHValue1,PHValue2=@PHValue2,Temperature1=@Temperature1,Temperature2=@Temperature2,
                          Temperature3=@Temperature3,Temperature4=@Temperature4,ProcessSecond=@ProcessSecond,FreeAcid1=@FreeAcid1,
                          FreeAcid2=@FreeAcid2,FreeAcid3=@FreeAcid3,FreeAcid4=@FreeAcid4,FreeAcid5=@FreeAcid5,
                          FreeAcid6=@FreeAcid6,FreeAcid7=@FreeAcid7,FreeAcid8=@FreeAcid8,TotalAcidity1=@TotalAcidity1,
                          TotalAcidity2=@TotalAcidity2,TotalAcidity3=@TotalAcidity3,TotalAcidity4=@TotalAcidity4,TotalAcidity5=@TotalAcidity5,
                          TotalAcidity6=@TotalAcidity6,TotalAcidity7=@TotalAcidity7,TotalAcidity8=@TotalAcidity8,PromotionPoint1=@PromotionPoint1,
                          PromotionPoint2=@PromotionPoint2,PromotionPoint3=@PromotionPoint3,PromotionPoint4=@PromotionPoint4,PromotionPoint5=@PromotionPoint5,
                          PromotionPoint6=@PromotionPoint6,PromotionPoint7=@PromotionPoint7,PromotionPoint8=@PromotionPoint8,Remark=@Remark,
                          ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where PID = @PID";

                dbcb.appendParameter(Schema.Attributes["ModifyAccountID"].copy(Master.AccountID));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["PID"].copy(PID));
            dbcb.appendParameter(Schema.Attributes["PDate"].copy(PDate));
            dbcb.appendParameter(Schema.Attributes["WorkClassID"].copy((DDL_WorkClass.SelectedValue)));
            dbcb.appendParameter(Schema.Attributes["PLID"].copy((DDL_PLID.SelectedValue)));

            decimal PHValue1 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue1.Text.Trim()) && !decimal.TryParse(TB_PHValue1.Text.Trim(), out PHValue1))
                PHValue1 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue1"].copy(PHValue1));

            decimal PHValue2 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue2.Text.Trim()) && !decimal.TryParse(TB_PHValue2.Text.Trim(), out PHValue2))
                PHValue2 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue2"].copy(PHValue2));

            int ProcessSecond = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecond.Text.Trim()) && !int.TryParse(TB_ProcessSecond.Text.Trim(), out ProcessSecond))
                ProcessSecond = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond"].copy(ProcessSecond));

            decimal Temperature1 = -1;

            if (!string.IsNullOrEmpty(TB_Temperature1.Text.Trim()) && !decimal.TryParse(TB_Temperature1.Text.Trim(), out Temperature1))
                Temperature1 = -1;
            dbcb.appendParameter(Schema.Attributes["Temperature1"].copy(Temperature1));

            decimal Temperature2 = -1;

            if (!string.IsNullOrEmpty(TB_Temperature2.Text.Trim()) && !decimal.TryParse(TB_Temperature2.Text.Trim(), out Temperature2))
                Temperature2 = -1;
            dbcb.appendParameter(Schema.Attributes["Temperature2"].copy(Temperature2));

            decimal Temperature3 = -1;

            if (!string.IsNullOrEmpty(TB_Temperature3.Text.Trim()) && !decimal.TryParse(TB_Temperature3.Text.Trim(), out Temperature3))
                Temperature3 = -1;
            dbcb.appendParameter(Schema.Attributes["Temperature3"].copy(Temperature3));

            decimal Temperature4 = -1;

            if (!string.IsNullOrEmpty(TB_Temperature4.Text.Trim()) && !decimal.TryParse(TB_Temperature4.Text.Trim(), out Temperature4))
                Temperature4 = -1;
            dbcb.appendParameter(Schema.Attributes["Temperature4"].copy(Temperature4));

            decimal FreeAcid1 = -1;

            if (!string.IsNullOrEmpty(TB_FreeAcid1.Text.Trim()) && !decimal.TryParse(TB_FreeAcid1.Text.Trim(), out FreeAcid1))
                FreeAcid1 = -1;
            dbcb.appendParameter(Schema.Attributes["FreeAcid1"].copy(FreeAcid1));

            decimal FreeAcid2 = -1;

            if (!string.IsNullOrEmpty(TB_FreeAcid2.Text.Trim()) && !decimal.TryParse(TB_FreeAcid2.Text.Trim(), out FreeAcid2))
                FreeAcid2 = -1;
            dbcb.appendParameter(Schema.Attributes["FreeAcid2"].copy(FreeAcid2));

            decimal FreeAcid3 = -1;

            if (!string.IsNullOrEmpty(TB_FreeAcid3.Text.Trim()) && !decimal.TryParse(TB_FreeAcid3.Text.Trim(), out FreeAcid3))
                FreeAcid3 = -1;
            dbcb.appendParameter(Schema.Attributes["FreeAcid3"].copy(FreeAcid3));

            decimal FreeAcid4 = -1;

            if (!string.IsNullOrEmpty(TB_FreeAcid4.Text.Trim()) && !decimal.TryParse(TB_FreeAcid4.Text.Trim(), out FreeAcid4))
                FreeAcid4 = -1;
            dbcb.appendParameter(Schema.Attributes["FreeAcid4"].copy(FreeAcid4));

            decimal FreeAcid5 = -1;

            if (!string.IsNullOrEmpty(TB_FreeAcid5.Text.Trim()) && !decimal.TryParse(TB_FreeAcid5.Text.Trim(), out FreeAcid5))
                FreeAcid5 = -1;
            dbcb.appendParameter(Schema.Attributes["FreeAcid5"].copy(FreeAcid5));

            decimal FreeAcid6 = -1;

            if (!string.IsNullOrEmpty(TB_FreeAcid6.Text.Trim()) && !decimal.TryParse(TB_FreeAcid6.Text.Trim(), out FreeAcid6))
                FreeAcid6 = -1;
            dbcb.appendParameter(Schema.Attributes["FreeAcid6"].copy(FreeAcid6));

            decimal FreeAcid7 = -1;

            if (!string.IsNullOrEmpty(TB_FreeAcid7.Text.Trim()) && !decimal.TryParse(TB_FreeAcid7.Text.Trim(), out FreeAcid7))
                FreeAcid7 = -1;
            dbcb.appendParameter(Schema.Attributes["FreeAcid7"].copy(FreeAcid7));

            decimal FreeAcid8 = -1;

            if (!string.IsNullOrEmpty(TB_FreeAcid8.Text.Trim()) && !decimal.TryParse(TB_FreeAcid8.Text.Trim(), out FreeAcid8))
                FreeAcid8 = -1;
            dbcb.appendParameter(Schema.Attributes["FreeAcid8"].copy(FreeAcid8));

            decimal TotalAcidity1 = -1;

            if (!string.IsNullOrEmpty(TB_TotalAcidity1.Text.Trim()) && !decimal.TryParse(TB_TotalAcidity1.Text.Trim(), out TotalAcidity1))
                TotalAcidity1 = -1;
            dbcb.appendParameter(Schema.Attributes["TotalAcidity1"].copy(TotalAcidity1));

            decimal TotalAcidity2 = -1;

            if (!string.IsNullOrEmpty(TB_TotalAcidity2.Text.Trim()) && !decimal.TryParse(TB_TotalAcidity2.Text.Trim(), out TotalAcidity2))
                TotalAcidity2 = -1;
            dbcb.appendParameter(Schema.Attributes["TotalAcidity2"].copy(TotalAcidity2));

            decimal TotalAcidity3 = -1;

            if (!string.IsNullOrEmpty(TB_TotalAcidity3.Text.Trim()) && !decimal.TryParse(TB_TotalAcidity3.Text.Trim(), out TotalAcidity3))
                TotalAcidity3 = -1;
            dbcb.appendParameter(Schema.Attributes["TotalAcidity3"].copy(TotalAcidity3));

            decimal TotalAcidity4 = -1;

            if (!string.IsNullOrEmpty(TB_TotalAcidity4.Text.Trim()) && !decimal.TryParse(TB_TotalAcidity4.Text.Trim(), out TotalAcidity4))
                TotalAcidity4 = -1;
            dbcb.appendParameter(Schema.Attributes["TotalAcidity4"].copy(TotalAcidity4));

            decimal TotalAcidity5 = -1;

            if (!string.IsNullOrEmpty(TB_TotalAcidity5.Text.Trim()) && !decimal.TryParse(TB_TotalAcidity5.Text.Trim(), out TotalAcidity5))
                TotalAcidity5 = -1;
            dbcb.appendParameter(Schema.Attributes["TotalAcidity5"].copy(TotalAcidity5));

            decimal TotalAcidity6 = -1;

            if (!string.IsNullOrEmpty(TB_TotalAcidity6.Text.Trim()) && !decimal.TryParse(TB_TotalAcidity6.Text.Trim(), out TotalAcidity6))
                TotalAcidity6 = -1;
            dbcb.appendParameter(Schema.Attributes["TotalAcidity6"].copy(TotalAcidity6));

            decimal TotalAcidity7 = -1;

            if (!string.IsNullOrEmpty(TB_TotalAcidity7.Text.Trim()) && !decimal.TryParse(TB_TotalAcidity7.Text.Trim(), out TotalAcidity7))
                TotalAcidity7 = -1;
            dbcb.appendParameter(Schema.Attributes["TotalAcidity7"].copy(TotalAcidity7));

            decimal TotalAcidity8 = -1;

            if (!string.IsNullOrEmpty(TB_TotalAcidity8.Text.Trim()) && !decimal.TryParse(TB_TotalAcidity8.Text.Trim(), out TotalAcidity8))
                TotalAcidity8 = -1;
            dbcb.appendParameter(Schema.Attributes["TotalAcidity8"].copy(TotalAcidity8));

            decimal PromotionPoint1 = -1;

            if (!string.IsNullOrEmpty(TB_PromotionPoint1.Text.Trim()) && !decimal.TryParse(TB_PromotionPoint1.Text.Trim(), out PromotionPoint1))
                PromotionPoint1 = -1;
            dbcb.appendParameter(Schema.Attributes["PromotionPoint1"].copy(PromotionPoint1));

            decimal PromotionPoint2 = -1;

            if (!string.IsNullOrEmpty(TB_PromotionPoint2.Text.Trim()) && !decimal.TryParse(TB_PromotionPoint2.Text.Trim(), out PromotionPoint2))
                PromotionPoint2 = -1;
            dbcb.appendParameter(Schema.Attributes["PromotionPoint2"].copy(PromotionPoint2));

            decimal PromotionPoint3 = -1;

            if (!string.IsNullOrEmpty(TB_PromotionPoint3.Text.Trim()) && !decimal.TryParse(TB_PromotionPoint3.Text.Trim(), out PromotionPoint3))
                PromotionPoint3 = -1;
            dbcb.appendParameter(Schema.Attributes["PromotionPoint3"].copy(PromotionPoint3));

            decimal PromotionPoint4 = -1;

            if (!string.IsNullOrEmpty(TB_PromotionPoint4.Text.Trim()) && !decimal.TryParse(TB_PromotionPoint4.Text.Trim(), out PromotionPoint4))
                PromotionPoint4 = -1;
            dbcb.appendParameter(Schema.Attributes["PromotionPoint4"].copy(PromotionPoint4));

            decimal PromotionPoint5 = -1;

            if (!string.IsNullOrEmpty(TB_PromotionPoint5.Text.Trim()) && !decimal.TryParse(TB_PromotionPoint5.Text.Trim(), out PromotionPoint5))
                PromotionPoint5 = -1;
            dbcb.appendParameter(Schema.Attributes["PromotionPoint5"].copy(PromotionPoint5));

            decimal PromotionPoint6 = -1;

            if (!string.IsNullOrEmpty(TB_PromotionPoint6.Text.Trim()) && !decimal.TryParse(TB_PromotionPoint6.Text.Trim(), out PromotionPoint6))
                PromotionPoint6 = -1;
            dbcb.appendParameter(Schema.Attributes["PromotionPoint6"].copy(PromotionPoint6));

            decimal PromotionPoint7 = -1;

            if (!string.IsNullOrEmpty(TB_PromotionPoint7.Text.Trim()) && !decimal.TryParse(TB_PromotionPoint7.Text.Trim(), out PromotionPoint7))
                PromotionPoint7 = -1;
            dbcb.appendParameter(Schema.Attributes["PromotionPoint7"].copy(PromotionPoint7));

            decimal PromotionPoint8 = -1;

            if (!string.IsNullOrEmpty(TB_PromotionPoint8.Text.Trim()) && !decimal.TryParse(TB_PromotionPoint8.Text.Trim(), out PromotionPoint8))
                PromotionPoint8 = -1;
            dbcb.appendParameter(Schema.Attributes["PromotionPoint8"].copy(PromotionPoint8));

            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            short SerialNo = 1;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID1));

            if (!string.IsNullOrEmpty(TB_CA1_AddDateTime1.Text.Trim()) && !string.IsNullOrEmpty(TB_CA1_Qty1.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID1, PDate, TB_CA1_AddDateTime1, TB_CA1_Qty1, TB_CA1_LotNumber1));
            else if (!string.IsNullOrEmpty(TB_CA1_AddDateTime1.Text.Trim() + TB_CA1_Qty1.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA1_Qty1.Text.Trim()) && double.Parse(TB_CA1_Qty1.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 2;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID1));

            if (!string.IsNullOrEmpty(TB_CA1_AddDateTime2.Text.Trim()) && !string.IsNullOrEmpty(TB_CA1_Qty2.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID1, PDate, TB_CA1_AddDateTime2, TB_CA1_Qty2, TB_CA1_LotNumber2));
            else if (!string.IsNullOrEmpty(TB_CA1_AddDateTime2.Text.Trim() + TB_CA1_Qty2.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA1_Qty2.Text.Trim()) && double.Parse(TB_CA1_Qty2.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 3;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID1));

            if (!string.IsNullOrEmpty(TB_CA1_AddDateTime3.Text.Trim()) && !string.IsNullOrEmpty(TB_CA1_Qty3.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID1, PDate, TB_CA1_AddDateTime3, TB_CA1_Qty3, TB_CA1_LotNumber3));
            else if (!string.IsNullOrEmpty(TB_CA1_AddDateTime3.Text.Trim() + TB_CA1_Qty3.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA1_Qty3.Text.Trim()) && double.Parse(TB_CA1_Qty3.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 4;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID1));

            if (!string.IsNullOrEmpty(TB_CA1_AddDateTime4.Text.Trim()) && !string.IsNullOrEmpty(TB_CA1_Qty4.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID1, PDate, TB_CA1_AddDateTime4, TB_CA1_Qty4, TB_CA1_LotNumber4));
            else if (!string.IsNullOrEmpty(TB_CA1_AddDateTime4.Text.Trim() + TB_CA1_Qty4.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA1_Qty4.Text.Trim()) && double.Parse(TB_CA1_Qty4.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 5;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID1));

            if (!string.IsNullOrEmpty(TB_CA1_AddDateTime5.Text.Trim()) && !string.IsNullOrEmpty(TB_CA1_Qty5.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID1, PDate, TB_CA1_AddDateTime5, TB_CA1_Qty5, TB_CA1_LotNumber5));
            else if (!string.IsNullOrEmpty(TB_CA1_AddDateTime5.Text.Trim() + TB_CA1_Qty5.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA1_Qty5.Text.Trim()) && double.Parse(TB_CA1_Qty5.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 1;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID2));

            if (!string.IsNullOrEmpty(TB_CA2_AddDateTime1.Text.Trim()) && !string.IsNullOrEmpty(TB_CA2_Qty1.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID2, PDate, TB_CA2_AddDateTime1, TB_CA2_Qty1, TB_CA2_LotNumber1));
            else if (!string.IsNullOrEmpty(TB_CA2_AddDateTime1.Text.Trim() + TB_CA2_Qty1.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA2_Qty1.Text.Trim()) && double.Parse(TB_CA2_Qty1.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 2;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID2));

            if (!string.IsNullOrEmpty(TB_CA2_AddDateTime2.Text.Trim()) && !string.IsNullOrEmpty(TB_CA2_Qty2.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID2, PDate, TB_CA2_AddDateTime2, TB_CA2_Qty2, TB_CA2_LotNumber2));
            else if (!string.IsNullOrEmpty(TB_CA2_AddDateTime2.Text.Trim() + TB_CA2_Qty2.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA2_Qty2.Text.Trim()) && double.Parse(TB_CA2_Qty2.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 3;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID2));

            if (!string.IsNullOrEmpty(TB_CA2_AddDateTime3.Text.Trim()) && !string.IsNullOrEmpty(TB_CA2_Qty3.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID2, PDate, TB_CA2_AddDateTime3, TB_CA2_Qty3, TB_CA2_LotNumber3));
            else if (!string.IsNullOrEmpty(TB_CA2_AddDateTime3.Text.Trim() + TB_CA2_Qty3.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA2_Qty3.Text.Trim()) && double.Parse(TB_CA2_Qty3.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 4;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID2));

            if (!string.IsNullOrEmpty(TB_CA2_AddDateTime4.Text.Trim()) && !string.IsNullOrEmpty(TB_CA2_Qty4.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID2, PDate, TB_CA2_AddDateTime4, TB_CA2_Qty4, TB_CA2_LotNumber4));
            else if (!string.IsNullOrEmpty(TB_CA2_AddDateTime4.Text.Trim() + TB_CA2_Qty4.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA2_Qty4.Text.Trim()) && double.Parse(TB_CA2_Qty4.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 5;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID2));

            if (!string.IsNullOrEmpty(TB_CA2_AddDateTime5.Text.Trim()) && !string.IsNullOrEmpty(TB_CA2_Qty5.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID2, PDate, TB_CA2_AddDateTime5, TB_CA2_Qty5, TB_CA2_LotNumber5));
            else if (!string.IsNullOrEmpty(TB_CA2_AddDateTime5.Text.Trim() + TB_CA2_Qty5.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA2_Qty5.Text.Trim()) && double.Parse(TB_CA2_Qty5.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            Util.ED.DeletEDData(HF_PID.Value.ToStringFromBase64(), ((short)Util.ED.PIDType.T_EDPPhosphating), true);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}