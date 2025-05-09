using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;


public partial class TimeSheet_TicketQuarantineNotJudgmentSearch : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
            TB_CreateDateEnd.Text = DateTime.Now.ToCurrentUICultureString();

        HF_IsShowResultList.Value = false.ToStringValue();
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        string Query = @"Select 
                            '' As TicketIDValue,
                            T_TSTicket.TicketID,
                             (Select Top 1 CodeName From T_Code Where CodeType = 'TS_TicketType' And UICulture = @UICulture And CodeID = TicketTypeID) As TicketTypeName,
                            Case
	                            When CreateProcessID > 0 And IsNull(ParentTicketID,'') <> '' Then (Select Convert(nvarchar,ProcessID) + '-' + VORNR + '-' + LTXA1 From T_TSTicketRouting Where T_TSTicketRouting.TicketID = ParentTicketID And T_TSTicketRouting.ProcessID = CreateProcessID)
	                            Else ''
                            End As CreateProcessName,
                            (T_TSDevice.MachineID + '-' + T_TSDevice.MachineName) As MachineName,
                            T_TSTicketQuarantineResult.Qty,
                            T_TSTicketQuarantineResult.ScrapQty,
                            (Select Top 1 TEXT1 From T_TSSAPAFKO Left Join T_TSSAPMKAL On T_TSSAPMKAL.MATNR = T_TSSAPAFKO.PLNBEZ And T_TSSAPMKAL.VERID = T_TSSAPAFKO.VERID And IsLock = 0 And DATEDIFF(day,ADATU,getdate()) > -1 And DATEDIFF(day,BDATU,getdate()) < -1
		                    Where T_TSSAPAFKO.AUFNR = T_TSTicket.AUFNR) As TEXT1,
                            Case
	                            When IsNull(ParentTicketID,'') <> '' Then dbo.TS_GetParentTicketIDPath(T_TSTicket.TicketID,'/') 
	                            Else ''
                            End As ParentTicketIDPath,
                            CreateDate,
                            Base_Org.dbo.GetAccountName(CreateAccountID) As CreateAccountName,
                            Base_Org.dbo.GetAccountName(JudgmentAccount) As JudgmentAccountName,
                            IsJudgment,
                            Remark,
                            (Select Case When Count(*) > 0 Then Convert(bit,1) Else Convert(bit,0) End From T_TSTicketQuarantineResultItem Where T_TSTicketQuarantineResultItem.TicketID = T_TSTicketQuarantineResult.TicketID) As IsHaveResultItem
                        From T_TSTicket
                        Inner Join T_TSTicketQuarantineResult On T_TSTicket.TicketID = T_TSTicketQuarantineResult.TicketID 
                        Inner Join T_TSDevice On T_TSDevice.DeviceID = T_TSTicketQuarantineResult.DeviceID
                        Where T_TSTicket.TicketTypeID = @TicketTypeID And Datediff(day,@CreateDateStatr,T_TSTicket.CreateDate) >= 0 And Datediff(day,@CreateDateEnd,T_TSTicket.CreateDate) <= 0 ";

        if (DDL_IsViewOnlyNotJudgment.SelectedValue.ToBoolean())
            Query += " And T_TSTicketQuarantineResult.IsJudgment = 0";

        Query += "  Order By T_TSTicket.CreateDate,T_TSTicket.TicketID ";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.Quarantine).ToString()));

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(DateTime.Parse(TB_CreateDateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "CreateDateStatr"));

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(DateTime.Parse(TB_CreateDateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "CreateDateEnd"));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

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
                classes = Column.ColumnName == "TicketID" || Column.ColumnName == "Remark" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            TicketIDColumnName = "TicketIDValue",
            IsHaveResultItemColumnName = "IsHaveResultItem",
            MachineNameColumnName = "MachineName",
            QtyColumnName = "Qty",
            ScrapQtyColumnName = "ScrapQty",
            RemarkColumnName = "Remark",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                TicketIDValue = Row["TicketID"].ToString().Trim(),
                TicketID = Row["TicketID"].ToString().Trim(),
                TicketTypeName = Row["TicketTypeName"].ToString().Trim(),
                CreateProcessName = Row["CreateProcessName"].ToString().Trim(),
                MachineName = Row["MachineName"].ToString().Trim(),
                Qty = ((int)Row["Qty"]).ToString("N0"),
                ScrapQty = ((int)Row["ScrapQty"]).ToString("N0"),
                ParentTicketIDPath = Row["ParentTicketIDPath"].ToString().Trim(),
                TEXT1 = Row["TEXT1"].ToString().Trim(),
                CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureStringTime(),
                CreateAccountName = Row["CreateAccountName"].ToString().Trim(),
                Remark = Row["Remark"].ToString().Trim(),
                JudgmentAccountName = Row["JudgmentAccountName"].ToString().Trim(),
                IsJudgment = (bool)Row["IsJudgment"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                IsHaveResultItem = ((bool)Row["IsHaveResultItem"]).ToStringValue()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowFooterRowValue", "<script>var IsShowFooterRowValue='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowSubGridValue", "<script>var IsShowSubGridValue='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        if (DT.Rows.Count < 1000)
            Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");
        else
            Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

        HF_IsShowResultList.Value = true.ToStringValue();
    }

    /// <summary>
    /// 指定ColumnName得到是否影藏
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否影藏</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        if (DDL_IsViewOnlyNotJudgment.SelectedValue.ToBoolean() && ColumnName == "IsJudgment")
            return true;

        switch (ColumnName)
        {
            case "TicketIDValue":
            case "TicketTypeName":
            case "IsHaveResultItem":
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
            case "TicketTypeName":
            case "Qty":
            case "ScrapQty":
            case "CreateAccountName":
            case "JudgmentAccountName":
            case "IsJudgment":
            case "CreateDate":
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
            case "TicketID":
                return 95;
            case "CreateDate":
                return 80;
            case "CreateAccountName":
            case "JudgmentAccountName":
            case "IsJudgment":
                return 60;
            case "TicketTypeName":
            case "Qty":
            case "ScrapQty":
                return 40;
            case "CreateProcessName":
            case "MachineName":
            case "Remark":
            case "ParentTicketIDPath":
                return 100;
            default:
                return 150;
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
            case "TicketID":
                return (string)GetLocalResourceObject("Str_ColumnName_TicketID");
            case "TicketTypeName":
                return (string)GetLocalResourceObject("Str_ColumnName_TicketTypeName");
            case "Qty":
                return (string)GetLocalResourceObject("Str_ColumnName_Qty");
            case "ScrapQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQty");
            case "ParentTicketIDPath":
                return (string)GetLocalResourceObject("Str_ColumnName_ParentTicketIDPath");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            case "CreateProcessName":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateProcessName");
            case "MachineName":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineName");
            case "CreateDate":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateDate");
            case "CreateAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateAccountName");
            case "JudgmentAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_JudgmentAccountName");
            case "IsJudgment":
                return (string)GetLocalResourceObject("Str_ColumnName_IsJudgment");
            case "Remark":
                return (string)GetLocalResourceObject("Str_ColumnName_Remark");
            default:
                return ColumnName;
        }
    }
}