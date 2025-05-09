using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_WorkStationGoIn : System.Web.UI.Page
{
    protected int AccountID = -1;

    protected string DeviceID = string.Empty;

    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Request.Cookies["TS_WorkCode"] != null || Request.Cookies["TS_WorkShiftID"] != null || Request.Cookies["TS_WorkShiftText"] != null)
            {
                Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_GoOut"), true, false, "window.location.href='" + ResolveClientUrl("~/TimeSheet/WorkStationGoOut.aspx") + "'");

                return;
            }

            Util.TS.LoadDDLWorkShift(DDL_WorkShift, false);
        }
        else
            Util.TS.SetDDLItemColor(DDL_WorkShift, 1);
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            AccountID = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            string AccountName = GetAccountName(AccountID);

            CheckMachineRule();

            List<Util.TS.LoginInfo> LI = new List<Util.TS.LoginInfo>();

            int SecondAccountID = 0;

            string SecondAccountName = string.Empty;

            double Coefficient = -1;

            List<string> WorkCodeSecondList = new List<string>();

            if (!string.IsNullOrEmpty(TB_WorkCodeSecond1.Text.Trim()))
            {
                if (TB_WorkCodeSecond1.Text.Trim() == TB_WorkCode.Text.Trim())
                    throw new Exception((string)GetLocalResourceObject("Str_WorkCodeRepeat"));

                SecondAccountID = BaseConfiguration.GetAccountID(TB_WorkCodeSecond1.Text.Trim());

                if (SecondAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(SecondAccountID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                SecondAccountName = GetAccountName(SecondAccountID);

                if (!string.IsNullOrEmpty(SecondAccountName))
                    SecondAccountName = SecondAccountName.ToBase64String();

                if (string.IsNullOrEmpty(DDL_SecondCoefficient1.SelectedValue))
                    throw new Exception((string)GetLocalResourceObject("Str_Empty_Coefficient"));

                Coefficient = double.Parse(DDL_SecondCoefficient1.SelectedValue);

                LI.Add(new Util.TS.LoginInfo { WorkCode = TB_WorkCodeSecond1.Text.Trim(), AccountID = SecondAccountID, AccountName = SecondAccountName, Coefficient = Coefficient });

                WorkCodeSecondList.Add(TB_WorkCodeSecond1.Text.Trim());
            }

            if (!string.IsNullOrEmpty(TB_WorkCodeSecond2.Text.Trim()))
            {
                if (WorkCodeSecondList.Contains(TB_WorkCodeSecond2.Text.Trim()) || TB_WorkCodeSecond2.Text.Trim() == TB_WorkCode.Text.Trim())
                    throw new Exception((string)GetLocalResourceObject("Str_WorkCodeRepeat"));

                SecondAccountID = BaseConfiguration.GetAccountID(TB_WorkCodeSecond2.Text.Trim());

                if (SecondAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(SecondAccountID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                SecondAccountName = GetAccountName(SecondAccountID);

                if (!string.IsNullOrEmpty(SecondAccountName))
                    SecondAccountName = SecondAccountName.ToBase64String();

                if (string.IsNullOrEmpty(DDL_SecondCoefficient2.SelectedValue))
                    throw new Exception((string)GetLocalResourceObject("Str_Empty_Coefficient"));

                Coefficient = double.Parse(DDL_SecondCoefficient2.SelectedValue);

                LI.Add(new Util.TS.LoginInfo { WorkCode = TB_WorkCodeSecond2.Text.Trim(), AccountID = SecondAccountID, AccountName = SecondAccountName, Coefficient = Coefficient });

                WorkCodeSecondList.Add(TB_WorkCodeSecond2.Text.Trim());
            }

            if (!string.IsNullOrEmpty(TB_WorkCodeSecond3.Text.Trim()))
            {
                if (WorkCodeSecondList.Contains(TB_WorkCodeSecond3.Text.Trim()) || TB_WorkCodeSecond3.Text.Trim() == TB_WorkCode.Text.Trim())
                    throw new Exception((string)GetLocalResourceObject("Str_WorkCodeRepeat"));

                SecondAccountID = BaseConfiguration.GetAccountID(TB_WorkCodeSecond3.Text.Trim());

                if (SecondAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(SecondAccountID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                SecondAccountName = GetAccountName(SecondAccountID);

                if (!string.IsNullOrEmpty(SecondAccountName))
                    SecondAccountName = SecondAccountName.ToBase64String();

                if (string.IsNullOrEmpty(DDL_SecondCoefficient3.SelectedValue))
                    throw new Exception((string)GetLocalResourceObject("Str_Empty_Coefficient"));

                Coefficient = double.Parse(DDL_SecondCoefficient3.SelectedValue);

                LI.Add(new Util.TS.LoginInfo { WorkCode = TB_WorkCodeSecond3.Text.Trim(), AccountID = SecondAccountID, AccountName = SecondAccountName, Coefficient = Coefficient });

                WorkCodeSecondList.Add(TB_WorkCodeSecond3.Text.Trim());
            }

            if (!string.IsNullOrEmpty(TB_WorkCodeSecond4.Text.Trim()))
            {
                if (WorkCodeSecondList.Contains(TB_WorkCodeSecond4.Text.Trim()) || TB_WorkCodeSecond4.Text.Trim() == TB_WorkCode.Text.Trim())
                    throw new Exception((string)GetLocalResourceObject("Str_WorkCodeRepeat"));

                SecondAccountID = BaseConfiguration.GetAccountID(TB_WorkCodeSecond4.Text.Trim());

                if (SecondAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(SecondAccountID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                SecondAccountName = GetAccountName(SecondAccountID);

                if (!string.IsNullOrEmpty(SecondAccountName))
                    SecondAccountName = SecondAccountName.ToBase64String();

                if (string.IsNullOrEmpty(DDL_SecondCoefficient4.SelectedValue))
                    throw new Exception((string)GetLocalResourceObject("Str_Empty_Coefficient"));

                Coefficient = double.Parse(DDL_SecondCoefficient4.SelectedValue);

                LI.Add(new Util.TS.LoginInfo { WorkCode = TB_WorkCodeSecond4.Text.Trim(), AccountID = SecondAccountID, AccountName = SecondAccountName, Coefficient = Coefficient });

                WorkCodeSecondList.Add(TB_WorkCodeSecond4.Text.Trim());
            }

            if (!string.IsNullOrEmpty(TB_WorkCodeSecond5.Text.Trim()))
            {
                if (WorkCodeSecondList.Contains(TB_WorkCodeSecond5.Text.Trim()) || TB_WorkCodeSecond5.Text.Trim() == TB_WorkCode.Text.Trim())
                    throw new Exception((string)GetLocalResourceObject("Str_WorkCodeRepeat"));

                SecondAccountID = BaseConfiguration.GetAccountID(TB_WorkCodeSecond5.Text.Trim());

                if (SecondAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(SecondAccountID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                SecondAccountName = GetAccountName(SecondAccountID);

                if (!string.IsNullOrEmpty(SecondAccountName))
                    SecondAccountName = SecondAccountName.ToBase64String();

                if (string.IsNullOrEmpty(DDL_SecondCoefficient5.SelectedValue))
                    throw new Exception((string)GetLocalResourceObject("Str_Empty_Coefficient"));

                Coefficient = double.Parse(DDL_SecondCoefficient5.SelectedValue);

                LI.Add(new Util.TS.LoginInfo { WorkCode = TB_WorkCodeSecond5.Text.Trim(), AccountID = SecondAccountID, AccountName = SecondAccountName, Coefficient = Coefficient });

                WorkCodeSecondList.Add(TB_WorkCodeSecond5.Text.Trim());
            }

            if (!string.IsNullOrEmpty(TB_WorkCodeSecond6.Text.Trim()))
            {
                if (WorkCodeSecondList.Contains(TB_WorkCodeSecond6.Text.Trim()) || TB_WorkCodeSecond6.Text.Trim() == TB_WorkCode.Text.Trim())
                    throw new Exception((string)GetLocalResourceObject("Str_WorkCodeRepeat"));

                SecondAccountID = BaseConfiguration.GetAccountID(TB_WorkCodeSecond6.Text.Trim());

                if (SecondAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(SecondAccountID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                SecondAccountName = GetAccountName(SecondAccountID);

                if (!string.IsNullOrEmpty(SecondAccountName))
                    SecondAccountName = SecondAccountName.ToBase64String();

                if (string.IsNullOrEmpty(DDL_SecondCoefficient6.SelectedValue))
                    throw new Exception((string)GetLocalResourceObject("Str_Empty_Coefficient"));

                Coefficient = double.Parse(DDL_SecondCoefficient6.SelectedValue);

                LI.Add(new Util.TS.LoginInfo { WorkCode = TB_WorkCodeSecond6.Text.Trim(), AccountID = SecondAccountID, AccountName = SecondAccountName, Coefficient = Coefficient });

                WorkCodeSecondList.Add(TB_WorkCodeSecond6.Text.Trim());
            }

            if (!string.IsNullOrEmpty(TB_WorkCodeSecond7.Text.Trim()))
            {
                if (WorkCodeSecondList.Contains(TB_WorkCodeSecond7.Text.Trim()) || TB_WorkCodeSecond7.Text.Trim() == TB_WorkCode.Text.Trim())
                    throw new Exception((string)GetLocalResourceObject("Str_WorkCodeRepeat"));

                SecondAccountID = BaseConfiguration.GetAccountID(TB_WorkCodeSecond7.Text.Trim());

                if (SecondAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(SecondAccountID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                SecondAccountName = GetAccountName(SecondAccountID);

                if (!string.IsNullOrEmpty(SecondAccountName))
                    SecondAccountName = SecondAccountName.ToBase64String();

                if (string.IsNullOrEmpty(DDL_SecondCoefficient7.SelectedValue))
                    throw new Exception((string)GetLocalResourceObject("Str_Empty_Coefficient"));

                Coefficient = double.Parse(DDL_SecondCoefficient7.SelectedValue);

                LI.Add(new Util.TS.LoginInfo { WorkCode = TB_WorkCodeSecond7.Text.Trim(), AccountID = SecondAccountID, AccountName = SecondAccountName, Coefficient = Coefficient });

                WorkCodeSecondList.Add(TB_WorkCodeSecond7.Text.Trim());
            }

            if (!string.IsNullOrEmpty(TB_WorkCodeSecond8.Text.Trim()))
            {
                if (WorkCodeSecondList.Contains(TB_WorkCodeSecond8.Text.Trim()) || TB_WorkCodeSecond8.Text.Trim() == TB_WorkCode.Text.Trim())
                    throw new Exception((string)GetLocalResourceObject("Str_WorkCodeRepeat"));

                SecondAccountID = BaseConfiguration.GetAccountID(TB_WorkCodeSecond8.Text.Trim());

                if (SecondAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(SecondAccountID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                SecondAccountName = GetAccountName(SecondAccountID);

                if (!string.IsNullOrEmpty(SecondAccountName))
                    SecondAccountName = SecondAccountName.ToBase64String();

                if (string.IsNullOrEmpty(DDL_SecondCoefficient8.SelectedValue))
                    throw new Exception((string)GetLocalResourceObject("Str_Empty_Coefficient"));

                Coefficient = double.Parse(DDL_SecondCoefficient8.SelectedValue);

                LI.Add(new Util.TS.LoginInfo { WorkCode = TB_WorkCodeSecond8.Text.Trim(), AccountID = SecondAccountID, AccountName = SecondAccountName, Coefficient = Coefficient });

                WorkCodeSecondList.Add(TB_WorkCodeSecond8.Text.Trim());
            }

            if (!string.IsNullOrEmpty(TB_WorkCodeSecond9.Text.Trim()))
            {
                if (WorkCodeSecondList.Contains(TB_WorkCodeSecond9.Text.Trim()) || TB_WorkCodeSecond9.Text.Trim() == TB_WorkCode.Text.Trim())
                    throw new Exception((string)GetLocalResourceObject("Str_WorkCodeRepeat"));

                SecondAccountID = BaseConfiguration.GetAccountID(TB_WorkCodeSecond9.Text.Trim());

                if (SecondAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(SecondAccountID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                SecondAccountName = GetAccountName(SecondAccountID);

                if (!string.IsNullOrEmpty(SecondAccountName))
                    SecondAccountName = SecondAccountName.ToBase64String();

                if (string.IsNullOrEmpty(DDL_SecondCoefficient9.SelectedValue))
                    throw new Exception((string)GetLocalResourceObject("Str_Empty_Coefficient"));

                Coefficient = double.Parse(DDL_SecondCoefficient9.SelectedValue);

                LI.Add(new Util.TS.LoginInfo { WorkCode = TB_WorkCodeSecond9.Text.Trim(), AccountID = SecondAccountID, AccountName = SecondAccountName, Coefficient = Coefficient });

                WorkCodeSecondList.Add(TB_WorkCodeSecond9.Text.Trim());
            }

            if (Request.Cookies["TS_WorkCode"] != null)
                Response.Cookies["TS_WorkCode"].Expires = DateTime.Now.AddDays(-1);
            if (Request.Cookies["TS_AccountName"] != null)
                Response.Cookies["TS_AccountName"].Expires = DateTime.Now.AddDays(-1);
            if (Request.Cookies["TS_WorkShiftID"] != null)
                Response.Cookies["TS_WorkShiftID"].Expires = DateTime.Now.AddDays(-1);
            if (Request.Cookies["TS_WorkShiftText"] != null)
                Response.Cookies["TS_WorkShiftText"].Expires = DateTime.Now.AddDays(-1);
            if (Request.Cookies["TS_Coefficient"] != null)
                Response.Cookies["TS_Coefficient"].Expires = DateTime.Now.AddDays(-1);
            if (Request.Cookies["TS_MachineID"] != null)
                Response.Cookies["TS_MachineID"].Expires = DateTime.Now.AddDays(-1);
            if (Request.Cookies["TS_SecondInfo"] != null)
                Response.Cookies["TS_SecondInfo"].Expires = DateTime.Now.AddDays(-1);

            Response.Cookies.Add(new HttpCookie("TS_WorkCode", TB_WorkCode.Text.Trim()));
            Response.Cookies.Add(new HttpCookie("TS_AccountName", AccountName.ToBase64String()));
            Response.Cookies.Add(new HttpCookie("TS_WorkShiftID", DDL_WorkShift.SelectedItem.Value));
            Response.Cookies.Add(new HttpCookie("TS_WorkShiftText", DDL_WorkShift.SelectedItem.Text.ToBase64String()));
            Response.Cookies.Add(new HttpCookie("TS_Coefficient", DDL_Coefficient.SelectedItem.Value));

            if (!string.IsNullOrEmpty(TB_MachineID.Text.Trim()))
                Response.Cookies.Add(new HttpCookie("TS_MachineID", TB_MachineID.Text.Trim()));

            if (LI.Count > 0)
                Response.Cookies.Add(new HttpCookie("TS_SecondInfo", Newtonsoft.Json.JsonConvert.SerializeObject(LI)));

            Response.Redirect("~/TimeSheet/TicketGoIn.aspx", true);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);
        }
    }

    /// <summary>
    /// 指定帳號id的到帳號姓名
    /// </summary>
    /// <param name="AccountID">帳號id</param>
    /// <returns>帳號姓名</returns>
    protected string GetAccountName(int AccountID)
    {
        string Query = @"Select * From Base_Org.dbo.V_Employee Where id = @AccountID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("AccountID", "int", 0, AccountID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            return DT.Rows[0]["lastname"].ToString().Trim();
        else
            return string.Empty;
    }

    /// <summary>
    /// 檢查設備登入規定
    /// </summary>
    protected void CheckMachineRule()
    {
        DataRow Row = Util.TS.GetDeviceRow(TB_MachineID.Text.Trim());

        if (Row == null)
            throw new Exception((string)GetLocalResourceObject("Str_Error_DeviceID"));

        DeviceID = Row["DeviceID"].ToString().Trim();

        if ((bool)Row["IsSuspension"])
            throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_MachineSuspension"));

        if (!(bool)Row["IsMultipleGoIn"])
        {
            if (CheckMachineHaveNotApprovedData())
                throw new Exception((string)GetLocalResourceObject("Str_Error_ApprovedData"));
        }
    }

    /// <summary>
    /// 檢查此機台是否有尚未核准報工資料(非主要作業員)
    /// </summary>
    /// <returns>是否有尚未核准報工資料</returns>
    protected bool CheckMachineHaveNotApprovedData()
    {
        string Query = @"Select Operator From T_TSTicketResult Where DeviceID = @DeviceID And (IsNull(Approver,0) < 1 or ApprovalTime Is Null) And (T_TSTicketResult.GoodQty + T_TSTicketResult.ScrapQty + T_TSTicketResult.ReWorkQty) > 0
	                     Union All
	                     Select Operator From T_TSTicketCurrStatus Where DeviceID = @DeviceID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return false;

        return DT.AsEnumerable().Where(Row => (int)Row["Operator"] != AccountID).Count() > 0;

    }
}