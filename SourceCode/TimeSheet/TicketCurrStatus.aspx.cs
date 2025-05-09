using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketCurrStatus : System.Web.UI.Page
{
    protected override void OnPreRenderComplete(EventArgs e)
    {
        LoadData();

        base.OnPreRenderComplete(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
        {
            System.Reflection.PropertyInfo IsAdmin = Master.GetType().GetProperty("IsAdmin");

            HF_IsAdmin.Value = (IsAdmin != null && (bool)IsAdmin.GetValue(Master)).ToStringValue();
        }
    }

    protected void LoadData()
    {
        string Query = @"Select  
                        '' As TicketIDValue,
                        T_TSTicketCurrStatus.TicketID,
                        V_TSMORouting.TEXT1,
                        Convert(nvarchar,T_TSTicketRouting.ProcessID) + '-' + T_TSTicketRouting.VORNR + '-' + T_TSTicketRouting.LTXA1　As ProcessName,
                        T_TSDevice.MachineID,
                        T_TSDevice.MachineName,
                        T_TSTicketCurrStatus.AllowQty,
                        T_TSTicketCurrStatus.Brand,
                        T_TSTicketCurrStatus.EntryTime,
                        T_TSWorkShift.WorkShiftName,
                        Base_Org.dbo.GetAccountName(T_TSTicketCurrStatus.Operator) As MainOperatorName
                        From T_TSTicketCurrStatus
                        Inner Join T_TSTicketRouting On T_TSTicketRouting.TicketID = T_TSTicketCurrStatus.TicketID And T_TSTicketRouting.ProcessID = T_TSTicketCurrStatus.ProcessID
                        Inner Join T_TSDevice On T_TSDevice.DeviceID = T_TSTicketCurrStatus.DeviceID
                        Inner Join T_TSWorkShift　On T_TSWorkShift.WorkShiftID = T_TSTicketCurrStatus.WorkShiftID
                        Inner Join V_TSMORouting On V_TSMORouting.AUFPL = T_TSTicketRouting.AUFPL And V_TSMORouting.APLZL = T_TSTicketRouting.APLZL And V_TSMORouting.VORNR = T_TSTicketRouting.VORNR
                        Order By T_TSTicketCurrStatus.EntryTime";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

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
                classes = Column.ColumnName == "TicketID" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            TicketIDColumnName = "TicketIDValue",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                TicketIDValue = Row["TicketID"].ToString().Trim(),
                TicketID = Row["TicketID"].ToString().Trim(),
                TEXT1 = Row["TEXT1"].ToString().Trim(),
                ProcessName = Row["ProcessName"].ToString().Trim(),
                MachineID = Row["MachineID"].ToString().Trim(),
                MachineName = Row["MachineName"].ToString().Trim(),
                AllowQty = Row["AllowQty"].ToString().Trim(),
                Brand = Row["Brand"].ToString().Trim(),
                EntryTime = ((DateTime)Row["EntryTime"]).ToCurrentUICultureStringTime(),
                WorkShiftName = Row["WorkShiftName"].ToString().Trim(),
                MainOperatorName = Row["MainOperatorName"].ToString().Trim()
            })
        };

        if (HF_IsAdmin.Value.ToBoolean())
            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelectValue", "<script>var IsMultiSelectValue='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");
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
            case "TicketIDValue":
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
            case "MainOperatorName":
            case "AllowQty":
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
            case "TicketID":
                return 100;
            case "AllowQty":
            case "MainOperatorName":
            case "MachineID":
            case "MachineName":
                return 80;
            case "EntryTime":
                return 120;
            case "WorkShiftName":
                return 120;
            default:
                return 150;
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
            case "TicketID":
                return (string)GetLocalResourceObject("Str_ColumnName_TicketID");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            case "ProcessName":
                return (string)GetLocalResourceObject("Str_ColumnName_ProcessName");
            case "MachineID":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineID");
            case "MachineName":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineName");
            case "AllowQty":
                return (string)GetLocalResourceObject("Str_ColumnName_AllowQty");
            case "Brand":
                return (string)GetLocalResourceObject("Str_ColumnName_Brand");
            case "EntryTime":
                return (string)GetLocalResourceObject("Str_ColumnName_EntryTime");
            case "WorkShiftName":
                return (string)GetLocalResourceObject("Str_ColumnName_WorkShiftName");
            case "MainOperatorName":
                return (string)GetLocalResourceObject("Str_ColumnName_MainOperatorName");
            default:
                return ColumnName;
        }
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        List<string> TicketIDList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(HF_TicketIDList.Value);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        foreach (string TicketID in TicketIDList)
        {
            int ProcessID = GetProcessID(TicketID);

            if (ProcessID < 1)
                continue;

            if (IsHaveChildren(TicketID, ProcessID) || IsHaveMaintain(TicketID, ProcessID))
                continue;

            string Query = @"Delete T_TSTicketCurrStatus Where TicketID = @TicketID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            CommonDB.ExecuteSingleCommand(dbcb);
        }
    }

    /// <summary>
    /// 指定流程卡號取得當前進工ProcessID
    /// </summary>
    /// <returns></returns>
    protected int GetProcessID(string TicketID)
    {
        string Query = @"Select ProcessID From T_TSTicketCurrStatus Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return -1;

        return (int)DT.Rows[0][0];
    }

    /// <summary>
    /// 指定流程卡號和工序得到使否有開立出返工或隔離單
    /// </summary>
    protected bool IsHaveChildren(string TicketID, int ProcessID)
    {
        string Query = @"Select Count(*) From T_TSTicket Where ParentTicketID = @ParentTicketID And CreateProcessID = @CreateProcessID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ParentTicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["CreateProcessID"].copy(ProcessID));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    ///  指定流程卡號和工序得到使否有維修單或是待維修資料
    /// </summary>
    protected bool IsHaveMaintain(string TicketID, int ProcessID)
    {
        string Query = @"Select * From T_TSTicketMaintain Where TicketID = @TicketID And ProcessID = @ProcessID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return false;

        return true;
    }
}