using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class WM_PalletConfirm : System.Web.UI.Page
{
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void BT_Confirm_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (string.IsNullOrEmpty(TB_PalletNo.Text.Trim()) || string.IsNullOrEmpty(TB_BoxNo.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPallet"];

            string Query = @"Select T_WMProductBox.*,T_WMProductPallet.IsConfirm From T_WMProductPallet Inner Join T_WMProductBox On T_WMProductPallet.PalletNo = T_WMProductBox.PalletNo
                            Where T_WMProductPallet.PalletNo = @PalletNo";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(TB_PalletNo.Text.Trim()));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_DataNotInWarehouse"));

            if (DT.AsEnumerable().Where(Row => (bool)Row["IsConfirm"]).Count() > 0)
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_RepeatPalletConfirm"));

            if (DT.AsEnumerable().Where(Row => Row["BoxNo"].ToString().Trim() == TB_BoxNo.Text.Trim()).Count() < 1)
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_PalletDontHaveBoxNo"));

            Query = @"Update T_WMProductPallet Set IsConfirm = 1 Where PalletNo = @PalletNo";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(TB_PalletNo.Text.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            TB_PalletNo.Text = "";

            TB_BoxNo.Text = "";

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_ConfirmSuccessAlertMessage"), true);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true);

            return;
        }
    }
}