using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using Newtonsoft.Json;

public partial class TimeSheet_TicketMaintain : System.Web.UI.Page
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
            string TicketID = string.Empty;

            if (Request["TicketID"] != null)
                TicketID = Request["TicketID"].Trim();

            if (string.IsNullOrEmpty(TicketID))
            {
                Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }

            TB_TicketID.Text = TicketID;

            try
            {
                LoadData();
            }
            catch (Exception ex)
            {
                HF_IsComplete.Value = "1";

                Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }

            if (Request.Cookies["TS_SecondInfo"] != null && !string.IsNullOrEmpty(Request.Cookies["TS_SecondInfo"].Value))
            {
                List<Util.TS.LoginInfo> SecondInfoList = JsonConvert.DeserializeObject<List<Util.TS.LoginInfo>>(Request.Cookies["TS_SecondInfo"].Value);

                HF_SecondOperatorWorkCode.Value = string.Join("|", SecondInfoList.Select(Info => Info.WorkCode).ToList());
            }
        }

        HF_Div.Value = DivID;
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select * From T_TSTicketMaintain Where TicketID = @TicketID And IsEnd = 0";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        HF_IsOnMaintain.Value = (DT.Rows.Count > 0).ToStringValue();

        if (DT.Rows.Count < 1)
        {
            Query = @"Select * From T_TSTicketCurrStatus Where TicketID = @TicketID";

            Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TB_TicketID.Text));

            DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                throw new Exception((string)GetLocalResourceObject("Str_Error_NoTicketCurrStatusRow"));

            TB_WaitTimeStart.Text = DateTime.Now.ToCurrentUICultureStringTime();

            HF_DeviceID.Value = DT.Rows[0]["DeviceID"].ToString().Trim();

            string WorkShiftID = DT.Rows[0]["WorkShiftID"].ToString().Trim();

            Master.AccountID = (int)DT.Rows[0]["Operator"];

            CommonDB.ExecuteSingleCommand(Util.TS.GetChangeWorkStationStatusDBCB(HF_DeviceID.Value, Util.TS.WorkStationStatus.WaitMaintain, DateTime.Now, Master.AccountID, WorkShiftID));
        }
        else
        {
            HF_MaintainID.Value = DT.Rows[0]["MaintainID"].ToString().Trim();

            TB_ParentMaintainID.Text = DT.Rows[0]["ParentMaintainID"].ToString().Trim();

            TB_WaitTimeStart.Text = ((DateTime)DT.Rows[0]["WaitTimeStart"]).ToCurrentUICultureStringTime();

            TB_WaitTimeEnd.Text = ((DateTime)DT.Rows[0]["WaitTimeEnd"]).ToCurrentUICultureStringTime();

            HF_DeviceID.Value = DT.Rows[0]["DeviceID"].ToString().Trim();

            DDL_IsConfirm.SelectedValue = ((bool)DT.Rows[0]["IsConfirm"]).ToStringValue();

            DDL_IsTrace.SelectedValue = ((bool)DT.Rows[0]["IsTrace"]).ToStringValue();

            TB_TraceQty.Text = DT.Rows[0]["TraceQty"].ToString().Trim();

            TB_TraceGoodQty.Text = DT.Rows[0]["TraceGoodQty"].ToString().Trim();

            TB_TraceNGQty.Text = DT.Rows[0]["TraceNGQty"].ToString().Trim();

            TB_TestQty1.Text = DT.Rows[0]["TestQty1"].ToString().Trim();

            TB_TestQty2.Text = DT.Rows[0]["TestQty2"].ToString().Trim();

            TB_TestTicketID.Text = DT.Rows[0]["TestTicketID"].ToString().Trim();

            DDL_IsAlert.SelectedValue = ((bool)DT.Rows[0]["IsAlert"]).ToStringValue();

            TB_Remark1.Text = DT.Rows[0]["Remark1"].ToString().Trim();

            TB_Remark2.Text = DT.Rows[0]["Remark2"].ToString().Trim();

            TB_Remark3.Text = DT.Rows[0]["Remark3"].ToString().Trim();
        }

        HF_ProcessID.Value = DT.Rows[0]["ProcessID"].ToString().Trim();

        HF_AUFPL.Value = DT.Rows[0]["AUFPL"].ToString().Trim();

        HF_APLZL.Value = DT.Rows[0]["APLZL"].ToString().Trim();

        HF_VORNR.Value = DT.Rows[0]["VORNR"].ToString().Trim();

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

        LoadDataByFaultCategory();

        LoadDataByFaultFitst();

        LoadDataByResponsible();
    }

    /// <summary>
    /// 載入故障分類
    /// </summary>
    protected void LoadDataByFaultCategory()
    {
        string Query = @"Select 
                        T_TSFaultCategory.FaultCategoryID,
                        T_TSFaultCategory.FaultCategoryName
                        From T_TSFaultCategory Inner Join T_TSFaultMappingPLNBEZ On T_TSFaultCategory.FaultCategoryID = T_TSFaultMappingPLNBEZ.FaultCategoryID
                        Where T_TSFaultMappingPLNBEZ.PLNBEZ = @PLNBEZ";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultMappingPLNBEZ"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNBEZ"].copy(HF_PLNBEZ.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_FaultCategory.DataValueField = "FaultCategoryID";

        DDL_FaultCategory.DataTextField = "FaultCategoryName";

        DDL_FaultCategory.DataSource = DT;

        DDL_FaultCategory.DataBind();

        DDL_FaultCategory.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }

    /// <summary>
    /// 載入故障代碼(已填入的)
    /// </summary>
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

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(HF_MaintainID.Value.Trim()));

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
    /// 載入責任歸屬
    /// </summary>
    protected void LoadDataByResponsible()
    {
        string Query = @"Select ResponsibleID,ResponsibleName From T_TSMaintainResponsible Order By SortID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMaintainResponsible"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_Responsible.DataValueField = "ResponsibleID";

        DDL_Responsible.DataTextField = "ResponsibleName";

        DDL_Responsible.DataSource = DT;

        DDL_Responsible.DataBind();

        DDL_Responsible.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));

        Query = @"Select ResponsibleID From T_TSTicketMaintainResponsible Where MaintainID = @MaintainID";

        Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainResponsible"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(HF_MaintainID.Value.Trim()));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        var ResponsibleID = DT.AsEnumerable().Select(Row => Row["ResponsibleID"].ToString().Trim()).ToList();

        Page.ClientScript.RegisterStartupScript(this.GetType(), "DefaultResponsibleID", "<script>var DefaultResponsibleID=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponsibleID) + ";</script>");
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