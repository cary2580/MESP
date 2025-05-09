using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_RPT_022 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            LoadData();
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

        Query = "Select GroupID,GroupName From T_TSMATNRGroup Group By GroupID,GroupName,SortID Order By SortID";

        dbcb = new DbCommandBuilder(Query);

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_Group.DataValueField = "GroupID";

        DDL_Group.DataTextField = "GroupName";

        DDL_Group.DataSource = DT;

        DDL_Group.DataBind();

        DDL_Group.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }
}