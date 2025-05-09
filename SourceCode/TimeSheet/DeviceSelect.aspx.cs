using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
public partial class TimeSheet_DeviceSelect : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (Request["DivID"] != null)
                HF_DivID.Value = Request["DivID"].Trim();

            DataTable DT = LoadData();

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
                }),
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    DeviceID = Row["DeviceID"].ToString().Trim(),
                    MachineID = Row["MachineID"].ToString().Trim(),
                    MachineName = Row["MachineName"].ToString().Trim(),
                    Location = Row["Location"].ToString().Trim(),
                    AreaName = Row["AreaName"].ToString().Trim(),
                })
            };

            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

            Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true, "parent.$(\"#" + HF_DivID.Value + "\" ).dialog(\"close\");");
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
            case "DeviceID":
                return (string)GetLocalResourceObject("Str_DeviceID");
            case "MachineID":
                return (string)GetLocalResourceObject("Str_MachineID");
            case "MachineName":
                return (string)GetLocalResourceObject("Str_MachineName");
            case "Location":
                return (string)GetLocalResourceObject("Str_Location");
            case "AreaName":
                return (string)GetLocalResourceObject("Str_AreaName");
            default:
                return ColumnName;
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
            case "MachineID":
                return 50;
            default:
                return 100;
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
                return "center";
            default:
                return "left";
        }
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
                return true;
            default:
                return false;
        }
    }
    private DataTable LoadData()
    {
        string Query = @"Select DeviceID,MachineID,MachineName,Location,Stuff((Select '、' + AreaName From T_TSArea Inner Join T_TSDeviceArea On T_TSArea.AreaID = T_TSDeviceArea.AreaID Where T_TSDeviceArea.DeviceID = T_TSDevice.DeviceID Order By T_TSArea.SortID For Xml Path,Type)
                        .value('.[1]','nvarchar(max)'),1,1,'') As AreaName From T_TSDevice ";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        return CommonDB.ExecuteSelectQuery(dbcb);
    }
}