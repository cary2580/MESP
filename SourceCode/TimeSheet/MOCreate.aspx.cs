using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_MOCreate : System.Web.UI.Page
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
                LoadData();

                TB_ERDAT.Text = DateTime.Now.ToCurrentUICultureString();

                TB_FTRMI.Text = DateTime.Now.ToCurrentUICultureString();
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
        string Query = @"Select TEXT1,(PLNNR + '_' + ALNAL) As GroupCurr From T_TSSAPMKAL Where IsLock = 0 Group By TEXT1,(PLNNR + '_' + ALNAL)";

        DataTable DT = CommonDB.ExecuteSelectQuery(Query);

        DDL_ProductionVersion.DataValueField = "GroupCurr";

        DDL_ProductionVersion.DataTextField = "TEXT1";

        DDL_ProductionVersion.DataSource = DT;

        DDL_ProductionVersion.DataBind();

        DDL_ProductionVersion.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }

    protected void BT_Save_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            if (DDL_ProductionVersion.SelectedValue == "" ||
                string.IsNullOrEmpty(TB_GSTRP.Text) ||
                string.IsNullOrEmpty(TB_GLTRP.Text) ||
                string.IsNullOrEmpty(TB_PSMNG.Text) ||
                string.IsNullOrEmpty(TB_ERDAT.Text) ||
                string.IsNullOrEmpty(TB_FTRMI.Text) ||
                string.IsNullOrEmpty(TB_BATCH.Text))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            int PSMNG = 0;

            if (!int.TryParse(TB_PSMNG.Text.Trim(), out PSMNG))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));
            if (PSMNG < 1)
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            string SPName = "SP_TS_CreateMO_" + DDL_ProductionVersion.SelectedValue;

            DbCommandBuilder dbcb = new DbCommandBuilder(SPName);

            dbcb.DbCommandType = CommandType.StoredProcedure;

            DateTime ERDAT = DateTime.Parse("1900/01/01");
            DateTime FTRMI = DateTime.Parse("1900/01/01");
            DateTime GSTRP = DateTime.Parse("1900/01/01");
            DateTime GLTRP = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_ERDAT.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ERDAT))
                ERDAT = DateTime.Parse("1900/01/01");
            if (!DateTime.TryParse(TB_FTRMI.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out FTRMI))
                FTRMI = DateTime.Parse("1900/01/01");
            if (!DateTime.TryParse(TB_GSTRP.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out GSTRP))
                GSTRP = DateTime.Parse("1900/01/01");
            if (!DateTime.TryParse(TB_GLTRP.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out GLTRP))
                GLTRP = DateTime.Parse("1900/01/01");

            dbcb.appendParameter(Util.GetDataAccessAttribute("PSMNG", "Decimal", 0, PSMNG));
            dbcb.appendParameter(Util.GetDataAccessAttribute("ERDAT", "DateTime", 0, ERDAT));
            dbcb.appendParameter(Util.GetDataAccessAttribute("FTRMI", "DateTime", 0, FTRMI));
            dbcb.appendParameter(Util.GetDataAccessAttribute("GSTRP", "DateTime", 0, GSTRP));
            dbcb.appendParameter(Util.GetDataAccessAttribute("GLTRP", "DateTime", 0, GLTRP));
            dbcb.appendParameter(Util.GetDataAccessAttribute("BATCH", "Nvarchar", 50, TB_BATCH.Text.Trim()));
            dbcb.appendParameter(Util.GetDataAccessAttribute("AUART", "Nvarchar", 50, DDL_AUART.SelectedValue));
            dbcb.appendParameter(Util.GetDataAccessAttribute("AUARTName", "Nvarchar", 50, DDL_AUART.SelectedItem.Text));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_CreateSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, false);
        }
    }
}