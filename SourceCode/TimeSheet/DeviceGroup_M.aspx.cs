using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_DeviceGroup_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (Request["DivID"] != null)
                DivID = Request["DivID"].Trim();

            if (Request["DeviceGroupID"] != null)
                TB_DeviceGroupID.Text = Request["DeviceGroupID"].Trim();

            DataTable DT = LoadData();

            if (!IsPostBack)
            {
                if (DT.Rows.Count > 0)
                    TB_DeviceGroupName.Text = DT.Rows[0]["DeviceGroupName"].ToString().Trim();
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
                    hidden = GetIsHidden(Column.ColumnName),
                }),
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    DeviceID = Row["DeviceID"].ToString().Trim(),
                    MachineID = Row["MachineID"].ToString().Trim(),
                    MachineName = Row["MachineName"].ToString().Trim()
                })
            };

            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridPagerValue", "<script>var IsShowJQGridPagerValue='" + false.ToStringValue() + "'</script>");

            Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelectValue", "<script>var IsMultiSelectValue='" + true.ToStringValue() + "'</script>");

            Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
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
                return (string)GetLocalResourceObject("Str_MachineID");
            case "MachineName":
                return (string)GetLocalResourceObject("Str_MachineName");
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
            case "MachineName":
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
            case "MachineName":
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
            case "DeviceGroupName":
                return true;
            default:
                return false;
        }
    }
    private DataTable LoadData()
    {
        string Query = string.Empty;

        DbCommandBuilder dbcb = new DbCommandBuilder();

        if (!IsPostBack)
        {
            Query = @"Select T_TSDevice.DeviceID,T_TSDevice.MachineID,T_TSDevice.MachineName,T_TSDeviceGroup.DeviceGroupName
                         From T_TSDeviceGroup 
                         Left Join T_TSDevice On T_TSDeviceGroup.DeviceID = T_TSDevice.DeviceID
                         Where DeviceGroupID = @DeviceGroupID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceGroup"];

            dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(TB_DeviceGroupID.Text.Trim()));
        }
        else
        {
            Query = @"Select DeviceID,MachineID,MachineName From T_TSDevice Where DeviceID in (
                        Select item From Base_Org.dbo.Split(@DeviceGroupID,'|'))";

            dbcb.appendParameter(Util.GetDataAccessAttribute("DeviceGroupID", "nvarchar", 10000, HF_GridDeviceID.Value));
        }

        dbcb.CommandText = Query;

        return CommonDB.ExecuteSelectQuery(dbcb);
    }
    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            string DeviceGroupID = string.Empty;

            DbCommandBuilder dbcb = new DbCommandBuilder();

            DBAction DBA = new DBAction();

            string Query = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceGroup"];

            Query = @"Select * From T_TSDeviceGroup Where DeviceGroupName = @DeviceGroupName ";

            dbcb.appendParameter(Schema.Attributes["DeviceGroupName"].copy(TB_DeviceGroupName.Text.Trim()));

            if (!string.IsNullOrEmpty(TB_DeviceGroupID.Text.Trim()))
            {
                Query += " And DeviceGroupID <> @DeviceGroupID";

                dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(TB_DeviceGroupID.Text.Trim()));
            }

            dbcb.CommandText = Query;

            if (CommonDB.ExecuteSelectQuery(dbcb).Rows.Count > 0)
                throw new Exception((string)GetLocalResourceObject("Str_Repeat_DeviceGroupName"));

            if (string.IsNullOrEmpty(TB_DeviceGroupID.Text))
                DeviceGroupID = BaseConfiguration.SerialObject[(short)22].取號();
            else
            {
                DeviceGroupID = TB_DeviceGroupID.Text.Trim();

                Query = @"Delete T_TSDeviceGroup Where DeviceGroupID = @DeviceGroupID;";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(DeviceGroupID));

                DBA.AddCommandBuilder(dbcb);
            }

            Query = @"Insert Into T_TSDeviceGroup (DeviceGroupID,DeviceID,DeviceGroupName)values(@DeviceGroupID,@DeviceID,@DeviceGroupName);";

            foreach (string DeviceID in HF_GridDeviceID.Value.Split('|'))
            {
                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(DeviceGroupID));
                dbcb.appendParameter(Schema.Attributes["DeviceGroupName"].copy(TB_DeviceGroupName.Text.Trim()));
                dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID.Trim()));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true, true);
        }
    }
    /// <summary>
    /// 檢查資料存在ProcessDeviceGroup
    /// </summary>
    protected void CheckProcessDeviceGroup()
    {
        string Query = @"Select distinct PLNNR,PLNAL From T_TSProcessDeviceGroup Where DeviceGroupID = @DeviceGroupID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceGroup"];

        dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(TB_DeviceGroupID.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            string PLNNRs = string.Empty;

            PLNNRs += string.Join("<p></p>", DT.AsEnumerable().Select(Row => "<p></p>" + GetLocalResourceObject("Str_PLNNR").ToString() + Row["PLNNR"].ToString() + "、" + GetLocalResourceObject("Str_PLNAL").ToString() + Row["PLNAL"].ToString()).Take(10)) + (DT.Rows.Count > 10 ? "<p></p>..." : "");

            throw new Exception(GetLocalResourceObject("Str_Error_ProcessDeviceGroup").ToString() + PLNNRs);
        }
    }
    /// <summary>
    /// 檢查資料存在TicketResult
    /// </summary>
    protected void CheckTicketResult()
    {
        string Query = @"Select Count(*) From T_TSTicketRouting Where DeviceGroupID = @DeviceGroupID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

        dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(TB_DeviceGroupID.Text.Trim()));

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new Exception(GetLocalResourceObject("Str_Error_TicketRouting").ToString());
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            CheckTicketResult();

            CheckProcessDeviceGroup();

            string Query = @"Delete T_TSDeviceGroup Where DeviceGroupID = @DeviceGroupID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceGroup"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(TB_DeviceGroupID.Text.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true, true);
        }
    }
}
