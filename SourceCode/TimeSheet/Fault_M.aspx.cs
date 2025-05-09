using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
public partial class TimeSheet_Fault_M : System.Web.UI.Page
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
            if (Request["FaultID"] != null && !string.IsNullOrEmpty(Request["FaultID"].Trim()))
            {
                TB_FaultID.Text = Request["FaultID"].ToStringFromBase64(true);

                HF_FaultID_OLD.Value = TB_FaultID.Text;

                LoadData();

                bool HaveUseFaultID = IsHaveUseFaultID();

                TB_FaultID.ReadOnly = HaveUseFaultID;

                BT_Delete.Visible = !HaveUseFaultID;
            }
            else
                BT_Delete.Visible = false;
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select Top 1 FaultName From T_TSFault Where FaultID = @FaultID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFault"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["FaultID"].copy(TB_FaultID.Text.Trim()));

        TB_FaultName.Text = CommonDB.ExecuteScalar(dbcb).ToString().Trim();
    }

    /// <summary>
    /// 取得此故障代碼是否被使用了
    /// </summary>
    /// <returns>是否被使用了</returns>
    protected bool IsHaveUseFaultID()
    {
        string Query = @"Select Count(*) From T_TSTicketMaintainFault Where FaultID = @FaultID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainFault"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["FaultID"].copy(TB_FaultID.Text.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    protected void BT_Save_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            if (IsFaultIDRepeat())
                throw new Exception((string)GetLocalResourceObject("Str_Error_FaultIDRepeat"));

            DBAction DBA = new DBAction();

            string Query = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFault"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            if (string.IsNullOrEmpty(HF_FaultID_OLD.Value))
                Query = @"Insert Into T_TSFault (FaultID,FaultName) Values (@FaultID,@FaultName)";
            else
            {
                Query = @"Update T_TSFault Set FaultID = @FaultID,FaultName = @FaultName Where FaultID = @FaultID_OLD";

                dbcb.appendParameter(Schema.Attributes["FaultID"].copy(HF_FaultID_OLD.Value.Trim(), "FaultID_OLD"));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["FaultID"].copy(TB_FaultID.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["FaultName"].copy(TB_FaultName.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            if (!string.IsNullOrEmpty(HF_FaultID_OLD.Value))
            {
                Query = @"Update T_TSFaultMapping Set FaultID = @FaultID Where FaultID = @FaultID_OLD";

                Schema = DBSchema.currentDB.Tables["T_TSFaultMapping"];

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["FaultID"].copy(TB_FaultID.Text.Trim()));

                dbcb.appendParameter(Schema.Attributes["FaultID"].copy(HF_FaultID_OLD.Value.Trim(), "FaultID_OLD"));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            bool HaveUseFaultID = IsHaveUseFaultID();

            if (HaveUseFaultID)
                throw new Exception((string)GetLocalResourceObject("Str_Error_HaveUseFaultID"));

            DBAction DBA = new DBAction();

            string Query = @"Delete T_TSFault Where FaultID = @FaultID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFault"];

            dbcb.appendParameter(Schema.Attributes["FaultID"].copy(HF_FaultID_OLD.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSFaultMapping Where FaultID = @FaultID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSFaultMapping"];

            dbcb.appendParameter(Schema.Attributes["FaultID"].copy(HF_FaultID_OLD.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }

    /// <summary>
    /// 檢查ID是否有重複
    /// </summary>
    /// <returns>ID是否有重複</returns>
    protected bool IsFaultIDRepeat()
    {
        string Query = @"Select Count(*) From T_TSFault Where FaultID = @FaultID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFault"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        dbcb.appendParameter(Schema.Attributes["FaultID"].copy(TB_FaultID.Text.Trim()));

        if (!string.IsNullOrEmpty(HF_FaultID_OLD.Value))
        {
            Query += " And FaultID <> @FaultID_OLD";

            dbcb.appendParameter(Schema.Attributes["FaultID"].copy(HF_FaultID_OLD.Value.Trim(), "FaultID_OLD"));
        }

        dbcb.CommandText = Query;

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }
}
