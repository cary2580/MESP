using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class GeneralRemark : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            HF_DivID.Value = Request["DivID"].Trim();

        if (Request["IsRequired"] != null)
            HF_IsRequired.Value = Request["IsRequired"].Trim();

        if (Request["DefaultValue"] != null)
            TB_Remark.Text = Request["DefaultValue"].Trim();

        if (Request["DisPlayName"] != null)
            L_Remark.Text = Request["DisPlayName"].Trim();
        else
            L_Remark.Text = (string)GetGlobalResourceObject("GlobalRes", "Str_Remark");
    }
}