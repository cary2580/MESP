using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using DataAccess.Data;
using System.Data;

/// <summary>
/// 內部常用類別
/// </summary>
public partial class BaseConfiguration
{
    public static Dictionary<int, BasePage.LoginMember> OnlineAccount;
    public static bool IsVerificationAccount = true;
    public static List<string> AdminAccounts;
    public static List<string> UserAdminAccounts;
    public static List<string> ShiftLeaderAccounts;
    public static List<string> SingleSignOnDnsSafeHost;
    public static string TempFolderPath = string.Empty;
    public static DirectoryInfo TempFolderInfo = null;
    public static DirectoryInfo SaveFileFolderInfo = null;
    public static Util.SerialObject.Object_ID_TypeCollection SerialObject = null;
    public static List<BasePage.Organization> OrganizationDeptAndEmpList;
    public static List<BasePage.Organization> OrganizationDeptList;
    public static string JQGridColumnClassesName = "JqgridLinkColumnStyle";
    public static bool IsTestEnvironment = false;
    public static decimal DownloadFileMaxSize = 102400;
    public static double TimeOutMinutes = -1;
    public static string SmtpServer = string.Empty;
    public static string SmtpAccount = string.Empty;
    public static string SmtpPWD = string.Empty;
    public static string SmtpMailFrom = string.Empty;
    public static string OADataBaseName = string.Empty;  //在webconfig
    public static string LoginUrl = string.Empty;
    public static List<int> GroupAllBUDeptIDList = new List<int>();
    public static string DefaultCultureInfo = string.Empty;

    /// <summary>
    /// 載入初始化設定
    /// </summary>
    public static void InitConfiguration()
    {
        string DBConn = global::System.Configuration.ConfigurationManager.ConnectionStrings["DBConnectionString"].ConnectionString.Trim();
        //設定DB初始連線值
        configuration.ConnectionStringBuilder = new System.Data.SqlClient.SqlConnectionStringBuilder(DBConn);

        configuration.CommandTimeout = 300;

        OnlineAccount = new Dictionary<int, BasePage.LoginMember>();

        LoadSysConfiguration();

        System.Reflection.MethodInfo Mi = typeof(BaseConfiguration).GetMethod("LoadSysConfigurationExtend", System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.NonPublic);

        if (Mi != null)
            Mi.Invoke(null, null);

        SerialObject = new Util.SerialObject.Object_ID_TypeCollection();

        CreatTempFolderInfo();
    }

