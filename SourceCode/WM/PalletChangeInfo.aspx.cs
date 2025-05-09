using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;


public partial class WM_PalletChangeInfo : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();
        if (Request["PalletNo"] != null)
            HF_PalletNo.Value = Request["PalletNo"].Trim();

        if (!IsPostBack)
            LoadData();
    }

    protected void LoadData()
    {
        string Query = @"Select * From T_SAPT001L";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT_Warehouse = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_LGORT.DataValueField = "LGORT";

        DDL_LGORT.DataTextField = "LGOBE";

        DDL_LGORT.DataSource = DT_Warehouse;

        DDL_LGORT.DataBind();

        DDL_LGORT.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            List<string> PalletNoList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(HF_PalletNo.Value);

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPallet"];

            string Query = @"Update T_WMProductPallet Set LGORT = @LGORT Where PalletNo = @PalletNo";

            foreach (string PalletNo in PalletNoList)
            {
                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["LGORT"].copy(DDL_LGORT.SelectedValue));

                dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_SubmitSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, false);
        }
    }
}