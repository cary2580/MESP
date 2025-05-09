using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;

public partial class ED_P_HCL1 : System.Web.UI.Page
{
    /// <summary>
    /// 目前寫死，因此這個值必須要跟T_Code的ChemicalAdding對的上
    /// </summary>
    protected string CA1CategoryID = "CA3";

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

        dbcb.appendParameter(Util.GetDataAccessAttribute("Prameters", "nvarchar", 10000, "EDP41|EDP42|EDP43"));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DataRow EDP41Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP41").FirstOrDefault();

        DataRow EDP42Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP42").FirstOrDefault();

        DataRow EDP43Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP43").FirstOrDefault();

        string PHRemark = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PHRemark");

        string ProcessSecondRemark = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_ProcessSecondRemark");

        string PValue1Remark = (string)GetLocalResourceObject("Str_ED_P_PValue1_Remark");

        string PValue2Remark = (string)GetLocalResourceObject("Str_ED_P_PValue2_Remark");

        if (EDP41Row != null)
        {
            string MaxValue = ((decimal)EDP41Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP41Row["MinValue"]).ToString("0.##");

            TB_PHValue.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue.Attributes.Add("data-MumberTypeMinValue", MinValue);

            PHRemark = string.Format(PHRemark, MaxValue, MinValue);
        }

        if (EDP42Row != null)
        {
            string MaxValue = ((decimal)EDP42Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP42Row["MinValue"]).ToString("0.##");

            TB_ProcessSecond.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecond.Attributes.Add("data-MumberTypeMinValue", MinValue);

            ProcessSecondRemark = string.Format(ProcessSecondRemark, MaxValue, MinValue);
        }

        if (EDP43Row != null)
        {
            string MaxValue = ((decimal)EDP43Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP43Row["MinValue"]).ToString("0.##");

            TB_PValue1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PValue1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PValue2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PValue2.Attributes.Add("data-MumberTypeMinValue", MinValue);

            PValue1Remark = string.Format(PValue1Remark, MaxValue, MinValue);

            PValue2Remark = string.Format(PValue2Remark, MaxValue, MinValue);
        }

        TB_PHValue.Attributes.Add("title", PHRemark);

        TB_ProcessSecond.Attributes.Add("title", ProcessSecondRemark);

        TB_PValue1.Attributes.Add("title", PValue1Remark);

        TB_PValue2.Attributes.Add("title", PValue2Remark);
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

    protected void LoadData()
    {
        if (string.IsNullOrEmpty(HF_PID.Value))
            return;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPHCL1"];

        string Query = "Select *,Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName From T_EDPHCL1 Where PID = @PID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PID"].copy(HF_PID.Value.ToStringFromBase64()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return;

        DataRow Row = DT.Rows[0];

        TB_PDate.Text = ((DateTime)Row["PDate"]).ToCurrentUICultureString();

        DDL_WorkClass.SelectedValue = Row["WorkClassID"].ToString().Trim();

        DDL_PLID.SelectedValue = Row["PLID"].ToString().Trim();

        decimal PHValue = (decimal)Row["PHValue"];

        if (PHValue > -1)
            TB_PHValue.Text = PHValue.ToString();

        int ProcessSecond = (int)Row["ProcessSecond"];

        if (ProcessSecond > -1)
            TB_ProcessSecond.Text = ProcessSecond.ToString();

        decimal PValue1 = (decimal)Row["PValue1"];

        if (PValue1 > -1)
            TB_PValue1.Text = PValue1.ToString();

        decimal PValue2 = (decimal)Row["PValue2"];

        if (PValue2 > -1)
            TB_PValue2.Text = PValue2.ToString();

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

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPHCL1"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            DateTime PDate = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_PDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out PDate))
                PDate = DateTime.Parse("1900/01/01");

            if (PDate.Year < 1911)
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if (string.IsNullOrEmpty(DDL_WorkClass.SelectedValue) || string.IsNullOrEmpty(DDL_PLID.SelectedValue))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            // 至少要輸入一個參數
            if (string.IsNullOrEmpty(TB_PHValue.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecond.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PValue1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PValue2.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));


            if (string.IsNullOrEmpty(HF_PID.Value))
            {
                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Insert Into T_EDPHCL1 (PID,PDate,WorkClassID,PLID,PHValue,ProcessSecond,PValue1,PValue2,Remark,CreateAccountID) Values (@PID,@PDate,@WorkClassID,@PLID,@PHValue,@ProcessSecond,@PValue1,@PValue2,@Remark,@CreateAccountID)";

                PID = BaseConfiguration.SerialObject[(short)4].取號();

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));
            }
            else
            {
                PID = HF_PID.Value.ToStringFromBase64();

                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue, PID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Update T_EDPHCL1 Set PDate = @PDate,WorkClassID = @WorkClassID,PLID = @PLID,PHValue = @PHValue,ProcessSecond = @ProcessSecond,PValue1 = @PValue1,PValue2 = @PValue2,Remark = @Remark,ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where PID = @PID";

                dbcb.appendParameter(Schema.Attributes["ModifyAccountID"].copy(Master.AccountID));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["PID"].copy(PID));
            dbcb.appendParameter(Schema.Attributes["PDate"].copy(PDate));
            dbcb.appendParameter(Schema.Attributes["WorkClassID"].copy((DDL_WorkClass.SelectedValue)));
            dbcb.appendParameter(Schema.Attributes["PLID"].copy((DDL_PLID.SelectedValue)));

            decimal PHValue = -1;

            if (!string.IsNullOrEmpty(TB_PHValue.Text.Trim()) && !decimal.TryParse(TB_PHValue.Text.Trim(), out PHValue))
                PHValue = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue"].copy(PHValue));

            int ProcessSecond = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecond.Text.Trim()) && !int.TryParse(TB_ProcessSecond.Text.Trim(), out ProcessSecond))
                ProcessSecond = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond"].copy(ProcessSecond));

            decimal PValue1 = -1;

            if (!string.IsNullOrEmpty(TB_PValue1.Text.Trim()) && !decimal.TryParse(TB_PValue1.Text.Trim(), out PValue1))
                PValue1 = -1;

            dbcb.appendParameter(Schema.Attributes["PValue1"].copy(PValue1));

            decimal PValue2 = -1;

            if (!string.IsNullOrEmpty(TB_PValue2.Text.Trim()) && !decimal.TryParse(TB_PValue2.Text.Trim(), out PValue2))
                PValue2 = -1;

            dbcb.appendParameter(Schema.Attributes["PValue2"].copy(PValue2));

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
            Util.ED.DeletEDData(HF_PID.Value.ToStringFromBase64(), ((short)Util.ED.PIDType.T_EDPHCL1), true);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}