using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ViewOnlineAccount : System.Web.UI.Page
{
    protected object ResponseData = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!Master.IsAdmin)
            Response.Redirect("~/Index.aspx");

        if (!IsPostBack)
        {
            if (!Master.IsAdmin)
            {
                Context.Items.Add("MessageString", (string)GetGlobalResourceObject("GlobalRes", "Str_NoPermissionAlertString"));

                Server.Transfer("~/NoPermission.aspx", true);

                return;
            }

            ShowList();
        }
    }

    protected void ShowList()
    {
        List<string> ColumnList = new List<string>() { "ColumnName1", "ColumnName2", "ColumnName3", "ColumnName4", "ColumnName5", "ColumnName6", "ColumnName7" };

        ResponseData = new
        {
            colModel = ColumnList.Select(ColumnName => new
            {
                name = ColumnName,
                index = ColumnName,
                label = (string)GetLocalResourceObject("Str_List1" + ColumnName),
                align = GetListAlign(ColumnName)
            }),

            Rows = BaseConfiguration.OnlineAccount.Select(Item => new
            {
                ColumnName1 = Item.Value.AccountID,
                ColumnName2 = Item.Value.WorkCode,
                ColumnName3 = Item.Value.AccountName,
                ColumnName4 = Item.Value.LoginTime.ToCurrentUICultureStringTime(),
                ColumnName5 = Item.Value.LastActionTime.ToCurrentUICultureStringTime(),
                ColumnName6 = Item.Value.LastActionAbsolutePath,
                ColumnName7 = Item.Value.LastActionIP
            }).OrderByDescending(Item => Item.ColumnName5)

        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + false.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
    }

    protected string GetLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ColumnName6":
                return "left";
            default:
                return "center";
        }
    }

    protected string GetListAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ColumnName6":
                return "left";
            default:
                return "center";
        }
    }
}