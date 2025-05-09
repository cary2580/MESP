using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_DeviceList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        LoadData();
    }

    /// <summary>
    /// 載入設備清單資料
    /// </summary>
    protected void LoadData()
    {
        string LinkMachineName = "MachineName";
        string LinkAreaName = "AreaName";
        string LinkDeviceViewGroup = "LinkDeviceViewGroup";

        string Query = @"Select DeviceID,MachineID,MachineName,MachineAlias,Location,Stuff((Select '、' + AreaName From T_TSArea Inner Join T_TSDeviceArea On T_TSArea.AreaID = T_TSDeviceArea.AreaID Where T_TSDeviceArea.DeviceID = T_TSDevice.DeviceID Order By T_TSArea.SortID For Xml Path,Type)
                        .value('.[1]','nvarchar(max)'),1,1,'') As AreaName,@" + LinkDeviceViewGroup + @" As LinkDeviceViewGroup,OnWorkBeforeMinute,OffWorkBeforeMinute,Power,PowerCoefficient,EstimateCurrent,IsMultipleGoIn,IsApprovalByDevice,IsBrand,IsFirstProcess,IsPrintPackage,IsCheckPreviousMOFinish,IsCheckProductionInspection,IsCheckSequenceDeclare,IsSuspension,
                        SortID,(Select SectionName From V_TSSection Where V_TSSection.SectionID = T_TSDevice.SectionID ) As SectionName From T_TSDevice";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("LinkDeviceViewGroup", "Nvarchar", 50, (string)GetLocalResourceObject("Str_LinkDeviceViewGroup")));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        var ResponseData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName),
                classes = Column.ColumnName == LinkMachineName || Column.ColumnName == LinkDeviceViewGroup || Column.ColumnName == LinkAreaName ? BaseConfiguration.JQGridColumnClassesName : string.Empty,
            }),
            DeviceIDColumnName = "DeviceID",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            LinkMachineName,
            LinkAreaName,
            LinkDeviceViewGroup,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                DeviceID = Row["DeviceID"].ToString().Trim(),
                MachineID = Row["MachineID"].ToString().Trim(),
                MachineName = Row["MachineName"].ToString().Trim(),
                MachineAlias = Row["MachineAlias"].ToString().Trim(),
                Location = Row["Location"].ToString().Trim(),
                AreaName = Row["AreaName"].ToString().Trim(),
                LinkDeviceViewGroup = Row["LinkDeviceViewGroup"].ToString().Trim(),
                OnWorkBeforeMinute = Row["OnWorkBeforeMinute"].ToString().Trim(),
                OffWorkBeforeMinute = Row["OffWorkBeforeMinute"].ToString().Trim(),
                Power = Row["Power"].ToString().Trim(),
                PowerCoefficient = Row["PowerCoefficient"].ToString().Trim(),
                EstimateCurrent = Row["EstimateCurrent"].ToString().Trim(),
                IsMultipleGoIn = ((bool)Row["IsMultipleGoIn"]) ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                IsApprovalByDevice = ((bool)Row["IsApprovalByDevice"]) ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                IsBrand = ((bool)Row["IsBrand"]) ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                IsFirstProcess = ((bool)Row["IsFirstProcess"]) ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                IsPrintPackage = ((bool)Row["IsPrintPackage"]) ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                IsCheckPreviousMOFinish = ((bool)Row["IsCheckPreviousMOFinish"]) ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                IsCheckProductionInspection = ((bool)Row["IsCheckProductionInspection"]) ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                IsCheckSequenceDeclare = ((bool)Row["IsCheckSequenceDeclare"]) ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                IsSuspension = ((bool)Row["IsSuspension"]) ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                SortID = Row["SortID"].ToString().Trim(),
                SectionName = Row["SectionName"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
    }

    /// <summary>
    /// 指定ColumnName得到是否顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "DeviceID":
            case "Power":
            case "PowerCoefficient":
            case "EstimateCurrent":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 指定ColumnName得到對齊方式
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>對齊方式</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "MachineID":
            case "OnWorkBeforeMinute":
            case "OffWorkBeforeMinute":
            case "Power":
            case "PowerCoefficient":
            case "EstimateCurrent":
            case "IsMultipleGoIn":
            case "IsApprovalByDevice":
            case "IsBrand":
            case "IsFirstProcess":
            case "IsPrintPackage":
            case "LinkDeviceViewGroup":
            case "IsCheckPreviousMOFinish":
            case "IsCheckProductionInspection":
            case "IsCheckSequenceDeclare":
            case "IsSuspension":
            case "SortID":
                return "center";
            default:
                return "left";
        }
    }

    /// <summary>
    /// 指定ColumnName得到欄位寬度
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>欄位寬度</returns>
    protected int GetWidth(string ColumnName)
    {
        switch (ColumnName)
        {
            case "MachineAlias":
                return 80;
            case "LinkDeviceViewGroup":
                return 50;
            case "OnWorkBeforeMinute":
            case "OffWorkBeforeMinute":
            case "Power":
            case "PowerCoefficient":
            case "EstimateCurrent":
            case "IsMultipleGoIn":
            case "IsApprovalByDevice":
            case "IsBrand":
            case "IsFirstProcess":
            case "IsPrintPackage":
            case "IsCheckPreviousMOFinish":
            case "IsCheckProductionInspection":
            case "IsCheckSequenceDeclare":
            case "IsSuspension":
            case "SortID":
                return 40;
            case "Location":
            case "AreaName":
            case "MachineID":
            case "SectionName":
                return 60;
            default:
                return 100;
        }
    }

    /// <summary>
    /// 指定ColumnName得到顯示欄位名稱
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "MachineID":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineID");
            case "MachineName":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineName");
            case "MachineAlias":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineAlias");
            case "Location":
                return (string)GetLocalResourceObject("Str_ColumnName_Location");
            case "AreaName":
                return (string)GetLocalResourceObject("Str_ColumnName_AreaName");
            case "OnWorkBeforeMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_OnWorkBeforeMinute");
            case "OffWorkBeforeMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_OffWorkBeforeMinute");
            case "Power":
                return (string)GetLocalResourceObject("Str_ColumnName_Power");
            case "PowerCoefficient":
                return (string)GetLocalResourceObject("Str_ColumnName_PowerCoefficient");
            case "EstimateCurrent":
                return (string)GetLocalResourceObject("Str_ColumnName_EstimateCurrent");
            case "IsMultipleGoIn":
                return (string)GetLocalResourceObject("Str_ColumnName_IsMultipleGoIn");
            case "IsApprovalByDevice":
                return (string)GetLocalResourceObject("Str_ColumnName_IsApprovalByDevice");
            case "IsBrand":
                return (string)GetLocalResourceObject("Str_ColumnName_IsBrand");
            case "IsFirstProcess":
                return (string)GetLocalResourceObject("Str_ColumnName_IsFirstProcess");
            case "LinkDeviceViewGroup":
                return (string)GetLocalResourceObject("Str_ColumnName_LinkDeviceViewGroup");
            case "IsPrintPackage":
                return (string)GetLocalResourceObject("Str_ColumnName_IsPrintPackage");
            case "IsCheckPreviousMOFinish":
                return (string)GetLocalResourceObject("Str_ColumnName_IsCheckPreviousMOFinish");
            case "IsCheckProductionInspection":
                return (string)GetLocalResourceObject("Str_ColumnName_IsCheckProductionInspection");
            case "IsCheckSequenceDeclare":
                return (string)GetLocalResourceObject("Str_ColumnName_IsCheckSequenceDeclare");
            case "IsSuspension":
                return (string)GetLocalResourceObject("Str_ColumnName_IsSuspension");
            case "SectionName":
                return (string)GetLocalResourceObject("Str_ColumnName_SectionName");
            case "SortID":
                return (string)GetLocalResourceObject("Str_ColumnName_SortID");
            default:
                return ColumnName;
        }
    }
}