using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class WM_PackingToInside : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
        {
            LoadData();

            RemovePackingTempData();
        }

        Page.ClientScript.RegisterStartupScript(this.GetType(), "AllowQty", "<script>var AllowQty=100000000;</script>");
    }

    protected void RemovePackingTempData()
    {
        string Query = @"Delete T_WMProductPackingListTemp Where DateDiff(Day,CreateDate,GetDate()) > 0";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        CommonDB.ExecuteSingleCommand(dbcb);
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

    }
}