using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_PlanWorkMinute_M : System.Web.UI.Page
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

        if (!IsPostBack)
        {
            LoadWorkShift();

            if (!string.IsNullOrEmpty(Request["WorkDate"]))
                TB_ReportDate.Text = Request["WorkDate"].Trim();
            if (!string.IsNullOrEmpty(Request["DeviceID"]))
                HF_DeviceID.Value = Request["DeviceID"].Trim();
            if (!string.IsNullOrEmpty(Request["WorkShiftID"]))
                HF_WorkShift.Value = Request["WorkShiftID"].Trim();

            bool IsNewData = (string.IsNullOrEmpty(Request["WorkDate"]) || string.IsNullOrEmpty(Request["DeviceID"]) || string.IsNullOrEmpty(Request["WorkShiftID"]));

            if (IsNewData)
            {
                if (!string.IsNullOrEmpty(Request["WorkCode"]))
                    TB_WorkCode.Text = Request["WorkCode"].Trim();

                if (Request.Cookies["TS_MachineID"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_MachineID"].Value))
                    TB_MachineID.Text = Request.Cookies["TS_MachineID"].Value;

                if (Request.Cookies["TS_WorkShiftID"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_WorkShiftID"].Value))
                    DDL_WorkShift.SelectedValue = Request.Cookies["TS_WorkShiftID"].Value;

                DateTime Now = DateTime.Now;

                /* 如果現在時間介於這段中，就將班別日期減一天 */
                if (Now.TimeOfDay > DateTime.Parse("00:00:00").TimeOfDay && Now.TimeOfDay < DateTime.Parse("07:20:00").TimeOfDay)
                    Now = Now.AddDays(-1);

                TB_ReportDate.Text = Now.ToCurrentUICultureString();

                BT_Delete.Visible = false;
            }
            else
            {
                TB_ReportDate.CssClass = "form-control readonly readonlyColor";

                TB_MachineID.CssClass = "form-control readonly readonlyColor";

                DDL_WorkShift.Enabled = false;

                LoadData();
            }

            HF_IsNewData.Value = IsNewData.ToStringValue();
        }
    }

    protected void LoadWorkShift()
    {
        string Query = @"Select * From T_TSWorkShift Order By SortID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_WorkShift.DataValueField = "WorkShiftID";

        DDL_WorkShift.DataTextField = "WorkShiftName";

        DDL_WorkShift.DataSource = DT;

        DDL_WorkShift.DataBind();

        DDL_WorkShift.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));

        foreach (ListItem Item in DDL_WorkShift.Items)
        {
            if (string.IsNullOrEmpty(Item.Value))
            {
                Item.Attributes.Add("data-ScheduledMinute", "0");

                continue;
            }

            Item.Attributes.Add("data-ScheduledMinute", DT.AsEnumerable().First(Row => Row["WorkShiftID"].ToString().Trim() == Item.Value)["ScheduledMinute"].ToString().Trim());
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select
                        WorkDate,
                        MachineID As MachineID,
                        WorkShiftID,
                        PlanWorkMinute
                        From T_TSPlanWorkMinute
                        Inner Join T_TSDevice On T_TSDevice.DeviceID = T_TSPlanWorkMinute.DeviceID
                        Where WorkDate = @WorkDate And T_TSPlanWorkMinute.DeviceID = @DeviceID And WorkShiftID = @WorkShiftID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSPlanWorkMinute"];

        DateTime ReportDate = DateTime.Parse("1900/01/01");

        if (!DateTime.TryParse(TB_ReportDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDate))
            ReportDate = DateTime.Parse("1900/01/01");

        dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(ReportDate));
        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value));
        dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(HF_WorkShift.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_MachineID.Text = DT.Rows[0]["MachineID"].ToString().Trim();
        DDL_WorkShift.SelectedValue = DT.Rows[0]["WorkShiftID"].ToString().Trim();
        TB_PlanWorkMinute.Text = DT.Rows[0]["PlanWorkMinute"].ToString().Trim();
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            DateTime ReportDate = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_ReportDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDate))
                ReportDate = DateTime.Parse("1900/01/01");

            if (ReportDate > DateTime.Now)
                throw new Exception((string)GetLocalResourceObject("Str_Error_ReportDate"));

            double PlanWorkMinute = 0;

            if (!double.TryParse(TB_PlanWorkMinute.Text, out PlanWorkMinute))
                throw new Exception((string)GetLocalResourceObject("Str_Error_PlanWorkMinute"));

            if (PlanWorkMinute < 1)
                throw new Exception((string)GetLocalResourceObject("Str_Error_PlanWorkMinute"));

            CheckPassword();

            int AccountID = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

            DBAction DBA = new DBAction();

            string DeviceID = HF_DeviceID.Value;

            if (HF_IsNewData.Value.ToBoolean())
            {
                DeviceID = Util.TS.GetDeviceID(TB_MachineID.Text.Trim());

                if (IsRepeat(DeviceID))
                    throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_DataRepeat"));
            }

            DBA.AddCommandBuilder(GetDeleteDBCB(DeviceID));

            string Query = @"Insert Into T_TSPlanWorkMinute (WorkDate,DeviceID,WorkShiftID,PlanWorkMinute,CreateAccountID) Values (@WorkDate,@DeviceID,@WorkShiftID,@PlanWorkMinute,@CreateAccountID)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSPlanWorkMinute"];

            dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(ReportDate));
            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
            dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(DDL_WorkShift.SelectedValue));
            dbcb.appendParameter(Schema.Attributes["PlanWorkMinute"].copy(PlanWorkMinute));
            dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();


        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false);
        }
    }

    /// <summary>
    /// 指定設備編號得到是否有重複資料
    /// </summary>
    /// <returns>是否有重複資料</returns>
    protected bool IsRepeat(string DeviceID)
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSPlanWorkMinute"];

        string Query = "Select Count(*) From T_TSPlanWorkMinute Where WorkDate = @WorkDate And DeviceID = @DeviceID And WorkShiftID = @WorkShiftID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DateTime ReportDate = DateTime.Parse("1900/01/01");

        if (!DateTime.TryParse(TB_ReportDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDate))
            ReportDate = DateTime.Parse("1900/01/01");

        dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(ReportDate));

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(DDL_WorkShift.SelectedValue));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 檢查員工帳密是否輸入正確
    /// </summary>
    protected void CheckPassword()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select Count(*) From Base_Org.dbo.V_Employee Where WorkCode = @WorkCode And [PassWord] = @PassWord And status in (0,1,2,3) And accounttype = 0");
        dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, TB_WorkCode.Text.Trim()));
        dbcb.appendParameter(Util.GetDataAccessAttribute("PassWord", "NVarChar", 1000, TB_Password.Text.ToMD5String()));

        bool PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;

        if (!PassWordIsPass)
        {
            /* 如果OA帳號密碼找不到或是不正確再找一下系統本身使用者資料表是否帳號密碼正確(但還是要比對一下OA是否已經離職了) */
            dbcb = new DbCommandBuilder("Select Count(*) From T_Users Where WorkCode = @WorkCode And [PassWord] = @PassWord");

            dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, TB_WorkCode.Text.Trim()));
            dbcb.appendParameter(Util.GetDataAccessAttribute("PassWord", "NVarChar", 1000, TB_Password.Text.ToMD5String()));
            PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;

            /* 本身系統帳密正確但還是要比對OA是否已經離職了 */
            if (PassWordIsPass)
            {
                dbcb = new DbCommandBuilder("Select Count(*) From Base_Org.dbo.V_Employee Where WorkCode = @WorkCode And status in (0,1,2,3) And accounttype = 0");
                dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, TB_WorkCode.Text.Trim()));
                PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;
            }

            if (!PassWordIsPass)
                throw new Exception((string)GetLocalResourceObject("Str_PasswordError"));
        }
    }

    /// <summary>
    /// 指定日期、設備編號、班別取得刪除DBCB
    /// </summary>
    /// <param name="DeviceID">設備編號</param>
    /// <returns>刪除DBCB</returns>
    protected DbCommandBuilder GetDeleteDBCB(string DeviceID)
    {
        string Query = @"Delete T_TSPlanWorkMinute Where WorkDate = @WorkDate And DeviceID = @DeviceID And WorkShiftID = @WorkShiftID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSPlanWorkMinute"];

        DateTime ReportDate = DateTime.Parse("1900/01/01");

        if (!DateTime.TryParse(TB_ReportDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDate))
            ReportDate = DateTime.Parse("1900/01/01");

        dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(ReportDate));
        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
        dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(DDL_WorkShift.SelectedValue));

        return dbcb;
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            CheckPassword();

            string DeviceID = HF_DeviceID.Value;

            DbCommandBuilder dbcb = GetDeleteDBCB(DeviceID);

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false);
        }
    }
}