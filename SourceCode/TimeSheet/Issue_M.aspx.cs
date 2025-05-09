using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_Issue_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["IssueID"] != null && !string.IsNullOrEmpty(Request["IssueID"].Trim()))
            {
                TB_IssueID.Text = Request["IssueID"].Trim();

                LoadData();

                BT_Delete.Visible = !IsHaveUseIssueID();
            }
            else
                BT_Delete.Visible = false;
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select Top 1 * From T_TSIssue Where IssueID = @IssueID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssue"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["IssueID"].copy(TB_IssueID.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_IssueName.Text = DT.Rows[0]["IssueName"].ToString().Trim();

        TB_SortID.Text = DT.Rows[0]["SortID"].ToString().Trim();
    }

    /// <summary>
    /// 是否有使用了問題代碼
    /// </summary>
    /// <returns></returns>
    protected bool IsHaveUseIssueID()
    {
        string Query = @"Select Count(*) From T_TSIssueList Where IssueID = @IssueID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueList"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["IssueID"].copy(TB_IssueID.Text.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    protected void BT_Save_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            DBAction DBA = new DBAction();

            string Query = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssue"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            string IssueID = string.Empty;

            if (string.IsNullOrEmpty(TB_IssueID.Text.Trim()))
            {
                Query = @"Insert Into T_TSIssue (IssueID,IssueName,SortID) Values (@IssueID,@IssueName,@SortID)";

                IssueID = BaseConfiguration.SerialObject[(short)34].取號();
            }
            else
            {
                Query = @"Update T_TSIssue Set IssueName = @IssueName,SortID = @SortID Where IssueID = @IssueID";

                IssueID = TB_IssueID.Text.Trim();
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["IssueID"].copy(IssueID));

            dbcb.appendParameter(Schema.Attributes["IssueName"].copy(TB_IssueName.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["SortID"].copy(TB_SortID.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            bool HaveUseID = IsHaveUseIssueID();

            if (HaveUseID)
                throw new Exception((string)GetLocalResourceObject("Str_Error_HaveUseID"));

            DBAction DBA = new DBAction();

            string Query = @"Delete T_TSIssue Where IssueID = @IssueID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssue"];

            dbcb.appendParameter(Schema.Attributes["IssueID"].copy(TB_IssueID.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSIssueRelation Where IssueID = @IssueID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSIssueRelation"];

            dbcb.appendParameter(Schema.Attributes["IssueID"].copy(TB_IssueID.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}