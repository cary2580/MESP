using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_Defect_M : System.Web.UI.Page
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
            if (Request["DefectID"] != null && !string.IsNullOrEmpty(Request["DefectID"].Trim()))
            {
                TB_DefectID.Text = Request["DefectID"].ToStringFromBase64(true);

                HF_DefectID_OLD.Value = TB_DefectID.Text;

                LoadData();

                bool HaveUseDefectID = IsHaveUseDefectID();

                TB_DefectID.ReadOnly = HaveUseDefectID;

                BT_Delete.Visible = !HaveUseDefectID;
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
        string Query = @"Select Top 1 DefectName,IsEnable From T_TSDefect Where DefectID = @DefectID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDefect"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DefectID"].copy(TB_DefectID.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            TB_DefectName.Text = DT.Rows[0]["DefectName"].ToString().Trim();

            DDL_IsEnable.SelectedValue = ((bool)DT.Rows[0]["IsEnable"]).ToStringValue();
        }
    }

    /// <summary>
    /// 取得此缺陷代碼是否被使用了
    /// </summary>
    /// <returns>是否被使用了</returns>
    protected bool IsHaveUseDefectID()
    {
        string Query = @"Select Count(*) From T_TSTicketQuarantineResultItem Where DefectID = @DefectID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResultItem"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DefectID"].copy(TB_DefectID.Text.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    protected void BT_Create_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            if (IsDefectIDRepeat())
                throw new Exception((string)GetLocalResourceObject("Str_Error_DefectIDRepeat"));

            DBAction DBA = new DBAction();

            string Query = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDefect"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            if (string.IsNullOrEmpty(HF_DefectID_OLD.Value))
                Query = @"Insert Into T_TSDefect (DefectID,DefectName,IsEnable) Values (@DefectID,@DefectName,@IsEnable)";
            else
            {
                Query = @"Update T_TSDefect Set DefectID = @DefectID,DefectName = @DefectName,IsEnable = @IsEnable Where DefectID = @DefectID_OLD";

                dbcb.appendParameter(Schema.Attributes["DefectID"].copy(HF_DefectID_OLD.Value.Trim(), "DefectID_OLD"));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["DefectID"].copy(TB_DefectID.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["DefectName"].copy(TB_DefectName.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["IsEnable"].copy(DDL_IsEnable.SelectedValue));

            DBA.AddCommandBuilder(dbcb);

            if (!string.IsNullOrEmpty(HF_DefectID_OLD.Value))
            {
                Query = @"Update T_TSScrapReasonMappingDefect Set DefectID = @DefectID Where DefectID = @DefectID_OLD";

                Schema = DBSchema.currentDB.Tables["T_TSScrapReasonMappingDefect"];

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["DefectID"].copy(TB_DefectID.Text.Trim()));

                dbcb.appendParameter(Schema.Attributes["DefectID"].copy(HF_DefectID_OLD.Value.Trim(), "DefectID_OLD"));

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
            bool HaveUseDefectID = IsHaveUseDefectID();

            if (HaveUseDefectID)
                throw new Exception((string)GetLocalResourceObject("Str_Error_HaveUseDefectID"));

            DBAction DBA = new DBAction();

            string Query = @"Delete T_TSDefect Where DefectID = @DefectID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDefect"];

            dbcb.appendParameter(Schema.Attributes["DefectID"].copy(HF_DefectID_OLD.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSScrapReasonMappingDefect Where DefectID = @DefectID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSScrapReasonMappingDefect"];

            dbcb.appendParameter(Schema.Attributes["DefectID"].copy(HF_DefectID_OLD.Value.Trim()));

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
    protected bool IsDefectIDRepeat()
    {
        string Query = @"Select Count(*) From T_TSDefect Where DefectID = @DefectID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDefect"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        dbcb.appendParameter(Schema.Attributes["DefectID"].copy(TB_DefectID.Text.Trim()));

        if (!string.IsNullOrEmpty(HF_DefectID_OLD.Value))
        {
            Query += " And DefectID <> @DefectID_OLD";

            dbcb.appendParameter(Schema.Attributes["DefectID"].copy(HF_DefectID_OLD.Value.Trim(), "DefectID_OLD"));
        }

        dbcb.CommandText = Query;

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }
}