using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TimeSheet_TicketGoIn : System.Web.UI.Page
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
            if (Request.Cookies["TS_WorkCode"] == null)
            {
                Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_WorkStationGoIn"), true, false, "window.location.href='" + ResolveClientUrl("~/TimeSheet/WorkStationGoIn.aspx") + "'");

                return;
            }

            HF_WorkShift.Value = Request.Cookies["TS_WorkShiftID"].Value.Trim();

            HF_WorkCode.Value = Request.Cookies["TS_WorkCode"].Value.Trim();

            L_Operator.Text = Request.Cookies["TS_WorkCode"].Value.Trim() + "(" + Request.Cookies["TS_AccountName"].Value.ToStringFromBase64() + ")";

            if (Request.Cookies["TS_Coefficient"] != null)
                L_Operator.Text += "(" + Request.Cookies["TS_Coefficient"].Value + ")";

            L_WorkShift.Text = Request.Cookies["TS_WorkShiftText"].Value.ToStringFromBase64();

            if (Request.Cookies["TS_MachineID"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_MachineID"].Value))
            {
                TB_MachineID.Text = Request.Cookies["TS_MachineID"].Value;

                HF_MachineID.Value = TB_MachineID.Text;
            }

            if (Request.Cookies["TS_SecondInfo"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_SecondInfo"].Value))
            {
                List<Util.TS.LoginInfo> SecondInfoList = JsonConvert.DeserializeObject<List<Util.TS.LoginInfo>>(Request.Cookies["TS_SecondInfo"].Value);

                L_SecondOperator.Text = string.Join("、", SecondInfoList.Select(Info => Info.WorkCode + "(" + Info.Coefficient.ToString() + ")").ToList());
            }
        }
    }
}