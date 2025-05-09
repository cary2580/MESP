using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_LableScan_M : System.Web.UI.Page
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

        HF_IsRepeat.Value = false.ToStringValue();

        if (!IsPostBack)
        {
            try
            {
                if (!string.IsNullOrEmpty(Request["ScanKey"]))
                    HF_ScanKey.Value = Request["ScanKey"].Trim();

                LoadData();
            }
            catch (Exception ex)
            {
                Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
            }
        }
    }

    /// <summary>
    /// 加载资料
    /// </summary>
    /// <returns></returns>
    protected void LoadData()
    {
        string Query = @"Select * From T_TSLableScan Where ScanKey = @ScanKey";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

        dbcb.appendParameter(Schema.Attributes["ScanKey"].copy(HF_ScanKey.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new Exception((string)GetLocalResourceObject("Str_Empty_ScanKey"));

        HF_TicketID.Value = DT.Rows[0]["TicketID"].ToString().Trim();

        HF_DeviceID.Value = DT.Rows[0]["DeviceID"].ToString().Trim();

        HF_WorkShiftID.Value = DT.Rows[0]["WorkShiftID"].ToString().Trim();

        HF_BoxNo.Value = DT.Rows[0]["BoxNo"].ToString().Trim();

        TB_OldLableID.Text = DT.Rows[0]["LableID"].ToString().Trim();
    }

    protected void BT_Update_Click(object sender, EventArgs e)
    {
        try
        {
            string Result = Util.TS.CheckScanLableIDRule(TB_NewLableID.Text.ToString().Trim());

            if (!string.IsNullOrEmpty(Result))
            {
                HF_IsRepeat.Value = true.ToStringValue();
                throw new Exception(Result);
            }

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

            string Query = @"Update T_TSLableScan Set StatusID = @StatusID , ChildLableID = @ChildLableID  Where ScanKey = @ScanKey";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["StatusID"].copy(((short)Util.TS.LableScanStatus.CancelLable).ToString()));

            dbcb.appendParameter(Schema.Attributes["ChildLableID"].copy(TB_NewLableID.Text));

            dbcb.appendParameter(Schema.Attributes["ScanKey"].copy(HF_ScanKey.Value));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Insert Into T_TSLableScan (ScanKey,TicketID,LableID,DeviceID,WorkShiftID,StatusID,BoxNo) Values (@ScanKey,@TicketID,@LableID,@DeviceID,@WorkShiftID,@StatusID,@BoxNo)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["ScanKey"].copy(BaseConfiguration.SerialObject[(short)24].取號()));

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value));

            dbcb.appendParameter(Schema.Attributes["LableID"].copy(TB_NewLableID.Text));

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value));

            dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(HF_WorkShiftID.Value));

            dbcb.appendParameter(Schema.Attributes["StatusID"].copy(((short)Util.TS.LableScanStatus.NormalLable).ToString()));

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(HF_BoxNo.Value));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false,"IsRepeat();");
        }
    }
}