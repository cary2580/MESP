using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TimeSheet_RPT_011 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
        {
            LoadData();
        }
    }
    private void LoadData()
    {
        DataTable DT = Util.GetCodeTypeData("TS_ProcessTypeID");

        DLL_ProcessType.DataValueField = "CodeID";

        DLL_ProcessType.DataTextField = "CodeName";

        DLL_ProcessType.DataSource = DT;

        DLL_ProcessType.DataBind();

        DLL_ProcessType.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }
}