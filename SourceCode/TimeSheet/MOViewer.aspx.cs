using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_MOViewer : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
        {
            string AUFNR = string.Empty;

            if (Request["AUFNR"] != null)
                AUFNR = Request["AUFNR"].Trim();

            if (string.IsNullOrEmpty(AUFNR))
            {
                Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Empty_AUFNR"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }

            HF_AUFNR.Value = Util.TS.ToAUFNR(AUFNR);

            LaodData();
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LaodData()
    {
        string Query = @"Select Top 1 *,
                        Case
	                        When (Select Count(*) From T_TSTicket Where AUFNR = V_TSMORouting.AUFNR) > 0 Then @Str_StatusName_InProcess
	                        When [STATUS] = '2' Then @Str_StatusName_Closed
	                        When [STATUS] = '1' Then @Str_StatusName_MIGO
	                        When [STATUS] = '0' Then @Str_StatusName_NoMIGO
                        End As [StatusName] From V_TSMORouting Where AUFNR = @AUFNR";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(HF_AUFNR.Value));

        dbcb.appendParameter(Util.GetDataAccessAttribute("Str_StatusName_InProcess", "nvarchar", 50, (string)GetLocalResourceObject("Str_StatusName_InProcess")));
        dbcb.appendParameter(Util.GetDataAccessAttribute("Str_StatusName_Closed", "nvarchar", 50, (string)GetLocalResourceObject("Str_StatusName_Closed")));
        dbcb.appendParameter(Util.GetDataAccessAttribute("Str_StatusName_MIGO", "nvarchar", 50, (string)GetLocalResourceObject("Str_StatusName_MIGO")));
        dbcb.appendParameter(Util.GetDataAccessAttribute("Str_StatusName_NoMIGO", "nvarchar", 50, (string)GetLocalResourceObject("Str_StatusName_NoMIGO")));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_NoMoData"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_AUFNR.Text = DT.Rows[0]["AUFNR"].ToString().Trim();

        TB_AUARTName.Text = DT.Rows[0]["AUARTName"].ToString().Trim();

        TB_StatusName.Text = DT.Rows[0]["StatusName"].ToString().Trim();

        double PSMNG = double.Parse(DT.Rows[0]["PSMNG"].ToString());

        TB_PSMNG.Text = ((int)PSMNG).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        double WEMNG = double.Parse(DT.Rows[0]["WEMNG"].ToString());

        TB_WEMNG.Text = ((int)WEMNG).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        TB_PLNBEZ.Text = DT.Rows[0]["PLNBEZ"].ToString().Trim();

        TB_KTEXT.Text = DT.Rows[0]["KTEXT"].ToString().Trim();

        TB_DISPO.Text = DT.Rows[0]["DISPO"].ToString().Trim();

        TB_ERDAT.Text = ((DateTime)DT.Rows[0]["ERDAT"]).ToCurrentUICultureString();

        TB_FTRMI.Text = ((DateTime)DT.Rows[0]["FTRMI"]).ToCurrentUICultureString();

        TB_GSTRP.Text = ((DateTime)DT.Rows[0]["GSTRP"]).ToCurrentUICultureString();

        TB_GLTRP.Text = ((DateTime)DT.Rows[0]["GLTRP"]).ToCurrentUICultureString();

        TB_VERID.Text = DT.Rows[0]["VERID"].ToString().Trim();

        TB_PLNNR.Text = DT.Rows[0]["PLNNR"].ToString().Trim();

        TB_PLNAL.Text = DT.Rows[0]["PLNAL"].ToString().Trim();

        TB_ZEINR.Text = DT.Rows[0]["ZEINR"].ToString().Trim();

        TB_FERTH.Text = DT.Rows[0]["FERTH"].ToString().Trim();

        int ScrapQty = GetScrapQty();

        TB_ScrapQty.Text = ScrapQty.ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        double CompletionRate = (WEMNG + ScrapQty) / PSMNG;

        TB_CompletionRate.Text = CompletionRate.ToString("P", System.Threading.Thread.CurrentThread.CurrentUICulture);

        int LastProcessGoodQty = GetLastProcessGoodQty();

        int NotGoInWEMNG = LastProcessGoodQty - (int)WEMNG;

        TB_NotGoInWEMNG.Text = NotGoInWEMNG.ToString();

        DDL_IsPreClose.Enabled = (CompletionRate >= 0.998 && NotGoInWEMNG < 1);

        if (DDL_IsPreClose.Enabled && (bool)DT.Rows[0]["IsPreClose"])
            DDL_IsPreClose.SelectedIndex = 1;

        BT_Save.Visible = DDL_IsPreClose.Enabled;

        BT_Save.Enabled = DDL_IsPreClose.Enabled;
    }

    /// <summary>
    /// 取得已核准報廢數量
    /// </summary>
    protected int GetScrapQty()
    {
        string Query = @"Select IsNull(Sum(T_TSTicketResult.ScrapQty),0) 
                        From T_TSTicketResult Inner Join T_TSTicket On T_TSTicketResult.TicketID = T_TSTicket.TicketID 
                        Where T_TSTicket.AUFNR = @AUFNR And Datediff(Day,T_TSTicketResult.ApprovalTime,getdate()) >= 0";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(HF_AUFNR.Value));

        return (int)CommonDB.ExecuteScalar(dbcb);
    }

    /// <summary>
    /// 取得末站良品數量
    /// </summary>
    /// <returns></returns>
    protected int GetLastProcessGoodQty()
    {
        string Query = @"Select 
                        IsNull(Sum(T_TSTicketResult.GoodQty),0)
                        From T_TSTicket
                        Inner Join T_TSTicketResult On T_TSTicketResult.TicketID = T_TSTicket.TicketID And T_TSTicketResult.ProcessID = (Select Max(ProcessID) From T_TSTicketRouting Where T_TSTicketRouting.TicketID = T_TSTicket.TicketID)
                        Where T_TSTicket.AUFNR = @AUFNR And Datediff(Day,T_TSTicketResult.ApprovalTime,getdate()) >= 0 ";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(HF_AUFNR.Value));

        return (int)CommonDB.ExecuteScalar(dbcb);
    }

    protected void BT_Save_Click(object sender, EventArgs e)
    {
        try
        {
            string Query = @"Update T_TSSAPAFKO Set IsPreClose = @IsPreClose Where AUFNR = @AUFNR";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(HF_AUFNR.Value));

            dbcb.appendParameter(Schema.Attributes["IsPreClose"].copy(DDL_IsPreClose.SelectedValue));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true);

            return;
        }
    }
}