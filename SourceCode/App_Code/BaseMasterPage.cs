using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// BaseMasterPage 的摘要描述
/// </summary>
public class BaseMasterPage : System.Web.UI.MasterPage
{
    /// <summary>
    /// 取得或設定首頁位置
    /// </summary>
    public string HomeAddress { get; set; }
    /// <summary>
    /// 取得或指定帳號ID
    /// </summary>
    public int AccountID { get; set; }
    /// <summary>
    /// 取得帳號名稱
    /// </summary>
    public string AccountName
    {
        get { return BaseConfiguration.GetAccountName(AccountID); }
    }
    /// <summary>
    /// 帳號驗證是否成功
    /// </summary>
    public bool IsAccountVerificationPass { get; set; }
    /// <summary>
    /// 是否為系統管理員
    /// </summary>
    public bool IsAdmin { get; set; }
    /// <summary>
    /// 是否為使用者管理員
    /// </summary>
    public bool IsUserAdmin { get; set; }
    /// <summary>
    /// 是否為班長
    /// </summary>
    public bool IsShiftLeader { get; set; }
    /// <summary>
    /// 取得帳號代碼
    /// </summary>
    public string WorkCode { get { return BaseConfiguration.GetWorkCode(AccountID); } }
    /// <summary>
    /// 取得或設定PageMenuName名稱
    /// </summary>
    public string PageMenuName { get; set; }
    /// <summary>
    /// 取得或設定啟用MenuBarID
    /// </summary>
    public string ActiveMenuBarID { get; set; }
    /// <summary>
    /// 取得或設定langCookie
    /// </summary>
    public string LangCookie { get; set; }
    /// <summary>
    /// 頁面是否要跳過驗證帳密
    /// </summary>
    public bool IsPassPageVerificationAccount { get; set; }

    protected override void OnInit(EventArgs e)
    {
        LangCookie = System.Threading.Thread.CurrentThread.CurrentUICulture.Name;

        IsAccountVerificationPass = false;

        HomeAddress = ResolveClientUrl(@"~/Login.aspx");

        try
        {
            if (BaseConfiguration.TimeOutMinutes > 0)
            {
                var TimeOutAccountList = BaseConfiguration.OnlineAccount.Where(item => (DateTime.Now - item.Value.LastActionTime).TotalMinutes >= BaseConfiguration.TimeOutMinutes).Select(item => item.Value.AccountID).ToList();

                foreach (int TimeOutAccountID in TimeOutAccountList)
                {
                    if (BaseConfiguration.OnlineAccount.Keys.Contains(TimeOutAccountID))
                        BaseConfiguration.OnlineAccount.Remove(TimeOutAccountID);
                }
            }

            AccountID = Request["AccountID"] != null ? int.Parse(Request["AccountID"].ToStringFromBase64()) : -1;

            if (BaseConfiguration.IsVerificationAccount && !IsPassPageVerificationAccount)
            {
                string AbsolutePath = Request.Url.AbsolutePath.ToLower();

                if (!AbsolutePath.Contains("default.aspx") && !AbsolutePath.Contains("nopermission.aspx"))
                {
                    string Guid = Request.Cookies["Guid"] != null ? Request.Cookies["Guid"].Value.ToStringFromBase64(true) : string.Empty;

                    if (Request["Guid"] != null)
                    {
                        Guid = Request["Guid"].ToStringFromBase64(true);

                        Page.ClientScript.RegisterHiddenField("Guid", Request["Guid"]);
                    }
                    else
                        Guid = Request.Cookies["Guid"] != null ? Request.Cookies["Guid"].Value.ToStringFromBase64(true) : string.Empty;

                    if (!string.IsNullOrEmpty(Guid) && AccountID > -1)
                        IsAccountVerificationPass = (GetUserGuid() == Guid);

                    if (!IsAccountVerificationPass)
                        throw new Exception();
                }
                else
                    IsAccountVerificationPass = true;
            }
            else
                IsAccountVerificationPass = true;

            if (BaseConfiguration.OnlineAccount.Keys.Contains(AccountID))
            {
                bool IsRecordLastActionTime = true;

                if (HttpContext.Current.Request["IsRecordLastActionTime"] != null && !string.IsNullOrEmpty(HttpContext.Current.Request["IsRecordLastActionTime"]))
                    IsRecordLastActionTime = HttpContext.Current.Request["IsRecordLastActionTime"].ToBoolean();

                if (IsRecordLastActionTime)
                {
                    BaseConfiguration.OnlineAccount[AccountID].LastActionTime = DateTime.Now;
                    BaseConfiguration.OnlineAccount[AccountID].LastActionIP = HttpContext.Current.Request.UserHostAddress;
                    BaseConfiguration.OnlineAccount[AccountID].LastActionAbsolutePath = HttpContext.Current.Request.Url.AbsoluteUri;
                }
            }

            IsAdmin = false;

            if (Request.Cookies["IsAdmin"] != null)
                IsAdmin = Request.Cookies["IsAdmin"].Value.ToStringFromBase64().ToBoolean();

            IsUserAdmin = false;

            IsShiftLeader = false;

            if (Request.Cookies["IsUserAdmin"] != null)
                IsUserAdmin = Request.Cookies["IsUserAdmin"].Value.ToStringFromBase64().ToBoolean();

            if (Request.Cookies["IsShiftLeader"] != null)
                IsShiftLeader = Request.Cookies["IsShiftLeader"].Value.ToStringFromBase64().ToBoolean();
        }
        catch
        {
            string strScript = "<script>";
            strScript += "alert(\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_VerificationAccountFail") + "\");";
            strScript += "if (parent == 'undefined') window.location.href=\"" + HomeAddress + "\";else parent.window.location.href=\"" + HomeAddress + "\"";
            strScript += "</script>";

            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Startup", strScript);
        }

