using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TimeSheet_RPT_012 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        TB_DateEnd.Text = DateTime.Now.ToCurrentUICultureString() + " 06:00:00";

        TB_DateStart.Text = DateTime.Now.AddDays(-30).ToCurrentUICultureString() + " 06:00:00";
    }
}