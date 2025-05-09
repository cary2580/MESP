using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_MATNRParameters_M : System.Web.UI.Page
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
            if (Request["MATNR"] != null)
                TB_MATNR.Text = Request["MATNR"].Trim();

            LoadData();
        }
    }

    /// <summary>
    /// 加载资料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select 
	                        MATNRResult.MAKTX,
	                        IsNull(T_TSMATNRParameters.HangPointQty,0) As HangPointQty,
                            T_TSMATNRParameters.ProductLGORT,
                            IsNull(T_TSMATNRParameters.AUFNRStdWorkDay,0) As AUFNRStdWorkDay
                        From 
                        (Select MATNR,MAKTX From T_TSSAPMAPL Group By MATNR,MAKTX) As MATNRResult 
                        Left Join T_TSMATNRParameters On T_TSMATNRParameters.MATNR = MATNRResult.MATNR
                        Where MATNRResult.MATNR = @MATNR";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPMAPL"];

        dbcb.appendParameter(Schema.Attributes["MATNR"].copy(TB_MATNR.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_NoMATNRRow"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_MAKTX.Text = DT.Rows[0]["MAKTX"].ToString().Trim();

        TB_HangPointQty.Text = DT.Rows[0]["HangPointQty"].ToString().Trim();

        DataTable DT_Warehouse = GetSAPT001L();

        DDL_ProductLGORT.DataValueField = "LGORT";

        DDL_ProductLGORT.DataTextField = "LGOBE";

        DDL_ProductLGORT.DataSource = DT_Warehouse;

        DDL_ProductLGORT.DataBind();

        DDL_ProductLGORT.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));

        if (!string.IsNullOrEmpty(DT.Rows[0]["ProductLGORT"].ToString().Trim()))
            DDL_ProductLGORT.SelectedValue = DT.Rows[0]["ProductLGORT"].ToString().Trim();

        TB_AUFNRStdWorkDay.Text = DT.Rows[0]["AUFNRStdWorkDay"].ToString().Trim();
    }

    /// <summary>
    /// 取得倉庫別資料表
    /// </summary>
    /// <returns>倉庫別資料表</returns>
    protected DataTable GetSAPT001L()
    {
        string Query = @"Select * From T_SAPT001L";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            string Query = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMATNRParameters"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            if (IsExistMATNRInParameters())
                Query = @"Update T_TSMATNRParameters Set HangPointQty = @HangPointQty,ProductLGORT = @ProductLGORT, AUFNRStdWorkDay = @AUFNRStdWorkDay Where MATNR = @MATNR";
            else
                Query = @"Insert Into T_TSMATNRParameters(MATNR,HangPointQty,ProductLGORT,AUFNRStdWorkDay) Values (@MATNR,@HangPointQty,@ProductLGORT,@AUFNRStdWorkDay)";

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["MATNR"].copy(TB_MATNR.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["HangPointQty"].copy(TB_HangPointQty.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["ProductLGORT"].copy(DDL_ProductLGORT.SelectedValue));
            dbcb.appendParameter(Schema.Attributes["AUFNRStdWorkDay"].copy(TB_AUFNRStdWorkDay.Text.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_ModifySuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, false);
        }
    }

    /// <summary>
    /// 检查这个物料是否已经存在物料参数表了
    /// </summary>
    /// <returns>是否已经在物料参数表了</returns>
    protected bool IsExistMATNRInParameters()
    {
        string Query = @"Select Count(*) From T_TSMATNRParameters Where MATNR = @MATNR";

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMATNRParameters"];

        dbcb.CommandText = Query;

        dbcb.appendParameter(Schema.Attributes["MATNR"].copy(TB_MATNR.Text.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }
}