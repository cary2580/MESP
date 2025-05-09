using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TimeSheet_RPT_030 : System.Web.UI.Page
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


    //加载工种下拉列表
    private void LoadData()
    {
        DataTable DT = Util.GetCodeTypeData("TS_ProcessID");

        DLL_ProcessID.DataValueField = "CodeID";

        DLL_ProcessID.DataTextField = "CodeName";

        DLL_ProcessID.DataSource = DT;

        DLL_ProcessID.DataBind();

        DLL_ProcessID.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }
}