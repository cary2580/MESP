using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_MaintainResponsible_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["ResponsibleID"] != null)
                HF_ResponsibleID.Value = Request["ResponsibleID"].Trim();

            bool IsNewData = string.IsNullOrEmpty(Request["ResponsibleID"]);

            if (!IsNewData)
                LoadData();

            HF_IsNewData.Value = IsNewData.ToStringValue();
        }
    }

    /// <summary>
    /// 载入资料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select 
                         ResponsibleID,
                         ResponsibleName,
                         SortID
                         From T_TSMaintainResponsible
                         Where ResponsibleID = @ResponsibleID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMaintainResponsible"];

        dbcb.appendParameter(Schema.Attributes["ResponsibleID"].copy(HF_ResponsibleID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_ResponsibleName.Text = DT.Rows[0]["ResponsibleName"].ToString().Trim();
        TB_SortID.Text = DT.Rows[0]["SortID"].ToString().Trim();
    }

    /// <summary>
    /// 新增和修改事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void BT_Save_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (IsMaintainResponsiblenRepeat())
                throw new Exception((string)GetLocalResourceObject("Str_Error_MaintainResponsiblenRepeat"));

            string Query = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMaintainResponsible"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            if (HF_IsNewData.Value.ToBoolean())
            {
                string ResponsibleID = BaseConfiguration.SerialObject[(short)27].取號();

                Query = @"Insert Into T_TSMaintainResponsible (ResponsibleID,ResponsibleName,SortID) Values (@ResponsibleID,@ResponsibleName,@SortID)";

                dbcb.appendParameter(Schema.Attributes["ResponsibleID"].copy(ResponsibleID));
            }
            else
            {
                Query = @"Update T_TSMaintainResponsible Set ResponsibleName = @ResponsibleName,SortID = @SortID Where ResponsibleID = @ResponsibleID";

                dbcb.appendParameter(Schema.Attributes["ResponsibleID"].copy(HF_ResponsibleID.Value));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["ResponsibleName"].copy(TB_ResponsibleName.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["SortID"].copy(TB_SortID.Text.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true);

            return;
        }
    }

    /// <summary>
    /// 维修责任归属名称是否重复
    /// </summary>
    /// <returns>是否重新</returns>
    protected bool IsMaintainResponsiblenRepeat()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMaintainResponsible"];

        string Query = @"Select Count(*) From T_TSMaintainResponsible Where ResponsibleName = @ResponsibleName And ResponsibleID <> @ResponsibleID";

        dbcb.CommandText = Query;

        dbcb.appendParameter(Schema.Attributes["ResponsibleName"].copy(TB_ResponsibleName.Text.Trim()));

        dbcb.appendParameter(Schema.Attributes["ResponsibleID"].copy(HF_ResponsibleID.Value));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 删除按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (IsMaintainResponsibleUsed())
                throw new Exception((string)GetLocalResourceObject("Str_Error_MaintainResponsibleUsed"));

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMaintainResponsible"];

            string Query = @"Delete From T_TSMaintainResponsible Where ResponsibleID = @ResponsibleID";

            DbCommandBuilder dbcb = new DbCommandBuilder();      

            dbcb.appendParameter(Schema.Attributes["ResponsibleID"].copy(HF_ResponsibleID.Value));

            dbcb.CommandText = Query;

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false);
        }
    }

    /// <summary>
    /// 维修责任归属名称是否使用过
    /// </summary>
    /// <returns>是否能删除</returns>
    protected bool IsMaintainResponsibleUsed()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainResponsible"];

        string Query = @"Select Count(*) From T_TSTicketMaintainResponsible Where ResponsibleID = @ResponsibleID";

        dbcb.CommandText = Query;

        dbcb.appendParameter(Schema.Attributes["ResponsibleID"].copy(HF_ResponsibleID.Value));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }
}