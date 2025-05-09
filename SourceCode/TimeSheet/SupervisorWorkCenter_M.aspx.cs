using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_SupervisorWorkCenter_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            LoadWorkCenter();

            if (!string.IsNullOrEmpty(Request["ReportDate"]))
                TB_ReportDate.Text = Request["ReportDate"].Trim();

            if (!string.IsNullOrEmpty(Request["OperatorWorkCode"]))
                TB_WorkCode.Text = Request["OperatorWorkCode"].Trim();

            if (!string.IsNullOrEmpty(Request["ARBPL"]))
                DDL_WorkCenter.SelectedValue = Request["ARBPL"].Trim();

            bool IsNewData = (string.IsNullOrEmpty(Request["ReportDate"]) || string.IsNullOrEmpty(Request["OperatorWorkCode"]) || string.IsNullOrEmpty(Request["ARBPL"]));

            if (IsNewData)
            {
                if (!string.IsNullOrEmpty(Request["ReportDate"]))
                    TB_ReportDate.Text = Request["ReportDate"].Trim();

                TB_ReportDate.Text = DateTime.Now.ToDefaultString("yyyy/MM");

                BT_Delete.Visible = false;
            }
            else
            {
                TB_ReportDate.CssClass = "form-control readonly readonlyColor";

                TB_WorkCode.CssClass = "form-control readonly readonlyColor";

                DDL_WorkCenter.Enabled = false;

                BT_Save.Visible = false;
            }

            HF_IsNewData.Value = IsNewData.ToStringValue();

        }
    }

    /// <summary>
    /// 加载工作中心下拉列表
    /// </summary>
    private void LoadWorkCenter()
    {
        string Query = @"Select 
	                        ARBPL,
	                        ARBPL_KTEXT
                        From T_TSSAPPLPO
                        Where ARBPL_KTEXT <> ''
                        Group By ARBPL,ARBPL_KTEXT 
                        Order By ARBPL_KTEXT";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_WorkCenter.DataValueField = "ARBPL";

        DDL_WorkCenter.DataTextField = "ARBPL_KTEXT";

        DDL_WorkCenter.DataSource = DT;

        DDL_WorkCenter.DataBind();

        DDL_WorkCenter.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }

    /// <summary>
    /// 新增按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void BT_Save_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            DBAction DBA = new DBAction();

            int Operator = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

            List<string> WorkCenterList = HF_WorkCenterSelected.Value.Split(',').ToList();

            foreach (string WorkCenter in WorkCenterList)
            {
                if (IsSupervisorWorkCenterRepeat(Operator, WorkCenter))
                    throw new Exception((string)GetLocalResourceObject("Str_Error_SupervisorWorkCenterRepeat"));

                string Query = "Insert Into T_TSSupervisorWorkCenter (ReportDate,Operator,ARBPL) Values (@ReportDate,@Operator,@ARBPL)";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSupervisorWorkCenter"];

                dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(TB_ReportDate.Text.Trim() + "/01"));
                dbcb.appendParameter(Schema.Attributes["Operator"].copy(Operator));
                dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(WorkCenter));

                DBA.AddCommandBuilder(dbcb);
            }

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
    /// 指定员工ID得到资料是否重复
    /// </summary>
    /// <param name="Operator">员工ID</param>
    /// <param name="WorkCenter">工作中心ID</param>
    /// <returns>是否重复</returns>
    protected bool IsSupervisorWorkCenterRepeat(int Operator,string WorkCenter)
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSupervisorWorkCenter"];

        string Query = @"Select Count(*) From T_TSSupervisorWorkCenter Where ReportDate = @ReportDate And Operator = @Operator And ARBPL = @ARBPL";

        dbcb.CommandText = Query;

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(TB_ReportDate.Text.Trim() + "/01"));

        dbcb.appendParameter(Schema.Attributes["Operator"].copy(Operator));

        dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(WorkCenter));

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

            int Operator = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

            string Query = @"Delete From T_TSSupervisorWorkCenter Where ReportDate = @ReportDate And Operator = @Operator And ARBPL = @ARBPL";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSupervisorWorkCenter"];

            dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(TB_ReportDate.Text.Trim() + "/01"));

            dbcb.appendParameter(Schema.Attributes["Operator"].copy(Operator));

            dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(DDL_WorkCenter.SelectedValue.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false);
        }
    }
}

