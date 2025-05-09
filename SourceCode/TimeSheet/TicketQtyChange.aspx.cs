using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketQtyChange : System.Web.UI.Page
{
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            CheckTicket();

            DataTable DT = GetTicketResultData();

            var ProcessList = DT.AsEnumerable().GroupBy(Row => (int)Row["ProcessID"]).Select(Item => Item.Key).ToList();

            int ProcessID = 1;

            if (ProcessList.Count > 0)
                ProcessID = ProcessList[0];

            int GoodQty = DT.AsEnumerable().Sum(Row => (int)Row["GoodQty"]);

            int SubTicketQty = IsTicketHaveCreateSubTicket();

            int NewQty = GoodQty + SubTicketQty;

            if (ProcessList.Count() > 1)
                throw new Exception((string)GetLocalResourceObject("Str_Error_MultipleProcess"));
            else if (NewQty < 1)
                throw new Exception((string)GetLocalResourceObject("Str_Error_NoResultData"));

            DBAction DBA = new DBAction();

            string Query = @"Update T_TSTicket Set Qty = @Qty Where TicketID = @TicketID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TickeID.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["Qty"].copy(NewQty));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSTicketCurrStatus Where TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TickeID.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            /* 如果成立，代表此張流程卡修改後的數量已經都做完了，因此要把這張流程卡所有流程都變為結束。會成立的話，就代表開隔離單數量後，就滿足流程卡開單數量了 */
            if (GoodQty == 0 && NewQty == SubTicketQty)
                Query = @"Update T_TSTicketRouting Set IsEnd = 1 Where TicketID = @TicketID";
            else
                Query = @"Update T_TSTicketRouting Set IsEnd = 1 Where TicketID = @TicketID And ProcessID = @ProcessID";

            Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TickeID.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Update T_TSTicket Set IsEnd = (Select Case When Count(*) < 1 Then Convert(bit,1) Else Convert(bit,0) End From T_TSTicketRouting Where T_TSTicketRouting.TicketID = T_TSTicket.TicketID And T_TSTicketRouting.IsEnd = 0) Where T_TSTicket.TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TickeID.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Update T_TSWorkStation Set Operator = Null, EventTime = '1900/01/01', WorkShiftID = Null,";

            Query += "StatusID = '" + ((short)Util.TS.WorkStationStatus.Idle).ToString().Trim() + "'";

            Query += @" From T_TSWorkStation
                    Where DeviceID Not In(
                        Select DeviceID From T_TSTicketCurrStatus
                    ) And StatusID<> '99'";

            dbcb = new DbCommandBuilder(Query);

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            TB_TickeID.Text = string.Empty;

            TB_MachineID.Text = string.Empty;

            HF_AUFNR.Value = string.Empty;

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"));
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);
        }
    }

    /// <summary>
    /// 檢查此流程卡是否可以變更數量
    /// </summary>
    protected void CheckTicket()
    {
        string Query = @"Select * From T_TSTicket Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TickeID.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new Exception((string)GetLocalResourceObject("Str_Error_TicketID"));

        if ((bool)DT.Rows[0]["IsEnd"])
            throw new Exception((string)GetLocalResourceObject("Str_Error_TicketEnd"));

        if ((Util.TS.TicketType)Enum.Parse(typeof(Util.TS.TicketType), DT.Rows[0]["TicketTypeID"].ToString()) != Util.TS.TicketType.General)
            throw new Exception((string)GetLocalResourceObject("Str_Error_TicketType"));

        if (IsTicketHaveFinishProcess())
            throw new Exception((string)GetLocalResourceObject("Str_Error_TicketHaveFinishProcess"));

        //取得工單基本資料
        DT = GetMOData();

        if (DT.Rows.Count < 1)
            throw new Exception((string)GetLocalResourceObject("Str_Empty_AUFNR"));

        //必須要在檢查此機台編號是否為第一道工序，這樣才允許被刪除
        DataRow DeviceRow = Util.TS.GetDeviceRow(TB_MachineID.Text.Trim());

        if (DeviceRow == null)
            throw new Exception((string)GetLocalResourceObject("Str_Empty_DeviceRow"));

        if (!(bool)DeviceRow["IsFirstProcess"])
            throw new Exception((string)GetLocalResourceObject("Str_Error_DeviceNotFirstProcess"));
    }

    /// <summary>
    /// 取得此流程卡有產生子流程卡的開單數量
    /// </summary>
    /// <returns>有產生子流程卡的開單數量</returns>
    protected int IsTicketHaveCreateSubTicket()
    {
        string Query = @"Select IsNull(Sum(Qty),0) From T_TSTicket Where ParentTicketID = @ParentTicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ParentTicketID"].copy(TB_TickeID.Text.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb);
    }

    /// <summary>
    /// 取得此流程卡是否有完成報工的工序
    /// </summary>
    /// <returns>是否有完成報工的工序</returns>
    protected bool IsTicketHaveFinishProcess()
    {
        string Query = @"Select Count(*) From T_TSTicketRouting Where TicketID = @TicketID And IsEnd = 1";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TickeID.Text.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 取得工單基本資料
    /// </summary>
    /// <returns>取得工單基本資料</returns>
    protected DataTable GetMOData()
    {
        string Query = @"Select * From V_TSMORouting Where AUFNR = @AUFNR Order By PLNNR,PLNKN";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(HF_AUFNR.Value));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 取得已報工資料
    /// </summary>
    /// <returns>取得已報工資料</returns>
    protected DataTable GetTicketResultData()
    {
        string Query = @"Select * From T_TSTicketResult Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TickeID.Text.Trim()));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }
}