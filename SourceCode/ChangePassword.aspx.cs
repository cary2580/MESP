using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class ChangePassword : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;
    }

    protected void BT_CreateUser_Click(object sender, EventArgs e)
    {
        if (IsPasswordSame())
        {
            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_PasswordSameAlertMessage"));

            return;
        }

        string Query = @"Update T_Users Set IsChangePassword = 1,PassWord = @PassWord Where AccountID = @AccountID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Users"];

        dbcb.appendParameter(Schema.Attributes["AccountID"].copy(Master.AccountID));

        dbcb.appendParameter(Schema.Attributes["PassWord"].copy(TB_Password.Text.ToMD5String()));

        CommonDB.ExecuteSingleCommand(dbcb);

        Page.Response.Redirect("~/Login.aspx");
    }

    /// <summary>
    /// 取得新舊密碼是否一樣
    /// </summary>
    /// <returns>新舊密碼是否一樣</returns>
    protected bool IsPasswordSame()
    {
        string Query = @"Select Top 1 PassWord From T_Users Where AccountID = @AccountID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Users"];

        dbcb.appendParameter(Schema.Attributes["AccountID"].copy(Master.AccountID));

        object SelectObject = CommonDB.ExecuteScalar(dbcb);

        string OldPassword = string.Empty;

        if (SelectObject != null)
            OldPassword = SelectObject.ToString().Trim();

        return OldPassword == TB_Password.Text.ToMD5String();
    }
}