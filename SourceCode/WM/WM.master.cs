using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class WM_WM : System.Web.UI.MasterPage
{
    /// <summary>
    /// 頁面是否要跳過驗證帳密
    /// </summary>
    public bool IsPassPageVerificationAccount
    {
        get { return Master.IsPassPageVerificationAccount; }
        set { Master.IsPassPageVerificationAccount = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {

    }
}
