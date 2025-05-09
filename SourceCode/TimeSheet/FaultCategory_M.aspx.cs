using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
public partial class TimeSheet_FaultCategory_M : System.Web.UI.Page
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
            if (Request["FaultCategoryID"] != null && !string.IsNullOrEmpty(Request["FaultCategoryID"].Trim()))
            {
                TB_FaultCategoryID.Text = Request["FaultCategoryID"].ToStringFromBase64(true);

                HF_FaultCategoryID_OLD.Value = TB_FaultCategoryID.Text;

                LoadData();

                bool HaveUseFaultCategoryID = IsHaveUseFaultCategoryID();

                TB_FaultCategoryID.ReadOnly = HaveUseFaultCategoryID;

                BT_Delete.Visible = !HaveUseFaultCategoryID;
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
        string Query = @"Select Top 1 FaultCategoryName From T_TSFaultCategory Where FaultCategoryID = @FaultCategoryID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultCategory"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(TB_FaultCategoryID.Text.Trim()));

        TB_FaultCategoryName.Text = CommonDB.ExecuteScalar(dbcb).ToString().Trim();
    }

    /// <summary>
    /// 取得此故障代碼是否被使用了
    /// </summary>
    /// <returns>是否被使用了</returns>
    protected bool IsHaveUseFaultCategoryID()
    {
        string Query = @"Select Count(*) From T_TSTicketMaintainFault Where FaultCategoryID = @FaultCategoryID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainFault"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(TB_FaultCategoryID.Text.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    protected void BT_Save_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            if (IsFaultCategoryIDRepeat())
                throw new Exception((string)GetLocalResourceObject("Str_Error_FaultCategoryIDRepeat"));

            DBAction DBA = new DBAction();

            string Query = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultCategory"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            if (string.IsNullOrEmpty(HF_FaultCategoryID_OLD.Value))
                Query = @"Insert Into T_TSFaultCategory (FaultCategoryID,FaultCategoryName) Values (@FaultCategoryID,@FaultCategoryName)";
            else
            {
                Query = @"Update T_TSFaultCategory Set FaultCategoryID = @FaultCategoryID,FaultCategoryName = @FaultCategoryName Where FaultCategoryID = @FaultCategoryID_OLD";

                dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID_OLD.Value.Trim(), "FaultCategoryID_OLD"));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(TB_FaultCategoryID.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["FaultCategoryName"].copy(TB_FaultCategoryName.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            if (!string.IsNullOrEmpty(HF_FaultCategoryID_OLD.Value))
            {
                Query = @"Update T_TSFaultMapping Set FaultCategoryID = @FaultCategoryID Where FaultCategoryID = @FaultCategoryID_OLD";

                Schema = DBSchema.currentDB.Tables["T_TSFaultMapping"];

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(TB_FaultCategoryID.Text.Trim()));

                dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID_OLD.Value.Trim(), "FaultCategoryID_OLD"));

                DBA.AddCommandBuilder(dbcb);

                Query = @"Update T_TSFaultMappingPLNBEZ Set FaultCategoryID = @FaultCategoryID Where FaultCategoryID = @FaultCategoryID_OLD";

                Schema = DBSchema.currentDB.Tables["T_TSFaultMappingPLNBEZ"];

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(TB_FaultCategoryID.Text.Trim()));

                dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID_OLD.Value.Trim(), "FaultCategoryID_OLD"));

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
            bool HaveUseFaultCategoryID = IsHaveUseFaultCategoryID();

            if (HaveUseFaultCategoryID)
                throw new Exception((string)GetLocalResourceObject("Str_Error_HaveUseFaultCategoryID"));

            DBAction DBA = new DBAction();

            string Query = @"Delete T_TSFaultCategory Where FaultCategoryID = @FaultCategoryID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultCategory"];

            dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID_OLD.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSFaultMapping Where FaultCategoryID = @FaultCategoryID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSFaultMapping"];

            dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID_OLD.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSFaultMappingPLNBEZ Where FaultCategoryID = @FaultCategoryID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSFaultMappingPLNBEZ"];

            dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID_OLD.Value.Trim()));

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
    protected bool IsFaultCategoryIDRepeat()
    {
        string Query = @"Select Count(*) From T_TSFaultCategory Where FaultCategoryID = @FaultCategoryID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultCategory"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(TB_FaultCategoryID.Text.Trim()));

        if (!string.IsNullOrEmpty(HF_FaultCategoryID_OLD.Value))
        {
            Query += " And FaultCategoryID <> @FaultCategoryID_OLD";

            dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID_OLD.Value.Trim(), "FaultCategoryID_OLD"));
        }

        dbcb.CommandText = Query;

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }
}
