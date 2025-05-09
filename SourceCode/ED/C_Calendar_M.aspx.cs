using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;

public partial class ED_C_Calendar_M : System.Web.UI.Page
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
            if (Request["CleanDate"] != null && !string.IsNullOrEmpty(Request["CleanDate"].ToString()))
                TB_CleanDate.Text = Request["CleanDate"].ToString().ToStringFromBase64();
            else if (Request["CID"] != null && !string.IsNullOrEmpty(Request["CID"].ToString()))
                HF_CID.Value = Request["CID"].ToString();
            else
            {
                Util.RegisterStartupScriptJqueryAlert(this,
                    (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_EmptyPDateOrPIDAlertMessage"),
                    true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }

            Util.ED.LaodWorkClass(DDL_WorkClass);

            Util.ED.LoadProductionLine(DDL_PLID);

            Util.ED.LoadCleanProcess(DDL_Process);

            if (Request["PLID"] != null && !string.IsNullOrEmpty(Request["PLID"].ToString()))
                DDL_PLID.SelectedValue = Request["PLID"].ToString().ToStringFromBase64();

            LoadData();
        }

        BT_Delete.Visible = !(string.IsNullOrEmpty(HF_CID.Value));
    }

    protected void LoadData()
    {
        if (string.IsNullOrEmpty(HF_CID.Value))
            return;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDCRecord"];

        string Query = "Select *,Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName From T_EDCRecord Where CID = @CID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["CID"].copy(HF_CID.Value.ToStringFromBase64()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return;

        DataRow Row = DT.Rows[0];

        TB_CleanDate.Text = ((DateTime)Row["CleanDate"]).ToCurrentUICultureString();

        DDL_WorkClass.SelectedValue = Row["WorkClassID"].ToString().Trim();

        DDL_PLID.SelectedValue = Row["PLID"].ToString().Trim();

        DDL_Process.SelectedValue = Row["ProcessID"].ToString().Trim();

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

            string CID = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDCRecord"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            DateTime CleanDate = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_CleanDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out CleanDate))
                CleanDate = DateTime.Parse("1900/01/01");

            if (CleanDate.Year < 1911)
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if (string.IsNullOrEmpty(DDL_WorkClass.SelectedValue) || string.IsNullOrEmpty(DDL_PLID.SelectedValue) || string.IsNullOrEmpty(DDL_Process.SelectedValue))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if (string.IsNullOrEmpty(HF_CID.Value))
            {
                if (Util.ED.IsCleanDateRepeat(CleanDate, DDL_PLID.SelectedValue, DDL_Process.SelectedValue))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_C_DataRepeat"));

                Query = @"Insert Into T_EDCRecord (CID,CleanDate,WorkClassID,PLID,ProcessID,Remark,CreateAccountID) 
                          Values (@CID,@CleanDate,@WorkClassID,@PLID,@ProcessID,@Remark,@CreateAccountID)";

                CID = BaseConfiguration.SerialObject[(short)16].取號();

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));
            }
            else
            {
                CID = HF_CID.Value.ToStringFromBase64();

                if (Util.ED.IsCleanDateRepeat(CleanDate, DDL_PLID.SelectedValue, DDL_Process.SelectedValue, CID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_C_DataRepeat"));

                Query = @"Update T_EDCRecord Set CleanDate = @CleanDate,WorkClassID = @WorkClassID,PLID = @PLID,ProcessID = @ProcessID,Remark = @Remark,ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where CID = @CID";

                dbcb.appendParameter(Schema.Attributes["ModifyAccountID"].copy(Master.AccountID));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["CID"].copy(CID));
            dbcb.appendParameter(Schema.Attributes["CleanDate"].copy(CleanDate));
            dbcb.appendParameter(Schema.Attributes["WorkClassID"].copy((DDL_WorkClass.SelectedValue)));
            dbcb.appendParameter(Schema.Attributes["PLID"].copy((DDL_PLID.SelectedValue)));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy((DDL_Process.SelectedValue)));

            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"),
                 true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
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

            string CID = HF_CID.Value.ToStringFromBase64();

            string Query = @"Delete T_EDCRecord Where CID = @CID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDCRecord"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["CID"].copy(CID));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"),
                true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}