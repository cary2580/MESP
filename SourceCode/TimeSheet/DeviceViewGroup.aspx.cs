using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_DeviceViewGroup : System.Web.UI.Page
{
    protected string DeviceID = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (Request["DeviceID"] != null)
            DeviceID = Request["DeviceID"].Trim();

        LoadData();
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceGroup"];

        string Query = @"Select T_TSDeviceGroup.DeviceGroupID,T_TSDeviceGroup.DeviceGroupName,T_TSDevice.MachineID,T_TSDevice.MachineName From T_TSDeviceGroup 
                         Inner Join T_TSDevice On T_TSDeviceGroup.DeviceID = T_TSDevice.DeviceID Where T_TSDeviceGroup.DeviceID = @DeviceID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            TB_MachineID.Text = DT.Rows[0]["MachineID"].ToString().Trim();
            TB_MachineName.Text = DT.Rows[0]["MachineName"].ToString().Trim();
        }

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
                hidden = GetIsHidden(Column.ColumnName)
            }),
            Rows = DT.AsEnumerable().Select(Row => new
            {
                DeviceGroupID = Row["DeviceGroupID"].ToString().Trim(),
                DeviceGroupName = Row["DeviceGroupName"].ToString().Trim(),
                MachineID = Row["MachineID"].ToString().Trim(),
                MachineName = Row["MachineName"].ToString().Trim(),
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
            case "MachineID":
            case "MachineName":
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
            default:
                return 50;
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
            case "DeviceGroupID":
                return (string)GetLocalResourceObject("Str_ColumnName_DeviceGroupID");
            case "DeviceGroupName":
                return (string)GetLocalResourceObject("Str_ColumnName_DeviceGroupName");
            case "MachineName":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineName");
            default:
                return ColumnName;
        }
    }
}