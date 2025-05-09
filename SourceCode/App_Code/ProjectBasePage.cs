using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public partial class BaseConfiguration
{
    /// <summary>
    /// 允許使用電泳參數模組的IP位置
    /// </summary>
    public static List<System.Net.IPAddress> ElectrophoresisModuleAccessIPList = new List<System.Net.IPAddress>();
    /// <summary>
    /// 允許使用電泳參數模組的登入帳號
    /// </summary>
    public static List<string> ElectrophoresisModuleAccessAccountList = new List<string>();
    /// <summary>
    /// 同步SAP工單建立日期如果超過幾天就不同步
    /// </summary>
    public static int SynchronizeSAPMODataMaxDays = 181;

    /// <summary>
    /// 載入系統參數設定(延伸)
    /// </summary>
    protected static void LoadSysConfigurationExtend()
    {
        var WebConfigAllKey = System.Configuration.ConfigurationManager.AppSettings.AllKeys;

        if (WebConfigAllKey.Contains("ElectrophoresisModuleAccessIP") && !string.IsNullOrEmpty(System.Configuration.ConfigurationManager.AppSettings["ElectrophoresisModuleAccessIP"]))
            ElectrophoresisModuleAccessIPList = System.Configuration.ConfigurationManager.AppSettings["ElectrophoresisModuleAccessIP"].Split('|').Select(IP => System.Net.IPAddress.Parse(IP)).ToList();

        if (WebConfigAllKey.Contains("ElectrophoresisModuleAccessAccount") && !string.IsNullOrEmpty(System.Configuration.ConfigurationManager.AppSettings["ElectrophoresisModuleAccessAccount"]))
            ElectrophoresisModuleAccessAccountList = System.Configuration.ConfigurationManager.AppSettings["ElectrophoresisModuleAccessAccount"].Split('|').ToList();

        if (WebConfigAllKey.Contains("SynchronizeSAPMODataMaxDays") && !string.IsNullOrEmpty(System.Configuration.ConfigurationManager.AppSettings["SynchronizeSAPMODataMaxDays"]))
            SynchronizeSAPMODataMaxDays = int.Parse(System.Configuration.ConfigurationManager.AppSettings["SynchronizeSAPMODataMaxDays"]);
    }
}