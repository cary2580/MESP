using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;

public partial class ED_P_ECoating : System.Web.UI.Page
{
    /// <summary>
    /// 目前寫死，因此這個值必須要跟T_Code的ChemicalAdding對的上
    /// </summary>
    protected string CA1CategoryID = "CA8";
    /// <summary>
    /// 目前寫死，因此這個值必須要跟T_Code的ChemicalAdding對的上
    /// </summary>
    protected string CA2CategoryID = "CA9";
    /// <summary>
    /// 目前寫死，因此這個值必須要跟T_Code的ChemicalAdding對的上
    /// </summary>
    protected string CA3CategoryID = "CA10";
    /// <summary>
    /// 目前寫死，因此這個值必須要跟T_Code的ChemicalAdding對的上
    /// </summary>
    protected string CA4CategoryID = "CA11";

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

    protected void LoadDDLData()
    {
        Util.ED.LaodWorkClass(DDL_WorkClass);

        Util.ED.LoadProductionLine(DDL_PLID);
    }

    protected void LoadPrametersRemark()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select * From T_EDPStandardValue Where PrametersID in (Select item From Base_Org.dbo.Split(@Prameters,'|'))");

        dbcb.appendParameter(Util.GetDataAccessAttribute("Prameters", "nvarchar", 10000, "EDP91|EDP92|EDP93|EDP94|EDP95|EDP96|EDP97"));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DataRow EDP91Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP91").FirstOrDefault();

        DataRow EDP92Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP92").FirstOrDefault();

        DataRow EDP93Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP93").FirstOrDefault();

        DataRow EDP94Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP94").FirstOrDefault();

        DataRow EDP95Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP95").FirstOrDefault();

        DataRow EDP96Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP96").FirstOrDefault();

        DataRow EDP97Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP97").FirstOrDefault();

        if (EDP91Row != null)
        {
            string MaxValue = ((decimal)EDP91Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP91Row["MinValue"]).ToString("0.##");

            TB_PHValue1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PHValue2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue2.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PHValue3.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue3.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PHValue4.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue4.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue1.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHValue1_Remark"), MaxValue, MinValue));
            TB_PHValue2.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHValue2_Remark"), MaxValue, MinValue));
            TB_PHValue3.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHValue3_Remark"), MaxValue, MinValue));
            TB_PHValue4.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHValue4_Remark"), MaxValue, MinValue));
        }

        if (EDP92Row != null)
        {
            string ProcessSecondRemark = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_ProcessSecondRemark");

            string MaxValue = ((decimal)EDP92Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP92Row["MinValue"]).ToString("0.##");

            TB_ProcessSecond.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecond.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecond.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        if (EDP93Row != null)
        {
            string SolidValueRemark = (string)GetLocalResourceObject("Str_ED_P_Solid_Remark");

            string MaxValue = ((decimal)EDP93Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP93Row["MinValue"]).ToString("0.##");

            TB_Solid.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Solid.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_Solid.Attributes.Add("title", string.Format(SolidValueRemark, MaxValue, MinValue));
        }

        if (EDP94Row != null)
        {
            string PB_Remark = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PB_Remark");

            string MaxValue = ((decimal)EDP94Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP94Row["MinValue"]).ToString("0.##");

            TB_PB.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PB.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PB.Attributes.Add("title", string.Format(PB_Remark, MaxValue, MinValue));
        }

        if (EDP95Row != null)
        {
            string SolventHold_Remark = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_SolventHold_Remark");

            string MaxValue = ((decimal)EDP95Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP95Row["MinValue"]).ToString("0.##");

            TB_SolventHold.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_SolventHold.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_SolventHold.Attributes.Add("title", string.Format(SolventHold_Remark, MaxValue, MinValue));
        }

        if (EDP96Row != null)
        {
            string MaxValue = ((decimal)EDP96Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP96Row["MinValue"]).ToString("0.##");

            TB_Conductivity1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Conductivity1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_Conductivity2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Conductivity2.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_Conductivity3.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Conductivity3.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_Conductivity4.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Conductivity4.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_Conductivity1.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Conductivity1_Remark"), MaxValue, MinValue));
            TB_Conductivity2.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Conductivity2_Remark"), MaxValue, MinValue));
            TB_Conductivity3.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Conductivity3_Remark"), MaxValue, MinValue));
            TB_Conductivity4.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Conductivity4_Remark"), MaxValue, MinValue));
        }

        if (EDP97Row != null)
        {
            string MaxValue = ((decimal)EDP97Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP97Row["MinValue"]).ToString("0.##");

            TB_Temperature1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Temperature1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_Temperature2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Temperature2.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_Temperature3.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Temperature3.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_Temperature4.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Temperature4.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_Temperature1.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Temperature1_Remark"), MaxValue, MinValue));
            TB_Temperature2.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Temperature2_Remark"), MaxValue, MinValue));
            TB_Temperature3.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Temperature3_Remark"), MaxValue, MinValue));
            TB_Temperature4.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Temperature4_Remark"), MaxValue, MinValue));
        }

        L_PHValue1.Text += "1";
        L_PHValue2.Text += "2";
        L_PHValue3.Text += "3";
        L_PHValue4.Text += "4";

        L_Conductivity1.Text += "1";
        L_Conductivity2.Text += "2";
        L_Conductivity3.Text += "3";
        L_Conductivity4.Text += "4";

        L_Temperature1.Text += "1";
        L_Temperature2.Text += "2";
        L_Temperature3.Text += "3";
        L_Temperature4.Text += "4";
    }

