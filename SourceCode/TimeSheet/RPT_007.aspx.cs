using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TimeSheet_RPT_007 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        TB_CreateDateStart.Text = DateTime.Now.AddDays(-1).ToCurrentUICultureString() + " 06:00:00";

        TB_CreateDateEnd.Text = DateTime.Now.ToCurrentUICultureString() + " 05:59:59";
    }
}