using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;


public partial class ED_P_SurfaceActivation : System.Web.UI.Page
{
    /// <summary>
    /// 目前寫死，因此這個值必須要跟T_Code的ChemicalAdding對的上
    /// </summary>
    protected string CA1CategoryID = "CA5";

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

        dbcb.appendParameter(Util.GetDataAccessAttribute("CodeID", "nvarchar", 10000, CA1CategoryID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        string ChemicalAdding_HeadText = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_ChemicalAdding_HeadText");

        DataRow CA1Row = DT.AsEnumerable().Where(Row => Row["CodeID"].ToString().Trim() == CA1CategoryID).FirstOrDefault();

        CA1_Title.Text = ChemicalAdding_HeadText;

        if (CA1Row != null)
            CA1_Title.Text += "-" + CA1Row["CodeName"].ToString().Trim();
    }
    protected void LoadPrametersRemark()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select * From T_EDPStandardValue Where PrametersID in (Select item From Base_Org.dbo.Split(@Prameters,'|'))");

        dbcb.appendParameter(Util.GetDataAccessAttribute("Prameters", "nvarchar", 10000, "EDP71|EDP72"));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DataRow EDP71Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP71").FirstOrDefault();

        DataRow EDP72Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP72").FirstOrDefault();



        if (EDP71Row != null)
        {
            string MaxValue = ((decimal)EDP71Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP71Row["MinValue"]).ToString("0.##");

            TB_PHValue1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PHValue2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue2.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue1.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHValue1_Remark"), MaxValue, MinValue));
            TB_PHValue2.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHValue2_Remark"), MaxValue, MinValue));
        }

        if (EDP72Row != null)
        {
            string ProcessSecondRemark = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_ProcessSecondRemark");

            string MaxValue = ((decimal)EDP72Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP72Row["MinValue"]).ToString("0.##");

            TB_ProcessSecond.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecond.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecond.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        L_PHValue1.Text += "1";

        L_PHValue2.Text += "2";
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

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPSurfaceActivation"];

        string Query = "Select *,Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName From T_EDPSurfaceActivation Where PID = @PID";

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
                DateTime AddDateTime = (DateTime)R["AddDateTime"];

                if (AddDateTime.Year > 1911)
                    TB_CA1_AddDateTime.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                decimal Qty = (decimal)R["Qty"];

                if (Qty > -1)
                    TB_CA1_Qty.Text = Qty.ToString();

                TB_CA1_LotNumber.Text = R["LotNumber"].ToString().Trim();

                continue;
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

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPSurfaceActivation"];

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
                string.IsNullOrEmpty(TB_ProcessSecond.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));


            if (string.IsNullOrEmpty(HF_PID.Value))
            {
                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Insert Into T_EDPSurfaceActivation (PID,PDate,WorkClassID,PLID,PHValue1,PHValue2,ProcessSecond,Remark,CreateAccountID) Values (@PID,@PDate,@WorkClassID,@PLID,@PHValue1,@PHValue2,@ProcessSecond,@Remark,@CreateAccountID)";

                PID = BaseConfiguration.SerialObject[(short)7].取號();

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));
            }
            else
            {
                PID = HF_PID.Value.ToStringFromBase64();

                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue, PID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Update T_EDPSurfaceActivation Set PDate = @PDate,WorkClassID = @WorkClassID,PLID = @PLID,PHValue1 = @PHValue1,PHValue2 = @PHValue2,ProcessSecond = @ProcessSecond,Remark = @Remark,ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where PID = @PID";

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

            if (!string.IsNullOrEmpty(TB_PHValue1.Text.Trim()) && !decimal.TryParse(TB_PHValue2.Text.Trim(), out PHValue2))
                PHValue2 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue2"].copy(PHValue2));

            int ProcessSecond = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecond.Text.Trim()) && !int.TryParse(TB_ProcessSecond.Text.Trim(), out ProcessSecond))
                ProcessSecond = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond"].copy(ProcessSecond));

            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            short SerialNo = 1;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CA1CategoryID));

            if (!string.IsNullOrEmpty(TB_CA1_AddDateTime.Text.Trim()) && !string.IsNullOrEmpty(TB_CA1_Qty.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CA1CategoryID, PDate, TB_CA1_AddDateTime, TB_CA1_Qty, TB_CA1_LotNumber));
            else if (!string.IsNullOrEmpty(TB_CA1_AddDateTime.Text.Trim() + TB_CA1_Qty.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA1_Qty.Text.Trim()) && double.Parse(TB_CA1_Qty.Text.Trim()) > 0))
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
            Util.ED.DeletEDData(HF_PID.Value.ToStringFromBase64(), ((short)Util.ED.PIDType.T_EDPSurfaceActivation), true);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}