using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MasterPage : System.Web.UI.MasterPage
{
    /// <summary>
    /// 取得是否為系統管理員
    /// </summary>
    public bool IsAdmin { get { return Master.IsAdmin; } }

    /// <summary>
    /// 取得是否為使用者管理員
    /// </summary>
    public bool IsUserAdmin { get { return Master.IsUserAdmin; } }

    /// <summary>
    /// 取得是否為班長
    /// </summary>
    public bool IsShiftLeader { get { return Master.IsShiftLeader; } }

    /// <summary>
    /// 取得或設定帳號ID
    /// </summary>
    public int AccountID
    {
        get
        {
            return Master.AccountID;
        }
        set
        {
            Master.AccountID = value;
        }
    }

    /// <summary>
    /// 取得工號
    /// </summary>
    public string WorkCode
    {
        get { return Master.WorkCode; }
    }

    /// <summary>
    /// 取得或設定帳號驗證是否成功
    /// </summary>
    public bool IsAccountVerificationPass
    {
        get
        {
            return Master.IsAccountVerificationPass;
        }
        set
        {
            Master.IsAccountVerificationPass = value;
        }
    }

    /// <summary>
    /// 取得或設定langCookie
    /// </summary>
    public string LangCookie
    {
        get { return Master.LangCookie; }
        set { Master.LangCookie = value; }
    }

    /// <summary>
    /// 取得或設定PageMenuName名稱
    /// </summary>
    public string PageMenuName
    {
        get { return Master.PageMenuName; }
        set { Master.PageMenuName = value; }
    }

    /// <summary>
    /// 取得或設定首頁位置
    /// </summary>
    public string HomeAddress
    {
        get { return Master.HomeAddress; }
        set { Master.HomeAddress = value; }
    }

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
        if (BaseConfiguration.OnlineAccount.ContainsKey(AccountID) && BaseConfiguration.OnlineAccount[AccountID].IsHaveOAAccount)
            BT_ChangePassword.Visible = false;

        string UserMenuPath = string.Empty;

        switch (LangCookie)
        {
            case "en-US":
                UserMenuPath = @"~\UserMenu_US.pdf";
                break;
            case "zh-CN":
                UserMenuPath = @"~\UserMenu_CN.pdf";
                break;
            default:
                UserMenuPath = @"~\UserMenu_TW.pdf";
                break;
        }

        BT_UserMenu.HRef = UserMenuPath;

        BT_UserMenu.Visible = false;

        if (!IsAccountVerificationPass)
            return;

        MenuBarAMD.Visible = IsAdmin;

        MenuBarElectrophoresisModule.Visible = (IsAdmin || BaseConfiguration.ElectrophoresisModuleAccessIPList.Contains(System.Net.IPAddress.Parse(Request.UserHostAddress)) || BaseConfiguration.ElectrophoresisModuleAccessAccountList.Contains(WorkCode));

        //MenuBarElectrophoresisModule.Visible = false;
    }
}
