using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;
public partial class ED_P_Curing : System.Web.UI.Page
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
            //如果是新增要先取號讓FileUpload元件可以有值
            if (string.IsNullOrEmpty(HF_PID.Value))
            {
                string PID = BaseConfiguration.SerialObject[(short)19].取號();

                HF_PID.Value = PID.ToBase64String();

                HF_IsNewData.Value = true.ToStringValue();
            }

            WUC_File.FileID = HF_PID.Value;

            WUC_File.FileCategoryID = "ED".ToBase64String();

            LoadPrametersRemark();

            LoadDDLData();

            LoadData();
        }

        BT_Delete.Visible = !(HF_IsNewData.Value).ToBoolean();
    }
    protected void LoadPrametersRemark()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select * From T_EDPStandardValue Where PrametersID in (Select item From Base_Org.dbo.Split(@Prameters,'|'))");

        dbcb.appendParameter(Util.GetDataAccessAttribute("Prameters", "nvarchar", 10000, "EDP161|EDP162|EDP163|EDP164|EDP165|EDP166|EDP167|EDP168"));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DataRow EDP161Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP161").FirstOrDefault();

        DataRow EDP162Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP162").FirstOrDefault();

        DataRow EDP163Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP163").FirstOrDefault();

        DataRow EDP164Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP164").FirstOrDefault();

        DataRow EDP165Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP165").FirstOrDefault();

        DataRow EDP166Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP166").FirstOrDefault();

        DataRow EDP167Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP167").FirstOrDefault();

        DataRow EDP168Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP168").FirstOrDefault();

        if (EDP161Row != null)
        {
            string MaxValue = ((decimal)EDP161Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP161Row["MinValue"]).ToString("0.##");

            TB_Zone1Fan1Temperature1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Zone1Fan1Temperature1.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_Zone1Fan1Temperature1.Attributes.Add("title", string.Format((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Zone1Fan1Temperature1Remark"), MaxValue, MinValue));
        }

        if (EDP162Row != null)
        {
            string MaxValue = ((decimal)EDP162Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP162Row["MinValue"]).ToString("0.##");

            TB_Zone1Fan1Temperature2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Zone1Fan1Temperature2.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_Zone1Fan1Temperature2.Attributes.Add("title", string.Format((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Zone1Fan1Temperature2Remark"), MaxValue, MinValue));
        }

        if (EDP163Row != null)
        {
            string MaxValue = ((decimal)EDP163Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP163Row["MinValue"]).ToString("0.##");

            TB_Zone2Fan2Temperature1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Zone2Fan2Temperature1.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_Zone2Fan2Temperature1.Attributes.Add("title", string.Format((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Zone2Fan2Temperature1Remark"), MaxValue, MinValue));
        }

        if (EDP164Row != null)
        {
            string MaxValue = ((decimal)EDP164Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP164Row["MinValue"]).ToString("0.##");

            TB_Zone2Fan2Temperature2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Zone2Fan2Temperature2.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_Zone2Fan2Temperature2.Attributes.Add("title", string.Format((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Zone2Fan2Temperature2Remark"), MaxValue, MinValue));
        }

        if (EDP165Row != null)
        {
            string StandardValue = ((decimal)EDP165Row["MaxValue"]).ToString("0.##");

            TB_CombustorTemperature1.Attributes.Add("data-MumberTypeMaxValue", StandardValue);

            TB_CombustorTemperature1.Attributes.Add("title", string.Format((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_CombustorTemperature1Remark"), StandardValue));
        }

        if (EDP166Row != null)
        {
            string StandardValue = ((decimal)EDP166Row["MaxValue"]).ToString("0.##");

            TB_CombustorTemperature2.Attributes.Add("data-MumberTypeMaxValue", StandardValue);

            TB_CombustorTemperature2.Attributes.Add("title", string.Format((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_CombustorTemperature2Remark"), StandardValue));
        }

        if (EDP167Row != null)
        {
            string MaxValue = ((decimal)EDP167Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP167Row["MinValue"]).ToString("0.##");

            TB_PassingTime.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PassingTime.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PassingTime.Attributes.Add("title", string.Format((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PassingTimeRemark"), MaxValue, MinValue));
        }

        if (EDP168Row != null)
        {
            string MaxValue = ((decimal)EDP168Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP168Row["MinValue"]).ToString("0.##");

            TB_SettingTemperature.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_SettingTemperature.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_SettingTemperature.Attributes.Add("title", string.Format((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_SettingTemperatureRemark"), MaxValue, MinValue));
        }
    }

    protected void LoadDDLData()
    {
        Util.ED.LaodWorkClass(DDL_WorkClass);

        Util.ED.LoadProductionLine(DDL_PLID);
    }

    protected void LoadData()
    {
        if (string.IsNullOrEmpty(HF_PID.Value))
            return;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDCuring"];

        string Query = "Select *,Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName From T_EDCuring Where PID = @PID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PID"].copy(HF_PID.Value.ToStringFromBase64()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return;

        DataRow Row = DT.Rows[0];

        TB_PDate.Text = ((DateTime)Row["PDate"]).ToCurrentUICultureString();

        DDL_WorkClass.SelectedValue = Row["WorkClassID"].ToString().Trim();

        DDL_PLID.SelectedValue = Row["PLID"].ToString().Trim();

        int Zone1Fan1Temperature1 = (int)Row["Zone1Fan1Temperature1"];

        if (Zone1Fan1Temperature1 > -1)
            TB_Zone1Fan1Temperature1.Text = Zone1Fan1Temperature1.ToString();

        int Zone1Fan1Temperature2 = (int)Row["Zone1Fan1Temperature2"];

        if (Zone1Fan1Temperature2 > -1)
            TB_Zone1Fan1Temperature2.Text = Zone1Fan1Temperature2.ToString();

        int Zone2Fan2Temperature1 = (int)Row["Zone2Fan2Temperature1"];

        if (Zone2Fan2Temperature1 > -1)
            TB_Zone2Fan2Temperature1.Text = Zone2Fan2Temperature1.ToString();

        int Zone2Fan2Temperature2 = (int)Row["Zone2Fan2Temperature2"];

        if (Zone2Fan2Temperature2 > -1)
            TB_Zone2Fan2Temperature2.Text = Zone2Fan2Temperature2.ToString();

        int CombustorTemperature1 = (int)Row["CombustorTemperature1"];

        if (CombustorTemperature1 > -1)
            TB_CombustorTemperature1.Text = CombustorTemperature1.ToString();

        int CombustorTemperature2 = (int)Row["CombustorTemperature2"];

        if (CombustorTemperature2 > -1)
            TB_CombustorTemperature2.Text = CombustorTemperature2.ToString();

        int PassingTime = (int)Row["PassingTime"];

        if (PassingTime > -1)
            TB_PassingTime.Text = PassingTime.ToString();

        int SettingTemperature = (int)Row["SettingTemperature"];

        if (SettingTemperature > -1)
            TB_SettingTemperature.Text = SettingTemperature.ToString();

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

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDCuring"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            DateTime PDate = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_PDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out PDate))
                PDate = DateTime.Parse("1900/01/01");

            if (PDate.Year < 1911)
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if (string.IsNullOrEmpty(DDL_WorkClass.SelectedValue) || string.IsNullOrEmpty(DDL_PLID.SelectedValue))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            // 至少要輸入一個參數
            if (string.IsNullOrEmpty(TB_Zone1Fan1Temperature1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Zone1Fan1Temperature2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Zone2Fan2Temperature1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Zone2Fan2Temperature2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_CombustorTemperature1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_CombustorTemperature2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PassingTime.Text.Trim()) &&
                string.IsNullOrEmpty(TB_SettingTemperature.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));

            PID = HF_PID.Value.ToStringFromBase64();

            if (HF_IsNewData.Value.ToBoolean())
            {
                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Insert Into T_EDCuring (PID,PDate,WorkClassID,PLID,Zone1Fan1Temperature1,Zone1Fan1Temperature2,Zone2Fan2Temperature1,Zone2Fan2Temperature2,CombustorTemperature1,CombustorTemperature2,PassingTime,SettingTemperature,Remark,CreateAccountID) 
                          Values (@PID,@PDate,@WorkClassID,@PLID,@Zone1Fan1Temperature1,@Zone1Fan1Temperature2,@Zone2Fan2Temperature1,@Zone2Fan2Temperature2,@CombustorTemperature1,@CombustorTemperature2,@PassingTime,@SettingTemperature,@Remark,@CreateAccountID)";

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));
            }
            else
            {
                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue, PID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Update T_EDCuring Set PDate = @PDate,WorkClassID = @WorkClassID,PLID = @PLID,Zone1Fan1Temperature1 = @Zone1Fan1Temperature1,Zone1Fan1Temperature2 = @Zone1Fan1Temperature2,Zone2Fan2Temperature1 = @Zone2Fan2Temperature1 ,Zone2Fan2Temperature2 = @Zone2Fan2Temperature2,CombustorTemperature1 = @CombustorTemperature1,CombustorTemperature2 = @CombustorTemperature2,
                          PassingTime = @PassingTime,SettingTemperature = @SettingTemperature,Remark = @Remark,ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID 
                          Where PID = @PID";

                dbcb.appendParameter(Schema.Attributes["ModifyAccountID"].copy(Master.AccountID));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["PID"].copy(PID));
            dbcb.appendParameter(Schema.Attributes["PDate"].copy(PDate));
            dbcb.appendParameter(Schema.Attributes["WorkClassID"].copy((DDL_WorkClass.SelectedValue)));
            dbcb.appendParameter(Schema.Attributes["PLID"].copy((DDL_PLID.SelectedValue)));

            int Zone1Fan1Temperature1 = -1;

            if (!string.IsNullOrEmpty(TB_Zone1Fan1Temperature1.Text.Trim()) && !int.TryParse(TB_Zone1Fan1Temperature1.Text.Trim(), out Zone1Fan1Temperature1))
                Zone1Fan1Temperature1 = -1;

            dbcb.appendParameter(Schema.Attributes["Zone1Fan1Temperature1"].copy(Zone1Fan1Temperature1));

            int Zone1Fan1Temperature2 = -1;

            if (!string.IsNullOrEmpty(TB_Zone1Fan1Temperature2.Text.Trim()) && !int.TryParse(TB_Zone1Fan1Temperature2.Text.Trim(), out Zone1Fan1Temperature2))
                Zone1Fan1Temperature2 = -1;

            dbcb.appendParameter(Schema.Attributes["Zone1Fan1Temperature2"].copy(Zone1Fan1Temperature2));


            int Zone2Fan2Temperature1 = -1;

            if (!string.IsNullOrEmpty(TB_Zone2Fan2Temperature1.Text.Trim()) && !int.TryParse(TB_Zone2Fan2Temperature1.Text.Trim(), out Zone2Fan2Temperature1))
                Zone2Fan2Temperature1 = -1;

            dbcb.appendParameter(Schema.Attributes["Zone2Fan2Temperature1"].copy(Zone2Fan2Temperature1));

            int Zone2Fan2Temperature2 = -1;

            if (!string.IsNullOrEmpty(TB_Zone2Fan2Temperature2.Text.Trim()) && !int.TryParse(TB_Zone2Fan2Temperature2.Text.Trim(), out Zone2Fan2Temperature2))
                Zone2Fan2Temperature2 = -1;

            dbcb.appendParameter(Schema.Attributes["Zone2Fan2Temperature2"].copy(Zone2Fan2Temperature2));

            int CombustorTemperature1 = -1;

            if (!string.IsNullOrEmpty(TB_CombustorTemperature1.Text.Trim()) && !int.TryParse(TB_CombustorTemperature1.Text.Trim(), out CombustorTemperature1))
                CombustorTemperature1 = -1;

            dbcb.appendParameter(Schema.Attributes["CombustorTemperature1"].copy(CombustorTemperature1));

            int CombustorTemperature2 = -1;

            if (!string.IsNullOrEmpty(TB_CombustorTemperature2.Text.Trim()) && !int.TryParse(TB_CombustorTemperature2.Text.Trim(), out CombustorTemperature2))
                CombustorTemperature2 = -1;

            dbcb.appendParameter(Schema.Attributes["CombustorTemperature2"].copy(CombustorTemperature2));

            int PassingTime = -1;

            if (!string.IsNullOrEmpty(TB_PassingTime.Text.Trim()) && !int.TryParse(TB_PassingTime.Text.Trim(), out PassingTime))
                PassingTime = -1;

            dbcb.appendParameter(Schema.Attributes["PassingTime"].copy(PassingTime));

            int SettingTemperature = -1;

            if (!string.IsNullOrEmpty(TB_SettingTemperature.Text.Trim()) && !int.TryParse(TB_SettingTemperature.Text.Trim(), out SettingTemperature))
                SettingTemperature = -1;

            dbcb.appendParameter(Schema.Attributes["SettingTemperature"].copy(SettingTemperature));

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
            Util.ED.DeletEDData(HF_PID.Value.ToStringFromBase64(), ((short)Util.ED.PIDType.T_EDCuring), false);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}