﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TimeSheet_RPT_020 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if(!Master.IsAccountVerificationPass)
            return;
    }
}