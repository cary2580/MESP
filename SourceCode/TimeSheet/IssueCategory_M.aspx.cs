using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_IssueCategory_M : System.Web.UI.Page
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
            if (Request["CategoryID"] != null && !string.IsNullOrEmpty(Request["CategoryID"].Trim()))
            {
                TB_IssueCategoryID.Text = Request["CategoryID"].Trim();

                LoadData();

                BT_Delete.Visible = !IsHaveUseCategoryID();
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
        string Query = @"Select Top 1 * From T_TSIssueCategory Where CategoryID = @CategoryID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueCategory"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(TB_IssueCategoryID.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_IssueCategoryName.Text = DT.Rows[0]["CategoryName"].ToString().Trim();

        TB_SortID.Text = DT.Rows[0]["SortID"].ToString().Trim();
    }

    /// <summary>
    /// 是否有使用了類別代碼
    /// </summary>
    /// <returns></returns>
    protected bool IsHaveUseCategoryID()
    {
        string Query = @"Select Count(*) From T_TSIssueList Where CategoryID = @CategoryID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueList"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(TB_IssueCategoryID.Text.Trim()));

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

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueCategory"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            string IssueID = string.Empty;

            if (string.IsNullOrEmpty(TB_IssueCategoryID.Text.Trim()))
            {
                Query = @"Insert Into T_TSIssueCategory (CategoryID,CategoryName,SortID) Values (@CategoryID,@CategoryName,@SortID)";

                IssueID = BaseConfiguration.SerialObject[(short)35].取號();
            }
            else
            {
                Query = @"Update T_TSIssueCategory Set CategoryName = @CategoryName,SortID = @SortID Where CategoryID = @CategoryID";

                IssueID = TB_IssueCategoryID.Text.Trim();
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(IssueID));

            dbcb.appendParameter(Schema.Attributes["CategoryName"].copy(TB_IssueCategoryName.Text.Trim()));

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
            bool HaveUseID = IsHaveUseCategoryID();

            if (HaveUseID)
                throw new Exception((string)GetLocalResourceObject("Str_Error_HaveUseID"));

            DBAction DBA = new DBAction();

            string Query = @"Delete T_TSIssueCategory Where CategoryID = @CategoryID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueCategory"];

            dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(TB_IssueCategoryID.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSIssueRelation Where CategoryID = @CategoryID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSIssueRelation"];

            dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(TB_IssueCategoryID.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSIssueCategoryDevice Where CategoryID = @CategoryID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSIssueCategoryDevice"];

            dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(TB_IssueCategoryID.Text.Trim()));

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