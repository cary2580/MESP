using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_BrandSet : System.Web.UI.Page
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
            string ExceptionGoToPage = ResolveClientUrl("~/TimeSheet/WorkStationGoIn.aspx");

            try
            {
                if (Request.Cookies["TS_WorkCode"] != null)
                    TB_WorkCode.Text = Request.Cookies["TS_WorkCode"].Value;

                if (string.IsNullOrEmpty(TB_WorkCode.Text))
                    throw new Exception((string)GetLocalResourceObject("Str_Error_WorkStationGoIn"));

                LoadCurrBrand();
            }
            catch (Exception ex)
            {
                Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false, "window.location.href='" + ExceptionGoToPage + "'");

                return;
            }
        }
    }

    /// <summary>
    /// 載入前設定的刻字號
    /// </summary>
    protected void LoadCurrBrand()
    {
        string Query = @"Select Top 1 * From T_TSBrand Where DeviceID = @DeviceID And IsEnable = 1 Order By SerialNo";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBrand"];

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return;

        TB_CurrBrandNo.Text = DT.Rows[0]["Brand"].ToString().Trim();
    }

    protected void BT_BrandSet_Click(object sender, EventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(HF_DeviceID.Value.Trim()))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MachineID"));

            if (string.IsNullOrEmpty(TB_BrandNo.Text.Trim()))
                throw new Exception((string)GetLocalResourceObject("Str_Empty_BrandNo"));

            if (string.IsNullOrEmpty(TB_MPWorkCode.Text.Trim()) || string.IsNullOrEmpty(TB_QAWorkCode.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkCode"));

            if ((TB_MPWorkCode.Text.Trim() == TB_QAWorkCode.Text.Trim()) || (TB_WorkCode.Text.Trim() == TB_MPWorkCode.Text.Trim()) || (TB_WorkCode.Text.Trim() == TB_QAWorkCode.Text.Trim()))
                throw new Exception((string)GetLocalResourceObject("Str_WordCodeSame"));

            int CreateAccountID = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

            if (CreateAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(CreateAccountID))
                throw new Exception((string)GetLocalResourceObject("Str_Empty_CreateAccountID"));

            int MPAccountID = BaseConfiguration.GetAccountID(TB_MPWorkCode.Text.Trim());

            if (MPAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(MPAccountID))
                throw new Exception((string)GetLocalResourceObject("Str_Empty_MPAccountID"));

            int QAAccountID = BaseConfiguration.GetAccountID(TB_QAWorkCode.Text.Trim());

            if (QAAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(QAAccountID))
                throw new Exception((string)GetLocalResourceObject("Str_Empty_QAAccountID"));

            if (!IsBrandDevice())
                throw new Exception((string)GetLocalResourceObject("Str_Error_DevicePermissionDenied"));

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBrand"];

            string Query = @"Update T_TSBrand Set IsEnable = 0 Where DeviceID = @DeviceID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Insert Into T_TSBrand (DeviceID,SerialNo,Brand,CreateAccountID,MPAccountID,QAAccountID) Values (@DeviceID,(Select IsNull(Max(SerialNo) + 1,1) From T_TSBrand Where DeviceID = @DeviceID),@Brand,@CreateAccountID,@MPAccountID,@QAAccountID)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

            dbcb.appendParameter(Schema.Attributes["Brand"].copy(TB_BrandNo.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(CreateAccountID));

            dbcb.appendParameter(Schema.Attributes["MPAccountID"].copy(MPAccountID));

            dbcb.appendParameter(Schema.Attributes["QAAccountID"].copy(QAAccountID));

            DBA.AddCommandBuilder(dbcb);

            /*
                要把當前上工的設備刻字號更換成新設定的刻字號，這情況只會Update當前這台機器而已
            */
            dbcb = new DbCommandBuilder(@"Update T_TSTicketCurrStatus Set Brand = @Brand Where DeviceID = @DeviceID");

            Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

            dbcb.appendParameter(Schema.Attributes["Brand"].copy(TB_BrandNo.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "window.location.href='" + ResolveClientUrl("~/TimeSheet/TicketGoIn.aspx") + "'");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message);

            return;
        }
    }

    protected void BT_BrandDisable_Click(object sender, EventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(HF_DeviceID.Value.Trim()))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MachineID"));

            if (string.IsNullOrEmpty(TB_MPWorkCode.Text.Trim()) || string.IsNullOrEmpty(TB_QAWorkCode.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkCode"));

            if ((TB_MPWorkCode.Text.Trim() == TB_QAWorkCode.Text.Trim()) || (TB_WorkCode.Text.Trim() == TB_MPWorkCode.Text.Trim()) || (TB_WorkCode.Text.Trim() == TB_QAWorkCode.Text.Trim()))
                throw new Exception((string)GetLocalResourceObject("Str_WordCodeSame"));

            int CreateAccountID = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

            if (CreateAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(CreateAccountID))
                throw new Exception((string)GetLocalResourceObject("Str_Empty_CreateAccountID"));

            int MPAccountID = BaseConfiguration.GetAccountID(TB_MPWorkCode.Text.Trim());

            if (MPAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(MPAccountID))
                throw new Exception((string)GetLocalResourceObject("Str_Empty_MPAccountID"));

            int QAAccountID = BaseConfiguration.GetAccountID(TB_QAWorkCode.Text.Trim());

            if (QAAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(QAAccountID))
                throw new Exception((string)GetLocalResourceObject("Str_Empty_QAAccountID"));

            if (!IsBrandDevice())
                throw new Exception((string)GetLocalResourceObject("Str_Error_DevicePermissionDenied"));

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBrand"];

            string Query = @"Update T_TSBrand Set IsEnable = 0 Where DeviceID = @DeviceID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            /*
                要把當前上工的設備刻字號更換空白，這情況只會Update當前這台機器而已
            */
            dbcb = new DbCommandBuilder(@"Update T_TSTicketCurrStatus Set Brand = @Brand Where DeviceID = @DeviceID");

            Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

            dbcb.appendParameter(Schema.Attributes["Brand"].copy(string.Empty));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false, "window.location.href='" + ResolveClientUrl("~/TimeSheet/TicketGoIn.aspx") + "'");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message);

            return;
        }
    }

    /// <summary>
    /// 取得此設備是否允許設定刻字號
    /// </summary>
    /// <returns>是否允許設定刻字號</returns>
    protected bool IsBrandDevice()
    {
        string Query = @"Select IsBrand From T_TSDevice Where DeviceID = @DeviceID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDevice"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new Exception((string)GetLocalResourceObject("Str_Error_DeviceID"));

        return (bool)DT.Rows[0]["IsBrand"];
    }
}