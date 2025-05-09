using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Sap.Data.Hana;

public partial class TimeSheet_StandardMinute_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["ARBPL"] != null)
            {
                TB_ARBPL.Text = Request["ARBPL"].Trim();
                HF_ARBPL.Value = Request["ARBPL"].Trim();
            }

            if (!string.IsNullOrEmpty(TB_ARBPL.Text))
            {
                TB_ARBPL.CssClass += " readonly readonlyColor ";

                LoadData();
            }
        }

        BT_Delete.Visible = !(string.IsNullOrEmpty(HF_ARBPL.Value));
    }

    protected void LoadData()
    {
        string Query = @"Select * From T_TSStandardMinute Where ARBPL = @ARBPL";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSStandardMinute"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(TB_ARBPL.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_NoARBPLRow"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_KTEXT.Text = DT.Rows[0]["KTEXT"].ToString().Trim();

        DDL_IsResultMinute.SelectedValue = ((bool)DT.Rows[0]["IsResultMinute"]).ToStringValue();
        DDL_IsResultMinuteForPersonnel.SelectedValue = ((bool)DT.Rows[0]["IsResultMinuteForPersonnel"]).ToStringValue();
    }

    /// <summary>
    /// 取得是否已有設定此工作中心
    /// </summary>
    /// <returns></returns>
    protected bool CheckHaveARBPL()
    {
        string Query = @"Select Count(*) From T_TSStandardMinute Where ARBPL = @ARBPL";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSStandardMinute"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(TB_ARBPL.Text.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 取得SAP工作中心描述短文
    /// </summary>
    /// <returns>SAP工作中心描述短文</returns>
    protected string GetSAPKTEXT()
    {
        string Query = @"Select CRHD.ARBPL,CRTX.KTEXT
                            From CRHD Inner Join CRTX On CRHD.MANDT = CRTX.MANDT And CRHD.OBJTY = CRTX.OBJTY And CRHD.OBJID = CRTX.OBJID
                            Where CRHD.MANDT = ? And WERKS = ? And CRHD.ARBPL = ?";

        HanaCommand Command = new HanaCommand(Query);

        Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
        Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());
        Command.Parameters.Add("ARBPL", TB_ARBPL.Text.Trim());

        DataTable DT = SAP.GetSelectSAPData(Command);

        if (DT.Rows.Count > 0)
            return DT.Rows[0]["KTEXT"].ToString().Trim();
        else
            return string.Empty;
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            string Query = string.Empty;

            string KTEXT = GetSAPKTEXT();

            if (string.IsNullOrEmpty(KTEXT))
                throw new Exception((string)GetLocalResourceObject("Str_Error_KTEXT"));

            if (string.IsNullOrEmpty(HF_ARBPL.Value))
            {
                if (CheckHaveARBPL())
                    throw new Exception((string)GetLocalResourceObject("Str_Error_ARBPLRepeat"));

                Query = @"Insert Into T_TSStandardMinute (ARBPL,KTEXT,IsResultMinute,IsResultMinuteForPersonnel) Values (@ARBPL,@KTEXT,@IsResultMinute,@IsResultMinuteForPersonnel)";
            }
            else
                Query = @"Update T_TSStandardMinute Set KTEXT = @KTEXT,IsResultMinute = @IsResultMinute,IsResultMinuteForPersonnel = @IsResultMinuteForPersonnel Where ARBPL = @ARBPL";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSStandardMinute"];

            dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(TB_ARBPL.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["KTEXT"].copy(KTEXT));
            dbcb.appendParameter(Schema.Attributes["IsResultMinute"].copy(DDL_IsResultMinute.SelectedValue));
            dbcb.appendParameter(Schema.Attributes["IsResultMinuteForPersonnel"].copy(DDL_IsResultMinuteForPersonnel.SelectedValue));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true);
        }
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            string Query = @"Delete T_TSStandardMinute Where ARBPL = @ARBPL";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSStandardMinute"];

            dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(HF_ARBPL.Value.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true);
        }
    }
}