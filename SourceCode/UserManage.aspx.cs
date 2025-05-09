using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;

public partial class UserManage : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!Master.IsAdmin)
            Response.Redirect("~/Index.aspx");
    }

    protected void Page_LoadComplete(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        LaodUserData();
    }

    protected void LaodUserData()
    {
        string Query = @"Select 
                        V_Employee.id As UserID,
                        V_Employee.workcode As WorkCode,
                        Base_Org.dbo.GetDeptFullNameNotIncludedCompanyName(Base_Org.dbo.GetAccountDepID(V_Employee.id),'/') As DeptFullName,
                        V_Employee.lastname,
                        UseModule
                        From T_Users Inner Join Base_Org.dbo.V_Employee As V_Employee On T_Users.AccountID = V_Employee.id
                        Order By V_Employee.id Asc";

        DataTable DT = CommonDB.ExecuteSelectQuery(Query);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        List<string> ColumnList = Columns.Select(Column => Column.ColumnName).ToList();

        var ResponseData = new
        {
            colModel = ColumnList.Select(ColumnName => new
            {
                name = ColumnName,
                index = ColumnName,
                label = GetListLabel(ColumnName),
                hidden = GetIsHidden(ColumnName),
                align = GetAlign(ColumnName),
                width = GetWidth(ColumnName),
                classes = ColumnName == "lastname" ? BaseConfiguration.JQGridColumnClassesName : ""
            }),
            UserIDColumnName = "UserID",
            UserNnameColumnName = "lastname",
            PermissionModuleColumnName = "UseModule",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                UserID = Row["UserID"].ToString().Trim(),
                WorkCode = Row["WorkCode"].ToString().Trim(),
                DeptFullName = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(Row["DeptFullName"].ToString().Trim())),
                lastname = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(Row["lastname"].ToString().Trim())),
                UseModule = Row["UseModule"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelectValue", "<script>var IsMultiSelectValue='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
    }

    protected int GetWidth(string ColumnName)
    {
        switch (ColumnName)
        {
            case "UserID":
            case "WorkCode":
                return 80;
            case "lastname":
                return 120;
            default:
                return 200;
        }
    }

    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "UseModule":
            case "DeptFullName":
            case "lastname":
                return "left";
            default:
                return "center";
        }
    }

    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "PassWord":
                return true;
            default:
                return false;
        }
    }

    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "UserID":
                return (string)GetLocalResourceObject("Str_List1ColumnName1");
            case "WorkCode":
                return (string)GetLocalResourceObject("Str_List1ColumnName2");
            case "DeptFullName":
                return (string)GetLocalResourceObject("Str_List1ColumnName3");
            case "lastname":
                return (string)GetLocalResourceObject("Str_List1ColumnName4");
            case "UseModule":
                return (string)GetLocalResourceObject("Str_List1ColumnName5");
            default:
                return string.Empty;
        }
    }

    /// <summary>
    /// 指定員工序號得到使用者資料表示已有資料
    /// </summary>
    /// <param name="AccountID">員工序號</param>
    /// <returns><是否使用者資料表示已有資料/returns>
    protected bool IsHaveUsers(string AccountID)
    {
        string Query = @"Select Count(*) From T_Users Where AccountID = @AccountID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Users"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AccountID"].copy(AccountID));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    protected void BT_CreateUser_ServerClick(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (IsHaveUsers(HF_UserAccountID.Value))
        {
            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_AccountRepeatAlertMessage"));

            return;
        }

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Users"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Query = string.Empty;

        if (!IsHaveOALoginAccount())
            Query = @"Insert Into T_Users (AccountID,WorkCode,PassWord,UseModule) Values (@AccountID,(Select Base_Org.dbo.GetAccountWorkCode(@AccountID)),@PassWord,@UseModule)";
        else
            Query = @"Insert Into T_Users (AccountID,WorkCode,PassWord,UseModule,IsChangePassword) Values (@AccountID,(Select Base_Org.dbo.GetAccountWorkCode(@AccountID)),@PassWord,@UseModule,0)";

        dbcb.CommandText = Query;

        dbcb.appendParameter(Schema.Attributes["AccountID"].copy(HF_UserAccountID.Value));

        dbcb.appendParameter(Schema.Attributes["PassWord"].copy(TB_Password.Text.ToMD5String()));

        dbcb.appendParameter(Schema.Attributes["UseModule"].copy(TB_Module.Text.Trim()));

        CommonDB.ExecuteSingleCommand(dbcb);

        BT_CancelUser_Click(null, null);
    }

    protected void BT_DeleteUser_ServerClick(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        DBAction DBA = new DBAction();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Users"];

        List<string> Accounts = HF_DeleteUser.Value.Split('|').ToList();

        foreach (string AccountID in Accounts)
        {
            string Query = @"Delete T_Users Where AccountID = @AccountID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["AccountID"].copy(AccountID));

            DBA.AddCommandBuilder(dbcb);
        }

        DBA.Execute();

        BT_CancelUser_Click(null, null);
    }

    protected void BT_UpdateUser_ServerClick(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Users"];

        string Query = @"Update T_Users Set UseModule = @UseModule";

        if (!string.IsNullOrEmpty(TB_Password.Text))
        {
            Query += ",PassWord = @PassWord,IsChangePassword = 1";

            dbcb.appendParameter(Schema.Attributes["PassWord"].copy(TB_Password.Text.ToMD5String()));
        }

        Query += " Where AccountID = @AccountID";

        dbcb.appendParameter(Schema.Attributes["UseModule"].copy(TB_Module.Text.Trim()));

        dbcb.appendParameter(Schema.Attributes["AccountID"].copy(HF_UserAccountID.Value));

        dbcb.CommandText = Query;

        CommonDB.ExecuteSingleCommand(dbcb);

        BT_CancelUser_Click(null, null);
    }

    protected void BT_CancelUser_Click(object sender, EventArgs e)
    {
        TB_UserAccount.Text = string.Empty;
        HF_UserAccountID.Value = string.Empty;
        TB_Password.Text = string.Empty;
        HF_DeleteUser.Value = string.Empty;
        TB_Module.Text = string.Empty;
    }

    /// <summary>
    /// 取得是否有OA登入帳號
    /// </summary>
    /// <returns></returns>
    protected bool IsHaveOALoginAccount()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select Top 1 loginid From Base_Org.dbo.V_Employee Where workcode = Base_Org.dbo.GetAccountWorkCode(@AccountID) And status in (0,1,2,3) And accounttype = 0");

        dbcb.appendParameter(Util.GetDataAccessAttribute("AccountID", "NVarChar", 1000, HF_UserAccountID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            return !string.IsNullOrEmpty(DT.Rows[0][0].ToString().Trim());
        else
            return false;
    }
}