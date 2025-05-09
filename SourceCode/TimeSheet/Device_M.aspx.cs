using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_Device_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["DeviceID"] != null)
                HF_DeviceID.Value = Request["DeviceID"].Trim();

            LoadData();

            LoadSectionName();
        }

        BT_Delete.Visible = !(string.IsNullOrEmpty(HF_DeviceID.Value));
    }

    /// <summary>
    /// 载入资料
    /// </summary>
    protected void LoadData()
    {
        if (string.IsNullOrEmpty(HF_DeviceID.Value))
            return;

        string Query = @"Select * From T_TSDevice Where DeviceID = @DeviceID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDevice"];

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_NoDeviceRow"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        TB_MachineID.Text = DT.Rows[0]["MachineID"].ToString().Trim();
        TB_MachineName.Text = DT.Rows[0]["MachineName"].ToString().Trim();
        TB_MachineAlias.Text = DT.Rows[0]["MachineAlias"].ToString().Trim();
        TB_Location.Text = DT.Rows[0]["Location"].ToString().Trim();
        DDL_IsMultipleGoIn.SelectedValue = ((bool)DT.Rows[0]["IsMultipleGoIn"]).ToStringValue();
        DDL_IsApprovalByDevice.SelectedValue = ((bool)DT.Rows[0]["IsApprovalByDevice"]).ToStringValue();
        DDL_IsBrand.SelectedValue = ((bool)DT.Rows[0]["IsBrand"]).ToStringValue(); ;
        DDL_IsFirstProcess.SelectedValue = ((bool)DT.Rows[0]["IsFirstProcess"]).ToStringValue();
        DDL_IsPrintPackage.SelectedValue = ((bool)DT.Rows[0]["IsPrintPackage"]).ToStringValue();
        TB_OnWorkBeforeMinute.Text = DT.Rows[0]["OnWorkBeforeMinute"].ToString().Trim();
        TB_OffWorkBeforeMinute.Text = DT.Rows[0]["OffWorkBeforeMinute"].ToString().Trim();
        TB_Power.Text = DT.Rows[0]["Power"].ToString().Trim();
        TB_PowerCoefficient.Text = DT.Rows[0]["PowerCoefficient"].ToString().Trim();
        TB_EstimateCurrent.Text = DT.Rows[0]["EstimateCurrent"].ToString().Trim();
        DDL_IsCheckPreviousMOFinish.SelectedValue = ((bool)DT.Rows[0]["IsCheckPreviousMOFinish"]).ToStringValue();
        DDL_IsCheckProductionInspection.SelectedValue = ((bool)DT.Rows[0]["IsCheckProductionInspection"]).ToStringValue();
        DDL_IsCheckSequenceDeclare.SelectedValue = ((bool)DT.Rows[0]["IsCheckSequenceDeclare"]).ToStringValue();
        DDL_IsSuspension.SelectedValue = ((bool)DT.Rows[0]["IsSuspension"]).ToStringValue();
        DDL_SectionID.SelectedValue = DT.Rows[0]["SectionID"].ToString().Trim();
        TB_SortID.Text = DT.Rows[0]["SortID"].ToString().Trim();
    }

    /// <summary>
    /// 载入课级部门资料
    /// </summary>
    private void LoadSectionName()
    {
        string Query = "Select SectionID,SectionName From V_TSSection Order By SortID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_SectionID.DataValueField = "SectionID";

        DDL_SectionID.DataTextField = "SectionName";

        DDL_SectionID.DataSource = DT;

        DDL_SectionID.DataBind();

        DDL_SectionID.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }

    protected void BT_Add_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (IsMachineIDRepeat())
                throw new Exception((string)GetLocalResourceObject("Str_Error_MachineIDRepeat"));

            int OnWorkBeforeMinute = 0;

            int OffWorkBeforeMinute = 0;

            if (!int.TryParse(TB_OnWorkBeforeMinute.Text.Trim(), out OnWorkBeforeMinute))
                throw new Exception((string)GetLocalResourceObject("Str_Error_OnWorkBeforeMinute"));
            if (!int.TryParse(TB_OffWorkBeforeMinute.Text.Trim(), out OffWorkBeforeMinute))
                throw new Exception((string)GetLocalResourceObject("Str_Error_OffWorkBeforeMinute"));

            DBAction DBA = new DBAction();

            DbCommandBuilder dbcb = new DbCommandBuilder();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDevice"];

            string Query = string.Empty;

            string DeviceID = string.Empty;

            if (string.IsNullOrEmpty(HF_DeviceID.Value))
            {
                Query = "Insert Into T_TSDevice (DeviceID,MachineID,MachineName,MachineAlias,Location,IsMultipleGoIn,IsApprovalByDevice,IsBrand,IsFirstProcess,IsPrintPackage,IsCheckPreviousMOFinish,IsCheckProductionInspection,IsCheckSequenceDeclare,IsSuspension,OnWorkBeforeMinute,OffWorkBeforeMinute,Power,PowerCoefficient,EstimateCurrent,SectionID,SortID)" +
                    " Values (@DeviceID,@MachineID,@MachineName,@MachineAlias,@Location,@IsMultipleGoIn,@IsApprovalByDevice,@IsBrand,@IsFirstProcess,@IsPrintPackage,@IsCheckPreviousMOFinish,@IsCheckProductionInspection,@IsCheckSequenceDeclare,@IsSuspension,@OnWorkBeforeMinute,@OffWorkBeforeMinute,@Power,@PowerCoefficient,@EstimateCurrent,@SectionID,@SortID)";

                DeviceID = BaseConfiguration.SerialObject[(short)21].取號();

                DbCommandBuilder WorkStationStatusDBCB = new DbCommandBuilder("Insert Into T_TSWorkStation (DeviceID,StatusID) Values (@DeviceID,@StatusID)");

                ObjectSchema WorkStationSchema = DBSchema.currentDB.Tables["T_TSWorkStation"];

                WorkStationStatusDBCB.appendParameter(WorkStationSchema.Attributes["DeviceID"].copy(DeviceID));

                WorkStationStatusDBCB.appendParameter(WorkStationSchema.Attributes["StatusID"].copy(((short)Util.TS.WorkStationStatus.Idle).ToString()));

                DBA.AddCommandBuilder(WorkStationStatusDBCB);
            }
            else
            {
                if (DDL_IsSuspension.SelectedValue.ToBoolean())
                {
                    if (IsHaveInTicketCurrStatus())
                        throw new Exception((string)GetLocalResourceObject("Str_Error_SuspensionMachineInCurrStatus"));
                }

                Query = "Update T_TSDevice Set MachineID = @MachineID,MachineName = @MachineName,MachineAlias = @MachineAlias,Location = @Location,IsMultipleGoIn = @IsMultipleGoIn,IsApprovalByDevice = @IsApprovalByDevice,IsBrand = @IsBrand,IsFirstProcess = @IsFirstProcess,IsPrintPackage = @IsPrintPackage," +
                    "IsCheckPreviousMOFinish = @IsCheckPreviousMOFinish,IsCheckProductionInspection = @IsCheckProductionInspection,IsCheckSequenceDeclare = @IsCheckSequenceDeclare,IsSuspension = @IsSuspension,OnWorkBeforeMinute = @OnWorkBeforeMinute,OffWorkBeforeMinute = @OffWorkBeforeMinute," +
                    "Power = @Power,PowerCoefficient = @PowerCoefficient,EstimateCurrent = @EstimateCurrent,SectionID = @SectionID,SortID = @SortID Where DeviceID = @DeviceID";

                DeviceID = HF_DeviceID.Value;
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
            dbcb.appendParameter(Schema.Attributes["MachineID"].copy(TB_MachineID.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["MachineName"].copy(TB_MachineName.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["MachineAlias"].copy(TB_MachineAlias.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["Location"].copy(TB_Location.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["IsMultipleGoIn"].copy(DDL_IsMultipleGoIn.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["IsApprovalByDevice"].copy(DDL_IsApprovalByDevice.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["IsBrand"].copy(DDL_IsBrand.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["IsFirstProcess"].copy(DDL_IsFirstProcess.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["IsPrintPackage"].copy(DDL_IsPrintPackage.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["OnWorkBeforeMinute"].copy(OnWorkBeforeMinute));
            dbcb.appendParameter(Schema.Attributes["OffWorkBeforeMinute"].copy(OffWorkBeforeMinute));
            dbcb.appendParameter(Schema.Attributes["IsCheckPreviousMOFinish"].copy(DDL_IsCheckPreviousMOFinish.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["IsCheckProductionInspection"].copy(DDL_IsCheckProductionInspection.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["IsCheckSequenceDeclare"].copy(DDL_IsCheckSequenceDeclare.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["IsSuspension"].copy(DDL_IsSuspension.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["Power"].copy(TB_Power.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["PowerCoefficient"].copy(TB_PowerCoefficient.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["EstimateCurrent"].copy(TB_EstimateCurrent.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["SectionID"].copy(DDL_SectionID.SelectedValue.Trim()));
            dbcb.appendParameter(Schema.Attributes["SortID"].copy(TB_SortID.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            //因為修改成不能設置刻字號設備了，必免刻字號表有起用中的刻字號設定， 因此也要把它改為停用
            if (!DDL_IsBrand.SelectedValue.ToBoolean())
            {
                Query = @"Update T_TSBrand Set IsEnable = 0 Where DeviceID = @DeviceID";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true);

            return;
        }
    }

    /// <summary>
    /// MachineID是否重复
    /// </summary>
    /// <returns>是否重复</returns>
    protected bool IsMachineIDRepeat()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDevice"];

        string Query = "Select Count(*) From T_TSDevice Where MachineID = @MachineID";

        if (!string.IsNullOrEmpty(HF_DeviceID.Value))
        {
            Query += " And DeviceID <> @DeviceID";

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));
        }

        dbcb.CommandText = Query;

        dbcb.appendParameter(Schema.Attributes["MachineID"].copy(TB_MachineID.Text.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (!IsDeviceIDCanDelete())
                throw new Exception((string)GetLocalResourceObject("Str_Error_MachineIDUse"));

            DBAction DBA = new DBAction();

            string Query = "Delete From T_TSDevice Where DeviceID = @DeviceID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDevice"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = "Delete From T_TSWorkStation Where DeviceID = @DeviceID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSWorkStation"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = "Delete From T_TSBrand Where DeviceID = @DeviceID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSBrand"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = "Delete From T_TSDeviceGroup Where DeviceID = @DeviceID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_TSDeviceGroup"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true);
        }
    }

    /// <summary>
    /// DeviceID 是否可以删除
    /// </summary>
    /// <returns>是否可以删除</returns>
    protected bool IsDeviceIDCanDelete()
    {
        string Query = @"Select Sum(DeviceIDRowCount) From
                        (Select Count(*) As DeviceIDRowCount From T_TSTicketResult Where DeviceID = @DeviceID
                        Union All
                        Select Count(*) As DeviceIDRowCount From T_TSTicketQuarantineResult Where DeviceID = @DeviceID
                        Union All
                        Select Count(*) As DeviceIDRowCount From T_TSTicketMaintain Where DeviceID = @DeviceID) As Result";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) < 1;
    }

    /// <summary>
    /// 此機台是否有在生產中狀態
    /// </summary>
    /// <returns></returns>
    protected bool IsHaveInTicketCurrStatus()
    {
        string Query = @"Select Count(*) From T_TSTicketCurrStatus Where DeviceID = @DeviceID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }
}