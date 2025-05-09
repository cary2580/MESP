using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketLifeCycle : System.Web.UI.Page
{
    protected string ViewInside = string.Empty;

    protected override void OnPreInit(EventArgs e)
    {
        if (Request["ViewInside"] != null && !string.IsNullOrEmpty(Request["ViewInside"].Trim()))
        {
            try
            {
                if (Request["ViewInside"].ToStringFromBase64(true).ToBoolean())
                    this.MasterPageFile = "~/MasterPage.master";
                else
                    (Master as TimeSheet_TimeSheet).IsPassPageVerificationAccount = true;

                ViewInside = Request["ViewInside"].Trim();
            }
            catch (Exception ex)
            {

            }
        }
        else
        {
            this.MasterPageFile = "~/NoFrame.master";

            (Master as BaseMasterPage).IsPassPageVerificationAccount = true;
        }

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            HF_ViewInside.Value = ViewInside;

            if (Request["A2"] != null)
            {
                TB_TicketID.Text = Request["A2"].Trim();

                HF_PostTicketID.Value = TB_TicketID.Text;
            }
        }
        else
        {
            HF_PostTicketID.Value = string.Empty;
        }
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(TB_TicketID.Text.Trim()))
        {
            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            return;
        }

        TB_TicketID.Text = Util.TS.ToTicketID(TB_TicketID.Text);

        HF_SearchTicketID.Value = TB_TicketID.Text;

        string Query = @"Select
                        T_TSTicket.*,
                        (Select Count(*) From T_TSTicket As PST Where PST.AUFNR = T_TSTicket.AUFNR And TicketTypeID = @TicketTypeID) As BoxCount,
                        (Select Sum(Qty) From T_TSTicket As PST Where PST.AUFNR = T_TSTicket.AUFNR And TicketTypeID = @TicketTypeID) As TotalQty,
                        T_Code.CodeName As TicketTypeName,
                        (Select Top 1 Convert(nvarchar,ProcessID) + '-' + VORNR + '-' + LTXA1 From T_TSTicketRouting Where TicketID = T_TSTicket.ParentTicketID And ProcessID = T_TSTicket.CreateProcessID) As CreateProcess,
                        Base_Org.dbo.GetAccountName(T_TSTicket.CreateAccountID) As CreateAccountName
                        From T_TSTicket Inner Join T_Code On T_TSTicket.TicketTypeID = T_Code.CodeID And T_Code.CodeType = 'TS_TicketType' And T_Code.UICulture = @UICulture
                        Where T_TSTicket.TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text.Trim()));

        dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.General).ToString()));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_Error_NoTicketRow"));

            return;
        }

        TB_TicketType.Text = DT.Rows[0]["TicketTypeName"].ToString().Trim();

        TB_TickeBoxQty.Text = DT.Rows[0]["BoxCount"].ToString().Trim();

        TB_TotalTicketQty.Text = ((int)DT.Rows[0]["TotalQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        TB_Qty.Text = ((int)DT.Rows[0]["Qty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        TB_CreateDate.Text = ((DateTime)DT.Rows[0]["CreateDate"]).ToCurrentUICultureStringTime();

        TB_MainTicketID.Text = DT.Rows[0]["MainTicketID"].ToString().Trim();

        TB_CreateProcess.Text = DT.Rows[0]["CreateProcess"].ToString().Trim();

        TB_CreateAccountName.Text = DT.Rows[0]["CreateAccountName"].ToString().Trim();

        if (!string.IsNullOrEmpty(DT.Rows[0]["ParentTicketID"].ToString().Trim()))
        {
            Query = @"Select dbo.TS_GetParentTicketIDPath(@TicketID,@Delimiter)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text.Trim()));

            dbcb.appendParameter(Util.GetDataAccessAttribute("Delimiter", "nvarchar", 50, "/"));

            TB_ParentTicketID.Text = CommonDB.ExecuteScalar(dbcb).ToString().Trim();
        }

        string AUFNR = DT.Rows[0]["AUFNR"].ToString().Trim();

        Query = @"Select Top 1 CINFO,SEMIFINBATCH,CHARG,TEXT1,MAKTX,PSMNG,WEMNG,(PLNNR + '-' + PLNAL) As GroupCurr,STATUS,(Select CodeName From T_Code Where CodeType = 'TS_MOStatus' And CodeID = [STATUS] And UICulture = @UICulture) As StatusName From V_TSMORouting Where AUFNR = @AUFNR";

        Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            TB_BATCH.Text = DT.Rows[0]["CINFO"].ToString().Trim();
            TB_SEMIFINBATCH.Text = DT.Rows[0]["SEMIFINBATCH"].ToString().Trim();
            TB_CHARG.Text = DT.Rows[0]["CHARG"].ToString().Trim();
            TB_GroupCurr.Text = DT.Rows[0]["GroupCurr"].ToString().Trim();
            TB_TEXT1.Text = DT.Rows[0]["TEXT1"].ToString().Trim();
            TB_MAKTX.Text = DT.Rows[0]["MAKTX"].ToString().Trim();
            TB_PSMNG.Text = ((int)double.Parse(DT.Rows[0]["PSMNG"].ToString())).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);
            TB_WEMNG.Text = ((int)double.Parse(DT.Rows[0]["WEMNG"].ToString())).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);
            TB_MOStatusName.Text = DT.Rows[0]["StatusName"].ToString().Trim();
            HF_IsCanDeleteResultItem.Value = (Util.TS.MOStatus)Enum.Parse(typeof(Util.TS.MOStatus), DT.Rows[0]["STATUS"].ToString().Trim()) == Util.TS.MOStatus.Closed ? false.ToStringValue() : true.ToStringValue();
        }

        //只要找下一層流程卡即可
        Query = @"Select * From dbo.TS_GetFullSubTicket(@TicketID,0) Where Depth = 1";

        Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        EnumerableRowCollection<DataRow> SubTicketDataRow = DT.AsEnumerable();

        Query = @"Select 
                        T_TSTicket.TicketTypeID,
                        T_TSTicketRouting.TicketID,
                        T_TSTicketRouting.ProcessID,
                        T_TSTicketRouting.VORNR,
                        T_TSTicketRouting.LTXA1,
                        Base_Org.dbo.GetAccountName(T_TSTicketResult.Operator) As OperatorName,
                        T_TSTicketResult.GoodQty,
                        T_TSTicketResult.ScrapQty,
                        T_TSTicketResult.ReWorkQty,
                        T_TSWorkShift.WorkShiftName,
                        T_TSTicketResult.ReportTimeStart,
                        T_TSTicketResult.ReportTimeEnd,
                        T_TSTicketResult.ReportMinute,
                        T_TSTicketResult.MaintainMinute,
                        T_TSTicketResult.ResultMinute,
                        T_TSTicketResult.Coefficient,
                        T_TSTicketResult.ResultMinuteMainOperator,
                        T_TSTicketResult.WaitMinute,
                        T_TSTicketResult.Brand,
                        Base_Org.dbo.GetAccountName(T_TSTicketResult.Approver) As ApproverName,
                        T_TSTicketResult.ApprovalTime,
                        T_TSDevice.DeviceID,
                        T_TSDevice.MachineID,
                        T_TSDevice.MachineName,
                        T_TSTicket.CreateProcessID
                From T_TSTicket
                Inner Join T_TSTicketRouting On T_TSTicket.TicketID = T_TSTicketRouting.TicketID
                Left Join T_TSTicketResult On T_TSTicketRouting.TicketID = T_TSTicketResult.TicketID And T_TSTicketRouting.ProcessID = T_TSTicketResult.ProcessID
                Left Join T_TSWorkShift On T_TSTicketResult.WorkShiftID = T_TSWorkShift.WorkShiftID
                Left Join T_TSDevice On T_TSTicketResult.DeviceID = T_TSDevice.DeviceID
                Where T_TSTicket.TicketID = @TicketID
                Order By T_TSTicketRouting.ProcessID Asc";

        Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        var ResponseData = DT.AsEnumerable().Select(Row => new
        {
            TicketID = Row["TicketID"].ToString().Trim(),
            ProcessID = Row["ProcessID"].ToString().Trim(),
            CreateProcessID = Row["CreateProcessID"].ToString().Trim(),
            VORNR = Row["VORNR"].ToString().Trim(),
            LTXA1 = Row["LTXA1"].ToString().Trim(),
            ProcessName = Row["ProcessID"].ToString().Trim() + "-" + Row["VORNR"].ToString().Trim() + "-" + Row["LTXA1"].ToString().Trim(),
            OperatorName = Row["OperatorName"].ToString().Trim() + (Row["Coefficient"].ToString().Trim() != "1" && Row["OperatorName"].ToString().Trim() != string.Empty ? "(" + Row["Coefficient"].ToString().Trim() + ")" : string.Empty) + "<br>" + Row["WorkShiftName"].ToString().Trim(),
            GoodQty = Row["GoodQty"] == DBNull.Value ? string.Empty : ((int)Row["GoodQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
            ScrapQty = Row["ScrapQty"] == DBNull.Value ? string.Empty : ((int)Row["ScrapQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
            ReWorkQty = Row["ReWorkQty"] == DBNull.Value ? string.Empty : ((int)Row["ReWorkQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
            WorkShiftName = Row["WorkShiftName"].ToString().Trim(),
            ReportTimeStart = Row["ReportTimeStart"] != DBNull.Value ? ((DateTime)Row["ReportTimeStart"]).ToCurrentUICultureStringTime() : string.Empty,
            ReportTimeEnd = Row["ReportTimeEnd"] != DBNull.Value ? ((DateTime)Row["ReportTimeEnd"]).ToCurrentUICultureStringTime() : string.Empty,
            ReportMinute = Row["ReportMinute"].ToString().Trim(),
            MaintainMinute = Row["MaintainMinute"].ToString().Trim(),
            ResultMinute = Row["ResultMinute"].ToString().Trim(),
            WaitMinute = Row["WaitMinute"].ToString().Trim(),
            Brand = Row["Brand"].ToString().Trim(),
            ApproverName = Row["ApproverName"].ToString().Trim(),
            ApprovalTime = Row["ApprovalTime"] != DBNull.Value ? ((DateTime)Row["ApprovalTime"]).ToCurrentUICultureStringTime() : string.Empty,
            DeviceID = Row["DeviceID"].ToString().Trim(),
            MachineID = Row["MachineID"].ToString().Trim(),
            MachineName = Row["MachineID"].ToString().Trim() + "<br>" + Row["MachineName"].ToString().Trim(),
            ChildrenQuarantine = string.Join("|", SubTicketDataRow.Where(SubTicketRow => SubTicketRow["TicketTypeID"].ToString().Trim() == ((short)Util.TS.TicketType.Quarantine).ToString() && (int)SubTicketRow["CreateProcessID"] == (int)Row["ProcessID"]).Select(SubTicketRow => SubTicketRow["TicketID"].ToString().Trim()).ToList()),
            ChildrenReWork = string.Join("|", SubTicketDataRow.Where(SubTicketRow => SubTicketRow["TicketTypeID"].ToString().Trim() == ((short)Util.TS.TicketType.Rework).ToString() && (int)SubTicketRow["CreateProcessID"] == (int)Row["ProcessID"]).Select(SubTicketRow => SubTicketRow["TicketID"].ToString().Trim()).ToList())
        }).ToList();

        Page.ClientScript.RegisterStartupScript(this.GetType(), "DataValue", "<script>var DataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");

        bool IsQuarantineTicketType = (ResponseData.Count > 0 && (Util.TS.TicketType)Enum.Parse(typeof(Util.TS.TicketType), DT.Rows[0]["TicketTypeID"].ToString()) == Util.TS.TicketType.Quarantine);

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsQuarantineTicketType", "<script>var IsQuarantineTicketType='" + IsQuarantineTicketType.ToStringValue() + "'</script>");
    }
}