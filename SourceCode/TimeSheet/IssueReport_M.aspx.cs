using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_IssueReport_M : System.Web.UI.Page
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

        try
        {
            if (!IsPostBack)
            {
                Util.TS.LoadDDLWorkShift(DDL_WorkShift, false);

                if (string.IsNullOrEmpty(Request["CreateDate"].Trim()) && string.IsNullOrEmpty(Request["WorkShiftID"].Trim()) && string.IsNullOrEmpty(Request["DeviceID"].Trim()))
                {
                    TB_MachineID.Text = Request.Cookies["TS_MachineID"].Value.Trim();

                    HF_DeviceID.Value = Util.TS.GetDeviceID(TB_MachineID.Text);

                    DDL_WorkShift.SelectedValue = Request.Cookies["TS_WorkShiftID"].Value.Trim();

                    TB_IssueDate.Text = GetNowIssueDate().ToCurrentUICultureString();

                    BT_Delete.Visible = false;

                    int AccountID = BaseConfiguration.GetAccountID(Request.Cookies["TS_WorkCode"].Value.Trim());

                    if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                        throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                    HF_Operator.Value = AccountID.ToString();

                    LoadCategory();
                }
                else
                {
                    if (!string.IsNullOrEmpty(Request["CreateDate"].Trim()))
                        HF_CreateDate.Value = Request["CreateDate"].Trim();
                    if (!string.IsNullOrEmpty(Request["WorkShiftID"].Trim()))
                        DDL_WorkShift.SelectedValue = Request["WorkShiftID"].Trim();
                    if (!string.IsNullOrEmpty(Request["DeviceID"].Trim()))
                        HF_DeviceID.Value = Request["DeviceID"].Trim();
                    if (!string.IsNullOrEmpty(Request["MachineID"].Trim()))
                        TB_MachineID.Text = Request["MachineID"].Trim();

                    LoadCategory();

                    LoadData();
                }
            }

            if (string.IsNullOrEmpty(HF_DeviceID.Value))
                throw new Exception((string)GetLocalResourceObject("Str_Error_NoDevice"));
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select * From T_TSIssueList Where CreateDate = @CreateDate And WorkShiftID = @WorkShiftID And DeviceID = @DeviceID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueList"];

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(HF_CreateDate.Value));

        dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(DDL_WorkShift.SelectedValue));

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_IssueDate.Text = ((DateTime)DT.Rows[0]["IssueDate"]).ToCurrentUICultureString();

        TB_UsageMinutes.Text = DT.Rows[0]["UsageMinutes"].ToString().Trim();

        TB_Remark.Text = DT.Rows[0]["Remark"].ToString().Trim();

        HF_Operator.Value = DT.Rows[0]["Operator"].ToString().Trim();

        DDL_Category.ClearSelection();

        DDL_Category.SelectedValue = DT.Rows[0]["CategoryID"].ToString().Trim();

        DDL_Category_SelectedIndexChanged(null, null);

        DDL_Issue.ClearSelection();

        DDL_Issue.SelectedValue = DT.Rows[0]["IssueID"].ToString().Trim();
    }

    /// <summary>
    /// 取得問題日期
    /// </summary>
    /// <returns>問題日期</returns>
    protected DateTime GetNowIssueDate()
    {
        string Query = @"Select dbo.TS_GetReportDate(@TargetDateTime,@WorkShiftID)";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("TargetDateTime", "DateTime", 0, DateTime.Now));

        dbcb.appendParameter(Util.GetDataAccessAttribute("WorkShiftID", "NvarChar", 50, DDL_WorkShift.SelectedValue));

        return (DateTime)CommonDB.ExecuteScalar(dbcb);
    }

    /// <summary>
    /// 載入類別
    /// </summary>
    protected void LoadCategory()
    {
        string Query = @"Select T_TSIssueCategory.CategoryID,T_TSIssueCategory.CategoryName 
                        From T_TSIssueCategory Inner Join T_TSIssueCategoryDevice On T_TSIssueCategory.CategoryID = T_TSIssueCategoryDevice.CategoryID 
                        Where DeviceID = @DeviceID Order By SortID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueCategoryDevice"];

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_Category.DataValueField = "CategoryID";

        DDL_Category.DataTextField = "CategoryName";

        DDL_Category.DataSource = DT;

        DDL_Category.DataBind();

        DDL_Category.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));

        if (DT.Rows.Count == 1)
        {
            DDL_Category.SelectedIndex = 1;

            DDL_Category_SelectedIndexChanged(DDL_Category, null);
        }
    }

    protected void DDL_Category_SelectedIndexChanged(object sender, EventArgs e)
    {
        string Query = @"Select T_TSIssue.IssueID,T_TSIssue.IssueName From T_TSIssue Inner Join T_TSIssueRelation On T_TSIssue.IssueID = T_TSIssueRelation.IssueID Where T_TSIssueRelation.CategoryID = @CategoryID Order By SortID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueRelation"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(DDL_Category.SelectedValue));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_Issue.DataValueField = "IssueID";

        DDL_Issue.DataTextField = "IssueName";

        DDL_Issue.DataSource = DT;

        DDL_Issue.DataBind();

        DDL_Issue.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }

    protected void BT_Save_Click(object sender, EventArgs e)
    {
        try
        {
            DBAction DBA = new DBAction();

            if (!string.IsNullOrEmpty(HF_CreateDate.Value.Trim()))
                DBA.AddCommandBuilder(GetDeleteDBCB());

            string Query = "Insert Into T_TSIssueList (WorkShiftID,DeviceID,IssueDate,IssueID,CategoryID,UsageMinutes,Remark,Operator) Values (@WorkShiftID,@DeviceID,@IssueDate,@IssueID,@CategoryID,@UsageMinutes,@Remark,@Operator)";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueList"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(DDL_WorkShift.SelectedValue));

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

            dbcb.appendParameter(Schema.Attributes["IssueDate"].copy(DateTime.Parse(TB_IssueDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));

            dbcb.appendParameter(Schema.Attributes["IssueID"].copy(DDL_Issue.SelectedValue));

            dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(DDL_Category.SelectedValue));

            dbcb.appendParameter(Schema.Attributes["UsageMinutes"].copy(TB_UsageMinutes.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["Operator"].copy(HF_Operator.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            HF_IsRefresh.Value = true.ToStringValue();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }

    /// <summary>
    /// 取得刪除指令
    /// </summary>
    /// <returns>刪除指令</returns>
    protected DbCommandBuilder GetDeleteDBCB()
    {
        string Query = @"Delete T_TSIssueList Where CreateDate = @CreateDate And WorkShiftID = @WorkShiftID And DeviceID = @DeviceID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueList"];

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(HF_CreateDate.Value.Trim()));

        dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(DDL_WorkShift.SelectedValue));

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

        return dbcb;
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            DBAction DBA = new DBAction();

            if (!string.IsNullOrEmpty(HF_CreateDate.Value.Trim()))
                DBA.AddCommandBuilder(GetDeleteDBCB());

            DBA.Execute();

            HF_IsRefresh.Value = true.ToStringValue();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}