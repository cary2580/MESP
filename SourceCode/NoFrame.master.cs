using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class NoFrame : BaseMasterPage
{
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        if (!IsAccountVerificationPass)
            return;
    }

    private new void Page_Load(object sender, EventArgs e)
    {
        if (!IsAccountVerificationPass)
            return;

        base.Page_Load(sender, e);
    }
}
