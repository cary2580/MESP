using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class WM_PackingToOutside : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
            RemovePackingTempData();
    }

    protected void RemovePackingTempData()
    {
        string Query = @"Delete T_WMProductPackingListTemp Where DateDiff(Day,CreateDate,GetDate()) > 0";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        CommonDB.ExecuteSingleCommand(dbcb);
    }
}