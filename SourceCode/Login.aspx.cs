using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;

public partial class Login : System.Web.UI.Page
{
    protected override void OnInitComplete(EventArgs e)
    {
        Page.Header.DataBind();

        base.OnInitComplete(e);
    }

    protected override void InitializeCulture()
    {
        if (Request.Cookies["langCookie"] == null && HttpContext.Current != null && HttpContext.Current.Request.UserLanguages != null)
        {
            if (!HttpContext.Current.Request.UserLanguages[0].Contains("zh"))
                Page.UICulture = "en-US";
            else
                Page.UICulture = "auto";
        }

        Page.UICulture = BaseConfiguration.DefaultCultureInfo;

        base.InitializeCulture();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DocumentID"] != null && !string.IsNullOrEmpty(Request["DocumentID"].Trim()))
            Page.ClientScript.RegisterHiddenField("DocumentID", Request["DocumentID"].Trim());

        if (Request["ViewDocumentReject"] != null && Request["ViewDocumentReject"].ToBoolean())
            Page.ClientScript.RegisterHiddenField("ViewDocumentReject", "1");

        if (!IsPostBack && Request.UrlReferrer != null && Request["AccountID"] != null && !string.IsNullOrEmpty(Request["AccountID"].Trim()))
        {
            if (BaseConfiguration.SingleSignOnDnsSafeHost.Contains(Request.UrlReferrer.DnsSafeHost))
            {
                TB_Account.Text = Request["AccountID"].Trim();

                SetDefaultSelectLanguage();

                TB_IsSingleSignOn.Value = true.ToStringValue();
            }
            else
                TB_PassWord.Attributes.Add("required", "required");
        }
        else
            TB_PassWord.Attributes.Add("required", "required");

        if (Request.Cookies["langCookie"] != null)
            SL_Language.SelectedValue = Request.Cookies["langCookie"].Value;
        else if (!HttpContext.Current.Request.UserLanguages[0].Contains("zh"))
            SL_Language.SelectedValue = "pl";
        else
        {
            foreach (string Languages in HttpContext.Current.Request.UserLanguages)
            {
                ListItem Itme = SL_Language.Items.FindByValue(Languages);

                if (Itme != null)
                {
                    SL_Language.SelectedValue = Itme.Value;

                    break;
                }
            }
        }
    }

    /// <summary>
    /// 設定預設選擇語系代碼
    /// </summary>
    protected void SetDefaultSelectLanguage()
    {
        try
        {
            string Query = @"Select top 1 systemlanguage From " + BaseConfiguration.OADataBaseName + " .dbo.HrmResource Where workcode = @workcode";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Util.GetDataAccessAttribute("workcode", "Nvarchar", 50, TB_Account.Text));

            int systemlanguage = (int)CommonDB.ExecuteScalar(dbcb);

            switch (systemlanguage)
            {
                case 9:
                    SL_Language.SelectedValue = "zh-TW";
                    break;
                case 8:
                    SL_Language.SelectedValue = "pl";
                    break;
                case 7:
                    SL_Language.SelectedValue = "zh-CN";
                    break;
            }
        }
        catch (Exception ex)
        {

        }
    }
}