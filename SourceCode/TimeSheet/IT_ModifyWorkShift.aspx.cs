using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;


public partial class TimeSheet_IT_ModifyWorkShift : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected List<TicketResultKey> TicketResultKeyList = new List<TicketResultKey>();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            Util.TS.LoadDDLWorkShift(DDL_WorkShift, false);

            if (Request["SelectedList"] != null)
                HF_ResultKeyData.Value = Request["SelectedList"].Trim();

            if (string.IsNullOrEmpty(HF_ResultKeyData.Value))
                Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_SelectTicketResultKey"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
    }

    /// <summary>
    /// 修改确认事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void BT_Confirm_Click(object sender, EventArgs e)
    {
        try
        {
            TicketResultKeyList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<TicketResultKey>>(HF_ResultKeyData.Value);

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

            foreach (TicketResultKey TicketResultKey in TicketResultKeyList)
            {
                string Query = @"Update T_TSTicketResult 
                                 Set WorkShiftID = @WorkShiftID,ReportDate = dbo.TS_GetReportDate(ReportTimeEnd,'@WorkShiftID')
                                 Where TicketID = @TicketID And ProcessID = @ProcessID And SerialNo = @SerialNo";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(DDL_WorkShift.SelectedValue));

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketResultKey.TicketID));

                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(TicketResultKey.ProcessID));

                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(TicketResultKey.SerialNo));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true);
        }
    }

    /// <summary>
    /// 流程卡结果Key值类
    /// </summary>
    protected class TicketResultKey
    {
        public string TicketID { get; set; }

        public int ProcessID { get; set; }

        public short SerialNo { get; set; }
    }
}