using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;

public partial class ED_P_CoatingTestForPD : System.Web.UI.Page
{
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

            LoadPrametersRemark();

            LoadDDLData();

            LoadData();
        }

        BT_Delete.Visible = !(string.IsNullOrEmpty(HF_PID.Value));

    }

    protected void LoadPrametersRemark()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select * From T_EDPStandardValue Where PrametersID in (Select item From Base_Org.dbo.Split(@Prameters,'|'))");

        dbcb.appendParameter(Util.GetDataAccessAttribute("Prameters", "nvarchar", 10000, "EDP151|EDP152|EDP153|EDP154|EDP155|EDP156|EDP157"));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DataRow EDP151Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP151").FirstOrDefault();
        DataRow EDP152Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP152").FirstOrDefault();
        DataRow EDP153Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP153").FirstOrDefault();
        DataRow EDP154Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP154").FirstOrDefault();
        DataRow EDP155Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP155").FirstOrDefault();
        DataRow EDP156Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP156").FirstOrDefault();
        DataRow EDP157Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP157").FirstOrDefault();

        string FilmThickness = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_FilmThicknessRemark");

        string HardnessID = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_HardnessIDRemark");

        string FlexibilityID = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_FlexibilityIDRemark");

        string ImpactResistanceID = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_ImpactResistanceIDRemark");

        string AdhesionID = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_AdhesionIDRemark");

        string AlcoholFrictionID = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_AlcoholFrictionIDRemark");

        string QuickCorrosionID = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_QuickCorrosionIDRemark");


        if (EDP151Row != null)
        {
            string MaxValue = ((decimal)EDP151Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP151Row["MinValue"]).ToString("0.##");

            TB_FilmThicknessValue.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_FilmThicknessValue.Attributes.Add("data-MumberTypeMinValue", MinValue);

            FilmThickness = string.Format(FilmThickness, MaxValue, MinValue);
        }

        if (EDP151Row != null)
        {
            string MaxValue = ((decimal)EDP151Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP151Row["MinValue"]).ToString("0.##");

            TB_FilmThicknessValue.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_FilmThicknessValue.Attributes.Add("data-MumberTypeMinValue", MinValue);

            FilmThickness = string.Format(FilmThickness, MaxValue, MinValue);
        }

        if (EDP152Row != null)
        {
            string MaxValue = ((decimal)EDP152Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP152Row["MinValue"]).ToString("0.##");

            DDL_HardnessID.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            DDL_HardnessID.Attributes.Add("data-MumberTypeMinValue", MinValue);

            HardnessID = string.Format(HardnessID, MaxValue, MinValue);
        }

        if (EDP153Row != null)
        {
            string MaxValue = ((decimal)EDP153Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP153Row["MinValue"]).ToString("0.##");

            DDL_FlexibilityID.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            DDL_FlexibilityID.Attributes.Add("data-MumberTypeMinValue", MinValue);

            FlexibilityID = string.Format(FlexibilityID, MinValue);
        }

        if (EDP154Row != null)
        {
            string MaxValue = ((decimal)EDP154Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP154Row["MinValue"]).ToString("0.##");

            DDL_ImpactResistanceID.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            DDL_ImpactResistanceID.Attributes.Add("data-MumberTypeMinValue", MinValue);

            ImpactResistanceID = string.Format(ImpactResistanceID, MinValue);
        }

        if (EDP155Row != null)
        {
            string MaxValue = ((decimal)EDP155Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP155Row["MinValue"]).ToString("0.##");

            DDL_AdhesionID.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            DDL_AdhesionID.Attributes.Add("data-MumberTypeMinValue", MinValue);

            AdhesionID = string.Format(AdhesionID, MaxValue, MinValue);
        }

        if (EDP156Row != null)
        {
            string MaxValue = ((decimal)EDP156Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP156Row["MinValue"]).ToString("0.##");

            DDL_AlcoholFrictionID.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            DDL_AlcoholFrictionID.Attributes.Add("data-MumberTypeMinValue", MinValue);

            AlcoholFrictionID = string.Format(AlcoholFrictionID, MaxValue, MinValue);

        }

        if (EDP157Row != null)
        {
            string MaxValue = ((decimal)EDP157Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP157Row["MinValue"]).ToString("0.##");

            DDL_QuickCorrosionID.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            DDL_QuickCorrosionID.Attributes.Add("data-MumberTypeMinValue", MinValue);

            QuickCorrosionID = string.Format(QuickCorrosionID, MinValue);
        }

        TB_FilmThicknessValue.Attributes.Add("title", FilmThickness);

        DDL_HardnessID.Attributes.Add("title", HardnessID);

        DDL_FlexibilityID.Attributes.Add("title", FlexibilityID);

        DDL_ImpactResistanceID.Attributes.Add("title", ImpactResistanceID);

        DDL_AdhesionID.Attributes.Add("title", AdhesionID);

        DDL_AlcoholFrictionID.Attributes.Add("title", AlcoholFrictionID);

        DDL_QuickCorrosionID.Attributes.Add("title", QuickCorrosionID);

    }

    protected void LoadDDLData()
    {
        Util.ED.LaodWorkClass(DDL_WorkClass);

        Util.ED.LoadProductionLine(DDL_PLID);

        Util.LoadDDLData(DDL_HardnessID);

        Util.LoadDDLData(DDL_FlexibilityID);

        Util.LoadDDLData(DDL_ImpactResistanceID);

        Util.LoadDDLData(DDL_AdhesionID);

        Util.LoadDDLData(DDL_AlcoholFrictionID);

        Util.LoadDDLData(DDL_QuickCorrosionID);
    }

    protected void LoadData()
    {
        if (string.IsNullOrEmpty(HF_PID.Value))
            return;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPCoatingTestForPD"];

        string Query = "Select *,Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName From T_EDPCoatingTestForPD Where PID = @PID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PID"].copy(HF_PID.Value.ToStringFromBase64()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return;

        DataRow Row = DT.Rows[0];

        TB_PDate.Text = ((DateTime)Row["PDate"]).ToCurrentUICultureString();

        DDL_WorkClass.SelectedValue = Row["WorkClassID"].ToString().Trim();

        DDL_PLID.SelectedValue = Row["PLID"].ToString().Trim();

        TB_FilmThicknessValue.Text = Row["FilmThickness"].ToString().Trim();

        DDL_HardnessID.SelectedValue = Row["HardnessID"].ToString().Trim();

        DDL_FlexibilityID.SelectedValue = Row["FlexibilityID"].ToString().Trim();

        DDL_ImpactResistanceID.SelectedValue = Row["ImpactResistanceID"].ToString().Trim();

        DDL_AdhesionID.SelectedValue = Row["AdhesionID"].ToString().Trim();

        DDL_AlcoholFrictionID.SelectedValue = Row["AlcoholFrictionID"].ToString().Trim();

        DDL_QuickCorrosionID.SelectedValue = Row["QuickCorrosionID"].ToString().Trim();

        TB_Remark.Text = Row["Remark"].ToString().Trim();

        WUC_DataCreateInfo.SetControlData(Row);

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

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPCoatingTestForPD"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            DateTime PDate = DateTime.Parse("1900/01/01");

            string DefaultVaule = "-1";

            if (!DateTime.TryParse(TB_PDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out PDate))
                PDate = DateTime.Parse("1900/01/01");

            if (PDate.Year < 1911)
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if (string.IsNullOrEmpty(DDL_WorkClass.SelectedValue) || string.IsNullOrEmpty(DDL_PLID.SelectedValue))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            // 至少要輸入一個參數
            if (string.IsNullOrEmpty(TB_FilmThicknessValue.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));


            if (string.IsNullOrEmpty(HF_PID.Value))
            {
                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Insert Into T_EDPCoatingTestForPD (PID,PDate,WorkClassID,PLID,FilmThickness,HardnessID,FlexibilityID,ImpactResistanceID,AdhesionID,AlcoholFrictionID,QuickCorrosionID,Remark,CreateAccountID) 
                          Values (@PID,@PDate,@WorkClassID,@PLID,@FilmThickness,@HardnessID,@FlexibilityID,@ImpactResistanceID,@AdhesionID,@AlcoholFrictionID,@QuickCorrosionID,@Remark,@CreateAccountID)";

                PID = BaseConfiguration.SerialObject[(short)15].取號();

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));
            }
            else
            {
                PID = HF_PID.Value.ToStringFromBase64();

                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue, PID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Update T_EDPCoatingTestForPD Set PDate = @PDate,WorkClassID = @WorkClassID,PLID = @PLID,FilmThickness=@FilmThickness,HardnessID=@HardnessID,FlexibilityID=@FlexibilityID,ImpactResistanceID=@ImpactResistanceID
                         ,AdhesionID=@AdhesionID,AlcoholFrictionID=@AlcoholFrictionID,QuickCorrosionID=@QuickCorrosionID,Remark=@Remark,ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where PID = @PID";

                dbcb.appendParameter(Schema.Attributes["ModifyAccountID"].copy(Master.AccountID));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["PID"].copy(PID));
            dbcb.appendParameter(Schema.Attributes["PDate"].copy(PDate));
            dbcb.appendParameter(Schema.Attributes["WorkClassID"].copy((DDL_WorkClass.SelectedValue)));
            dbcb.appendParameter(Schema.Attributes["PLID"].copy((DDL_PLID.SelectedValue)));

            decimal FilmThicknessValue = -1;

            if (!string.IsNullOrEmpty(TB_FilmThicknessValue.Text.Trim()) && !decimal.TryParse(TB_FilmThicknessValue.Text.Trim(), out FilmThicknessValue))
                FilmThicknessValue = -1;

            dbcb.appendParameter(Schema.Attributes["FilmThickness"].copy(FilmThicknessValue));

            dbcb.appendParameter(Schema.Attributes["HardnessID"].copy((string.IsNullOrEmpty(DDL_HardnessID.SelectedValue) ? DefaultVaule : DDL_HardnessID.SelectedValue)));

            dbcb.appendParameter(Schema.Attributes["FlexibilityID"].copy((string.IsNullOrEmpty(DDL_FlexibilityID.SelectedValue) ? DefaultVaule : DDL_FlexibilityID.SelectedValue)));

            dbcb.appendParameter(Schema.Attributes["ImpactResistanceID"].copy((string.IsNullOrEmpty(DDL_ImpactResistanceID.SelectedValue) ? DefaultVaule : DDL_ImpactResistanceID.SelectedValue)));

            dbcb.appendParameter(Schema.Attributes["AdhesionID"].copy((string.IsNullOrEmpty(DDL_AdhesionID.SelectedValue) ? DefaultVaule : DDL_AdhesionID.SelectedValue)));

            dbcb.appendParameter(Schema.Attributes["AlcoholFrictionID"].copy((string.IsNullOrEmpty(DDL_AlcoholFrictionID.SelectedValue) ? DefaultVaule : DDL_AlcoholFrictionID.SelectedValue)));

            dbcb.appendParameter(Schema.Attributes["AlcoholFrictionID"].copy((string.IsNullOrEmpty(DDL_AlcoholFrictionID.SelectedValue) ? DefaultVaule : DDL_AlcoholFrictionID.SelectedValue)));

            dbcb.appendParameter(Schema.Attributes["QuickCorrosionID"].copy((string.IsNullOrEmpty(DDL_QuickCorrosionID.SelectedValue) ? DefaultVaule : DDL_QuickCorrosionID.SelectedValue)));

            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

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
            Util.ED.DeletEDData(HF_PID.Value.ToStringFromBase64(), ((short)Util.ED.PIDType.T_EDPCoatingTestForPD), false);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}