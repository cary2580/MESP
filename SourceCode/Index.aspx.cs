using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;


public partial class Index : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (BaseConfiguration.OnlineAccount.ContainsKey(Master.AccountID) && !BaseConfiguration.OnlineAccount[Master.AccountID].IsHaveOAAccount && !GetIsChangePassword())
        {
            Page.Response.Redirect("~/ChangePassword.aspx");
            return;
        }
    }

    protected bool GetIsChangePassword()
    {
        bool Result = false;

        string Query = @"Select IsChangePassword From T_Users Where AccountID = @AccountID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Users"];

        dbcb.appendParameter(Schema.Attributes["AccountID"].copy(Master.AccountID));

        object Value = CommonDB.ExecuteScalar(dbcb);

        if (Value != null)
            Result = (bool)Value;

        return Result;
    }
}