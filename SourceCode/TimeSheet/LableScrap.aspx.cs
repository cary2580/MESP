using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_LableScrap : System.Web.UI.Page
{
    protected string DivID = string.Empty;
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            Util.TS.LoadDDLWorkShift(DDL_WorkShift);

            if (Request["MachineID"] != null)
                TB_MachineID.Text = Request["MachineID"].Trim();

            if (Request["WorkShiftID"] != null)
                DDL_WorkShift.Text = Request["WorkShiftID"].Trim();
        }

        HF_IsRepeat.Value = false.ToStringValue();
    }

    protected void Page_LoadComplete(object sender, EventArgs e)
    {
        LaodCancelLableIDList();
    }

    protected void BT_Add_Click(object sender, EventArgs e)
    {
        try
        {
            string Result = Util.TS.CheckScanLableIDRule(TB_ExcessiveLableID.Text.ToString().Trim());

            if (!string.IsNullOrEmpty(Result))
            {
                HF_IsRepeat.Value = true.ToStringValue();

                throw new Exception(Result);
            }

            string DeviceID = Util.TS.GetDeviceID(TB_MachineID.Text);

            string Query = @"Insert Into T_TSLableScrap (LableID,StatusID,DeviceID,WorkShiftID) Values (@LableID,@StatusID,@DeviceID,@WorkShiftID)";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScrap"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["LableID"].copy(TB_ExcessiveLableID.Text.ToString().Trim()));

            dbcb.appendParameter(Schema.Attributes["StatusID"].copy(((short)Util.TS.LableScanStatus.ExcessiveLable).ToString()));

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

            dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(DDL_WorkShift.SelectedValue));

            CommonDB.ExecuteSingleCommand(dbcb);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false, "IsRepeat();");
        }
    }

    /// <summary>
    /// 多余条码List
    /// </summary>
    protected void LaodCancelLableIDList()
    {
        string Query = @"Select
                            Row_Number() Over (Order By ScanTime Asc) As RowID,
                            LableID,
                            ScanTime,
	                        MachineID,
	                        WorkShiftName
                        From T_TSLableScrap 
                        Inner Join T_TSDevice On T_TSDevice.DeviceID = T_TSLableScrap.DeviceID
                        Inner Join T_TSWorkShift On T_TSWorkShift.WorkShiftID = T_TSLableScrap.WorkShiftID
                        Where T_TSLableScrap.DeviceID In (Select DeviceID From T_TSDevice Where MachineID = @MachineID) And T_TSLableScrap.WorkShiftID = @WorkShiftID
                        And Datediff(Day,ScanTime,GetDate()) = 0 Order By ScanTime Desc";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("MachineID", "Nvarchar", 50, TB_MachineID.Text.Trim()));

        dbcb.appendParameter(Util.GetDataAccessAttribute("WorkShiftID", "Nvarchar", 50, DDL_WorkShift.SelectedValue));

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
                align = GetAlign(Column.ColumnName)
            }),
            Rows = DT.AsEnumerable().Select(Row => new
            {
                RowID = Row["RowID"].ToString().Trim(),
                LableID = Row["LableID"].ToString().Trim(),
                MachineID = Row["MachineID"].ToString().Trim(),
                WorkShiftName = Row["WorkShiftName"].ToString().Trim(),
                ScanTime = Row["ScanTime"].ToString().Trim()
            })
        };
        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");
        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQRowNumbersValue", "<script>var IsShowJQRowNumbersValue='" + false.ToStringValue() + "'</script>");
        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
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
            case "RowID":
            case "LableID":
            case "ScanTime":
            case "MachineID":
            case "WorkShiftName":
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
            case "RowID":
                return 30;
            case "LableID":
            case "ScanTime":
            case "MachineID":
            case "WorkShiftName":
                return 100;
            default:
                return 250;
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
            case "LableID":
                return (string)GetLocalResourceObject("Str_ColumnName_LableID");
            case "ScanTime":
                return (string)GetLocalResourceObject("Str_ColumnName_ScanTime");
            case "MachineID":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineID");
            case "WorkShiftName":
                return (string)GetLocalResourceObject("Str_ColumnName_WorkShiftName");
            case "RowID":
                return (string)GetLocalResourceObject("Str_ColumnName_RowID");
            default:
                return ColumnName;
        }
    }

    protected void BT_Load_Click(object sender, EventArgs e)
    {

    }
}