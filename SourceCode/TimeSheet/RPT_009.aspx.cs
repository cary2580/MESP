using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using System.Data;

public partial class TimeSheet_RPT_009 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        TB_ReportDateStart.Text = DateTime.Now.AddDays(-1).ToCurrentUICultureString();

        TB_ReportDateEnd.Text = TB_ReportDateStart.Text;

        if (!IsPostBack)
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
}