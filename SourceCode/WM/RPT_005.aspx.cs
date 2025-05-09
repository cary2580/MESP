using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class WM_RPT_005 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            TB_DeliveryDateStart.Text = DateTime.Now.ToCurrentUICultureString();
            TB_DeliveryDateEnd.Text = DateTime.Now.ToCurrentUICultureString();
        }
    }
}