using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_PlanWorkMinuteList : System.Web.UI.Page
{
    protected string ViewInside = string.Empty;

    protected override void OnPreInit(EventArgs e)
    {
        if (Request["ViewInside"] != null && !string.IsNullOrEmpty(Request["ViewInside"].Trim()))
        {
            try
            {
                if (Request["ViewInside"].ToStringFromBase64(true).ToBoolean())
                    this.MasterPageFile = "~/MasterPage.master";
                else
                    (Master as BaseMasterPage).IsPassPageVerificationAccount = true;

                ViewInside = Request["ViewInside"].Trim();
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
            TB_ReportDateSrart.Text = DateTime.Now.ToCurrentUICultureString();

            TB_ReportDateEnd.Text = TB_ReportDateSrart.Text;
        }
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        string Query = @"Select
                        T_TSPlanWorkMinute.WorkDate,
                        T_TSDevice.DeviceID,
                        T_TSDevice.[Location],
                        MachineID + '-' + MachineName As Machine,
                        T_TSWorkShift.WorkShiftID,
                        T_TSWorkShift.WorkShiftName,
                        T_TSPlanWorkMinute.PlanWorkMinute,
                        T_TSPlanWorkMinute.CreateDate,
                        Base_Org.dbo.GetAccountName(CreateAccountID) + '/' + Base_Org.dbo.GetDeptName(Base_Org.dbo.GetAccountDepID(CreateAccountID)) As Creator
                        From T_TSPlanWorkMinute
                        Inner Join T_TSDevice On T_TSDevice.DeviceID = T_TSPlanWorkMinute.DeviceID
                        Inner Join T_TSWorkShift On T_TSWorkShift.WorkShiftID = T_TSPlanWorkMinute.WorkShiftID Where Datediff(Day,T_TSPlanWorkMinute.WorkDate,@WorkDateStart) <= 0 And Datediff(Day,T_TSPlanWorkMinute.WorkDate,@WorkDateEnd) >= 0
                        Order By T_TSPlanWorkMinute.WorkDate Desc,T_TSDevice.[Location], T_TSPlanWorkMinute.DeviceID,T_TSPlanWorkMinute.WorkShiftID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSPlanWorkMinute"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(TB_ReportDateSrart.Text, "WorkDateStart"));

        dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(TB_ReportDateEnd.Text, "WorkDateEnd"));

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
                classes = Column.ColumnName == "Machine" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            MachineColumnName = "Machine",
            WorkDateColumnName = (string)GetLocalResourceObject("Str_ColumnName_WorkDate"),
            WorkDateValueColumnName = "WorkDate",
            DeviceIDColumnName = "DeviceID",
            WorkShiftIDColumnName = "WorkShiftID",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                WorkDate = ((DateTime)Row["WorkDate"]).ToCurrentUICultureString(),
                DeviceID = Row["DeviceID"].ToString().Trim(),
                Location = Row["Location"].ToString().Trim(),
                Machine = Row["Machine"].ToString().Trim(),
                WorkShiftID = Row["WorkShiftID"].ToString().Trim(),
                WorkShiftName = Row["WorkShiftName"].ToString().Trim(),
                PlanWorkMinute = Row["PlanWorkMinute"].ToString().Trim(),
                CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureStringTime(),
                Creator = Row["Creator"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

        HF_IsShowResultList.Value = true.ToStringValue();
    }

    /// <summary>
    /// 指定ColumnName得到是否影藏
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否影藏</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "DeviceID":
            case "WorkShiftID":
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
            case "WorkDate":
            case "PlanWorkMinute":
            case "CreateDate":
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
            case "WorkDate":
                return 80;
            case "CreateDate":
                return 100;
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
            case "WorkDate":
                return (string)GetLocalResourceObject("Str_ColumnName_WorkDate");
            case "Location":
                return (string)GetLocalResourceObject("Str_ColumnName_Location");
            case "Machine":
                return (string)GetLocalResourceObject("Str_ColumnName_Machine");
            case "WorkShiftName":
                return (string)GetLocalResourceObject("Str_ColumnName_WorkShiftName");
            case "PlanWorkMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_PlanWorkMinute");
            case "CreateDate":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateDate");
            case "Creator":
                return (string)GetLocalResourceObject("Str_ColumnName_Creator");
            default:
                return ColumnName;
        }
    }
}