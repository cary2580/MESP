using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Newtonsoft.Json;

public partial class TimeSheet_WorkStationGoOut : System.Web.UI.Page
{
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Request.Cookies["TS_WorkCode"] == null || Request.Cookies["TS_WorkShiftID"] == null || Request.Cookies["TS_WorkShiftText"] == null)
            {
                Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_GoIn"), true, false, "window.location.href='" + ResolveClientUrl("~/TimeSheet/WorkStationGoIn.aspx") + "'");

                return;
            }

            if (CheckRule())
                LoadData();

            Util.LoadDDLData(DDL_PayrollType, "TS_PayrollType", false);
        }
    }

    protected bool CheckRule()
    {
        int AccountID = BaseConfiguration.GetAccountID(Request.Cookies["TS_WorkCode"].Value.Trim());

        string Query = @"Select * From T_TSTicketCurrStatus Where Operator = @Operator";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            List<string> TicketIDList = DT.AsEnumerable().Select(Row => Row["TicketID"].ToString().Trim()).ToList();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_HaveTicketCurrStatus") + string.Join("<br>", TicketIDList), true, false, "window.location.href='" + ResolveClientUrl("~/TimeSheet/TicketGoIn.aspx") + "'");

            return false;
        }

        HF_AccountID.Value = AccountID.ToString();

        TB_WorkCode.Text = Request.Cookies["TS_WorkCode"].Value.Trim() + "(" + Request.Cookies["TS_AccountName"].Value.ToStringFromBase64() + ")";

        if (Request.Cookies["TS_Coefficient"] != null)
            TB_WorkCode.Text += "(" + Request.Cookies["TS_Coefficient"].Value + ")";

        return true;
    }

    protected void LoadData()
    {
        /* 只要是該員工尚未審批過的，都出現。因為有可能有些是跨日的大夜班 */
        string Query = @"Select 
                        '' As TicketIDValue,
                        T_TSTicketResult.TicketID,
                        T_TSTicketResult.SerialNo,
                        T_TSTicketRouting.VORNR + '-' + T_TSTicketRouting.LTXA1 As ProcessName,
                        (Select MachineID + '-' + MachineName From T_TSDevice Where DeviceID = T_TSTicketResult.DeviceID) As MachineName,
                        T_TSTicketResult.GoodQty,
                        T_TSTicketResult.ScrapQty,
                        T_TSTicketResult.ReWorkQty,
                        T_TSTicketResult.ReportTimeStart,
                        T_TSTicketResult.ReportTimeEnd,
                        T_TSTicketResult.ReportMinute,
                        T_TSTicketResult.WaitMaintainMinute,
                        T_TSTicketResult.MaintainMinute,
                        T_TSTicketResult.ResultMinute,
                        T_TSTicketResult.ResultMinuteMainOperator,
                        T_TSTicketResult.WaitMinute,
                        T_TSTicketResult.Brand,
                        (Select WorkShiftName From T_TSWorkShift Where WorkShiftID = T_TSTicketResult.WorkShiftID) As WorkShiftName,
                        Base_Org.dbo.GetAccountName(Operator) + '/' + Base_Org.dbo.GetDeptName(Base_Org.dbo.GetAccountDepID(Operator)) As OperatorName,
                        Stuff(((Select '、' + Base_Org.dbo.GetAccountName(SecondOperator) + '(' + Convert(nvarchar,Coefficient) + ')' From T_TSTicketResultSecondOperator Where T_TSTicketResultSecondOperator.TicketID = T_TSTicketResult.TicketID And T_TSTicketResultSecondOperator.ProcessID = T_TSTicketResult.ProcessID And T_TSTicketResultSecondOperator.SerialNo = T_TSTicketResult.SerialNo For Xml Path(''))),1,1,'') AS SecondOperator,
                        T_TSTicketResult.DeviceID,
                        T_TSTicketResult.WorkShiftID
                        From T_TSTicketResult 
                        Inner Join T_TSTicketRouting On T_TSTicketResult.TicketID = T_TSTicketRouting.TicketID And T_TSTicketResult.ProcessID = T_TSTicketRouting.ProcessID
                        Inner Join T_TSDevice On T_TSDevice.DeviceID = T_TSTicketResult.DeviceID
                        Where T_TSDevice.MachineID = @MachineID
	                    And (T_TSDevice.IsApprovalByDevice = 1 Or T_TSTicketResult.Operator = @Operator)
	                    And (IsNull(T_TSTicketResult.Approver,0) < 1 or T_TSTicketResult.ApprovalTime Is Null)
                        Order By T_TSTicketResult.ReportTimeEnd Asc,T_TSTicketResult.TicketID,T_TSTicketResult.SerialNo Desc";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["Operator"].copy(HF_AccountID.Value));

        string MachineID = string.Empty;

        if (Request.Cookies["TS_MachineID"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_MachineID"].Value))
            MachineID = Request.Cookies["TS_MachineID"].Value;

        Schema = DBSchema.currentDB.Tables["T_TSDevice"];

        dbcb.appendParameter(Schema.Attributes["MachineID"].copy(MachineID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Alert_NoResultData"), true, false, "window.location.href='" + ResolveClientUrl("~/TimeSheet/WorkStationGoIn.aspx") + "'");

            ClearCookies();

            return;
        }

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        IEnumerable<DataRow> Rows = DT.AsEnumerable();

        var ResponseData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName),
                classes = Column.ColumnName == "TicketID" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            TicketIDColumnName = "TicketIDValue",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                TicketIDValue = Row["TicketID"].ToString().Trim(),
                TicketID = Row["TicketID"].ToString().Trim(),
                SerialNo = Row["SerialNo"].ToString().Trim(),
                ProcessName = Row["ProcessName"].ToString().Trim(),
                MachineName = Row["MachineName"].ToString().Trim(),
                GoodQty = Row["GoodQty"].ToString().Trim(),
                ScrapQty = Row["ScrapQty"].ToString().Trim(),
                ReWorkQty = Row["ReWorkQty"].ToString().Trim(),
                ReportTimeStart = ((DateTime)Row["ReportTimeStart"]).ToCurrentUICultureStringTime(),
                ReportTimeEnd = ((DateTime)Row["ReportTimeEnd"]).ToCurrentUICultureStringTime(),
                ReportMinute = Row["ReportMinute"].ToString().Trim(),
                WaitMaintainMinute = Row["WaitMaintainMinute"].ToString().Trim(),
                MaintainMinute = Row["MaintainMinute"].ToString().Trim(),
                ResultMinute = Row["ResultMinute"].ToString().Trim(),
                ResultMinuteMainOperator = Row["ResultMinuteMainOperator"].ToString().Trim(),
                WaitMinute = Row["WaitMinute"].ToString().Trim(),
                Brand = Row["Brand"].ToString().Trim(),
                WorkShiftName = Row["WorkShiftName"].ToString().Trim(),
                OperatorName = Row["OperatorName"].ToString().Trim(),
                SecondOperator = Row["SecondOperator"].ToString().Trim()
            })
        };

        string[] HeaderDataColumns = new string[] { "GoodQty", "ScrapQty", "ReWorkQty", "ReportMinute", "WaitMaintainMinute", "MaintainMinute", "ResultMinute", "WaitMinute" };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowHeaderRowValue", "<script>var IsShowHeaderRowValue='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "HeaderDataColumns", "<script>var HeaderDataColumns=" + Newtonsoft.Json.JsonConvert.SerializeObject(HeaderDataColumns) + "</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");

        List<OffWorkDeviceID> OffWorkDeviceIDList = new List<OffWorkDeviceID>();

        var DeviceList = Rows.GroupBy(Row => new { DeviceID = Row["DeviceID"].ToString().Trim(), WorkShiftID = Row["WorkShiftID"].ToString().Trim(), ReportTimeEnd = ((DateTime)Row["ReportTimeEnd"]).ToDefaultString() });

        foreach (var item in DeviceList)
        {
            string DeviceID = item.Key.DeviceID;

            string WorkShiftID = item.Key.WorkShiftID;

            DateTime ReportTimeEnd = Rows.Where(Row => Row["DeviceID"].ToString().Trim() == DeviceID && Row["WorkShiftID"].ToString().Trim() == WorkShiftID && ((DateTime)Row["ReportTimeEnd"]).ToDefaultString() == item.Key.ReportTimeEnd).Max(Row => (DateTime)Row["ReportTimeEnd"]);

            Query = @"Select Count(*) From T_TSTicketResult Inner Join T_TSTicket On T_TSTicket.TicketID = T_TSTicketResult.TicketID
                    Where DeviceID = @DeviceID And WorkShiftID = @WorkShiftID And ScrapQty < 1 And T_TSTicket.TicketTypeID = @TicketTypeID And 
                    dbo.TS_GetReportDate(ReportTimeEnd,@WorkShiftID) = dbo.TS_GetReportDate(@ReportTimeEnd,@WorkShiftID)
                    And (ExtendResultMinute + ExtendResultMinuteOperator) > 0";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.General).ToString()));

            Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
            dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(WorkShiftID));
            dbcb.appendParameter(Schema.Attributes["ReportTimeEnd"].copy(ReportTimeEnd));

            if ((int)CommonDB.ExecuteScalar(dbcb) < 1)
            {
                if (OffWorkDeviceIDList.Where(DeviceIDListItem => DeviceIDListItem.DeviceID == DeviceID && DeviceIDListItem.WorkShiftID == WorkShiftID && (DeviceIDListItem.ReportTimeEnd - ReportTimeEnd).Days == 0).Count() < 1)
                {
                    OffWorkDeviceIDList.Add(new OffWorkDeviceID()
                    {
                        DeviceID = DeviceID,
                        WorkShiftID = WorkShiftID,
                        ReportTimeEnd = ReportTimeEnd
                    });
                }
            }
        }

        HF_ExtendResultMinute.Value = JsonConvert.SerializeObject(OffWorkDeviceIDList);
    }

    /// <summary>
    /// 指定ColumnName得到是否顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "TicketIDValue":
            case "DeviceID":
            case "WorkShiftID":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 指定ColumnName得到欄位寬度
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>欄位寬度</returns>
    protected int GetWidth(string ColumnName)
    {
        switch (ColumnName)
        {
            case "TicketID":
                return 120;
            case "SerialNo":
                return 30;
            case "GoodQty":
            case "ScrapQty":
            case "ReWorkQty":
            case "ReportMinute":
            case "WaitMaintainMinute":
            case "MaintainMinute":
            case "ResultMinute":
            case "ResultMinuteMainOperator":
            case "WaitMinute":
                return 50;
            case "ReportTimeStart":
            case "ReportTimeEnd":
                return 80;
            default:
                return 100;
        }
    }

    /// <summary>
    /// 指定ColumnName得到對齊方式
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>對齊方式</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "SerialNo":
            case "GoodQty":
            case "ScrapQty":
            case "ReWorkQty":
            case "ReportMinute":
            case "WaitMaintainMinute":
            case "MaintainMinute":
            case "ResultMinute":
            case "ResultMinuteMainOperator":
            case "WaitMinute":
                return "center";
            default:
                return "left";
        }
    }

    /// <summary>
    /// 指定ColumnName得到顯示欄位名稱
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "TicketID":
                return (string)GetLocalResourceObject("Str_ColumnName_TicketID");
            case "SerialNo":
                return (string)GetLocalResourceObject("Str_ColumnName_SerialNo");
            case "ProcessName":
                return (string)GetLocalResourceObject("Str_ColumnName_ProcessName");
            case "MachineName":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineName");
            case "GoodQty":
                return (string)GetLocalResourceObject("Str_ColumnName_GoodQty");
            case "ScrapQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQty");
            case "ReWorkQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ReWorkQty");
            case "ReportTimeStart":
                return (string)GetLocalResourceObject("Str_ColumnName_ReportTimeStart");
            case "ReportTimeEnd":
                return (string)GetLocalResourceObject("Str_ColumnName_ReportTimeEnd");
            case "ReportMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_ReportMinute");
            case "WaitMaintainMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_WaitMaintainMinute");
            case "MaintainMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_MaintainMinute");
            case "ResultMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_ResultMinute");
            case "ResultMinuteMainOperator":
                return (string)GetLocalResourceObject("Str_ColumnName_ResultMinuteMainOperator");
            case "WaitMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_WaitMinute");
            case "Brand":
                return (string)GetLocalResourceObject("Str_ColumnName_Brand");
            case "WorkShiftName":
                return (string)GetLocalResourceObject("Str_ColumnName_WorkShiftName");
            case "OperatorName":
                return (string)GetLocalResourceObject("Str_ColumnName_Operator");
            case "SecondOperator":
                return (string)GetLocalResourceObject("Str_ColumnName_SecondOperator");
            default:
                return ColumnName;
        }
    }

    /// <summary>
    /// 清除Cookies
    /// </summary>
    protected void ClearCookies()
    {
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
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            CheckPassword();

            int Approver = BaseConfiguration.GetAccountID(TB_SupervisorWorkCode.Text.Trim());

            if (HF_AccountID.Value == Approver.ToString().Trim())
                throw new Exception((string)GetLocalResourceObject("Str_SameWorkCode"));

            string Query = @"Update T_TSTicketResult
                            Set T_TSTicketResult.Approver = @Approver,T_TSTicketResult.ApprovalTime = GetDate(),PayrollType = @PayrollType,T_TSTicketResult.ResultMinuteSecondOperator = IsNull(T_TSTicketResultSecondOperator.ResultMinute,0)
                            From T_TSTicketResult 
                            Inner Join T_TSDevice On T_TSDevice.DeviceID = T_TSTicketResult.DeviceID
                            Left Join 
                            (
	                            Select 
	                            T_TSTicketResultSecondOperator.TicketID,
	                            T_TSTicketResultSecondOperator.ProcessID,
	                            T_TSTicketResultSecondOperator.SerialNo,
	                            Sum(T_TSTicketResultSecondOperator.ResultMinute) As ResultMinute
	                            From T_TSTicketResultSecondOperator
	                            Group By T_TSTicketResultSecondOperator.TicketID,T_TSTicketResultSecondOperator.ProcessID,T_TSTicketResultSecondOperator.SerialNo
                            ) As T_TSTicketResultSecondOperator On 
                            T_TSTicketResult.TicketID = T_TSTicketResultSecondOperator.TicketID And 
                            T_TSTicketResult.ProcessID = T_TSTicketResultSecondOperator.ProcessID And
                            T_TSTicketResult.SerialNo = T_TSTicketResultSecondOperator.SerialNo
                            Where T_TSDevice.MachineID = @MachineID
                            And (T_TSDevice.IsApprovalByDevice = 1 Or T_TSTicketResult.Operator = @Operator)
                            And (IsNull(T_TSTicketResult.Approver,0) < 1 Or T_TSTicketResult.ApprovalTime Is Null)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

            dbcb.appendParameter(Schema.Attributes["Approver"].copy(Approver));

            dbcb.appendParameter(Schema.Attributes["PayrollType"].copy(DDL_PayrollType.SelectedValue));

            dbcb.appendParameter(Schema.Attributes["Operator"].copy(HF_AccountID.Value));

            string MachineID = string.Empty;

            if (Request.Cookies["TS_MachineID"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_MachineID"].Value))
                MachineID = Request.Cookies["TS_MachineID"].Value;

            Schema = DBSchema.currentDB.Tables["T_TSDevice"];

            dbcb.appendParameter(Schema.Attributes["MachineID"].copy(MachineID));

            CommonDB.ExecuteSingleCommand(dbcb);

            UpdateExtendResultMinute();

            string Url = string.Empty;

            if ((sender as Button).ID == BT_Submit.ID)
            {
                ClearCookies();

                Url = ResolveClientUrl("~/TimeSheet/WorkStationGoIn.aspx");
            }
            else
                Url = ResolveClientUrl("~/TimeSheet/TicketGoIn.aspx");

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_SuccessAlertMessage"), true, false, "window.location.href='" + Url + "'");
        }
        catch (Exception ex)
        {
            LoadData();

            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);
        }
    }

    /// <summary>
    /// 檢查員工帳密是否輸入正確
    /// </summary>
    protected void CheckPassword()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select Count(*) From Base_Org.dbo.V_Employee Where WorkCode = @WorkCode And [PassWord] = @PassWord And status in (0,1,2,3) And accounttype = 0");
        dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, TB_SupervisorWorkCode.Text.Trim()));
        dbcb.appendParameter(Util.GetDataAccessAttribute("PassWord", "NVarChar", 1000, TB_SupervisorPassword.Text.ToMD5String()));

        bool PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;

        if (!PassWordIsPass)
        {
            /* 如果OA帳號密碼找不到或是不正確再找一下系統本身使用者資料表是否帳號密碼正確(但還是要比對一下OA是否已經離職了) */
            dbcb = new DbCommandBuilder("Select Count(*) From T_Users Where WorkCode = @WorkCode And [PassWord] = @PassWord");

            dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, TB_SupervisorWorkCode.Text.Trim()));
            dbcb.appendParameter(Util.GetDataAccessAttribute("PassWord", "NVarChar", 1000, TB_SupervisorPassword.Text.ToMD5String()));
            PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;

            /* 本身系統帳密正確但還是要比對OA是否已經離職了 */
            if (PassWordIsPass)
            {
                dbcb = new DbCommandBuilder("Select Count(*) From Base_Org.dbo.V_Employee Where WorkCode = @WorkCode And status in (0,1,2,3) And accounttype = 0");
                dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, TB_SupervisorWorkCode.Text.Trim()));
                PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;
            }

            if (!PassWordIsPass)
                throw new Exception((string)GetLocalResourceObject("Str_PasswordError"));
        }
    }

    /// <summary>
    /// 更新延長機時和人時
    /// </summary>
    protected void UpdateExtendResultMinute()
    {
        List<OffWorkDeviceID> OffWorkDeviceIDList = JsonConvert.DeserializeObject<List<OffWorkDeviceID>>(HF_ExtendResultMinute.Value);

        if (OffWorkDeviceIDList.Count < 1)
            return;

        foreach (OffWorkDeviceID OffWorkDeviceItem in OffWorkDeviceIDList)
        {
            string Query = @"Select OnWorkBeforeMinute,OffWorkBeforeMinute From T_TSDevice Where DeviceID = @DeviceID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDevice"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(OffWorkDeviceItem.DeviceID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                continue;

            int OnWorkBeforeMinute = (int)DT.Rows[0]["OnWorkBeforeMinute"];

            int OffWorkBeforeMinute = (int)DT.Rows[0]["OffWorkBeforeMinute"];

            if ((OnWorkBeforeMinute + OffWorkBeforeMinute) < 1)
                continue;

            /* 報廢和復判的報工資料不能被抓出來當作延長機人時 */
            Query = @"Select T_TSTicketResult.* From T_TSTicketResult Inner Join T_TSTicket On T_TSTicket.TicketID = T_TSTicketResult.TicketID
                    Where DeviceID = @DeviceID And WorkShiftID = @WorkShiftID And ScrapQty < 1 And T_TSTicket.TicketTypeID = @TicketTypeID And
                    dbo.TS_GetReportDate(ReportTimeEnd,@WorkShiftID) = dbo.TS_GetReportDate(@ReportTimeEnd,@WorkShiftID)
                    Order By ReportTimeEnd Asc";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.General).ToString()));

            Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(OffWorkDeviceItem.DeviceID));
            dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(OffWorkDeviceItem.WorkShiftID));
            dbcb.appendParameter(Schema.Attributes["ReportTimeEnd"].copy(OffWorkDeviceItem.ReportTimeEnd));

            DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                continue;

            // 如果成立代表此設備此班別已經有延長機人時資料 (通常就是晚班有跨天生產的狀況會發生，如果沒有擋住，會發生被重複計算)
            if (DT.AsEnumerable().Sum(Row => (int)Row["ExtendResultMinute"]) > 0)
                continue;

            DBAction DBA = new DBAction();

            DataRow FirstTicketRow = DT.AsEnumerable().First();

            DataRow LastTicketRow = DT.AsEnumerable().Last();

            if (OnWorkBeforeMinute > 0)
            {
                double Coefficient = (double)FirstTicketRow["Coefficient"];

                int OnWorkBeforeMinuteByResultMinuteSecondOperator = GetExtendResultMinuteSecondOperator(FirstTicketRow, OnWorkBeforeMinute);

                Query = @"Update T_TSTicketResult Set ExtendResultMinute = (ExtendResultMinute + @ExtendResultMinute),ExtendResultMinuteOperator = (ExtendResultMinuteOperator + @ExtendResultMinuteOperator)
                        Where TicketID = @TicketID And ProcessID = @ProcessID And SerialNo = @SerialNo";

                dbcb = new DbCommandBuilder(Query);

                // 231122 潘素萍要求 : 延長機時不需要乘以系數
                dbcb.appendParameter(Schema.Attributes["ExtendResultMinute"].copy(OnWorkBeforeMinute));
                // 231122 潘素萍要求 : 延長人時需要乘以系數
                dbcb.appendParameter(Schema.Attributes["ExtendResultMinuteOperator"].copy((OnWorkBeforeMinute * Coefficient) + OnWorkBeforeMinuteByResultMinuteSecondOperator));

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(FirstTicketRow["TicketID"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy((int)FirstTicketRow["ProcessID"]));
                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy((short)FirstTicketRow["SerialNo"]));

                DBA.AddCommandBuilder(dbcb);
            }

            if (OffWorkBeforeMinute > 0)
            {
                double Coefficient = (double)LastTicketRow["Coefficient"];

                int OffWorkBeforeMinuteByResultMinuteSecondOperator = GetExtendResultMinuteSecondOperator(LastTicketRow, OffWorkBeforeMinute);

                Query = @"Update T_TSTicketResult Set ExtendResultMinute = (ExtendResultMinute + @ExtendResultMinute),ExtendResultMinuteOperator = (ExtendResultMinuteOperator + @ExtendResultMinuteOperator)
                        Where TicketID = @TicketID And ProcessID = @ProcessID And SerialNo = @SerialNo";

                dbcb = new DbCommandBuilder(Query);

                // 231122 潘素萍要求 : 延長機時不需要乘以系數
                dbcb.appendParameter(Schema.Attributes["ExtendResultMinute"].copy(OffWorkBeforeMinute));
                // 231122 潘素萍要求 : 延長人時需要乘以系數
                dbcb.appendParameter(Schema.Attributes["ExtendResultMinuteOperator"].copy((OffWorkBeforeMinute * Coefficient) + OffWorkBeforeMinuteByResultMinuteSecondOperator));

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(LastTicketRow["TicketID"].ToString().Trim()));
                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy((int)LastTicketRow["ProcessID"]));
                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy((short)LastTicketRow["SerialNo"]));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();
        }
    }

    /// <summary>
    /// 指定Result資料列得到次要操作人員人時
    /// </summary>
    /// <param name="Row">Result資料列</param>
    /// <param name="ExtendMinute">延長時間(分鐘)</param>
    /// <returns>次要操作人員人時</returns>
    protected int GetExtendResultMinuteSecondOperator(DataRow Row, int ExtendMinute)
    {
        string TicketID = Row["TicketID"].ToString().Trim();

        int ProcessID = (int)Row["ProcessID"];

        short SerialNo = (short)Row["SerialNo"];

        string Query = @"Select Convert(int,IsNull(Sum(@ExtendMinute * Coefficient),0)) From T_TSTicketResultSecondOperator Where TicketID = @TicketID And ProcessID = @ProcessID And SerialNo = @SerialNo";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResultSecondOperator"];

        dbcb.appendParameter(Util.GetDataAccessAttribute("ExtendMinute", "int", 0, ExtendMinute));

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));
        dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(SerialNo));

        return (int)CommonDB.ExecuteScalar(dbcb);
    }

    /// <summary>
    /// 下崗設備類別
    /// </summary>
    public class OffWorkDeviceID
    {
        public string DeviceID { get; set; }
        public string WorkShiftID { get; set; }
        public DateTime ReportTimeEnd { get; set; }
    }
}