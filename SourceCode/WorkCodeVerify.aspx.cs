using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class WorkCodeVerify : System.Web.UI.Page
{
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            HF_Div.Value = Request["DivID"].Trim();
        if (Request["AlertMessageWidth"] != null)
            HF_AlertMessageWidth.Value = Request["AlertMessageWidth"].Trim();
    }

    protected void BT_Confirm_Click(object sender, EventArgs e)
    {
        try
        {
            DbCommandBuilder dbcb = new DbCommandBuilder("Select Count(*) From Base_Org.dbo.V_Employee Where WorkCode = @WorkCode And [PassWord] = @PassWord And status in (0,1,2,3) And accounttype = 0");
            dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, TB_WorkCode.Text.Trim()));
            dbcb.appendParameter(Util.GetDataAccessAttribute("PassWord", "NVarChar", 1000, TB_Password.Text.ToMD5String()));

            bool PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;

            if (!PassWordIsPass)
            {
                /* 如果OA帳號密碼找不到或是不正確再找一下系統本身使用者資料表是否帳號密碼正確(但還是要比對一下OA是否已經離職了) */
                dbcb = new DbCommandBuilder("Select Count(*) From T_Users Where WorkCode = @WorkCode And [PassWord] = @PassWord");

                dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, TB_WorkCode.Text.Trim()));
                dbcb.appendParameter(Util.GetDataAccessAttribute("PassWord", "NVarChar", 1000, TB_Password.Text.ToMD5String()));
                PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;

                /* 本身系統帳密正確但還是要比對OA是否已經離職了 */
                if (PassWordIsPass)
                {
                    dbcb = new DbCommandBuilder("Select Count(*) From Base_Org.dbo.V_Employee Where WorkCode = @WorkCode And status in (0,1,2,3) And accounttype = 0");
                    dbcb.appendParameter(Util.GetDataAccessAttribute("WorkCode", "NVarChar", 1000, TB_WorkCode.Text.Trim()));
                    PassWordIsPass = (int)CommonDB.ExecuteScalar(dbcb) > 0 ? true : false;
                }

                if (!PassWordIsPass)
                    throw new Exception((string)GetLocalResourceObject("Str_PasswordError"));
            }

            HF_IsVerifySuccess.Value = true.ToStringValue();
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);
        }
    }
}