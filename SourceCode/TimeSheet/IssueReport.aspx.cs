using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_IssueReport : System.Web.UI.Page
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
            DateTime NowIssueDate = GetNowIssueDate();

            TB_CreateDateStart.Text = NowIssueDate.ToCurrentUICultureString();

            TB_CreateDateEnd.Text = NowIssueDate.ToCurrentUICultureString();

            string Query = @"Select MachineID,MachineName From T_TSDevice Where DeviceID Not Like 'X%' Order By MachineName Desc";

            DataTable DT = CommonDB.ExecuteSelectQuery(Query);

            DDL_Machine.DataValueField = "MachineID";

            DDL_Machine.DataTextField = "MachineName";

            DDL_Machine.DataSource = DT;

            DDL_Machine.DataBind();

            DDL_Machine.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));

            if (MasterPageFile.Contains("TimeSheet.master"))
            {
                if (Request.Cookies["TS_WorkCode"] == null)
                {
                    Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_WorkStationGoIn"), true, false, "window.location.href='" + ResolveClientUrl("~/TimeSheet/WorkStationGoIn.aspx") + "'");

                    return;
                }

                TB_WorkCode.Text = Request.Cookies["TS_WorkCode"].Value.Trim();

                TB_WorkCode.Enabled = false;

                HF_IsShowCreate.Value = true.ToStringValue();

                if (Request.Cookies["TS_MachineID"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_MachineID"].Value))
                    DDL_Machine.SelectedValue = Request.Cookies["TS_MachineID"].Value;
            }
            else
                HF_IsShowCreate.Value = false.ToStringValue();
        }

        HF_IsShowResultList.Value = false.ToStringValue();
    }

    /// <summary>
    /// 取得問題日期
    /// </summary>
    /// <returns>問題日期</returns>
    protected DateTime GetNowIssueDate()
    {
        if (Request.Cookies["TS_WorkShiftID"] != null)
        {
            string Query = @"Select dbo.TS_GetReportDate(@TargetDateTime,@WorkShiftID)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Util.GetDataAccessAttribute("TargetDateTime", "DateTime", 0, DateTime.Now));

            dbcb.appendParameter(Util.GetDataAccessAttribute("WorkShiftID", "NvarChar", 50, Request.Cookies["TS_WorkShiftID"].Value.Trim()));

            return (DateTime)CommonDB.ExecuteScalar(dbcb);
        }
        else
            return DateTime.Now;
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueList"];

        string Query = @"Select 
                            CreateDate,
                            IssueDate,
                            WorkShiftID,
                            (Select WorkShiftName From T_TSWorkShift Where T_TSWorkShift.WorkShiftID = T_TSIssueList.WorkShiftID) As WorkShiftName,
                            T_TSIssueList.DeviceID,
                            MachineID,
                            T_TSDevice.MachineName,
                            T_TSIssueCategory.CategoryName,
                            T_TSIssue.IssueName,
                            UsageMinutes,
                            Remark,
                            Base_Org.dbo.GetAccountName(Operator) As OperatorName
                        From T_TSIssueList 
                        Inner Join T_TSIssueCategory On T_TSIssueList.CategoryID = T_TSIssueCategory.CategoryID
                        Inner Join T_TSIssue On T_TSIssueList.IssueID = T_TSIssue.IssueID
                        Inner Join T_TSDevice On T_TSIssueList.DeviceID = T_TSDevice.DeviceID
                        Where IssueDate >= @IssueDateStart And IssueDate <= @IssueDateEnd ";

        if (!string.IsNullOrEmpty(TB_WorkCode.Text.Trim()))
        {
            int AccountID = BaseConfiguration.GetAccountID(TB_WorkCode.Text);

            dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

            Query += " And Operator = @Operator";
        }

        if (!string.IsNullOrEmpty(DDL_Machine.SelectedValue))
        {
            string DeviceID = Util.TS.GetDeviceID(DDL_Machine.SelectedValue);

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

            Query += " And T_TSIssueList.DeviceID = @DeviceID";
        }

        dbcb.CommandText = Query + " Order By T_TSIssue.SortID";

        dbcb.appendParameter(Schema.Attributes["IssueDate"].copy(DateTime.Parse(TB_CreateDateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "IssueDateStart"));

        dbcb.appendParameter(Schema.Attributes["IssueDate"].copy(DateTime.Parse(TB_CreateDateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "IssueDateEnd"));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        int WorkShiftCounmt = DT.AsEnumerable().GroupBy(Row => Row["WorkShiftID"].ToString().Trim()).Count();

        var ResponseData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName, WorkShiftCounmt),
                classes = Column.ColumnName == "UsageMinutes" ? BaseConfiguration.JQGridColumnClassesName : "",
                summaryType = Column.ColumnName == "UsageMinutes" ? "sum" : null,
                summaryTpl = Column.ColumnName != "UsageMinutes" ? null : "<span style=\"color:#FF9224;\">{0}</span>",
                sortable = false
            }),
            CreateDateColumnName = "CreateDate",
            WorkShiftIDColumnName = "WorkShiftID",
            DeviceIDColumnName = "DeviceID",
            MachineIDColumnName = "MachineID",
            IssueDateColumnName = "IssueDate",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            groupingView = new
            {
                groupField = new string[] { "IssueName" },
                groupColumnShow = new bool[] { false },
                groupSummary = new bool[] { true }
            },
            CustiomFormatterLocalizedNumericColumnNames = new string[] { "UsageMinutes" },
            Rows = DT.AsEnumerable().Select(Row => new
            {
                CreateDate = ((DateTime)Row["CreateDate"]).ToDefaultString("yyyy/MM/dd HH:mm:ss.fff"),
                IssueDate = ((DateTime)Row["IssueDate"]).ToCurrentUICultureString(),
                WorkShiftID = Row["WorkShiftID"].ToString().Trim(),
                WorkShiftName = Row["WorkShiftName"].ToString().Trim(),
                DeviceID = Row["DeviceID"].ToString().Trim(),
                MachineID = Row["MachineID"].ToString().Trim(),
                MachineName = Row["MachineName"].ToString().Trim(),
                CategoryName = Row["CategoryName"].ToString().Trim(),
                IssueName = Row["IssueName"].ToString().Trim(),
                UsageMinutes = Row["UsageMinutes"].ToString().Trim(),
                Remark = Row["Remark"].ToString().Trim(),
                OperatorName = Row["OperatorName"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelect", "<script>var IsMultiSelectValue='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

        HF_IsShowResultList.Value = true.ToStringValue();
    }

    /// <summary>
    /// 指定ColumnName得到是否影藏
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <param name="WorkShiftCounmt">班別數量</param>
    /// <returns>是否影藏</returns>
    protected bool GetIsHidden(string ColumnName, int WorkShiftCounmt)
    {
        if (ColumnName == "OperatorName" && !TB_WorkCode.Enabled)
            return true;
        if (ColumnName == "IssueDate" && TB_CreateDateStart.Text == TB_CreateDateEnd.Text)
            return true;
        if (ColumnName == "WorkShiftName" && WorkShiftCounmt > 1)
            return false;

        switch (ColumnName)
        {
            case "CreateDate":
            case "WorkShiftID":
            case "DeviceID":
            case "MachineID":
            case "MachineName":
            case "CategoryName":
            case "WorkShiftName":
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

            case "UsageMinutes":
                return "center";
            case "IssueDate":
                return "right";
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
            case "IssueDate":
                return 120;
            case "UsageMinutes":
            case "MachineName":
            case "CategoryName":
            case "OperatorName":
                return 150;
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
            case "IssueDate":
                return (string)GetLocalResourceObject("Str_ColumnName_IssueDate");
            case "WorkShiftName":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_WorkShift");
            case "MachineName":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Machine");
            case "CategoryName":
                return (string)GetLocalResourceObject("Str_ColumnName_CategoryName");
            case "IssueName":
                return (string)GetLocalResourceObject("Str_ColumnName_IssueName");
            case "UsageMinutes":
                return (string)GetLocalResourceObject("Str_ColumnName_UsageMinutes");
            case "Remark":
                return (string)GetGlobalResourceObject("GlobalRes", "Str_Remark");
            case "OperatorName":
                return (string)GetLocalResourceObject("Str_ColumnName_OperatorName");
            default:
                return ColumnName;
        }
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            List<dynamic> TaskList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<dynamic>>(HF_DeleteIssueItems.Value);

            DBAction DBA = new DBAction();

            string Query = @"Delete T_TSIssueList Where CreateDate = @CreateDate And WorkShiftID = @WorkShiftID And DeviceID = @DeviceID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueList"];

            for (int i = 0; i < TaskList.Count; i++)
            {
                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(TaskList[i].CreateDate.ToString()));

                dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(TaskList[i].WorkShiftID.ToString()));

                dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(TaskList[i].DeviceID.ToString()));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            BT_Search_Click(null, null);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, false);
        }
    }
}