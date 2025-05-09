using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TimeSheet_TicketCreate : System.Web.UI.Page
{
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {

    }
}