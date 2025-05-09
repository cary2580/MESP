using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketReWorkNotEndSearch : System.Web.UI.Page
{
    protected string YellowColor = "#D9B300";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            TB_CreateDateEnd.Text = DateTime.Now.ToCurrentUICultureString();

        HF_IsShowResultList.Value = false.ToStringValue();
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        string Query = @"Select 
                '' As TicketIDValue,
                T_TSTicket.TicketID,
                TicketTypeID,
                (Select Top 1 CodeName From T_Code Where CodeType = 'TS_TicketType' And UICulture = @UICulture And CodeID = TicketTypeID) As TicketTypeName,
                (Select Convert(nvarchar,T_TSTicketRouting.ProcessID) + '-' + T_TSTicketRouting.VORNR + '-' + T_TSTicketRouting.LTXA1 From T_TSTicketRouting Where TicketID =  T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID) As LastProcessName,
				(Select Top 1 Convert(nvarchar,T_TSTicketRouting.ProcessID) + '-' + T_TSTicketRouting.VORNR + '-' + T_TSTicketRouting.LTXA1  From T_TSTicketRouting  Where TicketID =  T_TSTicket.TicketID And ProcessID > IsNull(TicketResult.MaxProcessID,0) And IsEnd = 0 Order By T_TSTicketRouting.ProcessID Asc) As NextProcessName,
				Qty,
				IsNull((Select Sum(GoodQty) From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID),0) As GoodQty,
				IsNull((Select Sum(ReWorkQty) From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID),0) As ReWorkQty,
				IsNull((Select Sum(ScrapQty) From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID),0) As ScrapQty,
				IsNull((Select Count(*) From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID),0) As ReportCount,
				IsNull((Select Count(*) From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID And ApprovalTime Is Null),0) As ReportNotYetCount,
				IsNull((Select Count(*) From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID And ApprovalTime Is Not Null),0) As FinishReportCount,
				'' As ReportColor,
                (Select Top 1 TEXT1 From T_TSSAPAFKO Left Join T_TSSAPMKAL On T_TSSAPMKAL.MATNR = T_TSSAPAFKO.PLNBEZ And T_TSSAPMKAL.VERID = T_TSSAPAFKO.VERID And IsLock = 0 And DATEDIFF(day,ADATU,getdate()) > -1 And DATEDIFF(day,BDATU,getdate()) < -1
		        Where T_TSSAPAFKO.AUFNR = T_TSTicket.AUFNR) As TEXT1,
                Case
	                When IsNull(ParentTicketID,'') <> '' Then dbo.TS_GetParentTicketIDPath(T_TSTicket.TicketID,'/') 
	                Else ''
                End As ParentTicketIDPath,
                Case
	                When CreateProcessID > 0 And IsNull(ParentTicketID,'') <> '' Then (Select Convert(nvarchar,ProcessID) + '-' + VORNR + '-' + LTXA1 From T_TSTicketRouting Where T_TSTicketRouting.TicketID = ParentTicketID And T_TSTicketRouting.ProcessID = CreateProcessID)
	                Else ''
                End As CreateProcessName,
                CreateDate,
                Base_Org.dbo.GetAccountName(CreateAccountID) As CreateAccountName,
                IsEnd
                From T_TSTicket
                Left Join (Select T_TSTicketResult.TicketID,Max(ProcessID) As MaxProcessID From T_TSTicketResult Group By T_TSTicketResult.TicketID) As TicketResult On T_TSTicket.TicketID = TicketResult.TicketID
                Where T_TSTicket.TicketTypeID = @TicketTypeID And Datediff(day,@CreateDateStatr,T_TSTicket.CreateDate) >= 0 And Datediff(day,@CreateDateEnd,T_TSTicket.CreateDate) <= 0 
                And Exists(Select * From T_TSSAPAFKO Where T_TSSAPAFKO.AUFNR = T_TSTicket.AUFNR And T_TSSAPAFKO.[STATUS] = @MOStatus) ";

        if (DDL_IsViewOnlyEnd.SelectedValue.ToBoolean())
            Query += " And T_TSTicket.IsEnd = 0";

        Query += "  Order By T_TSTicket.CreateDate,T_TSTicket.TicketID ";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.Rework).ToString()));

        dbcb.appendParameter(Util.GetDataAccessAttribute("MOStatus", "Nvarchar", 50, ((short)Util.TS.MOStatus.InProcess).ToString()));

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(DateTime.Parse(TB_CreateDateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "CreateDateStatr"));

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(DateTime.Parse(TB_CreateDateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "CreateDateEnd"));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        EnumerableRowCollection<DataRow> DataRows = DT.AsEnumerable();

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
                classes = Column.ColumnName == "TicketID" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            TicketIDColumnName = "TicketIDValue",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DataRows.Select(Row => new
            {
                TicketIDValue = Row["TicketID"].ToString().Trim(),
                TicketID = Row["TicketID"].ToString().Trim(),
                TicketTypeName = Row["TicketTypeName"].ToString().Trim(),
                LastProcessName = Row["LastProcessName"].ToString().Trim(),
                NextProcessName = Row["NextProcessName"].ToString().Trim(),
                Qty = Row["Qty"].ToString().Trim(),
                GoodQty = Row["GoodQty"].ToString().Trim(),
                ReWorkQty = Row["ReWorkQty"].ToString().Trim(),
                ScrapQty = Row["ScrapQty"].ToString().Trim(),
                ReportColor = string.IsNullOrEmpty(Row["LastProcessName"].ToString().Trim()) ? string.Empty : (int)Row["FinishReportCount"] == 0 ? "red" : ((int)Row["ReportCount"] - (int)Row["FinishReportCount"]) > 0 ? YellowColor : string.Empty,
                ParentTicketIDPath = Row["ParentTicketIDPath"].ToString().Trim(),
                TEXT1 = Row["TEXT1"].ToString().Trim(),
                CreateProcessName = Row["CreateProcessName"].ToString().Trim(),
                CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureStringTime(),
                CreateAccountName = Row["CreateAccountName"].ToString().Trim(),
                IsEnd = (bool)Row["IsEnd"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty
            })
        };

        TB_TicketQty.Text = DataRows.Sum(Row => (int)Row["Qty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        TB_GoodQty.Text = DataRows.Sum(Row => (int)Row["GoodQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        TB_ReWorkQty.Text = DataRows.Sum(Row => (int)Row["ReWorkQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        TB_ScrapQty.Text = DataRows.Sum(Row => (int)Row["ScrapQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        if (DT.Rows.Count < 1000)
            Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");
        else
            Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

        HF_IsShowResultList.Value = true.ToStringValue();
    }

    /// <summary>
    /// 指定ColumnName得到是否顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        if (DDL_IsViewOnlyEnd.SelectedValue.ToBoolean() && ColumnName == "IsEnd")
            return true;

        switch (ColumnName)
        {
            case "TicketIDValue":
            case "TicketTypeID":
            case "TicketTypeName":
            case "ReportCount":
            case "ReportNotYetCount":
            case "FinishReportCount":
            case "ReportColor":
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
            case "Qty":
            case "GoodQty":
            case "ReWorkQty":
            case "ScrapQty":
            case "CreateAccountName":
            case "IsEnd":
            case "TicketTypeName":
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
            case "ParentTicketID":
            case "CreateDate":
                return 80;
            case "IsEnd":
            case "CreateAccountName":
                return 60;
            case "Qty":
            case "GoodQty":
            case "ReWorkQty":
            case "ScrapQty":
            case "TicketTypeName":
                return 40;
            case "LastProcessName":
            case "NextProcessName":
            case "CreateProcessName":
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
            case "LastProcessName":
                return (string)GetLocalResourceObject("Str_ColumnName_LastProcessName");
            case "NextProcessName":
                return (string)GetLocalResourceObject("Str_ColumnName_NextProcessName");
            case "Qty":
                return (string)GetLocalResourceObject("Str_ColumnName_Qty");
            case "GoodQty":
                return (string)GetLocalResourceObject("Str_ColumnName_GoodQty");
            case "ReWorkQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ReWorkQty");
            case "ScrapQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQty");
            case "ParentTicketIDPath":
                return (string)GetLocalResourceObject("Str_ColumnName_ParentTicketIDPath");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            case "CreateProcessName":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateProcessName");
            case "CreateDate":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateDate");
            case "CreateAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateAccountName");
            case "IsEnd":
                return (string)GetLocalResourceObject("Str_ColumnName_IsEnd");
            default:
                return ColumnName;
        }
    }
}