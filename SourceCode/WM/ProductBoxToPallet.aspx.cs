using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class WM_ProductBoxToPallet : System.Web.UI.Page
{
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadData();
    }

    protected void LoadData()
    {
        string Query = @"Select * From T_SAPT001L";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT_Warehouse = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_LGORT.DataValueField = "LGORT";

        DDL_LGORT.DataTextField = "LGOBE";

        DDL_LGORT.DataSource = DT_Warehouse;

        DDL_LGORT.DataBind();

        DDL_LGORT.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));

        Query = @"Select * From T_WMDeliveryLocation Order by SortID";

        dbcb = new DbCommandBuilder(Query);

        DataTable DT_DeliveryLocation = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_DeliveryLocation.DataValueField = "LocationID";

        DDL_DeliveryLocation.DataTextField = "LocationName";

        DDL_DeliveryLocation.DataSource = DT_DeliveryLocation;

        DDL_DeliveryLocation.DataBind();

        DDL_DeliveryLocation.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }
}