using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_Maintain_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["MaintainID"] != null)
                TB_MaintainID.Text = Request["MaintainID"].Trim();

            if (string.IsNullOrEmpty(TB_MaintainID.Text))
            {
                Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MaintainID"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }

            try
            {
                LoadData();
            }
            catch (Exception ex)
            {
                Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }
        }

        HF_Div.Value = DivID;
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select *,
                        Base_Org.dbo.GetAccountName(QACheckAccountID) As QACheckAccountName,
                        Base_Org.dbo.GetAccountName(PDCheckAccountID) As PDCheckAccountName,
                        Base_Org.dbo.GetAccountName(ConfirmAccountID) As ConfirmAccountName,
                        Base_Org.dbo.GetAccountWorkCode(ConfirmAccountID) As ConfirmWorkCode,
                        Base_Org.dbo.GetAccountName(ModifyAccountID) As ModifyAccountName 
                        From T_TSTicketMaintain Where MaintainID = @MaintainID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(TB_MaintainID.Text));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new Exception((string)GetLocalResourceObject("Str_Error_NoMaintainRow"));

        TB_TicketID.Text = DT.Rows[0]["TicketID"].ToString().Trim();

        TB_MaintainID.Text = DT.Rows[0]["MaintainID"].ToString().Trim();

        TB_ParentMaintainID.Text = DT.Rows[0]["ParentMaintainID"].ToString().Trim();

        TB_QACheckTimeStart.Text = ((DateTime)DT.Rows[0]["QACheckTimeStart"]).ToCurrentUICultureStringTime();

        TB_QACheckTimeEnd.Text = ((DateTime)DT.Rows[0]["QACheckTimeEnd"]).ToCurrentUICultureStringTime();

        TB_QACheckMinute.Text = DT.Rows[0]["QACheckMinute"].ToString().Trim();

        TB_QACheckAccountName.Text = DT.Rows[0]["QACheckAccountName"].ToString().Trim();

        TB_PDCheckTimeStart.Text = ((DateTime)DT.Rows[0]["PDCheckTimeStart"]).ToCurrentUICultureStringTime();

        TB_PDCheckTimeEnd.Text = ((DateTime)DT.Rows[0]["PDCheckTimeEnd"]).ToCurrentUICultureStringTime();

        TB_PDCheckMinute.Text = DT.Rows[0]["PDCheckMinute"].ToString().Trim();

        TB_PDCheckAccountName.Text = DT.Rows[0]["PDCheckAccountName"].ToString().Trim();

        HF_ConfirmWorkCode.Value = DT.Rows[0]["ConfirmWorkCode"].ToString().Trim();

        DDL_IsConfirm.SelectedValue = ((bool)DT.Rows[0]["IsConfirm"]).ToStringValue();

        TB_ConfirmAccountName.Text = DT.Rows[0]["ConfirmAccountName"].ToString().Trim();

        DDL_IsTrace.SelectedValue = ((bool)DT.Rows[0]["IsTrace"]).ToStringValue();

        TB_TraceQty.Text = DT.Rows[0]["TraceQty"].ToString().Trim();

        TB_TraceGoodQty.Text = DT.Rows[0]["TraceGoodQty"].ToString().Trim();

        TB_TraceNGQty.Text = DT.Rows[0]["TraceNGQty"].ToString().Trim();

        TB_TestQty1.Text = DT.Rows[0]["TestQty1"].ToString().Trim();

        TB_TestQty2.Text = DT.Rows[0]["TestQty2"].ToString().Trim();

        TB_TestTicketID.Text = DT.Rows[0]["TestTicketID"].ToString().Trim();

        DDL_IsAlert.SelectedValue = ((bool)DT.Rows[0]["IsAlert"]).ToStringValue();

        DDL_IsCancel.SelectedValue = ((bool)DT.Rows[0]["IsCancel"]).ToStringValue();

        TB_Remark1.Text = DT.Rows[0]["Remark1"].ToString().Trim();

        TB_Remark2.Text = DT.Rows[0]["Remark2"].ToString().Trim();

        TB_Remark3.Text = DT.Rows[0]["Remark3"].ToString().Trim();

        HF_ProcessID.Value = DT.Rows[0]["ProcessID"].ToString().Trim();

        HF_VORNR.Value = DT.Rows[0]["VORNR"].ToString().Trim();

        HF_DeviceID.Value = DT.Rows[0]["DeviceID"].ToString().Trim();

        TB_WaitTimeStart.Text = ((DateTime)DT.Rows[0]["WaitTimeStart"]).ToCurrentUICultureStringTime();

        TB_WaitTimeEnd.Text = ((DateTime)DT.Rows[0]["WaitTimeEnd"]).ToCurrentUICultureStringTime();

        TB_WaitMinute.Text = DT.Rows[0]["WaitMinute"].ToString().Trim();

        TB_ModifyDate.Text = ((DateTime)DT.Rows[0]["ModifyDate"]).ToCurrentUICultureStringTime();

        TB_ModifyDataAccountName.Text = DT.Rows[0]["ModifyAccountName"].ToString().Trim();

        Query = @"Select Top 1 * From T_TSDevice Where DeviceID = @DeviceID";

        Schema = DBSchema.currentDB.Tables["T_TSDevice"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new Exception(string.Format((string)GetLocalResourceObject("Str_Error_NoDeviceData"), HF_DeviceID.Value));

        TB_MachineID.Text = DT.Rows[0]["MachineID"].ToString().Trim();

        TB_MachineName.Text = DT.Rows[0]["MachineName"].ToString().Trim();

        Query = @"Select Top 1 * From T_TSTicketRouting Where TicketID = @TicketID And ProcessID = @ProcessID";

        Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(HF_ProcessID.Value));

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        TB_ProcessName.Text = HF_ProcessID.Value + "-" + HF_VORNR.Value + "-" + DT.Rows[0]["LTXA1"].ToString().Trim();

        Query = @"Select * From T_TSTicket Where TicketID = @TicketID";

        Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        string AUFNR = string.Empty;

        if (DT.Rows.Count > 0)
            AUFNR = DT.Rows[0]["AUFNR"].ToString().Trim();

        Query = @"Select Top 1 KTEXT,MAKTX,PLNBEZ From V_TSMORouting Where AUFNR = @AUFNR";

        Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            TB_RoutingName.Text = DT.Rows[0]["KTEXT"].ToString().Trim();

            TB_MAKTX.Text = DT.Rows[0]["MAKTX"].ToString().Trim();

            HF_PLNBEZ.Value = DT.Rows[0]["PLNBEZ"].ToString().Trim();
        }

        LoadDataByFaultFitst();

        Query = @"Select ResponsibleName From T_TSTicketMaintainResponsible Inner Join T_TSMaintainResponsible On T_TSTicketMaintainResponsible.ResponsibleID = T_TSMaintainResponsible.ResponsibleID Where MaintainID = @MaintainID Order by SerialNo";

        Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainResponsible"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(TB_MaintainID.Text.Trim()));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        var ResponsibleName = DT.AsEnumerable().Select(Row => Row["ResponsibleName"].ToString().Trim()).ToList();

        TB_Responsible.Text = string.Join(",", ResponsibleName);
    }

    protected void LoadDataByFaultFitst()
    {
        string Query = @"Select 
                        T_TSFaultCategory.FaultCategoryID,
                        T_TSFaultCategory.FaultCategoryName,
                        T_TSFault.FaultID,
                        T_TSFault.FaultName
                        From T_TSTicketMaintainFaultByFirstTime 
                        Inner Join T_TSFaultCategory On T_TSTicketMaintainFaultByFirstTime.FaultCategoryID = T_TSFaultCategory.FaultCategoryID 
                        Inner Join T_TSFault On T_TSTicketMaintainFaultByFirstTime.FaultID = T_TSFault.FaultID
                        Where T_TSTicketMaintainFaultByFirstTime.MaintainID = @MaintainID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainFaultByFirstTime"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(TB_MaintainID.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        var ResponseData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName),
            }),
            Rows = DT.AsEnumerable().Select(Row => new
            {
                FaultCategoryID = Row["FaultCategoryID"].ToString().Trim(),
                FaultCategoryName = Row["FaultCategoryName"].ToString().Trim(),
                FaultID = Row["FaultID"].ToString().Trim(),
                FaultName = Row["FaultName"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValueByFaultFitst", "<script>var JQGridDataValueByFaultFitst=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

    }

    /// <summary>
    /// 指定ColumnName得到對齊方式
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>對齊方式</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "FaultCategoryName":
                return "center";
            default:
                return "left";
        }
    }

    /// <summary>
    /// 指定ColumnName得到欄位寬度
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>欄位寬度</returns>
    protected int GetWidth(string ColumnName)
    {
        switch (ColumnName)
        {
            case "FaultCategoryName":
                return 120;
            default:
                return 300;
        }
    }

    /// <summary>
    /// 指定ColumnName得到顯示欄位名稱
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "FaultCategoryName":
                return (string)GetLocalResourceObject("Str_ColumnName_FaultCategoryName");
            case "FaultName":
                return (string)GetLocalResourceObject("Str_ColumnName_FaultName");
            default:
                return ColumnName;
        }
    }

    /// <summary>
    /// 指定ColumnName得到是否顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "FaultCategoryName":
            case "FaultName":
                return false;
            default:
                return true;
        }
    }
}