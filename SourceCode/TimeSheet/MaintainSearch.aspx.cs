using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_MaintainSearch : System.Web.UI.Page
{
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(TB_OperatorWorkCode.Text.Trim()) &&
            string.IsNullOrEmpty(TB_MaintainStartTime.Text.Trim()) &&
            string.IsNullOrEmpty(TB_MaintainEndTime.Text.Trim()) &&
            string.IsNullOrEmpty(TB_MaintainID.Text.Trim()) &&
            string.IsNullOrEmpty(TB_MachineID.Text.Trim()) &&
            string.IsNullOrEmpty(DDL_IsAlert.SelectedValue) &&
            string.IsNullOrEmpty(DDL_IsCompleteTrace.SelectedValue) &&
            string.IsNullOrEmpty(TB_TicketID.Text.Trim()))
        {
            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_NoConditionAlertMessage"));

            return;
        }

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema TicketMaintainSchema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        ObjectSchema TicketMaintainMinuteSchema = DBSchema.currentDB.Tables["T_TSTicketMaintainMinute"];

        ObjectSchema DeviceSchema = DBSchema.currentDB.Tables["T_TSDevice"];

        string Condition = string.Empty;

        string Query = @"Select Distinct
                        T_TSTicketMaintain.MaintainID As MaintainIDValue,
                        T_TSTicketMaintain.MaintainID,
                        dbo.TS_GetMaintainOperatorName(T_TSTicketMaintain.MaintainID,'、') As OperatorName,
                        T_TSTicketMaintain.MaintainMinute,
                        T_TSDevice.MachineID,
                        T_TSTicketMaintain.IsAlert,
                        IsTrace,
                        TraceQty,
                        '' IsFinishTrace            
                        From T_TSTicketMaintain 
                        Inner Join T_TSTicketMaintainMinute On T_TSTicketMaintain.MaintainID = T_TSTicketMaintainMinute.MaintainID
                        Inner Join T_TSDevice On T_TSTicketMaintain.DeviceID = T_TSDevice.DeviceID ";

        if (!string.IsNullOrEmpty(TB_OperatorWorkCode.Text.Trim()))
        {
            int Operator = BaseConfiguration.GetAccountID(TB_OperatorWorkCode.Text.Trim());

            Condition += " And T_TSTicketMaintainMinute.Operator = @Operator";

            dbcb.appendParameter(TicketMaintainMinuteSchema.Attributes["Operator"].copy(Operator));
        }

        if (!string.IsNullOrEmpty(TB_MaintainStartTime.Text.Trim()))
        {
            Condition += " And Datediff(day,@MaintainStartTime,T_TSTicketMaintainMinute.MaintainStartTime) >= 0";

            dbcb.appendParameter(TicketMaintainMinuteSchema.Attributes["MaintainStartTime"].copy(DateTime.Parse(TB_MaintainStartTime.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));
        }

        if (!string.IsNullOrEmpty(TB_MaintainEndTime.Text.Trim()))
        {
            Condition += " And Datediff(day,@MaintainEndTime,T_TSTicketMaintainMinute.MaintainEndTime) <= 0";

            dbcb.appendParameter(TicketMaintainMinuteSchema.Attributes["MaintainEndTime"].copy(DateTime.Parse(TB_MaintainEndTime.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));
        }

        if (!string.IsNullOrEmpty(TB_MaintainID.Text.Trim()))
        {
            Condition += " And T_TSTicketMaintainMinute.MaintainID = @MaintainID";

            dbcb.appendParameter(TicketMaintainMinuteSchema.Attributes["MaintainID"].copy(TB_MaintainID.Text.Trim()));
        }

        if (!string.IsNullOrEmpty(TB_MachineID.Text.Trim()))
        {
            Condition += " And T_TSDevice.MachineID = @MachineID";

            dbcb.appendParameter(DeviceSchema.Attributes["MachineID"].copy(TB_MachineID.Text.Trim()));
        }

        if (!string.IsNullOrEmpty(DDL_IsAlert.SelectedValue))
        {
            Condition += " And T_TSTicketMaintain.IsAlert = @IsAlert";

            dbcb.appendParameter(TicketMaintainSchema.Attributes["IsAlert"].copy(DDL_IsAlert.SelectedValue));
        }

        if (!string.IsNullOrEmpty(DDL_IsCompleteTrace.SelectedValue))
        {
            if (DDL_IsCompleteTrace.SelectedValue.ToBoolean())
                Condition += " And T_TSTicketMaintain.IsTrace = 1 And TraceQty > 0";
            else
                Condition += " And T_TSTicketMaintain.IsTrace = 1 And TraceQty < 1";
        }

        if (!string.IsNullOrEmpty(TB_TicketID.Text.Trim()))
        {
            Condition += " And T_TSTicketMaintain.TicketID = @TicketID";

            dbcb.appendParameter(TicketMaintainSchema.Attributes["TicketID"].copy(TB_TicketID.Text.Trim()));
        }

        Condition += " And T_TSTicketMaintain.IsEnd = 1";

        Query += " Where " + Condition.Substring(4, Condition.Length - 4);

        dbcb.CommandText = Query;

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
                classes = Column.ColumnName == "MaintainID" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            MaintainIDColumnName = "MaintainIDValue",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                MaintainIDValue = Row["MaintainIDValue"].ToString().Trim(),
                MaintainID = Row["MaintainID"].ToString().Trim(),
                OperatorName = Row["OperatorName"].ToString().Trim(),
                MaintainMinute = Row["MaintainMinute"].ToString().Trim(),
                MachineID = Row["MachineID"].ToString().Trim(),
                IsTrace = ((bool)Row["IsTrace"]).ToStringValue(),
                TraceQty = Row["TraceQty"].ToString(),
                IsFinishTrace = (bool)Row["IsTrace"] ? (int)Row["TraceQty"] > 0 ? string.Empty : "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                IsAlert = (bool)Row["IsAlert"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty
            })
        };

        if (DT.Rows.Count > 0)
            HF_IsShowResultList.Value = true.ToStringValue();
        else
        {
            HF_IsShowResultList.Value = false.ToStringValue();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_NoSearchData"));

            return;
        }

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
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
            case "MaintainIDValue":
            case "IsTrace":
            case "TraceQty":
                return true;
            default:
                return false;
        }
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
            case "MaintainID":
            case "MaintainMinute":
            case "MachineID":
            case "IsAlert":
            case "IsFinishTrace":
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
            case "MaintainID":
                return 80;
            case "MaintainMinute":
            case "MachineID":
                return 60;
            case "IsFinishTrace":
            case "IsAlert":
                return 40;
            default:
                return 200;
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
            case "MaintainID":
                return (string)GetLocalResourceObject("Str_ColumnName_MaintainID");
            case "OperatorName":
                return (string)GetLocalResourceObject("Str_ColumnName_OperatorName");
            case "MaintainMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_MaintainMinute");
            case "MachineID":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineID");
            case "IsFinishTrace":
                return (string)GetLocalResourceObject("Str_ColumnName_IsFinishTrace");
            case "IsAlert":
                return (string)GetLocalResourceObject("Str_ColumnName_IsAlert");
            default:
                return ColumnName;
        }
    }
}