using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;


public partial class TimeSheet_ProcessDeviceGroup_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["PLNNR"] != null)
                HF_PLNNR.Value = Request["PLNNR"].Trim();
            if (Request["PLNAL"] != null)
                HF_PLNAL.Value = Request["PLNAL"].Trim();
            if (Request["PLNKN"] != null)
                HF_PLNKN.Value = Request["PLNKN"].Trim();
            if (Request["ProcessID"] != null)
                HF_ProcessID.Value = Request["ProcessID"].Trim();

            try
            {
                LoadData();
            }
            catch (Exception ex)
            {
                Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
            }
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select Top 1 DeviceGroupID From T_TSProcessDeviceGroup Where PLNNR = @PLNNR And PLNAL = @PLNAL And PLNKN = @PLNKN And ProcessID = @ProcessID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProcessDeviceGroup"];

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(HF_PLNNR.Value));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(HF_PLNAL.Value));
        dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(HF_PLNKN.Value));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            TB_DeviceGroupID.Text = DT.Rows[0]["DeviceGroupID"].ToString().Trim();

        Query = @"Select Top 1 * From V_TSProcess Where PLNNR = @PLNNR And PLNAL = @PLNAL And PLNKN = @PLNKN";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(HF_PLNNR.Value));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(HF_PLNAL.Value));
        dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(HF_PLNKN.Value));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new Exception((string)GetLocalResourceObject("Str_Empty_VORNR"));

        HF_VORNR.Value = DT.Rows[0]["VORNR"].ToString().Trim();
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            string Query = @"Select Count(*) From T_TSDeviceGroup Where DeviceGroupID = @DeviceGroupID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceGroup"];

            dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(TB_DeviceGroupID.Text.Trim()));

            if ((int)CommonDB.ExecuteScalar(dbcb) < 1)
                throw new Exception((string)GetLocalResourceObject("Str_Error_NoDeviceGroupID"));

            DBAction DBA = new DBAction();

            Query = @"Delete T_TSProcessDeviceGroup Where PLNNR = @PLNNR And PLNAL = @PLNAL And PLNKN = @PLNKN And ProcessID = @ProcessID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSProcessDeviceGroup"];

            dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(HF_PLNNR.Value));
            dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(HF_PLNAL.Value));
            dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(HF_PLNKN.Value));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

            DBA.AddCommandBuilder(dbcb);

            Query = "Insert Into T_TSProcessDeviceGroup (PLNNR,PLNAL,PLNKN,ProcessID,VORNR,DeviceGroupID) Values (@PLNNR,@PLNAL,@PLNKN,@ProcessID,@VORNR,@DeviceGroupID)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(HF_PLNNR.Value));
            dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(HF_PLNAL.Value));
            dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(HF_PLNKN.Value));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));
            dbcb.appendParameter(Schema.Attributes["VORNR"].copy(HF_VORNR.Value));
            dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(TB_DeviceGroupID.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}