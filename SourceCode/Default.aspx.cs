using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class _Default : System.Web.UI.Page
{
    protected string AccountWorkCode = string.Empty;
    protected string PassWordMD5 = string.Empty;
    protected string AlertMessage = string.Empty;
    protected BasePage.LoginMember LM;
    protected bool IsSingleSignOn = false;

    protected override void InitializeCulture()
    {
        if (Request.Cookies["langCookie"] == null && HttpContext.Current != null && HttpContext.Current.Request.UserLanguages != null)
            Page.UICulture = "auto";

        base.InitializeCulture();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            try
            {
                if (Request["TB_Account"] != null)
                    AccountWorkCode = Request["TB_Account"].Trim();
                if (Request["TB_PassWord"] != null)
                    PassWordMD5 = Request["TB_PassWord"].Trim().ToMD5String();

                if (Request["TB_IsSingleSignOn"] != null && Request.UrlReferrer != null && Request.UrlReferrer.AbsoluteUri.ToLower().Contains("login.aspx"))
                {
                    if (!Util.BoolTryParse(Request["TB_IsSingleSignOn"].Trim(), out IsSingleSignOn))
                        IsSingleSignOn = false;
                }

                //這邊要檢查是否可以登入此MES系統
                string AccountModule = GetSysAccountModule(AccountWorkCode);

                if (string.IsNullOrEmpty(AccountModule))
                    throw new Exception((string)GetLocalResourceObject("Str_PasswordError"));

                DbCommandBuilder dbcb = new DbCommandBuilder();

                /*這裡驗證登入帳號密碼是否正確*/
                if (!IsSingleSignOn)
                {
                    dbcb = new DbCommandBuilder("Select Count(*) From Base_Org.dbo.V_Employee Where WorkCode = @WorkCode And [PassWord] = @PassWord And IsNull(loginid,'') <> '' And status in (0,1,2,3) And accounttype = 0");
                    dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, AccountWorkCode));
                    dbcb.appendParameter(Util.GetDataAccessAttribute("PassWord", "NVarChar", 1000, PassWordMD5));
                    bool PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;

                    if (!PassWordIsPass)
                    {
                        /* 如果OA帳號密碼找不到或是不正確再找一下系統本身使用者資料表是否帳號密碼正確(但還是要比對一下OA是否已經離職了) */
                        dbcb = new DbCommandBuilder("Select Count(*) From T_Users Where WorkCode = @WorkCode And [PassWord] = @PassWord");

                        dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, AccountWorkCode));
                        dbcb.appendParameter(Util.GetDataAccessAttribute("PassWord", "NVarChar", 1000, PassWordMD5));
                        PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;

                        /* 本身系統帳密正確但還是要比對OA是否已經離職了 */
                        if (PassWordIsPass)
                        {
                            dbcb = new DbCommandBuilder("Select Count(*) From Base_Org.dbo.V_Employee Where WorkCode = @WorkCode And status in (0,1,2,3) And accounttype = 0");
                            dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, AccountWorkCode));
                            PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;
                        }

                        if (!PassWordIsPass)
                            throw new Exception((string)GetLocalResourceObject("Str_PasswordError"));
                    }
                }

                string Query = @"Select id,loginid,seclevel,managerid,ManagerSecLevel,workcode, lastname As AccountName,subcompanyid1 As CompanyNameID,
                               Base_Org.dbo.GetSubCompanyName(departmentid) As CompanyName,departmentid As DeptID,
                               Base_Org.dbo.GetDeptFullNameNotIncludedCompanyName(departmentid, '_') As DeptFullName,(Select jobtitlename From Base_Org.dbo.V_EmployeeJobTitles 
                               Where id = jobtitle) As TitleName From Base_Org.dbo.V_Employee Where workcode = @WorkCode And status in (0,1,2,3) And accounttype = 0";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, AccountWorkCode));

                DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

                LM = new BasePage.LoginMember()
                {
                    AccountID = (int)DT.Rows[0]["id"],
                    WorkCode = DT.Rows[0]["workcode"].ToString().Trim(),
                    AccountName = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(DT.Rows[0]["AccountName"].ToString().Trim())),
                    TitleName = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(DT.Rows[0]["TitleName"].ToString().Trim())),
                    CompanyID = (int)DT.Rows[0]["CompanyNameID"],
                    CompanyName = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(DT.Rows[0]["CompanyName"].ToString().Trim())),
                    DeptID = (int)DT.Rows[0]["DeptID"],
                    DeptName = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(DT.Rows[0]["DeptFullName"].ToString().Trim())),
                    Guid = BaseConfiguration.NewGuid(),
                    SecLevel = (int)DT.Rows[0]["seclevel"],
                    ManagerID = (int)DT.Rows[0]["managerid"],
                    ManagerSecLevel = (int)DT.Rows[0]["ManagerSecLevel"],
                    IsHaveOAAccount = !string.IsNullOrEmpty(DT.Rows[0]["loginid"].ToString().Trim()),
                    UseModule = AccountModule.Split('|').ToList()
                };

                Master.AccountID = LM.AccountID;

                LM.LoginTime = DateTime.Now;

                LM.LastActionTime = LM.LoginTime;

                if (BaseConfiguration.OnlineAccount.ContainsKey(Master.AccountID))
                    BaseConfiguration.OnlineAccount[Master.AccountID] = LM;
                else
                    BaseConfiguration.OnlineAccount.Add(Master.AccountID, LM);

                Page.ClientScript.RegisterHiddenField("Guid", LM.Guid.ToBase64String(true));

                if (Request["SL_Language"] != null)
                    Response.Cookies.Add(new HttpCookie("langCookie", Request["SL_Language"]));

                Response.Cookies.Add(new HttpCookie("AccountID", LM.AccountID.ToString().ToBase64String()));

                Response.Cookies.Add(new HttpCookie("IsAdmin", BaseConfiguration.AdminAccounts.ConvertAll(AWC=> AWC.ToUpper()).Contains(AccountWorkCode.ToUpper()).ToStringValue().ToBase64String()));

                Response.Cookies.Add(new HttpCookie("IsUserAdmin", BaseConfiguration.UserAdminAccounts.ConvertAll(AWC => AWC.ToUpper()).Contains(AccountWorkCode.ToUpper()).ToStringValue().ToBase64String()));

                Response.Cookies.Add(new HttpCookie("IsShiftLeader", BaseConfiguration.ShiftLeaderAccounts.ConvertAll(AWC => AWC.ToUpper()).Contains(AccountWorkCode.ToUpper()).ToStringValue().ToBase64String()));

                dbcb = new DbCommandBuilder("Insert Into T_SysLoginLog (LoginAccountID,IPAddress) Values (@LoginAccountID,@IPAddress)");
                dbcb.appendParameter(Util.GetDataAccessAttribute("LoginAccountID", "int", 0, Master.AccountID));
                dbcb.appendParameter(Util.GetDataAccessAttribute("IPAddress", "NVarChar", 50, Request.UserHostAddress));
                CommonDB.ExecuteSingleCommand(dbcb);
            }
            catch (Exception ex)
            {
                AlertMessage = ex.Message;
                string strScript = "<script>";
                strScript += "alert(\"" + AlertMessage.Replace("\r\n", "").Replace("'", "").Replace("\"", "") + "\");";
                strScript += "location.href=\"Login.aspx\"";
                strScript += "</script>";
                Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Startup", strScript);
            }
        }
    }

    /// <summary>
    /// 指定工號得到T_Users有哪些功能模組
    /// </summary>
    /// <param name="AccountWorkCode">工號</param>
    /// <returns>有哪些功能模組</returns>
    protected string GetSysAccountModule(string AccountWorkCode)
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select Top 1 UseModule From T_Users Where WorkCode = @WorkCode");

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Users"];

        dbcb.appendParameter(Schema.Attributes["WorkCode"].copy(AccountWorkCode));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            return DT.Rows[0][0].ToString().Trim();
        else
            return string.Empty;
    }
}