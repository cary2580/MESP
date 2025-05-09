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

public partial class TimeSheet_ProductionInspection_Create : System.Web.UI.Page
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
            CheckCanCreate();

            CheckTicketRouting();

            int CreateAccountID = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

            if (CreateAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(CreateAccountID))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            string Query = @"Insert Into T_TSProductionInspection (PIID,AUFNR,TicketID,Brand,InspectionQty,CreateAccountID) Values (@PIID,@AUFNR,@TicketID,@Brand,@InspectionQty,@CreateAccountID)";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspection"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            string PIID = BaseConfiguration.SerialObject[(short)23].取號();

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(PIID));

            dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["Brand"].copy(TB_Brand.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["InspectionQty"].copy(TB_InspectionQty.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(CreateAccountID));

            CommonDB.ExecuteSingleCommand(dbcb);

            HF_IsFinish.Value = true.ToStringValue();

            HF_IsRefresh.Value = HF_IsFinish.Value;

            HF_PIID.Value = PIID;

            HF_QuarantineQty.Value = TB_InspectionQty.Text.Trim();
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);
        }
    }

    /// <summary>
    /// 檢查是否可以新增送檢紀錄
    /// </summary>
    protected void CheckCanCreate()
    {
        string Query = string.Empty;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspection"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        //如果刻字號是空白的話，就檢查此工單是否已有送過
        if (string.IsNullOrEmpty(TB_Brand.Text.Trim()))
        {
            Query = @"Select Count(*) From T_TSTicket Inner Join T_TSProductionInspection On T_TSProductionInspection.AUFNR = T_TSTicket.AUFNR Where T_TSTicket.TicketID = @TicketID";

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text.Trim()));
        }
        else
        {
            Query = @"Select Count(*) From T_TSProductionInspection Where Brand = @Brand";

            dbcb.appendParameter(Schema.Attributes["Brand"].copy(TB_Brand.Text.Trim()));
        }

        dbcb.CommandText = Query;

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new Exception((string)GetLocalResourceObject("Str_Error_ProductionInspectionAUFNRRepeat"));
    }

    /// <summary>
    /// 檢查此流程卡路由是否可以新增送檢紀錄
    /// </summary>
    protected DataTable CheckTicketRouting()
    {
        string Query = @"Select Top 1
	                        Case
		                        When (V_TSMORouting.AUART <> 'ZP21') Then (Select Top 1 ProcessTypeID From T_TSBaseRouting Where (T_TSBaseRouting.PLNNR + '-' + T_TSBaseRouting .PLNAL + '-' + T_TSBaseRouting .PLNKN = V_TSMORouting.PLNNR + '-' + V_TSMORouting.PLNAL + '-' + V_TSMORouting.PLNKN) And T_TSBaseRouting.ProcessID = T_TSTicketRouting.ProcessID)
		                        Else Null
	                        End AS ProcessTypeID,
	                        T_TSTicket.TicketID,
	                        (Select Top 1 Brand From V_TSTicketResult Where V_TSTicketResult.TicketID = T_TSTicket.TicketID And V_TSTicketResult.Brand <> '' Order By V_TSTicketResult.ReportTimeEnd) As Brand,
	                        V_TSMORouting.*
                        From  T_TSTicket
                        Inner Join T_TSTicketRouting On T_TSTicketRouting.TicketID = T_TSTicket.TicketID
                        Inner Join V_TSMORouting On T_TSTicket.AUFNR = V_TSMORouting.AUFNR And T_TSTicketRouting.AUFPL = V_TSMORouting.AUFPL And T_TSTicketRouting.APLZL = V_TSMORouting.APLZL
                        Where T_TSTicket.TicketID = @TicketID
                        And T_TSTicketRouting.IsEnd = 0
                        Order By ProcessID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new Exception((string)GetLocalResourceObject("Str_Error_TicketRoutingEnd"));

        // 代表此流程卡有綁定群組技術器，就得再比對是不是已經做到全檢去了(全檢的工種ID=5)
        if (DT.Rows[0]["ProcessTypeID"].ToString().Trim() != "" && DT.Rows[0]["ProcessTypeID"].ToString().Trim() != "5")
            throw new Exception((string)GetLocalResourceObject("Str_Error_TicketRoutingProcessTypeID"));

        return DT;
    }
}