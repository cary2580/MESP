using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;
using Sap.Data.Hana;

public partial class TimeSheet_BaseRouting_M : System.Web.UI.Page
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

            if (Request["ProcessID"] != null)
                HF_ProcessID.Value = Request["ProcessID"].Trim();

            if (Request["IsModify"] != null)
                HF_IsModify.Value = bool.Parse(Request["IsModify"].Trim()).ToStringValue();

            HF_IsTSProcess.Value = true.ToStringValue();

            LoadData();
        }
    }


    protected void LoadData()
    {
        DataTable BaseRouting_DT = GetBaseRoutingData();

        if (BaseRouting_DT.Rows.Count == 1)
        {
            HF_PLNKN.Value = BaseRouting_DT.Rows[0]["PLNKN"].ToString().Trim();

            TB_VORNR.Text = BaseRouting_DT.Rows[0]["VORNR"].ToString().Trim();

            HF_ARBID.Value = BaseRouting_DT.Rows[0]["ARBID"].ToString().Trim();

            TB_ARBPL.Text = BaseRouting_DT.Rows[0]["ARBPL"].ToString().Trim();

            TB_ARBPL_KTEXT.Text = BaseRouting_DT.Rows[0]["ARBPL_KTEXT"].ToString().Trim();

            TB_VERAN.Text = BaseRouting_DT.Rows[0]["VERAN"].ToString().Trim();

            TB_VERAN_KTEXT.Text = BaseRouting_DT.Rows[0]["VERAN_KTEXT"].ToString().Trim();

            TB_VGW01.Text = BaseRouting_DT.Rows[0]["VGW01"].ToString().Trim();

            TB_VGW02.Text = BaseRouting_DT.Rows[0]["VGW02"].ToString().Trim();

            TB_USR00.Text = BaseRouting_DT.Rows[0]["USR00"].ToString().Trim();

            TB_KTEXT.Text = BaseRouting_DT.Rows[0]["KTEXT"].ToString().Trim();

            TB_LTXA1.Text = BaseRouting_DT.Rows[0]["LTXA1"].ToString().Trim();

            //修改
            if (HF_IsModify.Value.ToString().ToBoolean())
            {
                TB_ProcessID.Text = int.Parse(BaseRouting_DT.Rows[0]["ProcessID"].ToString().Trim()).ToString();

                BT_Submit.Text = (string)GetGlobalResourceObject("GlobalRes", "Str_BT_SubmitName");

                BT_Delete.Visible = true;
            }
            //新增
            else
            {
                TB_ProcessID.Text = (int.Parse(BaseRouting_DT.Rows[0]["ProcessID"].ToString().Trim()) + 1).ToString();

                BT_Submit.Text = (string)GetGlobalResourceObject("GlobalRes", "Str_BT_AddName");

                BT_Delete.Visible = false;

                TB_LTXA1.Text = string.Empty;
            }
        }
    }

    /// <summary>
    /// 取得已設定報工工序資料
    /// </summary>
    /// <returns>已設定報工工序資料</returns>
    protected DataTable GetBaseRoutingData()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

        string Query = @"Select PLNNR,PLNAL,PLNKN,VORNR,ProcessID,
		                        KTEXT,LTXA1,ARBID,ARBPL,ARBPL_KTEXT,VERAN,VERAN_KTEXT,VGW01,VGW02,USR00,IsTSProcess
                        From T_TSBaseRouting Where PLNNR = @PLNNR And PLNAL = @PLNAL And ProcessID = @ProcessID";

        dbcb.appendParameter(Schema.Attributes["LTXA1"].copy(TB_LTXA1.Text));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text));
        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

        dbcb.CommandText = Query;

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        return DT;
    }
    /// <summary>
    /// 更新當前工序
    /// </summary>
    protected void UpdateBaseRouting()
    {
        DBAction DBA = new DBAction();

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

        string Query = @"Update T_TSBaseRouting Set LTXA1 = @LTXA1, ARBID = @ARBID,ARBPL = @ARBPL,ARBPL_KTEXT = @ARBPL_KTEXT,VERAN = @VERAN,VERAN_KTEXT = @VERAN_KTEXT, VGW01 = @VGW01, VGW02 = @VGW02, USR00 = @USR00 Where PLNNR = @PLNNR And PLNAL = @PLNAL And ProcessID = @ProcessID";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["LTXA1"].copy(TB_LTXA1.Text));
        dbcb.appendParameter(Schema.Attributes["ARBID"].copy(HF_ARBID.Value.Trim()));
        dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(TB_ARBPL.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["ARBPL_KTEXT"].copy(TB_ARBPL_KTEXT.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["VERAN"].copy(TB_VERAN.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["VERAN_KTEXT"].copy(TB_VERAN_KTEXT.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));
        dbcb.appendParameter(Schema.Attributes["VGW01"].copy(TB_VGW01.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["VGW02"].copy(TB_VGW02.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["USR00"].copy(TB_USR00.Text.Trim()));

        DBA.AddCommandBuilder(dbcb);

        DBA.Execute();
    }
    /// <summary>
    /// 新增工序
    /// </summary>
    protected void InsertBaseRouting()
    {
        DBAction DBA = new DBAction();

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

        //需要先把要插入Row的工序碼先加1
        string Query = string.Empty;

        if (DDL_IsInsertAfterProcessID.SelectedValue.ToBoolean())
            Query = @"Update T_TSBaseRouting Set ProcessID = ProcessID + 1 Where PLNNR = @PLNNR And PLNAL = @PLNAL And ProcessID > @ProcessID";
        else
            Query = @"Update T_TSBaseRouting Set ProcessID = ProcessID + 1 Where PLNNR = @PLNNR And PLNAL = @PLNAL And ProcessID >= @ProcessID";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

        DBA.AddCommandBuilder(dbcb);

        //需要先把要插入新工序
        Query = @"Insert Into T_TSBaseRouting (PLNNR,PLNAL,PLNKN,ProcessID,VORNR,KTEXT,LTXA1,ARBID,ARBPL,ARBPL_KTEXT,VERAN,VERAN_KTEXT,VGW01,VGW02,USR00,IsTSProcess)
                        Values (@PLNNR,@PLNAL,@PLNKN,@ProcessID,@VORNR,@KTEXT,@LTXA1,@ARBID,@ARBPL,@ARBPL_KTEXT,@VERAN,@VERAN_KTEXT,@VGW01,@VGW02,@USR00,@IsTSProcess)";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(HF_PLNKN.Value));
        if (DDL_IsInsertAfterProcessID.SelectedValue.ToBoolean())
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy((int.Parse(HF_ProcessID.Value) + 1)));
        else
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy((int.Parse(HF_ProcessID.Value))));
        dbcb.appendParameter(Schema.Attributes["VORNR"].copy(TB_VORNR.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["KTEXT"].copy(TB_KTEXT.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["LTXA1"].copy(TB_LTXA1.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["ARBID"].copy(HF_ARBID.Value.Trim()));
        dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(TB_ARBPL.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["ARBPL_KTEXT"].copy(TB_ARBPL_KTEXT.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["VERAN"].copy(TB_VERAN.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["VERAN_KTEXT"].copy(TB_VERAN_KTEXT.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["VGW01"].copy(TB_VGW01.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["VGW02"].copy(TB_VGW02.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["USR00"].copy(TB_USR00.Text.Trim()));
        dbcb.appendParameter(Schema.Attributes["IsTSProcess"].copy(HF_IsTSProcess.Value.ToBoolean()));

        DBA.AddCommandBuilder(dbcb);

        DBA.AddCommandBuilder(InsertProcessDeviceGroup());

        DBA.Execute();
    }

    /// <summary>
    /// 新增報工模組工序設備群組表
    /// </summary>
    protected DbCommandBuilder[] InsertProcessDeviceGroup()
    {
        DbCommandBuilder[] dbcbList = new DbCommandBuilder[2];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProcessDeviceGroup"];

        //需要先把要插入Row的工序碼先加1
        string Query = @"Update T_TSProcessDeviceGroup Set ProcessID = ProcessID + 1 Where PLNNR = @PLNNR And PLNAL = @PLNAL And ProcessID > @ProcessID";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

        dbcbList[0] = dbcb;

        //需要先把要插入新工序
        Query = @"Insert Into T_TSProcessDeviceGroup (PLNNR,PLNAL,PLNKN,ProcessID,VORNR,DeviceGroupID)
                        Values (@PLNNR,@PLNAL,@PLNKN,@ProcessID,@VORNR,@DeviceGroupID)";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text));
        dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(HF_PLNKN.Value));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy((int.Parse(HF_ProcessID.Value) + 1)));
        dbcb.appendParameter(Schema.Attributes["VORNR"].copy(TB_VORNR.Text));
        dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(string.Empty));

        dbcbList[1] = dbcb;

        return dbcbList;
    }
    /// <summary>
    /// 刪除工序
    /// </summary>
    protected void DeleBaseRouting()
    {
        DBAction DBA = new DBAction();

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

        //需要先刪除
        string Query = @"Delete T_TSBaseRouting Where PLNNR = @PLNNR And PLNAL = @PLNAL And ProcessID = @ProcessID";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

        DBA.AddCommandBuilder(dbcb);

        //把刪除工序碼以後的工序碼-1
        Query = @"Update T_TSBaseRouting Set ProcessID = ProcessID - 1 Where PLNNR = @PLNNR And PLNAL = @PLNAL And ProcessID > @ProcessID";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

        DBA.AddCommandBuilder(dbcb);

        DBA.AddCommandBuilder(DeleProcessDeviceGroup());

        DBA.Execute();
    }

    /// <summary>
    /// 刪除報工模組工序設備群組表
    /// </summary>
    protected DbCommandBuilder[] DeleProcessDeviceGroup()
    {
        DbCommandBuilder[] dbcbList = new DbCommandBuilder[2];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProcessDeviceGroup"];

        //需要先刪除
        string Query = @"Delete T_TSProcessDeviceGroup Where PLNNR = @PLNNR And PLNAL = @PLNAL And ProcessID = @ProcessID";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text));
        dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(HF_PLNKN.Value));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

        dbcbList[0] = dbcb;

        //把刪除工序碼以後的工序碼-1
        Query = @"Update T_TSProcessDeviceGroup Set ProcessID = ProcessID - 1 Where PLNNR = @PLNNR And PLNAL = @PLNAL And ProcessID > @ProcessID";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(TB_PLNNR.Text));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(TB_PLNAL.Text));
        dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(HF_PLNKN.Value));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

        dbcbList[1] = dbcb;

        return dbcbList;
    }

    /// <summary>
    /// 重新載入工作中心內碼(因為工作中心開放User修改，所以必要根據打的資料去SAP拿回來)
    /// </summary>
    protected void ARBIDReLoad()
    {
        string Query = @"Select OBJID From CRHD Where CRHD.MANDT = ? And WERKS = ? And CRHD.ARBPL = ?";

        HanaCommand Command = new HanaCommand(Query);

        Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
        Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());
        Command.Parameters.Add("ARBPL", TB_ARBPL.Text.Trim());

        DataTable DT = SAP.GetSelectSAPData(Command);

        if (DT.Rows.Count < 1)
            throw new Exception((string)GetLocalResourceObject("Str_Empty_ARBID"));

        HF_ARBID.Value = DT.Rows[0]["OBJID"].ToString().Trim();
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            ARBIDReLoad();

            if (HF_IsModify.Value.ToBoolean())
                UpdateBaseRouting();
            else
                InsertBaseRouting();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"),
                true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true);
        }

    }
    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;
        try
        {
            DeleBaseRouting();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"),
                true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true);
        }
    }
}