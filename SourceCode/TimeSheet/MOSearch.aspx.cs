using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_MOSearch : System.Web.UI.Page
{
    protected string YellowColor = "#D9B300";

    protected string PinkColor = "#FF359A";
    protected override void OnPreInit(EventArgs e)
    {
        if (Request["ViewInside"] != null && !string.IsNullOrEmpty(Request["ViewInside"].Trim()))
        {
            try
            {
                if (Request["ViewInside"].ToStringFromBase64(true).ToBoolean())
                    this.MasterPageFile = "~/MasterPage.master";
                else
                {
                    this.MasterPageFile = "~/TimeSheet/TimeSheet.master";

                    (Master as TimeSheet_TimeSheet).IsPassPageVerificationAccount = true;
                }
            }
            catch (Exception ex)
            {

            }
        }
        else
        {
            this.MasterPageFile = "~/TimeSheet/TimeSheet.master";

            (Master as TimeSheet_TimeSheet).IsPassPageVerificationAccount = true;
        }

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        HF_IsShowResultList.Value = false.ToStringValue();

        if (!IsPostBack)
        {
            if (Request["AUFNR"] != null)
                TB_AUFNR.Text = Request["AUFNR"].Trim();

            if (!string.IsNullOrEmpty(TB_AUFNR.Text))
                BT_Search_Click(null, null);
        }
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(TB_Brand.Text.Trim()))
                TB_AUFNR.Text = GetAUFNRFromBrand();
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);

            return;
        }

        TB_AUFNR.Text = Util.TS.ToAUFNR(TB_AUFNR.Text.Trim());

        string Query = @"Select Top 1 * From V_TSMORouting Where AUFNR = @AUFNR";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            HF_IsShowSetEnd.Value = false.ToStringValue();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

            return;
        }

        string STATUS = DT.Rows[0]["STATUS"].ToString().Trim();

        Util.TS.MOStatus MOStatus = (Util.TS.MOStatus)Enum.Parse(typeof(Util.TS.MOStatus), STATUS);

        TB_PSMNG.Text = ((int)double.Parse(DT.Rows[0]["PSMNG"].ToString().Trim())).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        TB_WEMNG.Text = ((int)double.Parse(DT.Rows[0]["WEMNG"].ToString().Trim())).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        TB_AUART.Text = DT.Rows[0]["AUARTName"].ToString().Trim();

        TB_VERID.Text = DT.Rows[0]["VERID"].ToString().Trim();

        TB_PLNBEZ.Text = DT.Rows[0]["PLNBEZ"].ToString().Trim();

        TB_MAKTX.Text = DT.Rows[0]["MAKTX"].ToString().Trim();

        TB_ZEINR.Text = DT.Rows[0]["ZEINR"].ToString().Trim();

        TB_FERTH.Text = DT.Rows[0]["FERTH"].ToString().Trim();

        TB_PLNNR.Text = DT.Rows[0]["PLNNR"].ToString().Trim();

        TB_PLNAL.Text = DT.Rows[0]["PLNAL"].ToString().Trim();

        TB_KTEXT.Text = DT.Rows[0]["KTEXT"].ToString().Trim();

        TB_ERDAT.Text = ((DateTime)DT.Rows[0]["ERDAT"]).ToCurrentUICultureString();

        TB_FTRMI.Text = ((DateTime)DT.Rows[0]["FTRMI"]).ToCurrentUICultureString();

        TB_GSTRP.Text = ((DateTime)DT.Rows[0]["GSTRP"]).ToCurrentUICultureString();

        TB_GLTRP.Text = ((DateTime)DT.Rows[0]["GLTRP"]).ToCurrentUICultureString();

        TB_IsPreClose.Text = (bool)DT.Rows[0]["IsPreClose"] ? (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_IsPreClose_True") : (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_IsPreClose_False");

        Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        Query = @"Select 
                Sum(GoodQty) As GoodQty,
                Sum(ReWorkQty) As ReWorkQty,
                Sum(ScrapQty) As ScrapQty
                From T_TSTicketResult Inner Join
                (
                Select T_TSTicketResult.TicketID,Max(ProcessID) As MaxProcessID 
                From T_TSTicketResult Inner Join T_TSTicket On T_TSTicketResult.TicketID = T_TSTicket.TicketID
                Where T_TSTicket.AUFNR = @AUFNR
                Group By T_TSTicketResult.TicketID
                ) As LastTicketResult On T_TSTicketResult.TicketID = LastTicketResult.TicketID And T_TSTicketResult.ProcessID = LastTicketResult.MaxProcessID";


        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            TB_GoodQty.Text = DT.Rows[0]["GoodQty"] == DBNull.Value ? string.Empty : ((int)DT.Rows[0]["GoodQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);
            TB_ReWorkQty.Text = DT.Rows[0]["ReWorkQty"] == DBNull.Value ? string.Empty : ((int)DT.Rows[0]["ReWorkQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);
            TB_ScrapQty.Text = DT.Rows[0]["ScrapQty"] == DBNull.Value ? string.Empty : ((int)DT.Rows[0]["ScrapQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);
        }

        switch (DDL_ViewModel.SelectedValue)
        {
            case "0":
                ViewModel0();
                break;
            case "1":
                ViewModel1();
                break;
            case "2":
                ViewModel2();
                break;
        }

        HF_IsShowResultList.Value = true.ToStringValue();

        SearchResultListDiv.Attributes.Add("class", "panel " + (string)GetGlobalResourceObject("GlobalRes", "Str_FormPanelTitleColor9"));

        SearchResultListDiv.Style.Add("display", "");

        System.Reflection.PropertyInfo IsAdmin = Master.GetType().GetProperty("IsAdmin");

        System.Reflection.PropertyInfo AccountID = Master.GetType().GetProperty("AccountID");

        if (IsAdmin != null && AccountID != null)
            HF_IsShowSetEnd.Value = (((bool)IsAdmin.GetValue(Master) || (AccountID != null && BaseConfiguration.OnlineAccount.ContainsKey((int)AccountID.GetValue(Master)) && BaseConfiguration.OnlineAccount[(int)AccountID.GetValue(Master)].UseModule.Contains("TS.PMCadmin"))) && (MOStatus == Util.TS.MOStatus.InProcess)).ToStringValue();
    }

    protected void ViewModel0()
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
                IsNull((Select Sum(ScrapQty) From T_TSTicketResult Where T_TSTicketResult.TicketID In (Select TicketID From dbo.TS_GetFullSubTicket(T_TSTicket.TicketID,1))),0) As ScrapQtyByTotal,
				(Select Count(*) From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID) As ReportCount,
				(Select Count(*) From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID And ApprovalTime Is Null) As ReportNotYetCount,
				(Select Count(*) From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID And ApprovalTime Is Not Null) As FinishReportCount,
				'' As ReportColor,
                '' As DifferentQTYColor,
                Replace(T_TSTicket.MainTicketID,@AUFNR + '-','') As MainTicketID,
                Case
	                When IsNull(ParentTicketID,'') <> '' Then Replace(dbo.TS_GetParentTicketIDPath(T_TSTicket.TicketID,'/'),@AUFNR + '-','')
	                Else ''
                End As ParentTicketIDPath,
                Case
	                When CreateProcessID > 0 And IsNull(ParentTicketID,'') <> '' Then (Select Convert(nvarchar,ProcessID) + '-' + VORNR + '-' + LTXA1 From T_TSTicketRouting Where T_TSTicketRouting.TicketID = ParentTicketID And T_TSTicketRouting.ProcessID = CreateProcessID)
	                Else ''
                End As CreateProcessName,
                CreateDate,
                Base_Org.dbo.GetAccountName(CreateAccountID) As CreateAccountName,
                IsNull((Select Top 1 ReportTimeEnd From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID Order By ProcessID,SerialNo Desc),'1900/01/01') As ReportTimeEnd,
                (Select Top 1 Base_Org.dbo.GetAccountName(Operator) From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And ProcessID = TicketResult.MaxProcessID Order By ProcessID,SerialNo Desc) As ReportAccountName,
                (Select Top 1 Brand From T_TSTicketResult Where T_TSTicketResult.TicketID = T_TSTicket.TicketID And Brand <> '' Order By CreateDate Desc) As Brand,                
                IsEnd
                From T_TSTicket
                Left Join (Select T_TSTicketResult.TicketID,Max(ProcessID) As MaxProcessID From T_TSTicketResult Group By T_TSTicketResult.TicketID) As TicketResult On T_TSTicket.TicketID = TicketResult.TicketID
                Where AUFNR = @AUFNR
                Order By TicketID";


        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

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
                classes = Column.ColumnName == "TicketID" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            TicketIDColumnName = "TicketIDValue",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                TicketIDValue = Row["TicketID"].ToString().Trim(),
                TicketID = Row["TicketID"].ToString().Trim(),
                TicketTypeName = Row["TicketTypeName"].ToString().Trim(),
                LastProcessName = Row["LastProcessName"].ToString().Trim(),
                NextProcessName = Row["NextProcessName"].ToString().Trim(),
                Qty = Row["Qty"] == DBNull.Value ? string.Empty : ((int)Row["Qty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                GoodQty = Row["GoodQty"] == DBNull.Value ? string.Empty : ((int)Row["GoodQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ReWorkQty = Row["ReWorkQty"] == DBNull.Value ? string.Empty : ((int)Row["ReWorkQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQty = Row["ScrapQty"] == DBNull.Value ? string.Empty : ((int)Row["ScrapQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQtyByTotal = Row["ScrapQtyByTotal"].ToString().Trim(),
                ReportColor = string.IsNullOrEmpty(Row["LastProcessName"].ToString().Trim()) ? string.Empty : !(bool)Row["IsEnd"] && (int)Row["FinishReportCount"] == 0 ? "red" : !(bool)Row["IsEnd"] && ((int)Row["ReportCount"] - (int)Row["FinishReportCount"]) > 0 ? YellowColor : string.Empty,
                DifferentQTYColor = (int)Row["Qty"] == ((int)Row["GoodQty"] + (int)Row["ScrapQtyByTotal"]) ? string.Empty : PinkColor,
                ParentTicketIDPath = Row["ParentTicketIDPath"].ToString().Trim(),
                MainTicketID = Row["MainTicketID"].ToString().Trim(),
                CreateProcessName = Row["CreateProcessName"].ToString().Trim(),
                CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureStringTime(),
                CreateAccountName = Row["CreateAccountName"].ToString().Trim(),
                ReportTimeEnd = ((DateTime)Row["ReportTimeEnd"]).ToCurrentUICultureStringTime(),
                ReportAccountName = Row["ReportAccountName"].ToString().Trim(),
                Brand = Row["Brand"].ToString().Trim(),
                IsEnd = (bool)Row["IsEnd"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty
            })
        };

        TB_TicketTotalQty.Text = DT.AsEnumerable().Where(Row => Row["TicketTypeID"].ToString().Trim() == ((short)Util.TS.TicketType.General).ToString()).Sum(Row => (int)Row["Qty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");
    }

    protected void ViewModel1()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        string Query = @"Select String_Agg('[' + LTXA1 +']',',') Within Group (Order By ProcessID)
                        From (
	                        Select ProcessID,LTXA1
	                        From T_TSTicket Inner Join T_TSTicketRouting On T_TSTicket.TicketID = T_TSTicketRouting.TicketID Where T_TSTicket.AUFNR = @AUFNR Group By ProcessID,LTXA1
                        ) As RoutingTable";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        string LTXA1 = CommonDB.ExecuteScalar(dbcb).ToString();

        if (string.IsNullOrEmpty(LTXA1))
        {
            HF_IsShowSetEnd.Value = false.ToStringValue();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

            return;
        }

        Query = @"Select String_Agg('IsNull(Sum([' + LTXA1 +']),0) As [' + LTXA1 +']',',') Within Group (Order By ProcessID)
                From (
	                Select ProcessID,LTXA1
	                From T_TSTicket Inner Join T_TSTicketRouting On T_TSTicket.TicketID = T_TSTicketRouting.TicketID Where T_TSTicket.AUFNR = @AUFNR Group By ProcessID,LTXA1
                ) As RoutingTable";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        string SumLTXA1 = CommonDB.ExecuteScalar(dbcb).ToString();

        Query = @"Select ResultTable.TicketID As TicketIDValue,ResultTable.TicketID,T_TSTicket.Qty," + SumLTXA1 + @",(Select Top 1 Brand From T_TSTicketResult Where T_TSTicketResult.TicketID = ResultTable.TicketID And Brand <> '' And Approver > 0 Order By CreateDate) As Brand,
                Replace(T_TSTicket.MainTicketID,@AUFNR + '-','') As MainTicketID,
                Case
	                When IsNull(T_TSTicket.ParentTicketID,'') <> '' Then Replace(dbo.TS_GetParentTicketIDPath(ResultTable.TicketID,'/'),@AUFNR + '-','')
	                Else ''
                End As ParentTicketIDPath,
                Case
	                When T_TSTicket.CreateProcessID > 0 And IsNull(T_TSTicket.ParentTicketID,'') <> '' Then (Select Convert(nvarchar,ProcessID) + '-' + VORNR + '-' + LTXA1 From T_TSTicketRouting Where T_TSTicketRouting.TicketID = ParentTicketID And T_TSTicketRouting.ProcessID = CreateProcessID)
	                Else ''
                End As CreateProcessName,T_TSTicket.IsEnd From
                (
	                Select TicketID," + LTXA1 + @" From
	                (
		                Select TicketID,LTXA1,GoodQty From V_TSTicketResult
		                Where AUFNR = @AUFNR And Approver > 0
	                ) As ResultTable
	                Pivot
	                (
		                Sum(GoodQty)
		                For LTXA1 In (" + LTXA1 + @")
	                )
	                As PivotTable
	                Union All
	                Select TicketID," + LTXA1 + @" From
	                (
		                Select TicketID,LTXA1,ScrapQty From V_TSTicketResult
		                Where AUFNR = @AUFNR And Approver > 0
	                ) As ResultTable
	                Pivot
	                (
		                Sum(ScrapQty)
		                For LTXA1 In (" + LTXA1 + @")
	                )
	                As PivotTable
                ) As ResultTable
                Inner Join T_TSTicket On ResultTable.TicketID = T_TSTicket.TicketID
                Group By ResultTable.TicketID,T_TSTicket.Qty,T_TSTicket.MainTicketID,T_TSTicket.ParentTicketID,T_TSTicket.CreateProcessID,T_TSTicket.IsEnd";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        IList<Dictionary<string, string>> Rows = DT.ToDictionary();

        foreach (Dictionary<string, string> Row in Rows)
        {
            Row["IsEnd"] = Row["IsEnd"].ToBoolean() ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty;
        }

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
            Rows = Rows
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");
    }

    protected void ViewModel2()
    {
        string Query = @"Select
                        Convert(Nvarchar(50),T_TSTicketRouting.ProcessID) + '-' + T_TSTicketRouting.VORNR + '-' + T_TSTicketRouting.LTXA1 As ProcessName,
                        T_TSTicketResult.ReportDate,
                        Sum(GoodQty) As GoodQty,
                        Sum(ScrapQty) As ScrapQty
                        From T_TSTicket 
                        Inner Join T_TSTicketRouting On T_TSTicket.TicketID = T_TSTicketRouting.TicketID
                        Inner Join T_TSTicketResult On T_TSTicketResult.TicketID = T_TSTicketRouting.TicketID And T_TSTicketResult.ProcessID = T_TSTicketRouting.ProcessID And T_TSTicketResult.Approver Is Not Null And T_TSTicketResult.ApprovalTime Is Not Null
                        Where T_TSTicket.AUFNR = @AUFNR
                        Group By 
                        T_TSTicket.AUFNR,
                        T_TSTicketRouting.LTXA1,
                        T_TSTicketRouting.ProcessID,
                        T_TSTicketRouting.VORNR,
                        T_TSTicketResult.ReportDate
                        Order By T_TSTicketRouting.ProcessID,ReportDate";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            HF_IsShowSetEnd.Value = false.ToStringValue();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

            return;
        }

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
                summaryType = Column.ColumnName == "GoodQty" || Column.ColumnName == "ScrapQty" ? "sum" : null,
                summaryTpl = Column.ColumnName != "GoodQty" && Column.ColumnName != "ScrapQty" ? null : "<b>{0}</b>",
            }),
            groupingView = new
            {
                groupField = new string[] { "ProcessName" },
                groupColumnShow = new bool[] { false },
                groupSummary = new bool[] { true }
            },
            ReportDateColumnName = "ReportDate",
            CustiomFormatterLocalizedNumericColumnNames = new string[] { "GoodQty", "ScrapQty" },
            Rows = DT.AsEnumerable().Select(Row => new
            {
                ProcessName = Row["ProcessName"].ToString().Trim(),
                ReportDate = ((DateTime)Row["ReportDate"]).ToCurrentUICultureString(),
                GoodQty = Row["GoodQty"].ToString().Trim(),
                ScrapQty = Row["ScrapQty"].ToString().Trim()
            })
        };

        Query = @"Select Sum(Qty) From T_TSTicket As Ticket Where Ticket.AUFNR = @AUFNR And TicketTypeID = @TicketTypeID";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.General).ToString()));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        int TotalQty = 0;

        if (DT.Rows.Count > 0)
            TotalQty = (int)DT.Rows[0][0];

        TB_TicketTotalQty.Text = TotalQty.ToString().Trim();

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");
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
            case "TicketIDValue":
            case "TicketTypeID":
            case "ReportCount":
            case "ReportNotYetCount":
            case "FinishReportCount":
            case "ReportColor":
            case "DifferentQTYColor":
            case "CreateDate":
            case "CreateAccountName":
            case "TicketTypeName":
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
        if (DDL_ViewModel.SelectedValue == "0")
        {
            switch (ColumnName)
            {
                case "Qty":
                case "GoodQty":
                case "ReWorkQty":
                case "ScrapQty":
                case "ScrapQtyByTotal":
                case "CreateAccountName":
                case "ReportAccountName":
                case "IsEnd":
                case "TicketTypeName":
                case "CreateDate":
                case "ReportTimeEnd":
                    return "center";
                default:
                    return "left";
            }
        }
        if (DDL_ViewModel.SelectedValue == "1")
        {
            switch (ColumnName)
            {
                case "TicketID":
                case "ParentTicketIDPath":
                case "MainTicketID":
                case "CreateProcessName":
                    return "left";
                default:
                    return "center";
            }
        }
        else
        {
            switch (ColumnName)
            {
                case "GoodQty":
                case "ScrapQty":
                case "ScrapQtyByTotal":
                    return "center";
                case "ReportDate":
                    return "right";
                default:
                    return "left";
            }
        }
    }

    /// <summary>
    /// 指定ColumnName得到欄位寬度
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>欄位寬度</returns>
    protected int GetWidth(string ColumnName)
    {
        if (DDL_ViewModel.SelectedValue == "0")
        {
            switch (ColumnName)
            {
                case "TicketID":
                    return 120;
                case "CreateDate":
                case "ReportTimeEnd":
                case "CreateAccountName":
                    return 80;
                case "ParentTicketIDPath":
                case "MainTicketID":
                case "ReportAccountName":
                case "Brand":
                case "IsEnd":
                    return 60;
                case "Qty":
                case "GoodQty":
                case "ReWorkQty":
                case "ScrapQty":
                case "ScrapQtyByTotal":
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
        else if (DDL_ViewModel.SelectedValue == "1")
        {
            switch (ColumnName)
            {
                case "TicketID":
                    return 120;
                case "Qty":
                case "Brand":
                case "ParentTicketIDPath":
                case "MainTicketID":
                case "CreateProcessName":
                    return 80;
                case "IsEnd":
                    return 60;
                default:
                    return 100;
            }
        }
        else
        {
            switch (ColumnName)
            {
                case "ReportDateTime":
                    return 80;
                case "GoodQty":
                case "ScrapQty":
                    return 40;
                default:
                    return 150;
            }
        }
    }

    /// <summary>
    /// 指定ColumnName得到顯示欄位名稱
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        if (DDL_ViewModel.SelectedValue == "0")
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
                case "ScrapQtyByTotal":
                    return (string)GetLocalResourceObject("Str_ColumnName_ScrapQtyByTotal");
                case "ParentTicketIDPath":
                    return (string)GetLocalResourceObject("Str_ColumnName_ParentTicketIDPath");
                case "MainTicketID":
                    return (string)GetLocalResourceObject("Str_ColumnName_MainTicketID");
                case "CreateProcessName":
                    return (string)GetLocalResourceObject("Str_ColumnName_CreateProcessName");
                case "CreateDate":
                    return (string)GetLocalResourceObject("Str_ColumnName_CreateDate");
                case "ReportTimeEnd":
                    return (string)GetLocalResourceObject("Str_ColumnName_ReportTimeEnd");
                case "CreateAccountName":
                    return (string)GetLocalResourceObject("Str_ColumnName_CreateAccountName");
                case "ReportAccountName":
                    return (string)GetLocalResourceObject("Str_ColumnName_ReportAccountName");
                case "Brand":
                    return (string)GetLocalResourceObject("Str_ColumnName_Brand");
                case "IsEnd":
                    return (string)GetLocalResourceObject("Str_ColumnName_IsEnd");
                default:
                    return ColumnName;
            }
        }
        else if (DDL_ViewModel.SelectedValue == "1")
        {
            switch (ColumnName)
            {
                case "TicketID":
                    return (string)GetLocalResourceObject("Str_ColumnName_TicketID");
                case "Qty":
                    return (string)GetLocalResourceObject("Str_ColumnName_Qty");
                case "IsEnd":
                    return (string)GetLocalResourceObject("Str_ColumnName_IsEnd");
                case "Brand":
                    return (string)GetLocalResourceObject("Str_ColumnName_Brand");
                case "CreateProcessName":
                    return (string)GetLocalResourceObject("Str_ColumnName_CreateProcessName");
                case "MainTicketID":
                    return (string)GetLocalResourceObject("Str_ColumnName_MainTicketID");
                case "ParentTicketIDPath":
                    return (string)GetLocalResourceObject("Str_ColumnName_ParentTicketIDPath");
                default:
                    return ColumnName;
            }
        }
        else
        {
            switch (ColumnName)
            {
                case "ProcessName":
                    return (string)GetLocalResourceObject("Str_ViewModel1ColumnName_ProcessName");
                case "ReportDate":
                    return (string)GetLocalResourceObject("Str_ViewModel1ColumnName_ReportDate");
                case "GoodQty":
                    return (string)GetLocalResourceObject("Str_ViewModel1ColumnName_GoodQty");
                case "ScrapQty":
                    return (string)GetLocalResourceObject("Str_ViewModel1ColumnName_ScrapQty");
                default:
                    return ColumnName;
            }
        }
    }

    protected void BT_SetEnd_Click(object sender, EventArgs e)
    {
        TB_AUFNR.Text = Util.TS.ToAUFNR(TB_AUFNR.Text.Trim());

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        //Synchronize_SAPData.MO.SynchronizeData_AFKO(new List<string>() { TB_AUFNR.Text });

        //Synchronize_SAPData.MO.SynchronizeData_JEST(new List<string>() { TB_AUFNR.Text });

        /*
        string Query = "Select [STATUS] From T_TSSAPAFKO Where AUFNR = @AUFNR";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        Util.TS.MOStatus MOStatus = (Util.TS.MOStatus)Enum.Parse(typeof(Util.TS.MOStatus), CommonDB.ExecuteScalar(dbcb).ToString().Trim());

        if (MOStatus != Util.TS.MOStatus.Closed)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_MONotClose"));

            BT_Search_Click(sender, e);

            return;
        }
        */

        DBAction DBA = new DBAction();

        string Query = "Update T_TSSAPAFKO Set [STATUS] = @STATUS,CloseDateTime = GetDate(),CloseAccountID = @CloseAccountID Where AUFNR = @AUFNR";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        dbcb.appendParameter(Schema.Attributes["STATUS"].copy(((short)Util.TS.MOStatus.Closed).ToString()));

        System.Reflection.PropertyInfo AccountID = Master.GetType().GetProperty("AccountID");

        dbcb.appendParameter(Schema.Attributes["CloseAccountID"].copy((int)AccountID.GetValue(Master)));

        DBA.AddCommandBuilder(dbcb);

        Query = @"Update T_TSTicketRouting Set IsEnd = 1 Where TicketID in (Select TicketID From T_TSTicket Where AUFNR = @AUFNR) And IsEnd = 0";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        DBA.AddCommandBuilder(dbcb);

        Query = @"Delete T_TSTicketCurrStatus Where TicketID in (Select TicketID From T_TSTicket Where AUFNR = @AUFNR)";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        DBA.AddCommandBuilder(dbcb);

        Query = @"Update T_TSTicket Set IsEnd = 1 Where AUFNR = @AUFNR And IsEnd = 0";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        DBA.AddCommandBuilder(dbcb);

        DBA.Execute();

        BT_Search_Click(sender, e);
    }

    /// <summary>
    /// 得到所屬工單號(從刻字號)
    /// </summary>
    /// <returns>工單號</returns>
    protected string GetAUFNRFromBrand()
    {
        string Query = @"Select AUFNR From V_TSTicketResult Where Brand = @Brand Group By AUFNR";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        dbcb.appendParameter(Schema.Attributes["Brand"].copy(TB_Brand.Text.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 1)
        {
            HF_IsShowSetEnd.Value = false.ToStringValue();

            throw new Exception((string)GetLocalResourceObject("Str_Error_MultipleAUFNR"));

        }
        else if (DT.Rows.Count < 1)
        {
            HF_IsShowSetEnd.Value = false.ToStringValue();

            throw new Exception((string)GetLocalResourceObject("Str_Error_NoAUFNR"));
        }
        else
            return DT.Rows[0][0].ToString().Trim();
    }
}