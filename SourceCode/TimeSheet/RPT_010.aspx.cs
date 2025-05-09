using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_RPT_010 : System.Web.UI.Page
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
            LoadWorkShift();

            LoadMachine();

            if (Request.Cookies["TS_MachineID"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_MachineID"].Value))
                DDL_Machine.SelectedValue = Request.Cookies["TS_MachineID"].Value;

            if (Request.Cookies["TS_WorkShiftID"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_WorkShiftID"].Value))
                DDL_WorkShift.SelectedValue = Request.Cookies["TS_WorkShiftID"].Value;
        }
    }

    protected void LoadWorkShift()
    {
        string Query = @"Select * From T_TSWorkShift Order By SortID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_WorkShift.DataValueField = "WorkShiftID";

        DDL_WorkShift.DataTextField = "WorkShiftName";

        DDL_WorkShift.DataSource = DT;

        DDL_WorkShift.DataBind();

        DDL_WorkShift.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }

    protected void LoadMachine()
    {
        string Query = @"Select MachineID,MachineName From T_TSDevice Where DeviceID Not Like 'X%' Order By MachineName Desc";

        DataTable DT = CommonDB.ExecuteSelectQuery(Query);

        DDL_Machine.DataValueField = "MachineID";

        DDL_Machine.DataTextField = "MachineName";

        DDL_Machine.DataSource = DT;

        DDL_Machine.DataBind();

        DDL_Machine.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }
}