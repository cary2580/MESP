using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_ParametersByPower_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (!string.IsNullOrEmpty(Request["ReportDate"]))
                TB_ReportDate.Text = Request["ReportDate"].Trim();

            bool IsNewData = string.IsNullOrEmpty(TB_ReportDate.Text);

            if (!IsNewData)
                LoadData();

            HF_IsNewData.Value = IsNewData.ToStringValue();

            BT_Delete.Visible = !IsNewData;
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select * From T_TSParametersByPower Where ReportDate = @ReportDate";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSParametersByPower"];

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(TB_ReportDate.Text));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_ReportDate.Text = ((DateTime)DT.Rows[0]["ReportDate"]).ToCurrentUICultureString();
        TB_Power.Text = DT.Rows[0]["Power"].ToString().Trim();
        TB_ElectricCurrent.Text = DT.Rows[0]["ElectricCurrent"].ToString().Trim();
    }

    /// <summary>
    /// 按下儲存後動作事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void BT_Save_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            DBAction DBA = new DBAction();

            if (HF_IsNewData.Value.ToBoolean())
            {
                if (IsParametersRepeat())
                    throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_DataRepeat"));
            }

            DBA.AddCommandBuilder(GetDeleteDBCB());

            string Query = "Insert Into T_TSParametersByPower (ReportDate,Power,ElectricCurrent) Values (@ReportDate,@Power,@ElectricCurrent)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSParametersByPower"];

            DateTime ReportDate = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_ReportDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDate))
                ReportDate = DateTime.Parse("1900/01/01");

            dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(ReportDate));
            dbcb.appendParameter(Schema.Attributes["Power"].copy(TB_Power.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["ElectricCurrent"].copy(TB_ElectricCurrent.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false);

            return;
        }
    }

    /// <summary>
    /// 檢查填報日期是否重複
    /// </summary>
    /// <returns>是否重複</returns>
    protected bool IsParametersRepeat()
    {
        string Query = @"Select Count(*) From T_TSParametersByPower Where ReportDate = @ReportDate";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSParametersByPower"];

        DateTime ReportDate = DateTime.Parse("1900/01/01");

        if (!DateTime.TryParse(TB_ReportDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDate))
            ReportDate = DateTime.Parse("1900/01/01");

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(ReportDate));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }


    /// <summary>
    ///  取得删除的DBCB
    /// </summary>
    /// <returns>删除DBCB</returns>
    protected DbCommandBuilder GetDeleteDBCB()
    {
        string Query = @"Delete T_TSParametersByPower Where ReportDate = @ReportDate";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSParametersByPower"];

        DateTime ReportDate = DateTime.Parse("1900/01/01");

        if (!DateTime.TryParse(TB_ReportDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDate))
            ReportDate = DateTime.Parse("1900/01/01");

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(ReportDate));

        return dbcb;
    }

    /// <summary>
    /// 按下刪除後動作事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            DbCommandBuilder dbcb = GetDeleteDBCB();

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false);
        }
    }
}