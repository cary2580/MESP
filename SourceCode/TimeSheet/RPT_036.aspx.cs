using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_RPT_036 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
            TB_ReportDateMonth.Text = DateTime.Now.ToString("yyyy/MM");
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        string ReportDateMonth = TB_ReportDateMonth.Text + "/01";

        string Query = @"Select * Into #AFKO From(
	                        Select AUFNR,
		                        (Select Max(ReportDate) From V_TSTicketResult Where V_TSTicketResult.AUFNR = T_TSSAPAFKO.AUFNR And V_TSTicketResult.ProcessID = 1 And Datediff(Day,V_TSTicketResult.ApprovalTime,getdate()) >= 0) As ReportDate,
		                        CloseDateTime,
		                        [STATUS]
	                        From T_TSSAPAFKO
	                        ) As Result
                        Where Datediff(Month,Result.ReportDate,@ReportDateMonth) = 0 Or Datediff(Month,Result.CloseDateTime,@ReportDateMonth) = 0;

                        With TotalCount As (
                        Select Count(*) As Total From #AFKO Where Datediff(Month,ReportDate,@ReportDateMonth) = 0
                        ),
                        FilteredCount AS (
                        Select 
	                        Count(Case When Datediff(Month,ReportDate,@ReportDateMonth) = 0 And Datediff(Month,CloseDateTime,@ReportDateMonth) = 0 And [STATUS] = @Status Then 1 Else Null End) AS FilteredByClose,
	                        Count(Case When Datediff(Month,CloseDateTime,@ReportDateMonth) = 0 Then 1 Else Null End) AS FilteredByCloseSameMonth
                        From #AFKO
                        )
                        Select 
                        T.Total, 
                        F.FilteredByClose,
                        F.FilteredByCloseSameMonth,
                        Cast(F.FilteredByClose As Float) / NullIf(T.Total, 0) AS [PercentageByClose],
                        Cast(F.FilteredByCloseSameMonth As Float) / NullIf(T.Total, 0) AS [PercentageByByCloseSameMonth]
                        From TotalCount As T, FilteredCount As F;";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateMonth", "DateTime", 0, DateTime.Parse(ReportDateMonth, System.Threading.Thread.CurrentThread.CurrentUICulture)));

        dbcb.appendParameter(Util.GetDataAccessAttribute("Status", "Nvarchar", 50, Util.TS.MOStatus.Closed));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            TB_ResultValue1ByTotal.Text = DT.Rows[0]["Total"].ToString().Trim();

            TB_ResultValue1ByFiltered.Text = DT.Rows[0]["FilteredByClose"].ToString().Trim();

            TB_ResultValue1.Text = DT.Rows[0].IsNull("PercentageByClose") ? "0.00" : ((double)DT.Rows[0]["PercentageByClose"]).ToString("P", System.Threading.Thread.CurrentThread.CurrentUICulture).Replace("%", string.Empty);

            TB_ResultValue2ByTotal.Text = DT.Rows[0]["Total"].ToString().Trim();

            TB_ResultValue2ByFiltered.Text = DT.Rows[0]["FilteredByCloseSameMonth"].ToString().Trim();

            TB_ResultValue2.Text = DT.Rows[0].IsNull("PercentageByByCloseSameMonth") ? "0.00" : ((double)DT.Rows[0]["PercentageByByCloseSameMonth"]).ToString("P", System.Threading.Thread.CurrentThread.CurrentUICulture).Replace("%", string.Empty);
        }
    }
}