    /// <summary>
    /// 載入系統參數設定
    /// </summary>
    public static void LoadSysConfiguration()
    {
        string SaveFileFolderPath = string.Empty;

        DbCommandBuilder dbcb = new DbCommandBuilder("Select * From T_SysConfig");

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        var Rows = DT.ToDictionary();

        foreach (Dictionary<string, string> Row in Rows)
        {
            switch (Row["ConfigKey"])
            {
                case "AdminAccounts":
                    AdminAccounts = Row["ConfigValue"].Split('|').ToList();
                    break;
                case "UserAdminAccounts":
                    UserAdminAccounts = Row["ConfigValue"].Split('|').ToList();
                    break;
                case "ShiftLeaderAccounts":
                    ShiftLeaderAccounts = Row["ConfigValue"].Split('|').ToList();
                    break;
                case "DownloadFileMaxSize":
                    DownloadFileMaxSize = decimal.Parse(Row["ConfigValue"].ToString());
                    break;
                case "IsVerificationAccount":
                    IsVerificationAccount = Row["ConfigValue"].ToBoolean();
                    break;
                case "OADataBaseName":
                    OADataBaseName = Row["ConfigValue"];
                    break;
                case "SaveFileFolderPath":
                    SaveFileFolderPath = Row["ConfigValue"];
                    break;
                case "SingleSignOnDnsSafeHost":
                    SingleSignOnDnsSafeHost = Row["ConfigValue"].Split('|').ToList();
                    break;
                case "SmtpAccount":
                    SmtpAccount = Row["ConfigValue"];
                    break;
                case "SmtpMailFrom":
                    SmtpMailFrom = Row["ConfigValue"];
                    break;
                case "SmtpPWD":
                    SmtpPWD = Row["ConfigValue"];
                    break;
                case "SmtpServer":
                    SmtpServer = Row["ConfigValue"];
                    break;
                case "TempFolderPath":
                    TempFolderPath = Row["ConfigValue"];
                    break;
                case "TimeOutMinutes":
                    TimeOutMinutes = double.Parse(Row["ConfigValue"].ToString());
                    break;
                case "LoginUrl":
                    LoginUrl = Row["ConfigValue"];
                    break;
                case "GroupAllBUDeptID":
                    GroupAllBUDeptIDList = Row["ConfigValue"].Split('|').Select(Int32.Parse).ToList();
                    break;
                case "IsTestEnvironment":
                    IsTestEnvironment = Row["ConfigValue"].ToBoolean();
                    break;
                case "DefaultCultureInfo":
                    DefaultCultureInfo = Row["ConfigValue"].Trim();
                    break;
            }
        }

        var WebConfigAllKey = System.Configuration.ConfigurationManager.AppSettings.AllKeys;

        /*依字串內容排序,方便由資料庫比對*/
        if (WebConfigAllKey.Contains("AdminAccounts"))
            AdminAccounts = System.Configuration.ConfigurationManager.AppSettings["AdminAccounts"].Split('|').ToList();
        if (WebConfigAllKey.Contains("UserAdminAccounts"))
            UserAdminAccounts = System.Configuration.ConfigurationManager.AppSettings["UserAdminAccounts"].Split('|').ToList();
        if (WebConfigAllKey.Contains("ShiftLeaderAccounts"))
            ShiftLeaderAccounts = System.Configuration.ConfigurationManager.AppSettings["ShiftLeaderAccounts"].Split('|').ToList();
        if (WebConfigAllKey.Contains("DownloadFileMaxSize"))
            DownloadFileMaxSize = decimal.Parse(System.Configuration.ConfigurationManager.AppSettings["DownloadFileMaxSize"]);
        if (WebConfigAllKey.Contains("IsVerificationAccount"))
            IsVerificationAccount = bool.Parse(System.Configuration.ConfigurationManager.AppSettings["IsVerificationAccount"]);
        if (WebConfigAllKey.Contains("OADataBaseName"))
            OADataBaseName = System.Configuration.ConfigurationManager.AppSettings["OADataBaseName"];
        if (WebConfigAllKey.Contains("SaveFileFolderPath"))
            SaveFileFolderPath = System.Configuration.ConfigurationManager.AppSettings["SaveFileFolderPath"];
        if (WebConfigAllKey.Contains("SingleSignOnDnsSafeHost"))
            SingleSignOnDnsSafeHost = System.Configuration.ConfigurationManager.AppSettings["SingleSignOnDnsSafeHost"].Split('|').ToList();
        if (WebConfigAllKey.Contains("SmtpAccount"))
            SmtpAccount = System.Configuration.ConfigurationManager.AppSettings["SmtpAccount"];
        if (WebConfigAllKey.Contains("SmtpMailFrom"))
            SmtpMailFrom = System.Configuration.ConfigurationManager.AppSettings["SmtpMailFrom"];
        if (WebConfigAllKey.Contains("SmtpPWD"))
            SmtpPWD = System.Configuration.ConfigurationManager.AppSettings["SmtpPWD"];
        if (WebConfigAllKey.Contains("SmtpServer"))
            SmtpServer = System.Configuration.ConfigurationManager.AppSettings["SmtpServer"];
        if (WebConfigAllKey.Contains("TempFolderPath"))
            TempFolderPath = System.Configuration.ConfigurationManager.AppSettings["TempFolderPath"];
        if (WebConfigAllKey.Contains("TimeOutMinutes"))
            TimeOutMinutes = double.Parse(System.Configuration.ConfigurationManager.AppSettings["TimeOutMinutes"]);
        if (WebConfigAllKey.Contains("LoginUrl"))
            LoginUrl = System.Configuration.ConfigurationManager.AppSettings["LoginUrl"];
        if (WebConfigAllKey.Contains("IsTestEnvironment"))
            IsTestEnvironment = System.Configuration.ConfigurationManager.AppSettings["IsTestEnvironment"].ToBoolean();
        if (WebConfigAllKey.Contains("DefaultCultureInfo"))
            DefaultCultureInfo = System.Configuration.ConfigurationManager.AppSettings["DefaultCultureInfo"];

        if (!string.IsNullOrEmpty(SaveFileFolderPath))
        {
            if (!SaveFileFolderPath.EndsWith(@"\"))
                SaveFileFolderPath += @"\";

            try
            {
                if (!Directory.Exists(SaveFileFolderPath))
                    SaveFileFolderInfo = Directory.CreateDirectory(SaveFileFolderPath);
                else
                    SaveFileFolderInfo = new DirectoryInfo(SaveFileFolderPath);
            }
            catch { }
        }
    }

    public static void CreatTempFolderInfo()
    {
        if (!string.IsNullOrEmpty(TempFolderPath))
        {
            if (!TempFolderPath.StartsWith(@"\"))
                TempFolderPath = @"\" + TempFolderPath;
            if (!TempFolderPath.EndsWith(@"\"))
                TempFolderPath += @"\";

            try
            {
                if (Directory.Exists(HttpContext.Current.Server.MapPath(@"~\") + TempFolderPath))
                    Directory.Delete(HttpContext.Current.Server.MapPath(@"~\") + TempFolderPath, true);

                TempFolderInfo = Directory.CreateDirectory(HttpContext.Current.Server.MapPath(@"~\") + TempFolderPath);
            }
            catch { }
        }
    }

    /// <summary>
    /// 指定員工帳號ID得到是否活動中(OA status in (0,1,2,3))
    /// </summary>
    /// <returns>帳號是否活動中</returns>
    public static bool GetAccountIDIsActivity(int AccountID)
    {
        string Query = @"Select Count(*) From Base_Org.dbo.V_Employee Where id = @AccountID And status in (0,1,2,3) And accounttype = 0";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("AccountID", "int", 0, AccountID));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 指定員工編號得到帳號ID
    /// </summary>
    /// <param name="WorkCode">員工編號</param>
    /// <returns>帳號ID</returns>
    public static int GetAccountID(string WorkCode)
    {
        int Result = -1;

        string Query = @"Select Base_Org.dbo.GetAccountIDByWorkCode(@WorkCode)";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "nvarchar", 50, WorkCode.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0 && DT.Rows[0][0] != DBNull.Value)
            Result = (int)DT.Rows[0][0];

        return Result;
    }

    /// <summary>
    /// 指定帳號ID取得人員所屬主要部門代碼
    /// </summary>
    /// <param name="AccountID">帳號ID</param>
    /// <returns>人員所屬主要部門代碼</returns>
    public static int GetDeptID(int AccountID)
    {
        return BaseConfiguration.OnlineAccount.ContainsKey(AccountID) ? (BaseConfiguration.OnlineAccount[AccountID] as BasePage.LoginMember).DeptID : -1;
    }
    /// <summary>
    /// 指定帳號ID取得人員所屬主要部門名稱
    /// </summary>
    /// <param name="AccountID">指定帳號ID</param>
    /// <returns>人員所屬主要部門名稱</returns>
    public static string GetDeptName(int AccountID) { return BaseConfiguration.OnlineAccount.ContainsKey(AccountID) ? (BaseConfiguration.OnlineAccount[AccountID] as BasePage.LoginMember).DeptName : string.Empty; }
    /// <summary>
    /// 指定帳號ID取得新增人員工作代碼
    /// </summary>
    /// <param name="AccountID">指定帳號ID</param>
    /// <returns>新增人員工作代碼</returns>
    public static string GetWorkCode(int AccountID) { return BaseConfiguration.OnlineAccount.ContainsKey(AccountID) ? (BaseConfiguration.OnlineAccount[AccountID] as BasePage.LoginMember).WorkCode : string.Empty; }
    /// <summary>
    /// 指定帳號ID取得新增人員職稱名稱
    /// </summary>
    /// <param name="AccountID">指定帳號ID</param>
    /// <returns>新增人員職稱名稱</returns>
    public static string GetCreateAccountTitleName(int AccountID) { return BaseConfiguration.OnlineAccount.ContainsKey(AccountID) ? (BaseConfiguration.OnlineAccount[AccountID] as BasePage.LoginMember).TitleName : string.Empty; }
    /// <summary>
    /// 指定帳號ID取得子公司代碼
    /// </summary>
    /// <param name="AccountID">指定帳號ID</param>
    /// <returns>子公司代碼</returns>
    public static int GetSubCompanyID(int AccountID)
    {
        { return BaseConfiguration.OnlineAccount.ContainsKey(AccountID) ? (BaseConfiguration.OnlineAccount[AccountID] as BasePage.LoginMember).CompanyID : -1; }
    }
    /// <summary>
    /// 指定帳號ID取得人員名稱
    /// </summary>
    /// <param name="AccountID">帳號ID</param>
    /// <returns>人員名稱</returns>
    public static string GetAccountName(int AccountID) { return BaseConfiguration.OnlineAccount.ContainsKey(AccountID) ? (BaseConfiguration.OnlineAccount[AccountID] as BasePage.LoginMember).AccountName : string.Empty; }
    /// <summary>
    /// 取得新的Grid
    /// </summary>
    /// <returns></returns>
    public static string NewGuid()
    {
        return Guid.NewGuid().ToString().Replace("-", "");
    }
}

/// <summary>
/// BasePage 的摘要描述
/// </summary>
public partial class BasePage : _baseAshx
{
    public BasePage(bool IsAccountVerificationFaillAlert = true)
    { _IsAccountVerificationFaillAlert = IsAccountVerificationFaillAlert; }

    public class LoginMember
    {
        public int AccountID { get; set; }
        public string WorkCode { get; set; }
        public string AccountName { get; set; }
        public string TitleName { get; set; }
        public int CompanyID { get; set; }
        public string CompanyName { get; set; }
        public int DeptID { get; set; }
        public string DeptName { get; set; }
        public string Guid { get; set; }
        public DateTime LoginTime { get; set; }
        public DateTime LastActionTime { get; set; }
        public string LastActionIP { get; set; }
        public string LastActionAbsolutePath { get; set; }
        public int SecLevel { get; set; }
        public int ManagerID { get; set; }
        public int ManagerSecLevel { get; set; }
        public bool IsHaveOAAccount { get; set; }

        public List<string> UseModule { get; set; }
    }

    public class Organization : ICloneable
    {
        public bool IsCompany { get; set; }
        public bool IsRoot { get; set; }
        public bool IsDept { get; set; }
        public int key { get; set; }
        public string title { get; set; }
        public string icon { get; set; }
        public string CompanyName { get; set; }
        public string CompanyCode { get; set; }
        public int CompanyID { get; set; }
        public string Status { get; set; }
        public string Code { get; set; }
        public string FullName { get; set; }
        public bool hideCheckbox { get; set; }
        public bool select { get; set; }
        public int ParentKey { get; set; }
        public string ParentCode { get; set; }
        public string ParentName { get; set; }
        public bool IsCanceled { get; set; }
        public int ManagerID { get; set; }
        public List<Organization> children { get; set; }

        public object Clone()
        {
            Organization NO = new Organization();
            NO.IsCompany = this.IsCompany;
            NO.IsRoot = this.IsRoot;
            NO.IsDept = this.IsDept;
            NO.key = this.key;
            NO.title = this.title;
            NO.icon = this.icon;
            NO.CompanyName = this.CompanyName;
            NO.CompanyCode = this.CompanyCode;
            NO.CompanyID = this.CompanyID;
            NO.Status = this.Status;
            NO.Code = this.Code;
            NO.FullName = this.FullName;
            NO.hideCheckbox = this.hideCheckbox;
            NO.select = this.select;
            NO.ParentKey = this.ParentKey;
            NO.ParentCode = this.ParentCode;
            NO.ParentName = this.ParentName;
            NO.IsCanceled = this.IsCanceled;
            NO.ManagerID = this.ManagerID;

            List<Organization> NewChildren = new List<Organization>();

            if (this.children != null)
            {
                foreach (Organization NewO in this.children)
                {
                    NewChildren.Add(NewO.Clone() as Organization);
                }
            }

            NO.children = NewChildren;

            return NO;
        }
    }

    public class DownloadFileInfo
    {
        private bool _IsAddHeader = true;

        public string DownloadFileFullPath { get; set; }
        public string SaveFileName { get; set; }
        public bool IsDeleteDownloadFile { get; set; }
        public bool IsNoClearSession { get; set; }
        public string ContentType { get; set; }
        public bool IsAddHeader { get { return _IsAddHeader; } set { _IsAddHeader = value; } }
    }
}

public class _baseAshx : System.Web.UI.Page, IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    protected HttpContext _context;
    protected string Guid = string.Empty;
    protected int AccountID = -1;
    protected string WorkCode = string.Empty;
    protected string langCookie = "zh-TW";
    protected bool IsAccountVerificationPass = false;
    protected bool _IsAccountVerificationFaillAlert = true;

    protected _baseAshx()
    {
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

            if (HttpContext.Current.Request["AccountID"] != null)
            {
                AccountID = int.Parse(HttpContext.Current.Request["AccountID"].ToStringFromBase64());

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
            }
        }
        catch { }
    }

    /// <summary>
    /// 指定HttpContext載入基本資訊
    /// </summary>
    /// <param name="context">HttpContext</param>
    /// <param name="IsVerificationAccount">是否驗證帳號是否通過</param>
    protected void processRequest(HttpContext context, bool IsVerificationAccount = true)
    {
        _context = context;

        if (_context.Request["Guid"] != null)
            Guid = _context.Request["Guid"].Trim().ToStringFromBase64(true);
        if (_context.Request["AccountID"] != null && !string.IsNullOrEmpty(_context.Request["AccountID"].Trim()))
            AccountID = int.Parse(_context.Request["AccountID"].Trim().ToStringFromBase64());
        if (_context.Request.Cookies["langCookie"] != null)
            langCookie = _context.Request.Cookies["langCookie"].Value;

        if (!VerificationAccount(IsVerificationAccount))
            throw new Exception("Logout Error");
    }

    /// <summary>
    /// 指定資源ID根據所在目錄虛擬路徑取的資源檔值(一般來說不需要使用這個，只有遇到URL是採用RouteTable轉換過的才需要指定FilePath)
    /// </summary>
    /// <param name="FilePath">檔案路徑</param>
    /// <param name="resourceKey">資源ID</param>
    /// <returns>資源檔值</returns>
    protected object GetLocalResourceObject(string FilePath, string resourceKey)
    {
        return HttpContext.GetLocalResourceObject(FilePath, resourceKey);
    }

    /// <summary>
    /// 指定資源ID根據所在目錄虛擬路徑取的資源檔值
    /// </summary>
    /// <param name="resourceKey">資源ID</param>
    /// <returns>資源檔值</returns>
    protected new object GetLocalResourceObject(string resourceKey)
    {
        return HttpContext.GetLocalResourceObject(_context.Request.AppRelativeCurrentExecutionFilePath, resourceKey);
    }

    /// <summary>
    /// 驗證帳號
    /// </summary>
    /// <returns>是否正確</returns>
    protected bool VerificationAccount(bool IsVerificationAccount = true)
    {
        bool Result = false;

        if (IsVerificationAccount)
        {
            if (!BaseConfiguration.IsVerificationAccount || (GetUserGuid(AccountID) == Guid && !string.IsNullOrEmpty(Guid)))
                Result = true;
        }
        else
            Result = true;

        return Result;
    }
    /// <summary>
    /// 取得新的Grid
    /// </summary>
    protected string NewGuid
    {
        get { return BaseConfiguration.NewGuid(); }
    }

    /// <summary>
    /// 指定帳號得到所屬Guid
    /// </summary>
    /// <param name="AccountID">帳號代碼</param>
    /// <returns>Guid</returns>
    protected string GetUserGuid(int AccountID)
    {
        if (BaseConfiguration.OnlineAccount != null && BaseConfiguration.OnlineAccount.ContainsKey(AccountID))
            return (BaseConfiguration.OnlineAccount[AccountID] as BasePage.LoginMember).Guid;
        else
            return string.Empty;
    }
    /// <summary>
    /// 指定ResponseData序列化物件
    /// </summary>
    /// <param name="SerializeObject">ResponseData</param>
    /// <param name="IsRenewGuid">是否要更新Guid</param>
    /// <returns>序列化字串</returns>
    protected string SerializResponseData(object SerializeObject, bool IsRenewGuid = false)
    {
        string Result = string.Empty;
        dynamic ResultObj = new System.Dynamic.ExpandoObject();
        Guid = GetUserGuid(AccountID);

        if (BaseConfiguration.OnlineAccount != null && BaseConfiguration.OnlineAccount.ContainsKey(AccountID) && IsRenewGuid)
        {
            Guid = NewGuid;
            (BaseConfiguration.OnlineAccount[AccountID] as BasePage.LoginMember).Guid = Guid;
        }

        ResultObj.Guid = Guid.ToBase64String(true);
        ResultObj.data = SerializeObject;
        Result = Newtonsoft.Json.JsonConvert.SerializeObject(ResultObj);

        return Result;
    }
    /// <summary>
    /// 指定序列化物件回傳資料
    /// </summary>
    /// <param name="SerializeObject">序列化物件</param>
    protected void ResponseSuccessData(object SerializeObject)
    {
        if (!_context.Response.IsClientConnected)
            return;
        _context.Response.ContentType = "application/json";

        if (_context.Request["callback"] == null)
            _context.Response.Write(SerializResponseData(SerializeObject));
        else
            _context.Response.Write(_context.Request["callback"] + "(" + SerializResponseData(SerializeObject) + ")");
        _context.Response.Flush();
    }
    /// <summary>
    /// 指定例外錯誤回傳資料
    /// </summary>
    /// <param name="ex">例外錯誤物件</param>
    protected void ResponseErrorData(Exception ex)
    {
        if (!_context.Response.IsClientConnected)
            return;
        _context.Response.ContentType = "application/json";
        string ResponseString = string.Empty;

        if (ex is CustomException)
            ResponseString = SerializResponseData(new { ErrorMsg = (ex as CustomException).Message, MessageIsHtml = (ex as CustomException).MessageIsHtml ? "1" : "0" });
        else if (ex.Message != "Logout Error")
            ResponseString = SerializResponseData(new { ErrorMsg = ex.ToString() });
        else
            ResponseString = SerializResponseData(new { Logout = ex.ToString() }, false);
        if (_context.Request["callback"] == null)
            _context.Response.Write(ResponseString);
        else
            _context.Response.Write(_context.Request["callback"] + "(" + ResponseString + ")");
        _context.Response.Flush();
    }
    /// <summary>
    /// 指定資料流回傳資料
    /// </summary>
    /// <param name="Stream">資料流</param>
    /// <param name="FileName">檔案名稱</param>
    /// <param name="ContentType">ContentType</param>
    /// <param name="IsAddHeader">是否要加入回應表頭</param>
    protected void ResponseStream(Stream Stream, string FileName = "Error.txt", string ContentType = "application/octet-stream", bool IsAddHeader = true)
    {
        StreamWriter sw = null;

        if (string.IsNullOrEmpty(FileName))
            FileName = "Error.txt";

        try
        {
            _context.Response.Clear();
            _context.Response.ClearHeaders();
            _context.Response.Buffer = true;

            if (_context.Request.Browser.Browser.ToLower().Contains("explorer") || _context.Request.Browser.Browser.ToLower().Contains("mozilla") || _context.Request.Browser.Browser.ToLower().Contains("ie"))
                FileName = _context.Server.UrlEncode(FileName);

            if (IsAddHeader)
                _context.Response.AddHeader("content-disposition", "attachment; filename=" + FileName);

            _context.Response.ContentEncoding = System.Text.Encoding.UTF8;
            _context.Response.Charset = "utf-8";
            _context.Response.ContentType = ContentType;

            if (Stream.Length < 1)
                throw new Exception("資料流長度小於1");

            Stream.Seek(0, SeekOrigin.Begin);

            Stream.CopyTo(_context.Response.OutputStream);
        }
        catch (Exception ex)
        {
            sw = new StreamWriter(_context.Response.OutputStream, System.Text.Encoding.UTF8);
            sw.Write(ex.Message);
            sw.Flush();
        }
        finally
        {
            if (!_context.Request.UserAgent.ToLower().Contains("android") && !(_context.Request.UserAgent.ToLower().Contains("ipad") || _context.Request.UserAgent.ToLower().Contains("iPhone")))
            {
                if ((Stream.Length / 1024) < BaseConfiguration.DownloadFileMaxSize)
                {
                    _context.Response.AppendHeader("Set-Cookie", "fileDownload=true; path=/");
                    //_context.Response.Flush();
                    //_context.Response.Close();
                }
            }

            if (Stream != null)
            {
                Stream.Close();
                //Stream.Dispose();
            }
            if (sw != null)
            {
                sw.Close();
                //sw.Dispose();
            }
        }
    }

    /// <summary>
    /// 客製化例外物件
    /// </summary>
    [Serializable]
    protected class CustomException : Exception
    {
        public bool MessageIsHtml { get; set; }

        public CustomException(string message)
            : base(message)
        {
            base.Source = "CustomException";
            this.MessageIsHtml = false;
        }

        public CustomException(string message, bool MessageIsHtml)
            : base(message)
        {
            base.Source = "CustomException";
            this.MessageIsHtml = MessageIsHtml;
        }
    }
}