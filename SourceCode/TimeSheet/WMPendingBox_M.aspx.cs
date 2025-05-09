using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_WMPendingBox_M : System.Web.UI.Page
{
    protected string BoxNo = string.Empty;

    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["BoxNo"] != null)
            BoxNo = Request["BoxNo"].Trim();

        if (!string.IsNullOrEmpty(BoxNo))
            TB_BoxNo.Text = BoxNo;
    }
}