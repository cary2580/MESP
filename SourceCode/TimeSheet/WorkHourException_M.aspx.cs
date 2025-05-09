using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_WorkHourException_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            LoadSectionName();

            if (!string.IsNullOrEmpty(Request["WorkDate"]))
                TB_WorkDate.Text = Request["WorkDate"].Trim();
            if (!string.IsNullOrEmpty(Request["SectionID"]))
                HF_SectionID.Value = Request["SectionID"].Trim();

            bool IsNewData = (string.IsNullOrEmpty(Request["WorkDate"]) || string.IsNullOrEmpty(Request["SectionID"]));

            if (IsNewData)
            {
                if (!string.IsNullOrEmpty(Request["WorkDate"]))
                    TB_WorkDate.Text = Request["WorkDate"].Trim();

                if (Request.Cookies["TS_SectionID"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_SectionID"].Value))
                    DDL_SectionID.SelectedValue = Request.Cookies["TS_SectionID"].Value;

                TB_WorkDate.Text = DateTime.Now.ToCurrentUICultureString();

                BT_Delete.Visible = false;
            }
            else
            {
                TB_WorkDate.CssClass = "form-control readonly readonlyColor";

                DDL_SectionID.Enabled = false;

                LoadData();
            }

            HF_IsNewData.Value = IsNewData.ToStringValue();
        }
    }

    /// <summary>
    /// 载入课级部门资料
    /// </summary>
    private void LoadSectionName()
    {
        string Query = "Select SectionID,SectionName From V_TSSection Order By SortID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_SectionID.DataValueField = "SectionID";

        DDL_SectionID.DataTextField = "SectionName";

        DDL_SectionID.DataSource = DT;

        DDL_SectionID.DataBind();

        DDL_SectionID.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }

    protected void BT_Save_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            DBAction DBA = new DBAction();

            if (HF_IsNewData.Value.ToBoolean())
            {
                if (IsWorkHoursExceptionRepeat())
                    throw new Exception((string)GetLocalResourceObject("Str_Error_WorkHoursExceptionRepeat"));
            }

            DBA.AddCommandBuilder(GetDeleteDBCB());

            string Query = "Insert Into T_TSWorkHourException (WorkDate,SectionID,IIPHour,SampleHour,BorrowHour,Remark) Values(@WorkDate,@SectionID,@IIPHour,@SampleHour,@BorrowHour,@Remark)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSWorkHourException"];

            DateTime WorkDate = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_WorkDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out WorkDate))
                WorkDate = DateTime.Parse("1900/01/01");

            dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(WorkDate));
            dbcb.appendParameter(Schema.Attributes["SectionID"].copy(DDL_SectionID.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["IIPHour"].copy(TB_IIPHour.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["SampleHour"].copy(TB_SampleHour.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["BorrowHour"].copy(TB_BorrowHour.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true);

            return;
        }
    }

    /// <summary>
    /// 非计件转出工时是否重复
    /// </summary>
    /// <returns>是否重新</returns>
    protected bool IsWorkHoursExceptionRepeat()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSWorkHourException"];

        string Query = @"Select Count(*) From T_TSWorkHourException Where WorkDate = @WorkDate And SectionID = @SectionID";

        dbcb.CommandText = Query;

        DateTime WorkDate = DateTime.Parse("1900/01/01");

        if (!DateTime.TryParse(TB_WorkDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out WorkDate))
            WorkDate = DateTime.Parse("1900/01/01");

        dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(WorkDate));

        dbcb.appendParameter(Schema.Attributes["SectionID"].copy(DDL_SectionID.SelectedValue.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 载入资料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select 
                         WorkDate,
                         SectionID,
	                     IIPHour,
	                     SampleHour,
	                     BorrowHour,
	                     Remark
                         From T_TSWorkHourException
                         Where WorkDate = @WorkDate And SectionID = @SectionID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSWorkHourException"];

        dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(TB_WorkDate.Text));
        dbcb.appendParameter(Schema.Attributes["SectionID"].copy(HF_SectionID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_WorkDate.Text = ((DateTime)DT.Rows[0]["WorkDate"]).ToCurrentUICultureString();
        DDL_SectionID.SelectedValue = DT.Rows[0]["SectionID"].ToString().Trim();
        TB_IIPHour.Text = DT.Rows[0]["IIPHour"].ToString().Trim();
        TB_SampleHour.Text = DT.Rows[0]["SampleHour"].ToString().Trim();
        TB_BorrowHour.Text = DT.Rows[0]["BorrowHour"].ToString().Trim();
        TB_Remark.Text = DT.Rows[0]["Remark"].ToString().Trim();
    }


    /// <summary>
    /// 指定日期和课别删除DBCB
    /// </summary>
    /// <param name="DeviceID"></param>
    /// <returns></returns>
    protected DbCommandBuilder GetDeleteDBCB()
    {
        string Query = @"Delete T_TSWorkHourException Where WorkDate = @WorkDate And SectionID = @SectionID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSWorkHourException"];

        DateTime WorkDate = DateTime.Parse("1900/01/01");

        if (!DateTime.TryParse(TB_WorkDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out WorkDate))
            WorkDate = DateTime.Parse("1900/01/01");

        dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(WorkDate));
        dbcb.appendParameter(Schema.Attributes["SectionID"].copy(DDL_SectionID.SelectedValue));

        return dbcb;
    }

    /// <summary>
    /// 删除资料
    /// </summary>
    /// <param name="sender">删除按钮</param>
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