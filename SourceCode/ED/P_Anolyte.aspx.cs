using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;

public partial class ED_P_Anolyte : System.Web.UI.Page
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

    protected void LoadDDLData()
    {
        Util.ED.LaodWorkClass(DDL_WorkClass);

        Util.ED.LoadProductionLine(DDL_PLID);
    }

    protected void LoadPrametersRemark()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select * From T_EDPStandardValue Where PrametersID in (Select item From Base_Org.dbo.Split(@Prameters,'|'))");

        dbcb.appendParameter(Util.GetDataAccessAttribute("Prameters", "nvarchar", 10000, "EDP121|EDP122"));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DataRow EDP121Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP121").FirstOrDefault();

        DataRow EDP122Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP122").FirstOrDefault();


        if (EDP121Row != null)
        {
            string MaxValue = ((decimal)EDP121Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP121Row["MinValue"]).ToString("0.##");

            TB_PHValue1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PHValue2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue2.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue1.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHValue1_Remark"), MaxValue, MinValue));
            TB_PHValue2.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHValue2_Remark"), MaxValue, MinValue));
        }

        if (EDP122Row != null)
        {
            string MaxValue = ((decimal)EDP122Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP122Row["MinValue"]).ToString("0.##");

            TB_Conductivity1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Conductivity1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_Conductivity2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Conductivity2.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_Conductivity1.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Conductivity1_Remark"), MaxValue, MinValue));
            TB_Conductivity2.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Conductivity2_Remark"), MaxValue, MinValue));
        }

        L_PHValue1.Text += "1";
        L_PHValue2.Text += "2";

        L_Conductivity1.Text += "1";
        L_Conductivity2.Text += "2";
    }

    protected void LoadData()
    {
        if (string.IsNullOrEmpty(HF_PID.Value))
            return;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPAnolyte"];

        string Query = "Select *,Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName From T_EDPAnolyte Where PID = @PID";

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

        decimal Conductivity1 = (decimal)Row["Conductivity1"];

        if (Conductivity1 > -1)
            TB_Conductivity1.Text = Conductivity1.ToString();

        decimal Conductivity2 = (decimal)Row["Conductivity2"];

        if (Conductivity2 > -1)
            TB_Conductivity2.Text = Conductivity2.ToString();

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

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPAnolyte"];

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
                string.IsNullOrEmpty(TB_Conductivity1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Conductivity2.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));

            if (string.IsNullOrEmpty(HF_PID.Value))
            {
                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Insert Into T_EDPAnolyte (PID,PDate,WorkClassID,PLID,PHValue1,PHValue2,Conductivity1,Conductivity2,Remark,CreateAccountID) 
                          Values (@PID,@PDate,@WorkClassID,@PLID,@PHValue1,@PHValue2,@Conductivity1,@Conductivity2,@Remark,@CreateAccountID)";

                PID = BaseConfiguration.SerialObject[(short)12].取號();

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));
            }
            else
            {
                PID = HF_PID.Value.ToStringFromBase64();

                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue, PID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Update T_EDPAnolyte Set PDate = @PDate,WorkClassID = @WorkClassID,PLID = @PLID,PHValue1 = @PHValue1,PHValue2 = @PHValue2,Conductivity1 = @Conductivity1,Conductivity2 = @Conductivity2,
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

            decimal Conductivity1 = -1;

            if (!string.IsNullOrEmpty(TB_Conductivity1.Text.Trim()) && !decimal.TryParse(TB_Conductivity1.Text.Trim(), out Conductivity1))
                Conductivity1 = -1;
            dbcb.appendParameter(Schema.Attributes["Conductivity1"].copy(Conductivity1));

            decimal Conductivity2 = -1;

            if (!string.IsNullOrEmpty(TB_Conductivity2.Text.Trim()) && !decimal.TryParse(TB_Conductivity2.Text.Trim(), out Conductivity2))
                Conductivity2 = -1;
            dbcb.appendParameter(Schema.Attributes["Conductivity2"].copy(Conductivity2));

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
            Util.ED.DeletEDData(HF_PID.Value.ToStringFromBase64(), ((short)Util.ED.PIDType.T_EDPAnolyte), false);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}