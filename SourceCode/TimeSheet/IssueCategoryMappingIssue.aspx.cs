using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_IssueCategoryMappingIssue : System.Web.UI.Page
{
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        if (Request["CategoryID"] != null)
            HF_CategoryID.Value = Request["CategoryID"].Trim();

        if (!Master.IsAccountVerificationPass)
            return;

        HF_IssueID.Value = string.Empty;

        TB_IssueName.Text = string.Empty;

        LoadData();
    }

    protected void Page_Load(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select 
                            T_TSIssueCategory.CategoryName,
                            T_TSIssue.IssueID,
                            T_TSIssue.IssueName
                        From T_TSIssueCategory
                        Inner Join T_TSIssueRelation On T_TSIssueRelation.CategoryID = T_TSIssueCategory.CategoryID
                        Inner Join T_TSIssue On T_TSIssue.IssueID = T_TSIssueRelation.IssueID
                        Where T_TSIssueCategory.CategoryID = @CategoryID
                        Order By T_TSIssue.SortID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueCategory"];

        dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(HF_CategoryID.Value.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            TB_CategoryName.Text = DT.Rows[0]["CategoryName"].ToString();

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
            }),
            IssueIDColumnName = "IssueID",
            IssueNameColumnName = "IssueName",
            Rows = DT.AsEnumerable().Select(Row => new
            {
                IssueID = Row["IssueID"].ToString().Trim(),
                IssueName = Row["IssueName"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
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
            default:
                return 100;
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
            case "IssueName":
                return (string)GetLocalResourceObject("Str_ColumnName_IssueName");
            default:
                return ColumnName;
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
            default:
                return "left";
        }
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
            case "IssueID":
            case "CategoryName":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 取得分類是否有IssueID代碼
    /// </summary>
    /// <returns>是否有IssueID代碼</returns>
    protected bool IsExistsCategoryIDMappingIssueID()
    {
        string Query = @"Select Count(*) From T_TSIssueRelation Where CategoryID = @CategoryID And IssueID = @IssueID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueRelation"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(HF_CategoryID.Value.Trim()));

        dbcb.appendParameter(Schema.Attributes["IssueID"].copy(HF_IssueID.Value.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            //檢查Maping表是否有資料
            if (!IsExistsCategoryIDMappingIssueID())
            {
                string Query = @"Insert Into T_TSIssueRelation (CategoryID,IssueID) Values (@CategoryID,@IssueID)";

                ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueRelation"];

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(HF_CategoryID.Value.Trim()));

                dbcb.appendParameter(Schema.Attributes["IssueID"].copy(HF_IssueID.Value.Trim()));

                dbcb.CommandText = Query;

                CommonDB.ExecuteSingleCommand(dbcb);
            }

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true);
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
            string Query = @"Delete T_TSIssueRelation Where CategoryID = @CategoryID And IssueID = @IssueID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueRelation"];

            dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(HF_CategoryID.Value.Trim()));

            dbcb.appendParameter(Schema.Attributes["IssueID"].copy(HF_IssueID.Value.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}