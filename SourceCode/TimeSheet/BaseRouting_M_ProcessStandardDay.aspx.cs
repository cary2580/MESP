using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;

public partial class TimeSheet_BaseRouting_M_ProcessStandardDay : System.Web.UI.Page
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
            if (Request["PLNNR"] != null)
                HF_PLNNR.Value = Request["PLNNR"].Trim();

            if (Request["PLNAL"] != null)
                HF_PLNAL.Value = Request["PLNAL"].Trim();

            if (Request["PLNKN"] != null)
                HF_PLNKN.Value = Request["PLNKN"].Trim();

            if (Request["ProcessID"] != null)
                HF_ProcessID.Value = Request["ProcessID"].Trim();

            LoadData();
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select * From T_TSBaseRouting Where PLNNR = @PLNNR And PLNAL = @PLNAL And PLNKN = @PLNKN And ProcessID = @ProcessID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(HF_PLNNR.Value));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(HF_PLNAL.Value));
        dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(HF_PLNKN.Value));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            TB_ProcessStandardDay.Text = DT.Rows[0]["ProcessStandardDay"].ToString().Trim();
            TB_ProcessReWorkStandardDay.Text = DT.Rows[0]["ProcessReWorkStandardDay"].ToString().Trim();
        }
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            string Query = @"Update T_TSBaseRouting Set ProcessStandardDay = @ProcessStandardDay,ProcessReWorkStandardDay = @ProcessReWorkStandardDay Where PLNNR = @PLNNR And PLNAL = @PLNAL And PLNKN = @PLNKN And ProcessID = @ProcessID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

            dbcb.appendParameter(Schema.Attributes["ProcessStandardDay"].copy(TB_ProcessStandardDay.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["ProcessReWorkStandardDay"].copy(TB_ProcessReWorkStandardDay.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(HF_PLNNR.Value));
            dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(HF_PLNAL.Value));
            dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(HF_PLNKN.Value));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}