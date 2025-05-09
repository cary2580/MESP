using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_DeliveryLocation_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["LocationID"] != null)
                HF_LocationID.Value = Request["LocationID"].Trim();

            bool IsNewData = string.IsNullOrEmpty(Request["LocationID"]);

            if (!IsNewData)
                LoadData();

            HF_IsNewData.Value = IsNewData.ToStringValue();
        }
    }

    /// <summary>
    /// 载入资料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select 
                         LocationName,
                         SortID
                         From T_WMDeliveryLocation
                         Where LocationID = @LocationID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMDeliveryLocation"];

        dbcb.appendParameter(Schema.Attributes["LocationID"].copy(HF_LocationID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_LocationName.Text = DT.Rows[0]["LocationName"].ToString().Trim();
        TB_SortID.Text = DT.Rows[0]["SortID"].ToString().Trim();
    }

    /// <summary>
    /// 新增和修改事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void BT_Save_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (IsDeliveryLocationRepeat())
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_DataRepeat"));

            string Query = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMDeliveryLocation"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            if (HF_IsNewData.Value.ToBoolean())
            {
                string LocationID = BaseConfiguration.SerialObject[(short)29].取號();

                Query = @"Insert Into T_WMDeliveryLocation (LocationID,LocationName,SortID) Values (@LocationID,@LocationName,@SortID)";

                dbcb.appendParameter(Schema.Attributes["LocationID"].copy(LocationID));
            }
            else
            {
                Query = @"Update T_WMDeliveryLocation Set LocationName = @LocationName,SortID = @SortID Where LocationID = @LocationID";

                dbcb.appendParameter(Schema.Attributes["LocationID"].copy(HF_LocationID.Value));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["LocationName"].copy(TB_LocationName.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["SortID"].copy(TB_SortID.Text.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true);

            return;
        }
    }

    /// <summary>
    /// 删除按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (IsDeliveryLocationUsed())
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_DataNotDeleteMessage"));

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMDeliveryLocation"];

            string Query = @"Delete From T_WMDeliveryLocation Where LocationID = @LocationID";

            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.appendParameter(Schema.Attributes["LocationID"].copy(HF_LocationID.Value));

            dbcb.CommandText = Query;

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, false);
        }
    }

    /// <summary>
    /// 出货地点名称是否使用过
    /// </summary>
    /// <returns>是否能删除</returns>
    protected bool IsDeliveryLocationUsed()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPallet"];

        string Query = @"Select Count(*) From T_WMProductPallet Where DeliveryLocationID = @DeliveryLocationID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DeliveryLocationID"].copy(HF_LocationID.Value));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 出货地点名称是否重复
    /// </summary>
    /// <returns>是否重复</returns>
    protected bool IsDeliveryLocationRepeat()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMDeliveryLocation"];

        string Query = @"Select Count(*) From T_WMDeliveryLocation Where LocationName = @LocationName And LocationID <> @LocationID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["LocationName"].copy(TB_LocationName.Text.Trim()));

        dbcb.appendParameter(Schema.Attributes["LocationID"].copy(HF_LocationID.Value));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }
}