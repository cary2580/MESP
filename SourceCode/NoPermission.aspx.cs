using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class NoPermission : System.Web.UI.Page
{
    protected string MessageString = string.Empty;

    protected string NewPageUrl = string.Empty;

    protected override void OnInitComplete(EventArgs e)
    {
        Page.Header.DataBind();

        base.OnInitComplete(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Context.Items["MessageString"] != null)
            MessageString = Context.Items["MessageString"].ToString().Trim();

        if (Context.Items["NewPageUrl"] != null)
            NewPageUrl = Context.Items["NewPageUrl"].ToString().Trim();

        if (string.IsNullOrEmpty(NewPageUrl))
            NewPageUrl = "window.location.href='" + ResolveClientUrl(@"~/Index.aspx") + "'";

        if (!string.IsNullOrEmpty(MessageString))
            Util.RegisterStartupScriptJqueryAlert(Page, MessageString, true, true, NewPageUrl);
        else
            Response.Redirect("~/Index.aspx");
    }
}