        base.OnInit(e);
    }
    /// <summary>
    /// 指定帳號得到所屬Guid
    /// </summary>
    /// <param name="AccountID">帳號代碼</param>
    /// <returns>Guid</returns>
    protected string GetUserGuid()
    {
        if (BaseConfiguration.OnlineAccount.ContainsKey(AccountID))
            return (BaseConfiguration.OnlineAccount[AccountID] as BasePage.LoginMember).Guid;
        else
            return string.Empty;
    }
    protected override void OnLoad(EventArgs e)
    {
        Page.Header.DataBind();

        base.OnLoad(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        DateTime Now = DateTime.Now;

        Page.ClientScript.RegisterStartupScript(GetType(), "DefaultBackgroundColor", "<script>var DefaultBackgroundColor='" + (string)GetGlobalResourceObject("GlobalRes", "DefaultBackgroundColor") + "'</script>");

        Page.ClientScript.RegisterHiddenField("AccountName", AccountName);

        if (Request.QueryString["MenuName"] != null && !string.IsNullOrEmpty(Request.QueryString["MenuName"]))
            PageMenuName = Request.QueryString["MenuName"].ToStringFromBase64(true);

        if (!IsAccountVerificationPass)
            return;

        if (!IsAdmin && !VerifyPermission())
        {
            string IndexURL = ResolveClientUrl(@"~/Index.aspx");

            string strScript = "<script>";
            strScript += "alert(\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_NoPermissionAlertString") + "\");";
            strScript += "if (parent == 'undefined') window.location.href=\"" + IndexURL + "\";else parent.window.location.href=\"" + IndexURL + "\"";
            strScript += "</script>";
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Startup", strScript);
        }

        Page.ClientScript.RegisterStartupScript(GetType(), "NowtDate", "<script>var NowtDate='" + Now.ToCurrentUICultureString() + "'</script>");

        Page.ClientScript.RegisterStartupScript(GetType(), "NowtTime", "<script>var NowtTime='" + Now.ToCurrentUICultureStringTime() + "'</script>");
    }

    protected bool VerifyPermission()
    {
        bool Result = false;

        string AbsolutePath = Request.Url.AbsolutePath.ToLower();

        if (!AbsolutePath.Contains("default.aspx") && !AbsolutePath.Contains("nopermission.aspx") && !AbsolutePath.Contains("index.aspx"))
        {
            if (Request.QueryString["Module"] != null && !string.IsNullOrEmpty(Request.QueryString["Module"]))
            {
                string Modules = Request.QueryString["Module"].ToStringFromBase64(true);

                foreach (string Module in Modules.Split('|'))
                {
                    Result = BaseConfiguration.OnlineAccount[AccountID].UseModule.Contains(Module);

                    if (Result)
                        break;
                }
            }
            else
                Result = !this.AppRelativeVirtualPath.Contains("MasterPage.master"); /* 先開放例外，如果進來的頁面並沒有引用MasterPage.master，就讓他pass */
        }
        else
            Result = true;

        return Result;
    }
}