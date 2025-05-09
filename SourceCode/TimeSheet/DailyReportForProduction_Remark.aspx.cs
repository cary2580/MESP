using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_DailyReportForProduction_Remark : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (Request["DivID"] != null)
                DivID = Request["DivID"].Trim();

            if (!IsPostBack)
            {
                if (Request["TaskDateTime"] != null)
                    HF_TaskDateTime.Value = Request["TaskDateTime"].Trim();
                if (Request["PVGroupID"] != null)
                    HF_PVGroupID.Value = Request["PVGroupID"].Trim();
                if (Request["ProcessTypeID"] != null)
                    HF_ProcessTypeID.Value = Request["ProcessTypeID"].Trim();

                if (string.IsNullOrEmpty(HF_TaskDateTime.Value) || string.IsNullOrEmpty(HF_PVGroupID.Value) || string.IsNullOrEmpty(HF_ProcessTypeID.Value))
                    throw new Exception((string)GetLocalResourceObject("Str_ErrorKeyValueEmpty"));

                LoadData();
            }
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select Remark From T_TSProductionTaskRemark Where TaskDateTime = @TaskDateTime And PVGroupID = @PVGroupID And ProcessTypeID = @ProcessTypeID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionTaskRemark"];

        dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(DateTime.Parse(HF_TaskDateTime.Value.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));
        dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(HF_PVGroupID.Value.Trim()));
        dbcb.appendParameter(Schema.Attributes["ProcessTypeID"].copy(HF_ProcessTypeID.Value.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            TB_Remark.Text = DT.Rows[0]["Remark"].ToString().Trim();
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            DBAction DBA = new DBAction();

            string Query = @"Delete From T_TSProductionTaskRemark Where TaskDateTime = @TaskDateTime And PVGroupID = @PVGroupID And ProcessTypeID = @ProcessTypeID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionTaskRemark"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(DateTime.Parse(HF_TaskDateTime.Value.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));
            dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(HF_PVGroupID.Value.Trim()));
            dbcb.appendParameter(Schema.Attributes["ProcessTypeID"].copy(HF_ProcessTypeID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            if (!string.IsNullOrEmpty(TB_Remark.Text.Trim()))
            {
                Query = @"Insert Into T_TSProductionTaskRemark (TaskDateTime,PVGroupID,ProcessTypeID,Remark) Values (@TaskDateTime,@PVGroupID,@ProcessTypeID,@Remark)";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(DateTime.Parse(HF_TaskDateTime.Value.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));
                dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(HF_PVGroupID.Value.Trim()));
                dbcb.appendParameter(Schema.Attributes["ProcessTypeID"].copy(HF_ProcessTypeID.Value.Trim()));
                dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true, false);
        }
    }
}