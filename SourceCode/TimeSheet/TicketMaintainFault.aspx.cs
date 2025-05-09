using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketMaintainFault : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["MaintainID"] != null)
                HF_MaintainID.Value = Request["MaintainID"].Trim();
            if (Request["PLNBEZ"] != null)
                HF_PLNBEZ.Value = Request["PLNBEZ"].Trim();

            LoadDDL();
        }
    }

    protected void LoadDDL()
    {
        string Query = @"Select 
                        T_TSFaultCategory.FaultCategoryID,
                        T_TSFaultCategory.FaultCategoryName
                        From T_TSFaultCategory Inner Join T_TSFaultMappingPLNBEZ On T_TSFaultCategory.FaultCategoryID = T_TSFaultMappingPLNBEZ.FaultCategoryID
                        Where T_TSFaultMappingPLNBEZ.PLNBEZ = @PLNBEZ";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultMappingPLNBEZ"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNBEZ"].copy(HF_PLNBEZ.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_FaultCategory.DataValueField = "FaultCategoryID";

        DDL_FaultCategory.DataTextField = "FaultCategoryName";

        DDL_FaultCategory.DataSource = DT;

        DDL_FaultCategory.DataBind();

        DDL_FaultCategory.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }
}