    protected void LoadChemicalAddingTitle()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select CodeID,CodeName From T_Code Where CodeType = 'ChemicalAdding' And CodeID in (Select item From Base_Org.dbo.Split(@CodeID,'|')) And UICulture = @UICulture");

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CodeID", "nvarchar", 10000, CA1CategoryID + "|" + CA2CategoryID + "|" + CA3CategoryID + "|" + CA4CategoryID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        string ChemicalAdding_HeadText = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_ChemicalAdding_HeadText");

        DataRow CA1Row = DT.AsEnumerable().Where(Row => Row["CodeID"].ToString().Trim() == CA1CategoryID).FirstOrDefault();

        DataRow CA2Row = DT.AsEnumerable().Where(Row => Row["CodeID"].ToString().Trim() == CA2CategoryID).FirstOrDefault();

        DataRow CA3Row = DT.AsEnumerable().Where(Row => Row["CodeID"].ToString().Trim() == CA3CategoryID).FirstOrDefault();

        DataRow CA4Row = DT.AsEnumerable().Where(Row => Row["CodeID"].ToString().Trim() == CA4CategoryID).FirstOrDefault();

        CA1_Title.Text = ChemicalAdding_HeadText;

        CA2_Title.Text = ChemicalAdding_HeadText;

        CA3_Title.Text = ChemicalAdding_HeadText;

        CA4_Title.Text = ChemicalAdding_HeadText;

        if (CA1Row != null)
            CA1_Title.Text += "-" + CA1Row["CodeName"].ToString().Trim();
        if (CA2Row != null)
            CA2_Title.Text += "-" + CA2Row["CodeName"].ToString().Trim();
        if (CA3Row != null)
            CA3_Title.Text += "-" + CA3Row["CodeName"].ToString().Trim();
        if (CA4Row != null)
            CA4_Title.Text += "-" + CA4Row["CodeName"].ToString().Trim();
    }

    protected void LoadData()
    {
        if (string.IsNullOrEmpty(HF_PID.Value))
            return;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPECoating"];

        string Query = "Select *,Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName From T_EDPECoating Where PID = @PID";

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

        decimal PHValue3 = (decimal)Row["PHValue3"];

        if (PHValue3 > -1)
            TB_PHValue3.Text = PHValue3.ToString();

        decimal PHValue4 = (decimal)Row["PHValue4"];

        if (PHValue4 > -1)
            TB_PHValue4.Text = PHValue4.ToString();

        int ProcessSecond = (int)Row["ProcessSecond"];

        if (ProcessSecond > -1)
            TB_ProcessSecond.Text = ProcessSecond.ToString();

        decimal SolidValue = (decimal)Row["Solid"];

        if (SolidValue > -1)
            TB_Solid.Text = SolidValue.ToString();

        decimal PBValue = (decimal)Row["PB"];

        if (PBValue > -1)
            TB_PB.Text = PBValue.ToString();

        decimal SolventHoldValue = (decimal)Row["SolventHold"];

        if (SolventHoldValue > -1)
            TB_SolventHold.Text = SolventHoldValue.ToString();

        decimal Conductivity1 = (decimal)Row["Conductivity1"];

        if (Conductivity1 > -1)
            TB_Conductivity1.Text = Conductivity1.ToString();

        decimal Conductivity2 = (decimal)Row["Conductivity2"];

        if (Conductivity2 > -1)
            TB_Conductivity2.Text = Conductivity2.ToString();

        decimal Conductivity3 = (decimal)Row["Conductivity3"];

        if (Conductivity3 > -1)
            TB_Conductivity3.Text = Conductivity3.ToString();

        decimal Conductivity4 = (decimal)Row["Conductivity4"];

        if (Conductivity4 > -1)
            TB_Conductivity4.Text = Conductivity4.ToString();

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

        TB_Remark.Text = Row["Remark"].ToString().Trim();

        WUC_DataCreateInfo.SetControlData(Row);

        Query = "Select * From T_EDChemicalAdding Where PID = @PID Order By SerialNo Asc";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PID"].copy(HF_PID.Value.ToStringFromBase64()));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        foreach (DataRow R in DT.Rows)
        {
            if (R["CategoryID"].ToString().Trim() == CA1CategoryID)
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
            }

            if (R["CategoryID"].ToString().Trim() == CA2CategoryID)
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
            }

            if (R["CategoryID"].ToString().Trim() == CA3CategoryID)
            {
                if ((short)R["SerialNo"] == 1)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA3_AddDateTime1.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA3_Qty1.Text = Qty.ToString();

                    TB_CA3_LotNumber1.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 2)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA3_AddDateTime2.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA3_Qty2.Text = Qty.ToString();

                    TB_CA3_LotNumber2.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 3)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA3_AddDateTime3.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA3_Qty3.Text = Qty.ToString();

                    TB_CA3_LotNumber3.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
            }

            if (R["CategoryID"].ToString().Trim() == CA4CategoryID)
            {
                if ((short)R["SerialNo"] == 1)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA4_AddDateTime1.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA4_Qty1.Text = Qty.ToString();

                    TB_CA4_LotNumber1.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 2)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA4_AddDateTime2.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA4_Qty2.Text = Qty.ToString();

                    TB_CA4_LotNumber2.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 3)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA4_AddDateTime3.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA4_Qty3.Text = Qty.ToString();

                    TB_CA4_LotNumber3.Text = R["LotNumber"].ToString().Trim();

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

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPECoating"];

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
                string.IsNullOrEmpty(TB_PHValue3.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PHValue4.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecond.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Solid.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PB.Text.Trim()) &&
                string.IsNullOrEmpty(TB_SolventHold.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Conductivity1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Conductivity2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Conductivity3.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Conductivity4.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Temperature1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Temperature2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Temperature3.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Temperature4.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));

            if (string.IsNullOrEmpty(HF_PID.Value))
            {
                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Insert Into T_EDPECoating (PID,PDate,WorkClassID,PLID,PHValue1,PHValue2,PHValue3,PHValue4,ProcessSecond,Solid,PB,SolventHold,Conductivity1,Conductivity2,Conductivity3,Conductivity4,Temperature1,Temperature2,Temperature3,Temperature4,Remark,CreateAccountID) 
                          Values (@PID,@PDate,@WorkClassID,@PLID,@PHValue1,@PHValue2,@PHValue3,@PHValue4,@ProcessSecond,@Solid,@PB,@SolventHold,@Conductivity1,@Conductivity2,@Conductivity3,@Conductivity4,@Temperature1,@Temperature2,@Temperature3,@Temperature4,@Remark,@CreateAccountID)";

                PID = BaseConfiguration.SerialObject[(short)9].取號();

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));
            }
            else
            {
                PID = HF_PID.Value.ToStringFromBase64();

                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue, PID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Update T_EDPECoating Set PDate = @PDate,WorkClassID = @WorkClassID,PLID = @PLID,PHValue1 = @PHValue1,PHValue2 = @PHValue2,PHValue3 = @PHValue3,PHValue4 = @PHValue4,ProcessSecond = @ProcessSecond,Solid = @Solid,PB = @PB,SolventHold = @SolventHold,
                          Conductivity1 = @Conductivity1,Conductivity2 = @Conductivity2,Conductivity3 = @Conductivity3,Conductivity4 = @Conductivity4,Temperature1 = @Temperature1,Temperature2 = @Temperature2,Temperature3 = @Temperature3,Temperature4 = @Temperature4,
                          Remark = @Remark,ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where PID = @PID";

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

            decimal PHValue3 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue3.Text.Trim()) && !decimal.TryParse(TB_PHValue3.Text.Trim(), out PHValue3))
                PHValue3 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue3"].copy(PHValue3));

            decimal PHValue4 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue4.Text.Trim()) && !decimal.TryParse(TB_PHValue4.Text.Trim(), out PHValue4))
                PHValue4 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue4"].copy(PHValue4));

            int ProcessSecond = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecond.Text.Trim()) && !int.TryParse(TB_ProcessSecond.Text.Trim(), out ProcessSecond))
                ProcessSecond = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond"].copy(ProcessSecond));

            decimal Solid = -1;

            if (!string.IsNullOrEmpty(TB_Solid.Text.Trim()) && !decimal.TryParse(TB_Solid.Text.Trim(), out Solid))
                Solid = -1;
            dbcb.appendParameter(Schema.Attributes["Solid"].copy(Solid));

            decimal PB = -1;

            if (!string.IsNullOrEmpty(TB_PB.Text.Trim()) && !decimal.TryParse(TB_PB.Text.Trim(), out PB))
                PB = -1;
            dbcb.appendParameter(Schema.Attributes["PB"].copy(PB));

            decimal SolventHold = -1;

            if (!string.IsNullOrEmpty(TB_SolventHold.Text.Trim()) && !decimal.TryParse(TB_SolventHold.Text.Trim(), out SolventHold))
                SolventHold = -1;
            dbcb.appendParameter(Schema.Attributes["SolventHold"].copy(SolventHold));

            decimal Conductivity1 = -1;

            if (!string.IsNullOrEmpty(TB_Conductivity1.Text.Trim()) && !decimal.TryParse(TB_Conductivity1.Text.Trim(), out Conductivity1))
                Conductivity1 = -1;
            dbcb.appendParameter(Schema.Attributes["Conductivity1"].copy(Conductivity1));

            decimal Conductivity2 = -1;

            if (!string.IsNullOrEmpty(TB_Conductivity2.Text.Trim()) && !decimal.TryParse(TB_Conductivity2.Text.Trim(), out Conductivity2))
                Conductivity2 = -1;
            dbcb.appendParameter(Schema.Attributes["Conductivity2"].copy(Conductivity2));

            decimal Conductivity3 = -1;

            if (!string.IsNullOrEmpty(TB_Conductivity3.Text.Trim()) && !decimal.TryParse(TB_Conductivity3.Text.Trim(), out Conductivity3))
                Conductivity3 = -1;
            dbcb.appendParameter(Schema.Attributes["Conductivity3"].copy(Conductivity3));

            decimal Conductivity4 = -1;

            if (!string.IsNullOrEmpty(TB_Conductivity4.Text.Trim()) && !decimal.TryParse(TB_Conductivity4.Text.Trim(), out Conductivity4))
                Conductivity4 = -1;
            dbcb.appendParameter(Schema.Attributes["Conductivity4"].copy(Conductivity4));

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

            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            short SerialNo = 1;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA1CategoryID));

            if (!string.IsNullOrEmpty(TB_CA1_AddDateTime1.Text.Trim()) && !string.IsNullOrEmpty(TB_CA1_Qty1.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA1CategoryID, PDate, TB_CA1_AddDateTime1, TB_CA1_Qty1, TB_CA1_LotNumber1));
            else if (!string.IsNullOrEmpty(TB_CA1_AddDateTime1.Text.Trim() + TB_CA1_Qty1.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA1_Qty1.Text.Trim()) && double.Parse(TB_CA1_Qty1.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 2;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA1CategoryID));

            if (!string.IsNullOrEmpty(TB_CA1_AddDateTime2.Text.Trim()) && !string.IsNullOrEmpty(TB_CA1_Qty2.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA1CategoryID, PDate, TB_CA1_AddDateTime2, TB_CA1_Qty2, TB_CA1_LotNumber2));
            else if (!string.IsNullOrEmpty(TB_CA1_AddDateTime2.Text.Trim() + TB_CA1_Qty2.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA1_Qty2.Text.Trim()) && double.Parse(TB_CA1_Qty2.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 3;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA1CategoryID));

            if (!string.IsNullOrEmpty(TB_CA1_AddDateTime3.Text.Trim()) && !string.IsNullOrEmpty(TB_CA1_Qty3.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA1CategoryID, PDate, TB_CA1_AddDateTime3, TB_CA1_Qty3, TB_CA1_LotNumber3));
            else if (!string.IsNullOrEmpty(TB_CA1_AddDateTime3.Text.Trim() + TB_CA1_Qty3.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA1_Qty3.Text.Trim()) && double.Parse(TB_CA1_Qty3.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 1;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA2CategoryID));

            if (!string.IsNullOrEmpty(TB_CA2_AddDateTime1.Text.Trim()) && !string.IsNullOrEmpty(TB_CA2_Qty1.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA2CategoryID, PDate, TB_CA2_AddDateTime1, TB_CA2_Qty1, TB_CA2_LotNumber1));
            else if (!string.IsNullOrEmpty(TB_CA2_AddDateTime1.Text.Trim() + TB_CA2_Qty1.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA2_Qty1.Text.Trim()) && double.Parse(TB_CA2_Qty1.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 2;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA2CategoryID));

            if (!string.IsNullOrEmpty(TB_CA2_AddDateTime2.Text.Trim()) && !string.IsNullOrEmpty(TB_CA2_Qty2.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA2CategoryID, PDate, TB_CA2_AddDateTime2, TB_CA2_Qty2, TB_CA2_LotNumber2));
            else if (!string.IsNullOrEmpty(TB_CA2_AddDateTime2.Text.Trim() + TB_CA2_Qty2.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA2_Qty2.Text.Trim()) && double.Parse(TB_CA2_Qty2.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 3;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA2CategoryID));

            if (!string.IsNullOrEmpty(TB_CA2_AddDateTime3.Text.Trim()) && !string.IsNullOrEmpty(TB_CA2_Qty3.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA2CategoryID, PDate, TB_CA2_AddDateTime3, TB_CA2_Qty3, TB_CA2_LotNumber3));
            else if (!string.IsNullOrEmpty(TB_CA2_AddDateTime3.Text.Trim() + TB_CA2_Qty3.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA2_Qty3.Text.Trim()) && double.Parse(TB_CA2_Qty3.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 1;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA3CategoryID));

            if (!string.IsNullOrEmpty(TB_CA3_AddDateTime1.Text.Trim()) && !string.IsNullOrEmpty(TB_CA3_Qty1.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA3CategoryID, PDate, TB_CA3_AddDateTime1, TB_CA3_Qty1, TB_CA3_LotNumber1));
            else if (!string.IsNullOrEmpty(TB_CA3_AddDateTime1.Text.Trim() + TB_CA3_Qty1.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA3_Qty1.Text.Trim()) && double.Parse(TB_CA3_Qty1.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 2;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA3CategoryID));

            if (!string.IsNullOrEmpty(TB_CA3_AddDateTime2.Text.Trim()) && !string.IsNullOrEmpty(TB_CA3_Qty2.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA3CategoryID, PDate, TB_CA3_AddDateTime2, TB_CA3_Qty2, TB_CA3_LotNumber2));
            else if (!string.IsNullOrEmpty(TB_CA3_AddDateTime2.Text.Trim() + TB_CA3_Qty2.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA3_Qty2.Text.Trim()) && double.Parse(TB_CA3_Qty2.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 3;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA3CategoryID));

            if (!string.IsNullOrEmpty(TB_CA3_AddDateTime3.Text.Trim()) && !string.IsNullOrEmpty(TB_CA3_Qty3.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA3CategoryID, PDate, TB_CA3_AddDateTime3, TB_CA3_Qty3, TB_CA3_LotNumber3));
            else if (!string.IsNullOrEmpty(TB_CA3_AddDateTime3.Text.Trim() + TB_CA3_Qty3.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA3_Qty3.Text.Trim()) && double.Parse(TB_CA3_Qty3.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 1;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA4CategoryID));

            if (!string.IsNullOrEmpty(TB_CA4_AddDateTime1.Text.Trim()) && !string.IsNullOrEmpty(TB_CA4_Qty1.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA4CategoryID, PDate, TB_CA4_AddDateTime1, TB_CA4_Qty1, TB_CA4_LotNumber1));
            else if (!string.IsNullOrEmpty(TB_CA4_AddDateTime1.Text.Trim() + TB_CA4_Qty1.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA4_Qty1.Text.Trim()) && double.Parse(TB_CA4_Qty1.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 2;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA4CategoryID));

            if (!string.IsNullOrEmpty(TB_CA4_AddDateTime2.Text.Trim()) && !string.IsNullOrEmpty(TB_CA4_Qty2.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA4CategoryID, PDate, TB_CA4_AddDateTime2, TB_CA4_Qty2, TB_CA4_LotNumber2));
            else if (!string.IsNullOrEmpty(TB_CA4_AddDateTime2.Text.Trim() + TB_CA4_Qty2.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA4_Qty2.Text.Trim()) && double.Parse(TB_CA4_Qty2.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 3;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA4CategoryID));

            if (!string.IsNullOrEmpty(TB_CA4_AddDateTime3.Text.Trim()) && !string.IsNullOrEmpty(TB_CA4_Qty3.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA4CategoryID, PDate, TB_CA4_AddDateTime3, TB_CA4_Qty3, TB_CA4_LotNumber3));
            else if (!string.IsNullOrEmpty(TB_CA4_AddDateTime3.Text.Trim() + TB_CA4_Qty3.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA4_Qty3.Text.Trim()) && double.Parse(TB_CA4_Qty3.Text.Trim()) > 0))
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
            Util.ED.DeletEDData(HF_PID.Value.ToStringFromBase64(), ((short)Util.ED.PIDType.T_EDPECoating), true);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}