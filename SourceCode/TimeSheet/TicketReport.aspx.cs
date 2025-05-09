using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketReport : System.Web.UI.Page
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

        HF_DivID.Value = DivID;

        if (!IsPostBack)
        {
            string TicketID = string.Empty;

            if (Request["TicketID"] != null)
                TicketID = Request["TicketID"].Trim();

            if (string.IsNullOrEmpty(TicketID))
            {
                Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }

            HF_TicketID.Value = TicketID;

            LaodData();
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LaodData()
    {
        string Query = @"Select Count(*) From T_TSTicketCurrStatus Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_CurrStatusNoData"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        Query = @"Select 
                ProcessID,
                AUFPL,
                APLZL,
                VORNR,
                DeviceID,
                EntryTime As ReportTimeStart,
                GetDate() As ReportTimeEnd,
                Datediff(Minute,EntryTime,GetDate()) As ReportMinute,
                IsNull((Select Sum(MaintainMinuteByMachine) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsEnd = 1 And IsClose = 0),0) As MaintainMinute,
                IsNull((Select Sum(QACheckMinute) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsEnd = 1 And IsClose = 0),0) As QACheckMinute,
                IsNull((Select Sum(PDCheckMinute) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsEnd = 1 And IsClose = 0),0) As PDCheckMinute,
                IsNull((Select Sum(WaitMinute) From T_TSTicketMaintain Where TicketID = T_TSTicketCurrStatus.TicketID And ProcessID = T_TSTicketCurrStatus.ProcessID And IsEnd = 1 And IsClose = 0),0) As WaitMinute,
                AllowQty,
                Brand,
                T_TSWorkShift.WorkShiftID,
                T_TSWorkShift.WorkShiftName,
                Operator,
                Base_Org.dbo.GetAccountName(Operator) As OperatorName
                From T_TSTicketCurrStatus Inner Join T_TSWorkShift On T_TSTicketCurrStatus.WorkShiftID = T_TSWorkShift.WorkShiftID
                Where TicketID = @TicketID";

        Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_CurrStatusNoData"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        HF_ProcessID.Value = DT.Rows[0]["ProcessID"].ToString().Trim();

        Query = @"Select Count(*) From T_TSTicketMaintain Where TicketID = @TicketID And ProcessID = @ProcessID And IsEnd = 0";

        Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value));

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_MaintainNoEnd"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        HF_AUFPL.Value = DT.Rows[0]["AUFPL"].ToString().Trim();

        HF_APLZL.Value = DT.Rows[0]["APLZL"].ToString().Trim();

        HF_VORNR.Value = DT.Rows[0]["VORNR"].ToString().Trim();

        HF_DeviceID.Value = DT.Rows[0]["DeviceID"].ToString().Trim();

        TB_EntryTime.Text = ((DateTime)DT.Rows[0]["ReportTimeStart"]).ToCurrentUICultureStringTime();

        TB_EndTime.Text = ((DateTime)DT.Rows[0]["ReportTimeEnd"]).ToCurrentUICultureStringTime();

        int ReportMinute = (int)DT.Rows[0]["ReportMinute"];

        TB_ReportMinute.Text = ReportMinute.ToString();

        int MaintainMinute = (int)DT.Rows[0]["MaintainMinute"];

        TB_MaintainMinute.Text = MaintainMinute.ToString();

        int QACheckMinute = (int)DT.Rows[0]["QACheckMinute"];

        TB_MaintainQACheckMinute.Text = QACheckMinute.ToString();

        int PDCheckMinute = (int)DT.Rows[0]["PDCheckMinute"];

        TB_MaintainPDCheckMinute.Text = PDCheckMinute.ToString();

        int WaitMinute = (int)DT.Rows[0]["WaitMinute"];

        TB_WaitMaintainMinute.Text = WaitMinute.ToString();

        int ResultMinute = ReportMinute - (WaitMinute + MaintainMinute + QACheckMinute + PDCheckMinute);

        TB_ResultMinute.Text = ResultMinute.ToString();

        TB_Brand.Text = DT.Rows[0]["Brand"].ToString().Trim();

        HF_WorkShiftID.Value = DT.Rows[0]["WorkShiftID"].ToString().Trim();

        TB_WorkShift.Text = DT.Rows[0]["WorkShiftName"].ToString().Trim();

        HF_Operator.Value = DT.Rows[0]["Operator"].ToString().Trim();

        TB_OperatorName.Text = DT.Rows[0]["OperatorName"].ToString().Trim();

        Query = @"Select AUFNR,TicketTypeID,Qty From T_TSTicket Where TicketID = @TicketID";

        Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value));

        DataTable TicketDT = CommonDB.ExecuteSelectQuery(dbcb);

        HF_AUFNR.Value = TicketDT.Rows[0]["AUFNR"].ToString().Trim();

        HF_TicketQty.Value = TicketDT.Rows[0]["Qty"].ToString().Trim();

        bool IsReportGoodQty = GetIsReportGoodQty();

        if (IsReportGoodQty)
            TB_GoodQty.Text = DT.Rows[0]["AllowQty"].ToString().Trim();
        else
            TB_ReWorkQty.Text = DT.Rows[0]["AllowQty"].ToString().Trim();

        HF_AllowQty.Value = DT.Rows[0]["AllowQty"].ToString().Trim();

        HF_IsReportGoodQty.Value = IsReportGoodQty.ToStringValue();

        if (Request.Cookies["TS_SecondInfo"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_SecondInfo"].Value))
        {
            List<Util.TS.LoginInfo> SecondInfoList = JsonConvert.DeserializeObject<List<Util.TS.LoginInfo>>(Request.Cookies["TS_SecondInfo"].Value);

            TB_OperatorNameSecond.Text = string.Join("、", SecondInfoList.Select(Info => Info.AccountName.ToStringFromBase64() + "(" + Info.Coefficient.ToString() + ")").ToList());
        }

        LoadIsPrintPackage();
    }

    /// <summary>
    /// 取得是否回報良品數量
    /// </summary>
    /// <returns>是否回報良品數量</returns>
    protected bool GetIsReportGoodQty()
    {
        string Query = @"Select * From T_TSTicket Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        Util.TS.TicketType TicketType = (Util.TS.TicketType)Enum.Parse(typeof(Util.TS.TicketType), DT.Rows[0]["TicketTypeID"].ToString().Trim());

        if (TicketType == Util.TS.TicketType.General)
            return true;

        int ReWorkMainProcessID = (int)DT.Rows[0]["ReWorkMainProcessID"];

        /* 如果成立的話，代表此工單是隔離品單，然後並不是來自於返工單的開立。因為有可能是返工單後又開立隔離品單。 */
        if (ReWorkMainProcessID < 1)
            return true;

        int CurrProcessID = int.Parse(HF_ProcessID.Value);

        /* 如果當前的工序是超過源頭開立的返工單的工序就以良品數回報。 */
        if (CurrProcessID >= ReWorkMainProcessID)
            return true;
        else
            return false;
    }

    /// <summary>
    /// 載入此報工設備是否要列印裝箱報表
    /// </summary>
    protected void LoadIsPrintPackage()
    {
        string Query = @"Select IsPrintPackage From T_TSDevice Where DeviceID = @DeviceID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDevice"];

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value));

        bool Result = (bool)CommonDB.ExecuteScalar(dbcb);

        if (Result)
        {
            Query = @"Select Top 1 PackageQty From V_TSMORouting Where AUFNR = @AUFNR And AUFPL = @AUFPL And APLZL = @APLZL";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

            dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(HF_AUFNR.Value, "AUFNR"));
            dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(HF_AUFPL.Value));
            dbcb.appendParameter(Schema.Attributes["APLZL"].copy(HF_APLZL.Value));

            Result = (int)CommonDB.ExecuteScalar(dbcb) > 0;
        }

        HF_IsPrintPackage.Value = Result.ToStringValue();
    }
}