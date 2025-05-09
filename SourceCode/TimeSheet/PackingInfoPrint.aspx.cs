using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_PackingInfoPrint : System.Web.UI.Page
{
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void BT_Print_Click(object sender, EventArgs e)
    {
        try
        {
            int AccountID = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

            HF_DeviceID.Value = Util.TS.GetDeviceID(TB_MachineID.Text);

            string Query = @"Select IsPrintPackage From T_TSDevice Where DeviceID = @DeviceID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDevice"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value));

            if (!(bool)CommonDB.ExecuteScalar(dbcb))
                throw new Exception((string)GetLocalResourceObject("Str_Error_NotPrintPackageDevice"));

            Query = @"Select Top 1 *,(Select AUFNR From T_TSTicket Where T_TSTicket.TicketID = @TicketID) As AUFNR From T_TSTicketResult Where TicketID = @TicketID And DeviceID = @DeviceID And Operator = @Operator Order By CreateDate Desc";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text));
            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value));
            dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                throw new Exception((string)GetLocalResourceObject("Str_Error_NoTicketResultData"));

            string AUFNR = DT.Rows[0]["AUFNR"].ToString().Trim();
            string AUFPL = DT.Rows[0]["AUFPL"].ToString().Trim();
            string APLZL = DT.Rows[0]["APLZL"].ToString().Trim();

            Query = @"Select Top 1 PackageQty From V_TSMORouting Where AUFNR = @AUFNR And AUFPL = @AUFPL And APLZL = @APLZL";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

            dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(AUFNR, "AUFNR"));
            dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(AUFPL));
            dbcb.appendParameter(Schema.Attributes["APLZL"].copy(APLZL));

            if ((int)CommonDB.ExecuteScalar(dbcb) < 1)
                throw new Exception((string)GetLocalResourceObject("Str_Error_NotPrintPackageQty"));

            HF_ProcessID.Value = DT.Rows[0]["ProcessID"].ToString().Trim();
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);
        }
    }
}