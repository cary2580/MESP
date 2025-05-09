using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;


public partial class TimeSheet_TickResultWithoutApprovedList : System.Web.UI.Page
{
    protected override void OnPreRenderComplete(EventArgs e)
    {
        LoadData();

        base.OnPreRenderComplete(e);
    }

    protected override void OnPreInit(EventArgs e)
    {
        if (Request["ViewInside"] != null && !string.IsNullOrEmpty(Request["ViewInside"].Trim()))
        {
            try
            {
                if (Request["ViewInside"].ToStringFromBase64(true).ToBoolean())
                    this.MasterPageFile = "~/MasterPage.master";
                else
                {
                    this.MasterPageFile = "~/TimeSheet/TimeSheet.master";

                    (Master as TimeSheet_TimeSheet).IsPassPageVerificationAccount = true;
                }
            }
            catch (Exception ex)
            {

            }
        }
        else
        {
            this.MasterPageFile = "~/TimeSheet/TimeSheet.master";

            (Master as TimeSheet_TimeSheet).IsPassPageVerificationAccount = true;
        }

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            Util.LoadDDLData(DDL_PayrollType, "TS_PayrollType", false);
    }

    protected void LoadData()
    {
        /* 只要是該員工尚未審批過的，都出現。因為有可能有些是跨日的大夜班 */
        string Query = @"Select 
                        '' As TicketIDValue,
                        T_TSTicketResult.TicketID,
                        T_TSTicketResult.ProcessID,
                        T_TSTicketResult.SerialNo,
                        (Select TEXT1 From V_TSMORouting Where AUFNR = T_TSTicket.AUFNR And VORNR = T_TSTicketResult.VORNR) As TEXT1,
                        T_TSTicketRouting.VORNR + '-' + T_TSTicketRouting.LTXA1 As ProcessName,
                        (Select MachineID + '-' + MachineName From T_TSDevice Where DeviceID = T_TSTicketResult.DeviceID) As MachineName,
                        T_TSTicketResult.GoodQty,
                        T_TSTicketResult.ScrapQty,
                        T_TSTicketResult.ReWorkQty,
                        T_TSTicketResult.ReportTimeStart,
                        T_TSTicketResult.ReportTimeEnd,
                        T_TSTicketResult.Coefficient,
                        T_TSTicketResult.ReportMinute,
                        T_TSTicketResult.WaitMaintainMinute,
                        T_TSTicketResult.MaintainMinute,
                        T_TSTicketResult.ResultMinute,
                        (T_TSTicketResult.ResultMinuteMainOperator + T_TSTicketResult.ResultMinuteSecondOperator) As ResultMinuteOperator,
                        T_TSTicketResult.WaitMinute,
                        T_TSTicketResult.Brand,
                        (Select WorkShiftName From T_TSWorkShift Where WorkShiftID = T_TSTicketResult.WorkShiftID) As WorkShiftName,
                        Base_Org.dbo.GetAccountName(Operator) + '/' + Base_Org.dbo.GetDeptName(Base_Org.dbo.GetAccountDepID(Operator)) As OperatorName,
                        Stuff(((Select '、' + Base_Org.dbo.GetAccountName(SecondOperator) + '(' + Convert(nvarchar,Coefficient) + ')' From T_TSTicketResultSecondOperator Where T_TSTicketResultSecondOperator.TicketID = T_TSTicketResult.TicketID And T_TSTicketResultSecondOperator.ProcessID = T_TSTicketResult.ProcessID And T_TSTicketResultSecondOperator.SerialNo = T_TSTicketResult.SerialNo For Xml Path(''))),1,1,'') AS SecondOperator
                        From T_TSTicketResult 
                        Inner Join T_TSTicketRouting On T_TSTicketResult.TicketID = T_TSTicketRouting.TicketID And T_TSTicketResult.ProcessID = T_TSTicketRouting.ProcessID
                        Inner Join T_TSTicket On T_TSTicket.TicketID = T_TSTicketResult.TicketID
                        Where (T_TSTicketResult.ApprovalTime Is Null) --And (T_TSTicketResult.GoodQty + T_TSTicketResult.ScrapQty + T_TSTicketResult.ReWorkQty) > 0
                        Order By T_TSTicketResult.ReportTimeEnd Asc,T_TSTicketResult.TicketID,T_TSTicketResult.SerialNo Desc";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        IEnumerable<DataRow> Rows = DT.AsEnumerable();

        System.Reflection.PropertyInfo IsAdmin = Master.GetType().GetProperty("IsAdmin");

        System.Reflection.PropertyInfo IsUserAdmin = Master.GetType().GetProperty("IsUserAdmin");

        System.Reflection.PropertyInfo IsShiftLeader = Master.GetType().GetProperty("IsShiftLeader");

        if (IsAdmin != null && IsUserAdmin != null && IsShiftLeader != null)
            HF_IsShowApproval.Value = ((bool)IsAdmin.GetValue(Master) || (bool)IsUserAdmin.GetValue(Master) || (bool)IsShiftLeader.GetValue(Master)).ToStringValue();

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
            ProcessIDColumnName = "ProcessID",
            SerialNoColumnName = "SerialNo",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            IsMultiSelect = HF_IsShowApproval.Value.ToBoolean(),
            Rows = Rows.Select(Row => new
            {
                TicketIDValue = Row["TicketID"].ToString().Trim(),
                TicketID = Row["TicketID"].ToString().Trim(),
                ProcessID = Row["ProcessID"].ToString().Trim(),
                SerialNo = Row["SerialNo"].ToString().Trim(),
                TEXT1 = Row["TEXT1"].ToString().Trim(),
                ProcessName = Row["ProcessName"].ToString().Trim(),
                MachineName = Row["MachineName"].ToString().Trim(),
                GoodQty = Row["GoodQty"].ToString().Trim(),
                ScrapQty = Row["ScrapQty"].ToString().Trim(),
                ReWorkQty = Row["ReWorkQty"].ToString().Trim(),
                ReportTimeStart = ((DateTime)Row["ReportTimeStart"]).ToCurrentUICultureStringTime(),
                ReportTimeEnd = ((DateTime)Row["ReportTimeEnd"]).ToCurrentUICultureStringTime(),
                Coefficient = Row["Coefficient"].ToString().Trim(),
                ReportMinute = Row["ReportMinute"].ToString().Trim(),
                WaitMaintainMinute = Row["WaitMaintainMinute"].ToString().Trim(),
                MaintainMinute = Row["MaintainMinute"].ToString().Trim(),
                ResultMinute = Row["ResultMinute"].ToString().Trim(),
                ResultMinuteOperator = Row["ResultMinuteOperator"].ToString().Trim(),
                WaitMinute = Row["WaitMinute"].ToString().Trim(),
                Brand = Row["Brand"].ToString().Trim(),
                WorkShiftName = Row["WorkShiftName"].ToString().Trim(),
                OperatorName = Row["OperatorName"].ToString().Trim(),
                SecondOperator = Row["SecondOperator"].ToString().Trim()
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
            case "TicketIDValue":
            case "ProcessID":
            case "SerialNo":
                return true;
            default:
                return false;
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
            case "SerialNo":
                return 30;
            case "TEXT1":
                return 260;
            case "GoodQty":
            case "ScrapQty":
            case "ReWorkQty":
            case "ReportMinute":
            case "WaitMaintainMinute":
            case "MaintainMinute":
            case "ResultMinute":
            case "ResultMinuteOperator":
            case "WaitMinute":
            case "Coefficient":
                return 50;
            case "ReportTimeStart":
            case "ReportTimeEnd":
                return 80;
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
            case "SerialNo":
            case "GoodQty":
            case "ScrapQty":
            case "ReWorkQty":
            case "ReportMinute":
            case "WaitMaintainMinute":
            case "MaintainMinute":
            case "ResultMinute":
            case "ResultMinuteOperator":
            case "WaitMinute":
            case "Coefficient":
                return "center";
            default:
                return "left";
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
            case "SerialNo":
                return (string)GetLocalResourceObject("Str_ColumnName_SerialNo");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            case "ProcessName":
                return (string)GetLocalResourceObject("Str_ColumnName_ProcessName");
            case "MachineName":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineName");
            case "GoodQty":
                return (string)GetLocalResourceObject("Str_ColumnName_GoodQty");
            case "ScrapQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQty");
            case "ReWorkQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ReWorkQty");
            case "ReportTimeStart":
                return (string)GetLocalResourceObject("Str_ColumnName_ReportTimeStart");
            case "ReportTimeEnd":
                return (string)GetLocalResourceObject("Str_ColumnName_ReportTimeEnd");
            case "Coefficient":
                return (string)GetLocalResourceObject("Str_ColumnName_Coefficient");
            case "ReportMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_ReportMinute");
            case "WaitMaintainMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_WaitMaintainMinute");
            case "MaintainMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_MaintainMinute");
            case "ResultMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_ResultMinute");
            case "ResultMinuteOperator":
                return (string)GetLocalResourceObject("Str_ColumnName_ResultMinuteOperator");
            case "WaitMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_WaitMinute");
            case "Brand":
                return (string)GetLocalResourceObject("Str_ColumnName_Brand");
            case "WorkShiftName":
                return (string)GetLocalResourceObject("Str_ColumnName_WorkShiftName");
            case "OperatorName":
                return (string)GetLocalResourceObject("Str_ColumnName_OperatorName");
            case "SecondOperator":
                return (string)GetLocalResourceObject("Str_ColumnName_SecondOperator");
            default:
                return ColumnName;
        }
    }

    protected void BT_Approval_Click(object sender, EventArgs e)
    {
        List<ApprovalObject> AL = Newtonsoft.Json.JsonConvert.DeserializeObject<List<ApprovalObject>>(HF_ApprovalList.Value.Trim());

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        string Query = @"Update T_TSTicketResult
                            Set T_TSTicketResult.Approver = @Approver,T_TSTicketResult.ApprovalTime = GetDate(),PayrollType = @PayrollType,T_TSTicketResult.ResultMinuteSecondOperator = IsNull(T_TSTicketResultSecondOperator.ResultMinute,0)
                            From T_TSTicketResult 
                            Inner Join T_TSDevice On T_TSDevice.DeviceID = T_TSTicketResult.DeviceID
                            Left Join 
                            (
	                            Select 
	                            T_TSTicketResultSecondOperator.TicketID,
	                            T_TSTicketResultSecondOperator.ProcessID,
	                            T_TSTicketResultSecondOperator.SerialNo,
	                            Sum(T_TSTicketResultSecondOperator.ResultMinute) As ResultMinute
	                            From T_TSTicketResultSecondOperator
	                            Group By T_TSTicketResultSecondOperator.TicketID,T_TSTicketResultSecondOperator.ProcessID,T_TSTicketResultSecondOperator.SerialNo
                            ) As T_TSTicketResultSecondOperator On 
                            T_TSTicketResult.TicketID = T_TSTicketResultSecondOperator.TicketID And 
                            T_TSTicketResult.ProcessID = T_TSTicketResultSecondOperator.ProcessID And
                            T_TSTicketResult.SerialNo = T_TSTicketResultSecondOperator.SerialNo
                            Where (IsNull(T_TSTicketResult.Approver,0) < 1 Or T_TSTicketResult.ApprovalTime Is Null)
							And T_TSTicketResult.TicketID = @TicketID And T_TSTicketResult.ProcessID = @ProcessID And T_TSTicketResult.SerialNo = @SerialNo";

        System.Reflection.PropertyInfo Account = Master.GetType().GetProperty("AccountID");

        if (Account == null)
            return;

        int AccountID = (int)Account.GetValue(Master);

        DBAction DBA = new DBAction();

        foreach (ApprovalObject A in AL)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["Approver"].copy(AccountID));

            dbcb.appendParameter(Schema.Attributes["PayrollType"].copy(DDL_PayrollType.SelectedValue));

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(A.TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(A.ProcessID));

            dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(A.SerialNo));

            DBA.AddCommandBuilder(dbcb);
        }

        DBA.Execute();
    }

    protected class ApprovalObject
    {
        public string TicketID;
        public int ProcessID;
        public int SerialNo;
    }
}