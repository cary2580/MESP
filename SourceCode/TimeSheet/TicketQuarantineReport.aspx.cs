using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketQuarantineReport : System.Web.UI.Page
{
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadData();
        }
    }

    protected void LoadData()
    {
        string Query = @"Select ScrapReasonID,ScrapReasonName From T_TSScrapReason";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_ScrapReason.DataValueField = "ScrapReasonID";

        DDL_ScrapReason.DataTextField = "ScrapReasonName";

        DDL_ScrapReason.DataSource = DT;

        DDL_ScrapReason.DataBind();

        DDL_ScrapReason.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }
}