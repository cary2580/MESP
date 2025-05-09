<%@ Application Language="C#" %>
<%@ Import Namespace="System.Web.Routing" %>

<script RunAt="server">

    void Application_BeginRequest(Object sender, EventArgs e)
    {
        System.Globalization.CultureInfo CurrentUICulture = System.Threading.Thread.CurrentThread.CurrentUICulture;

        System.Globalization.CultureInfo ci = null;

        if (Request.Cookies["langCookie"] != null && !string.IsNullOrEmpty(Request.Cookies["langCookie"].Value) && CurrentUICulture.Name != Request.Cookies["langCookie"].Value)
            ci = new System.Globalization.CultureInfo(Request.Cookies["langCookie"].Value);
        else if (Request.Cookies["langCookie"] == null || string.IsNullOrEmpty(Request.Cookies["langCookie"].Value))
            ci = new System.Globalization.CultureInfo(BaseConfiguration.DefaultCultureInfo);  /*  因為會有不經過 Login 畫面來操作系統，因此預設就以參數設定為主 */
        else
            ci = System.Threading.Thread.CurrentThread.CurrentUICulture;

        if (ci != null)
        {
            ci = (System.Globalization.CultureInfo)ci.Clone();
            ci.DateTimeFormat.LongTimePattern = "HH:mm:ss";

            if (ci.Name.ToLower() == "pl")
            {
                ci.DateTimeFormat.ShortDatePattern = "dd.MM.yyyy";
                ci.DateTimeFormat.DateSeparator = ".";
            }
            else if (ci.Name.ToLower() == "zh-tw" || ci.Name.ToLower() == "zh-cn")
            {
                ci.DateTimeFormat.ShortDatePattern = "yyyy/MM/dd";
                ci.DateTimeFormat.DateSeparator = "/";
            }
            else
            {
                ci.DateTimeFormat.ShortDatePattern = "MM/dd/yyyy";
                ci.DateTimeFormat.DateSeparator = "/";
            }

            System.Threading.Thread.CurrentThread.CurrentUICulture = ci;
        }
    }

    void Application_Start(object sender, EventArgs e)
    {
        // 在應用程式啟動時執行的程式碼
        BaseConfiguration.InitConfiguration();

        Util.LoadOrganizationToBaseConfiguration();

        RoutingData(RouteTable.Routes);
    }

    private void RoutingData(RouteCollection RC)
    {
        RC.MapPageRoute("DownloadFileByFullPath", "DownloadFileByFullPath/{AccessGUID}", "~/Service/DownloadFile.ashx", true);
    }

    void Application_End(object sender, EventArgs e)
    {
        //  在應用程式關閉時執行的程式碼

    }

    void Application_Error(object sender, EventArgs e)
    {
        // 在發生未處理的錯誤時執行的程式碼

    }

    void Session_Start(object sender, EventArgs e)
    {
        // 在新的工作階段啟動時執行的程式碼

    }

    void Session_End(object sender, EventArgs e)
    {
        // 在工作階段結束時執行的程式碼
        // 注意: 只有在  Web.config 檔案中將 sessionstate 模式設定為 InProc 時，
        // 才會引起 Session_End 事件。如果將 session 模式設定為 StateServer 
        // 或 SQLServer，則不會引起該事件。

    }

</script>
