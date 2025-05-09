using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_DeviceParametersByED_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            EDProcessFirstDeviceID();

            if (!string.IsNullOrEmpty(Request["ReportDate"]))
                TB_ReportDate.Text = Request["ReportDate"].Trim();
            if (!string.IsNullOrEmpty(Request["DeviceID"]))
                DDL_DeviceID.SelectedValue = Request["DeviceID"].Trim();

            bool IsNewData = (string.IsNullOrEmpty(Request["ReportDate"]) || string.IsNullOrEmpty(Request["DeviceID"]));

            if (IsNewData)
            {
                if (!string.IsNullOrEmpty(Request["ReportDate"]))
                    TB_ReportDate.Text = Request["ReportDate"].Trim();

                TB_ReportDate.Text = DateTime.Now.ToCurrentUICultureString();

                BT_Delete.Visible = false;
            }
            else
            {
                TB_ReportDate.CssClass = "form-control readonly readonlyColor";

                DDL_DeviceID.Enabled = false;

                LoadData();
            }

            HF_IsNewData.Value = IsNewData.ToStringValue();
        }
    }

    /// <summary>
    /// 加载ED设备下拉列表
    /// </summary>
    private void EDProcessFirstDeviceID()
    {
        string EDProcessFirstDeviceID = System.Configuration.ConfigurationManager.AppSettings["EDProcessFirstDeviceID"];

        string Query = @"Select DeviceID,MachineID + '-' + MachineName As MachineName From T_TSDevice Where DeviceID In (Select item From Base_Org.dbo.Split(@EDProcessFirstDeviceID,'|'))";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("EDProcessFirstDeviceID", "nvarchar", 1000, EDProcessFirstDeviceID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_DeviceID.DataValueField = "DeviceID";

        DDL_DeviceID.DataTextField = "MachineName";

        DDL_DeviceID.DataSource = DT;

        DDL_DeviceID.DataBind();

        DDL_DeviceID.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }

    /// <summary>
    /// 载入资料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select 
                             T_TSDeviceParametersByED.ReportDate,
                             T_TSDevice.DeviceID,
                             T_TSDevice.MachineID + '-' + T_TSDevice.MachineName As MachineName,
	                         T_TSDeviceParametersByED.ChangeWaterMinute,
	                         T_TSDeviceParametersByED.StandardMinute
                         From T_TSDeviceParametersByED Inner Join T_TSDevice On T_TSDevice.DeviceID = T_TSDeviceParametersByED.DeviceID
                         Where ReportDate = @ReportDate And T_TSDevice.DeviceID = @DeviceID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceParametersByED"];

        DateTime ReportDate = DateTime.Parse("1900/01/01");

        if (!DateTime.TryParse(TB_ReportDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDate))
            ReportDate = DateTime.Parse("1900/01/01");

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(ReportDate));
        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DDL_DeviceID.SelectedValue));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_ReportDate.Text = ((DateTime)DT.Rows[0]["ReportDate"]).ToCurrentUICultureString();
        DDL_DeviceID.SelectedValue = DT.Rows[0]["DeviceID"].ToString().Trim();
        TB_ChangeWaterMinute.Text = DT.Rows[0]["ChangeWaterMinute"].ToString().Trim();
        TB_StandardMinute.Text = DT.Rows[0]["StandardMinute"].ToString().Trim();
    }

    protected void BT_Save_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            DBAction DBA = new DBAction();

            if (HF_IsNewData.Value.ToBoolean())
            {
                if (IsEDDeviceParametersRepeat())
                    throw new Exception((string)GetLocalResourceObject("Str_Error_EDDeviceParametersRepeat"));
            }

            DBA.AddCommandBuilder(GetDeleteDBCB());

            string Query = "Insert Into T_TSDeviceParametersByED (ReportDate,DeviceID,ChangeWaterMinute,StandardMinute) Values (@ReportDate,@DeviceID,@ChangeWaterMinute,@StandardMinute)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceParametersByED"];

            DateTime ReportDate = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_ReportDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDate))
                ReportDate = DateTime.Parse("1900/01/01");

            dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(ReportDate));
            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DDL_DeviceID.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["ChangeWaterMinute"].copy(TB_ChangeWaterMinute.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["StandardMinute"].copy(TB_StandardMinute.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false);

            return;
        }
    }

    /// <summary>
    /// ED设备参数是否重复
    /// </summary>
    /// <returns>是否重复</returns>
    protected bool IsEDDeviceParametersRepeat()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceParametersByED"];

        string Query = @"Select Count(*) From T_TSDeviceParametersByED Where ReportDate = @ReportDate And DeviceID = @DeviceID";

        dbcb.CommandText = Query;

        DateTime ReportDate = DateTime.Parse("1900/01/01");

        if (!DateTime.TryParse(TB_ReportDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDate))
            ReportDate = DateTime.Parse("1900/01/01");

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(ReportDate));

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DDL_DeviceID.SelectedValue.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 删除按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            DbCommandBuilder dbcb = GetDeleteDBCB();

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false);
        }
    }

    /// <summary>
    ///  取得删除的DBCB
    /// </summary>
    /// <returns>删除DBCB</returns>
    protected DbCommandBuilder GetDeleteDBCB()
    {
        string Query = @"Delete T_TSDeviceParametersByED Where ReportDate = @ReportDate And DeviceID = @DeviceID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceParametersByED"];

        DateTime ReportDate = DateTime.Parse("1900/01/01");

        if (!DateTime.TryParse(TB_ReportDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDate))
            ReportDate = DateTime.Parse("1900/01/01");

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(ReportDate));

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DDL_DeviceID.SelectedValue.Trim()));

        return dbcb;
    }
}