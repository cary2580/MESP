using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketDelete : System.Web.UI.Page
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
            //取得工單基本資料
            DataTable DT = GetMOData();

            if (DT.Rows.Count < 1)
                throw new Exception((string)GetLocalResourceObject("Str_Empty_AUFNR"));

            DataRow FirstRow = DT.Rows[0];

            string AUART = FirstRow["AUART"].ToString().Trim();
            string STATUS = FirstRow["STATUS"].ToString().Trim();

            string PLNNR = FirstRow["PLNNR"].ToString().Trim();
            string PLNAL = FirstRow["PLNAL"].ToString().Trim();

            Util.TS.MOStatus MOStatus = (Util.TS.MOStatus)Enum.Parse(typeof(Util.TS.MOStatus), STATUS);

            if (MOStatus == Util.TS.MOStatus.Issued && AUART != "ZP21")
                /* 系统上线初，除了試產無料號(ZP21)、輔助製程工單(ZR20)、試產有料號工單(ZP20)可以允許不發料，就可以產生流程卡 */
                /* 240711,与潘素平确认，輔助製程工單(ZR20)、試產有料號工單(ZP20)，需要加卡控发料才能打印*/
                throw new Exception((string)GetLocalResourceObject("Str_Error_MOStatus0"));
            else if (MOStatus == Util.TS.MOStatus.Closed)
                throw new Exception((string)GetLocalResourceObject("Str_Error_MOStatus2"));

            List<string> TicketList = GetTargetTicket();

            if (TicketList.Count < 1)
                throw new Exception((string)GetLocalResourceObject("Str_Empty_TargetTicket"));

            List<string> TicketReporttList = GetTargetTicketReport(TicketList);

            /* 如果成立，代表有流程卡有報工資料或是已上工，因此不允許被刪除 */
            if (TicketReporttList.Count > 0)
            {
                string ExceptionMessage = (string)GetLocalResourceObject("Str_Error_TargetTicketReport") + "<br>" + string.Join("<br>", TicketReporttList);

                throw new Exception(ExceptionMessage);
            }

            //必須要在檢查此機台編號是否為第一道工序，這樣才允許被刪除
            DataRow DeviceRow = Util.TS.GetDeviceRow(TB_MachineID.Text.Trim());

            if (DeviceRow == null)
                throw new Exception((string)GetLocalResourceObject("Str_Empty_DeviceRow"));

            if (!(bool)DeviceRow["IsFirstProcess"])
                throw new Exception((string)GetLocalResourceObject("Str_Error_DeviceNotFirstProcess"));

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            foreach (string Ticket in TicketList)
            {
                string Query = @"Delete T_TSTicketRouting Where TicketID = @TicketID";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(Ticket));

                DBA.AddCommandBuilder(dbcb);

                Query = @"Delete T_TSTicket Where TicketID = @TicketID";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(Ticket));

                DBA.AddCommandBuilder(dbcb);

                Query = @"Delete T_TSTicketResult Where TicketID = @TicketID";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(Ticket));

                DBA.AddCommandBuilder(dbcb);

                Query = @"Delete T_TSTicketResultSecondOperator Where TicketID = @TicketID";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(Ticket));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            //UpdateSAPAFKO();

            TB_TickeID.Text = string.Empty;

            TB_MachineID.Text = string.Empty;

            HF_AUFNR.Value = string.Empty;

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"));
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);
        }
    }

    /// <summary>
    /// 指定欲刪除流程卡號清單得到已報工或是上工流程卡或有開立出返工或隔離清單
    /// </summary>
    /// <param name="TargetTicket">欲刪除流程卡號清單</param>
    /// <returns>已報工或是上工流程卡號清單</returns>
    protected List<string> GetTargetTicketReport(List<string> TargetTicket)
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Query1 = @"Select TicketID From T_TSTicketCurrStatus Where TicketID in (";
        string Query2 = @"Select TicketID From T_TSTicketResult Where TicketID in (";
        string Query3 = @"Select TicketID From T_TSTicket Where TicketID in (";

        for (int i = 0; i < TargetTicket.Count; i++)
        {
            string ParameterName = "TicketID_" + i.ToString();

            Query1 += i > 0 ? "," + "@" + ParameterName : "@" + ParameterName;
            Query2 += i > 0 ? "," + "@" + ParameterName : "@" + ParameterName;
            Query3 += i > 0 ? "," + "@" + ParameterName : "@" + ParameterName;

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TargetTicket[i], ParameterName));
        }

        Query1 += ")";
        Query2 += ")";
        Query3 += ") And ParentTicketID <> ''";

        dbcb.CommandText = Query1 + " Union All " + Query2 + " Union All " + Query3;

        DataTable Result = CommonDB.ExecuteSelectQuery(dbcb);

        return Result.AsEnumerable().Select(Row => Row["TicketID"].ToString().Trim()).ToList();
    }

    /// <summary>
    /// 取得欲刪除的流程卡號
    /// </summary>
    /// <returns>流程卡號清單</returns>
    protected List<string> GetTargetTicket()
    {
        string Query = @"Select TicketID From T_TSTicket
                        Where Convert(int,BoxID) >= (
                        Select Convert(int,BoxID) From T_TSTicket
                        Where TicketID  = @TicketID And TicketTypeID = @TicketTypeID)
                        And AUFNR = @AUFNR ";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TickeID.Text.Trim()));

        dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.General).ToString()));

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(HF_AUFNR.Value));

        DataTable Result = CommonDB.ExecuteSelectQuery(dbcb);

        return Result.AsEnumerable().Select(Row => Row["TicketID"].ToString().Trim()).ToList();
    }

    /// <summary>
    /// 取得工單基本資料
    /// </summary>
    /// <returns></returns>
    private DataTable GetMOData()
    {
        string Query = @"Select * From V_TSMORouting Where AUFNR = @AUFNR Order By PLNNR,PLNKN";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(HF_AUFNR.Value));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 更新SAP工單總數量
    /// </summary>
    protected void UpdateSAPAFKO()
    {
        string Query = @"Select IsNull(Sum(Qty),0) From T_TSTicket Where AUFNR = @AUFNR And TicketTypeID = @TicketTypeID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(HF_AUFNR.Value));

        dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.General).ToString()));

        int TotalQty = (int)CommonDB.ExecuteScalar(dbcb);

        // 理論上不會成立，如果有事情就大條了
        if (TotalQty < 1)
            return;

        Sap.Data.Hana.HanaCommand Command = new Sap.Data.Hana.HanaCommand("Update AFPO Set PSMNG = ? Where AUFNR = ? And MANDT = ?");

        Command.Parameters.Add("PSMNG", TotalQty);
        Command.Parameters.Add("AUFNR", HF_AUFNR.Value);
        Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());

        Sap.Data.Hana.HanaCommand Command2 = new Sap.Data.Hana.HanaCommand("Update AFKO Set GAMNG = ? Where AUFNR = ? And MANDT = ?");

        Command2.Parameters.Add("GAMNG", TotalQty);
        Command2.Parameters.Add("AUFNR", HF_AUFNR.Value);
        Command2.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());

        SAP.ExecuteMultiCommand(new List<Sap.Data.Hana.HanaCommand>() { Command, Command2 });
    }
}