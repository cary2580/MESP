using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketQuarantine : System.Web.UI.Page
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
            try
            {
                string TicketID = string.Empty;

                if (Request["TicketID"] != null)
                    TicketID = Request["TicketID"].Trim();

                if (string.IsNullOrEmpty(TicketID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

                HF_TicketID.Value = TicketID;

                LaodData();
            }
            catch (Exception ex)
            {
                Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LaodData()
    {
        string Query = @"Select * From T_TSTicketCurrStatus Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return;

        HF_AllowQty.Value = DT.Rows[0]["AllowQty"].ToString().Trim();
    }
}