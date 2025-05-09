using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Logout : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (BaseConfiguration.OnlineAccount.ContainsKey(Master.AccountID))
            BaseConfiguration.OnlineAccount.Remove(Master.AccountID);

        Page.ClientScript.RegisterHiddenField("HomeAddress", Master.HomeAddress);
    }
}