using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class WM_RPT_002 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            TB_PalletCreateDateStart.Text = DateTime.Now.ToCurrentUICultureString() + " 00:00:00";
            TB_PalletCreateDateEnd.Text = DateTime.Now.ToCurrentUICultureString() + " 23:59:59";
        }
    }
}