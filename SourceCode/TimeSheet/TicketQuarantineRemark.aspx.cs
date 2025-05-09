using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketQuarantineRemark : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (Request["DivID"] != null)
                DivID = Request["DivID"].Trim();

            if (!IsPostBack)
            {
                if (Request["TicketID"] != null)
                    HF_TicketID.Value = Request["TicketID"].Trim();

                if (string.IsNullOrEmpty(HF_TicketID.Value))
                    throw new Exception((string)GetLocalResourceObject("Str_ErrorKeyValueEmpty"));

                LoadData();
            }
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select Remark From T_TSTicketQuarantineResult Where TicketID = @TicketID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResult"];

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            TB_Remark.Text = DT.Rows[0]["Remark"].ToString().Trim();
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            string Query = @"Update T_TSTicketQuarantineResult Set Remark = @Remark Where TicketID = @TicketID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResult"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value.Trim()));
            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true, false);
        }
    }
}