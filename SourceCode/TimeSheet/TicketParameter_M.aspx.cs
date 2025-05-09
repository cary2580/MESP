using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketParameter_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["PLNNR"] != null)
                TB_PLNNR.Text = Request["PLNNR"].Trim();
            if (Request["PLNAL"] != null)
                TB_PLNAL.Text = Request["PLNAL"].Trim();
            if (Request["MATNR"] != null)
                TB_MATNR.Text = Request["MATNR"].Trim();

            LoadData();
        }
    }

    /// <summary>
    /// 载入资料
    /// </summary>
    protected void LoadData()
    {
        Util.LoadDDLData(DLL_TicketPrintSizeName, "TicketPrintSize");

        string Query = @"Select MAKTX,MaxTicketBox,MaxTicketBoxQty,TicketPrintSize From T_TSSAPMAPL Where PLNNR = @PLNNR And PLNAL = @PLNAL And MATNR = @MATNR";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPMAPL"];

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["MATNR"].copy(TB_MATNR.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_NoMATNRRow"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_MAKTX.Text = DT.Rows[0]["MAKTX"].ToString().Trim();
        TB_MaxTicketBox.Text = DT.Rows[0]["MaxTicketBox"].ToString().Trim();
        TB_MaxTicketBoxQtyName.Text = DT.Rows[0]["MaxTicketBoxQty"].ToString().Trim();
        DLL_TicketPrintSizeName.SelectedValue = DT.Rows[0]["TicketPrintSize"].ToString().Trim();
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        string Query = "Update T_TSSAPMAPL Set MaxTicketBox = @MaxTicketBox,MaxTicketBoxQty = @MaxTicketBoxQty,TicketPrintSize = @TicketPrintSize Where PLNNR = @PLNNR And PLNAL = @PLNAL And MATNR = @MATNR";

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPMAPL"];

        dbcb.CommandText = Query;

        dbcb.appendParameter(Schema.Attributes["MaxTicketBox"].copy(TB_MaxTicketBox.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["MaxTicketBoxQty"].copy(TB_MaxTicketBoxQtyName.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["TicketPrintSize"].copy(DLL_TicketPrintSizeName.SelectedValue.Trim()));
        dbcb.appendParameter(Schema.Attributes["MATNR"].copy(TB_MATNR.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text.Trim()));

        CommonDB.ExecuteSingleCommand(dbcb);

        Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_ModifySuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
    }
}