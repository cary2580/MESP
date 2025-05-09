using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_DailyReport : System.Web.UI.Page
{
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
        {
            if (Request.Cookies["TS_WorkCode"] != null)
                TB_WorkCode.Text = Request.Cookies["TS_WorkCode"].Value;

            TB_ReportTimeEnd.Text = DateTime.Parse(DateTime.Now.ToDefaultString() + " 23:59:59").ToCurrentUICultureStringTime();
        }
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        int AccountID = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

        if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_AccountID"));

            return;
        }

        string Query = @"Select Distinct
                        '' As TicketIDValue,
                        T_TSTicketResult.TicketID,
                        T_TSTicketResult.ProcessID,
                        T_TSTicketResult.SerialNo,
                        T_TSTicketRouting.VORNR + '-' + T_TSTicketRouting.LTXA1 As ProcessName,
                        (Select MachineID + '-'+ MachineName From T_TSDevice Where DeviceID = T_TSTicketResult.DeviceID) As MachineName,
                        T_TSTicketResult.GoodQty,
                        T_TSTicketResult.ScrapQty,
                        T_TSTicketResult.ReWorkQty,
                        T_TSTicketResult.ReportTimeStart,
                        T_TSTicketResult.ReportTimeEnd,
                        T_TSTicketResult.ReportMinute,
                        T_TSTicketResult.WaitMaintainMinute,
                        T_TSTicketResult.MaintainMinute,
                        T_TSTicketResult.WaitMinute,
                        T_TSTicketResult.Coefficient,
					    T_TSTicketResult.ResultMinute,
                        (T_TSTicketResult.ResultMinuteMainOperator + T_TSTicketResult.ResultMinuteSecondOperator) As ResultMinuteOperator,
                        T_TSTicketResult.Brand,
                        (Select WorkShiftName From T_TSWorkShift Where WorkShiftID = T_TSTicketResult.WorkShiftID) As WorkShiftName,
                        (Select CodeName From T_Code Where CodeType = 'TS_PayrollType' And CodeID = T_TSTicketResult.PayrollType And UICulture = @UICulture) As PayrollType,
                        Stuff(((Select '、' + Base_Org.dbo.GetAccountName(SecondOperator) + '(' + Convert(nvarchar,Coefficient) + ')' From T_TSTicketResultSecondOperator Where T_TSTicketResultSecondOperator.TicketID = T_TSTicketResult.TicketID And T_TSTicketResultSecondOperator.ProcessID = T_TSTicketResult.ProcessID And T_TSTicketResultSecondOperator.SerialNo = T_TSTicketResult.SerialNo For Xml Path(''))),1,1,'') AS SecondOperator,
                        Base_Org.dbo.GetAccountName(T_TSTicketResult.Approver) As ApproverName,
                        T_TSTicketResult.ApprovalTime
                        From T_TSTicketResult Inner Join　T_TSTicketRouting On T_TSTicketResult.TicketID = T_TSTicketRouting.TicketID And T_TSTicketResult.ProcessID = T_TSTicketRouting.ProcessID
                        Left Join T_TSTicketResultSecondOperator On T_TSTicketResult.TicketID = T_TSTicketResultSecondOperator.TicketID And T_TSTicketResult.ProcessID = T_TSTicketResultSecondOperator.ProcessID And T_TSTicketResult.SerialNo = T_TSTicketResultSecondOperator.SerialNo 
                        Where (T_TSTicketResult.Operator = @Operator Or T_TSTicketResultSecondOperator.SecondOperator = @Operator) And T_TSTicketResult.ReportTimeStart >= @ReportTimeStart And T_TSTicketResult.ReportTimeEnd <= @ReportTimeEnd
                        And IsNull(T_TSTicketResult.Approver,0) > 0 And T_TSTicketResult.ApprovalTime Is Not Null
                        Order By T_TSTicketResult.ReportTimeEnd Asc,T_TSTicketResult.TicketID,T_TSTicketResult.SerialNo Desc";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

        dbcb.appendParameter(Schema.Attributes["ReportTimeStart"].copy(DateTime.Parse(TB_ReportTimeStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));

        dbcb.appendParameter(Schema.Attributes["ReportTimeEnd"].copy(DateTime.Parse(TB_ReportTimeEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        IEnumerable<DataRow> Rows = DT.AsEnumerable();

        TB_GoodQty.Text = Rows.Sum(Row => (int)Row["GoodQty"]).ToString();

        TB_ScrapQty.Text = Rows.Sum(Row => (int)Row["ScrapQty"]).ToString();

        TB_ReWorkQty.Text = Rows.Sum(Row => (int)Row["ReWorkQty"]).ToString();

        TB_ReportMinute.Text = Rows.Sum(Row => (int)Row["ReportMinute"]).ToString();

        TB_WaitMaintainMinute.Text = Rows.Sum(Row => (int)Row["WaitMaintainMinute"]).ToString();

        TB_MaintainMinute.Text = Rows.Sum(Row => (int)Row["MaintainMinute"]).ToString();

        TB_WaitMinute.Text = Rows.Sum(Row => (int)Row["WaitMinute"]).ToString();

        TB_ResultMinute.Text = Rows.Sum(Row => (int)Row["ResultMinute"]).ToString();

        TB_ResultMinuteOperator.Text = Rows.Sum(Row => (int)Row["ResultMinuteOperator"]).ToString();

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
            Rows = Rows.Select(Row => new
            {
                TicketIDValue = Row["TicketID"].ToString().Trim(),
                ProcessID = Row["ProcessID"].ToString().Trim(),
                SerialNo = Row["SerialNo"].ToString().Trim(),
                TicketID = Row["TicketID"].ToString().Trim(),
                ProcessName = Row["ProcessName"].ToString().Trim(),
                MachineName = Row["MachineName"].ToString().Trim(),
                GoodQty = Row["GoodQty"].ToString().Trim(),
                ScrapQty = Row["ScrapQty"].ToString().Trim(),
                ReWorkQty = Row["ReWorkQty"].ToString().Trim(),
                ReportTimeStart = ((DateTime)Row["ReportTimeStart"]).ToCurrentUICultureStringTime(),
                ReportTimeEnd = ((DateTime)Row["ReportTimeEnd"]).ToCurrentUICultureStringTime(),
                ReportMinute = Row["ReportMinute"].ToString().Trim(),
                WaitMaintainMinute = Row["WaitMaintainMinute"].ToString().Trim(),
                MaintainMinute = Row["MaintainMinute"].ToString().Trim(),
                Coefficient = Row["Coefficient"].ToString().Trim(),
                ResultMinute = Row["ResultMinute"].ToString().Trim(),
                ResultMinuteOperator = Row["ResultMinuteOperator"].ToString().Trim(),
                WaitMinute = Row["WaitMinute"].ToString().Trim(),
                Brand = Row["Brand"].ToString().Trim(),
                WorkShiftName = Row["WorkShiftName"].ToString().Trim(),
                PayrollType = Row["PayrollType"].ToString().Trim(),
                SecondOperator = Row["SecondOperator"].ToString().Trim(),
                ApproverName = Row["ApproverName"].ToString().Trim(),
                ApprovalTime = ((DateTime)Row["ApprovalTime"]).ToCurrentUICultureStringTime()
            })
        };

        System.Reflection.PropertyInfo PI = Master.GetType().GetProperty("IsAdmin");

        if (PI != null && (bool)PI.GetValue(Master) == true)
        {
            BT_WorkShift.Visible = (bool)PI.GetValue(Master);
            BT_PayrollType.Visible = (bool)PI.GetValue(Master);

            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelect", "<script>var IsMultiSelectValue='" + true.ToStringValue() + "';</script>");
        }

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
            case "GoodQty":
            case "ScrapQty":
            case "ReWorkQty":
            case "ReportMinute":
            case "WaitMaintainMinute":
            case "MaintainMinute":
            case "Coefficient":
            case "ResultMinute":
            case "ResultMinuteOperator":
            case "WaitMinute":
                return 50;
            case "ReportTimeStart":
            case "ReportTimeEnd":
            case "ApproverName":
            case "ApprovalTime":
            case "PayrollType":
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
            case "GoodQty":
            case "ScrapQty":
            case "ReWorkQty":
            case "ReportMinute":
            case "WaitMaintainMinute":
            case "MaintainMinute":
            case "Coefficient":
            case "ResultMinute":
            case "ResultMinuteOperator":
            case "WaitMinute":
            case "ApproverName":
            case "ApprovalTime":
            case "PayrollType":
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
            case "ReportMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_ReportMinute");
            case "WaitMaintainMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_WaitMaintainMinute");
            case "MaintainMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_MaintainMinute");
            case "Coefficient":
                return (string)GetLocalResourceObject("Str_ColumnName_Coefficient");
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
            case "PayrollType":
                return (string)GetLocalResourceObject("Str_ColumnName_PayrollType");
            case "SecondOperator":
                return (string)GetLocalResourceObject("Str_ColumnName_SecondOperator");
            case "ApproverName":
                return (string)GetLocalResourceObject("Str_ColumnName_ApproverName");
            case "ApprovalTime":
                return (string)GetLocalResourceObject("Str_ColumnName_ApprovalTime");
            default:
                return ColumnName;
        }
    }
}