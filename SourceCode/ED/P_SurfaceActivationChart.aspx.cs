using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class ED_P_SurfaceActivationChart : System.Web.UI.Page
{
    protected decimal MaxValueInRow = Util.ED.StandardMinValue;

    protected decimal MinValueInRow = Util.ED.StandardMaxValue;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
        {
            Util.ED.LaodWorkClass(CBL_WorkClass);

            Util.ED.LoadProductionLine(CBL_PLID);

            L_SurfaceActivation.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_SurfaceActivation");

            L_Phosphating.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_Phosphating");

        }
    }

    protected void LoadStandardValueToPage()
    {
        string PageFirstID = string.Empty;

        int ProcessCheckCount = 0;

        if (CB_SurfaceActivation.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "7";
        }

        if (CB_Phosphating.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "8";
        }

        /* 選取多個工序就不顯示標準值上下限 */
        if (ProcessCheckCount > 1)
            return;

        string PrametersID = "EDP" + PageFirstID;

        if (RB_PH.Checked)
            PrametersID += "1";
        else if (RB_Temperature.Checked)
            PrametersID += "2";
        else if (RB_FreeAcid.Checked)
            PrametersID += "4";
        else if (RB_TotalAcidity.Checked)
            PrametersID += "5";
        else if (RB_PromotionPoint.Checked)
            PrametersID += "6";

        DbCommandBuilder dbcb = new DbCommandBuilder("Select Top 1 * From T_EDPStandardValue Where PrametersID = @PrametersID");

        dbcb.appendParameter(Util.GetDataAccessAttribute("PrametersID", "nvarchar", 50, PrametersID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            decimal MaxValue = (decimal)DT.Rows[0]["MaxValue"];

            decimal MinValue = (decimal)DT.Rows[0]["MinValue"];

            if (MaxValue < Util.ED.StandardMaxValue)
                Page.ClientScript.RegisterClientScriptBlock(GetType(), "ChartStandardMaxValue", "<script>var ChartStandardMaxValue=" + MaxValue.ToString("0.##") + "</script>");

            if (MinValue > Util.ED.StandardMinValue)
                Page.ClientScript.RegisterClientScriptBlock(GetType(), "ChartStandardMinValue", "<script>var ChartStandardMinValue=" + MinValue.ToString("0.##") + "</script>");

            decimal ChartYMaxValue = (MaxValue < Util.ED.StandardMaxValue && MaxValue > MaxValueInRow) ? MaxValue : MaxValueInRow;

            decimal ChartYMinValue = (MinValue > Util.ED.StandardMinValue && MinValue < MinValueInRow) ? MinValue : MinValueInRow;

            Page.ClientScript.RegisterClientScriptBlock(GetType(), "ChartYMaxValue", "<script>var ChartYMaxValue=" + ChartYMaxValue.ToString("0.##") + "</script>");

            Page.ClientScript.RegisterClientScriptBlock(GetType(), "ChartYMinValue", "<script>var ChartYMinValue=" + ChartYMinValue.ToString("0.##") + "</script>");
        }
    }

    protected void BT_CreateChart_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        DateTime StartDate, EndDate;

        if (!DateTime.TryParse(TB_StartPDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out StartDate))
            StartDate = DateTime.Parse("1900/01/01");

        if (!DateTime.TryParse(TB_EndPDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out EndDate))
            EndDate = DateTime.Parse("1900/01/01");

        if (StartDate > EndDate)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"), true, true);

            return;
        }

        DataTable SurfaceActivation_DT = new DataTable();
        DataTable Phosphating_DT = new DataTable();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPSurfaceActivation"];

        string Query = @"Select *,(Select Top 1 CodeName From T_Code Where CodeID = PLID And CodeType = 'ProductionLine' And UICulture = @UICulture) As PLName ";

        if (CB_SurfaceActivation.Checked)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.CommandText = Query + " From T_EDPSurfaceActivation Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

            SurfaceActivation_DT = CommonDB.ExecuteSelectQuery(dbcb);
        }

        if (CB_Phosphating.Checked)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.CommandText = Query + " From T_EDPPhosphating Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

            Phosphating_DT = CommonDB.ExecuteSelectQuery(dbcb);
        }

        List<Util.ChartSeriesOption> Result = new List<Util.ChartSeriesOption>();

        if (SurfaceActivation_DT.Rows.Count > 0)
            SetDataToResultList(Result, (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_SurfaceActivation") + " ", SurfaceActivation_DT, StartDate, EndDate);
        if (Phosphating_DT.Rows.Count > 0)
            SetDataToResultList(Result, (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_Phosphating") + " ", Phosphating_DT, StartDate, EndDate);

        int NoDataCount = Result.Where(Item => Item.data.Count < 1).Count();

        if (NoDataCount == Result.Count)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"), true, true);

            return;
        }

        Page.ClientScript.RegisterClientScriptBlock(GetType(), "ChartValue", "<script>var ChartValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(Result) + "</script>");

        LoadStandardValueToPage();

    }

    /// <summary>
    /// 指定結果集合、資料表、起訖日期將資料加入至結果集合中
    /// </summary>
    /// <param name="Result">結果集合</param>
    /// <param name="FirstName">結果集合開頭名稱</param>
    /// <param name="DT">資料表</param>
    /// <param name="StartDate">起始日期</param>
    /// <param name="EndDate">訖止日期</param>
    protected void SetDataToResultList(List<Util.ChartSeriesOption> Result, string FirstName, DataTable DT, DateTime StartDate, DateTime EndDate)
    {
        EnumerableRowCollection<DataRow> Rows = DT.AsEnumerable();

        List<ListItem> SelectProductionLineList = CBL_PLID.Items.Cast<ListItem>().Where(item => item.Selected).ToList();

        List<ListItem> SelectWorkClassList = CBL_WorkClass.Items.Cast<ListItem>().Where(item => item.Selected).ToList();

        foreach (ListItem LI in SelectProductionLineList)
        {
            List<dynamic> ResultList_PH1 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH1 = new Util.ChartSeriesOption();
            CSO_PH1.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PHValue") + "1";

            List<dynamic> ResultList_PH2 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH2 = new Util.ChartSeriesOption();
            CSO_PH2.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PHValue") + "2";

            List<dynamic> ResultList_Temperature1 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Temperature1 = new Util.ChartSeriesOption();
            CSO_Temperature1.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Temperature") + "1";

            List<dynamic> ResultList_Temperature2 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Temperature2 = new Util.ChartSeriesOption();
            CSO_Temperature2.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Temperature") + "2";

            List<dynamic> ResultList_Temperature3 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Temperature3 = new Util.ChartSeriesOption();
            CSO_Temperature3.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Temperature") + "3";

            List<dynamic> ResultList_Temperature4 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Temperature4 = new Util.ChartSeriesOption();
            CSO_Temperature4.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Temperature") + "4";

            List<dynamic> ResultList_FreeAcid1 = new List<dynamic>();
            Util.ChartSeriesOption CSO_FreeAcid1 = new Util.ChartSeriesOption();
            CSO_FreeAcid1.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_FreeAcidValue") + "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_FreeAcid2 = new List<dynamic>();
            Util.ChartSeriesOption CSO_FreeAcid2 = new Util.ChartSeriesOption();
            CSO_FreeAcid2.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_FreeAcidValue") + "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            List<dynamic> ResultList_FreeAcid3 = new List<dynamic>();
            Util.ChartSeriesOption CSO_FreeAcid3 = new Util.ChartSeriesOption();
            CSO_FreeAcid3.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_FreeAcidValue") + "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_FreeAcid4 = new List<dynamic>();
            Util.ChartSeriesOption CSO_FreeAcid4 = new Util.ChartSeriesOption();
            CSO_FreeAcid4.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_FreeAcidValue") + "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            List<dynamic> ResultList_FreeAcid5 = new List<dynamic>();
            Util.ChartSeriesOption CSO_FreeAcid5 = new Util.ChartSeriesOption();
            CSO_FreeAcid5.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_FreeAcidValue") + "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_FreeAcid6 = new List<dynamic>();
            Util.ChartSeriesOption CSO_FreeAcid6 = new Util.ChartSeriesOption();
            CSO_FreeAcid6.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_FreeAcidValue") + "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            List<dynamic> ResultList_FreeAcid7 = new List<dynamic>();
            Util.ChartSeriesOption CSO_FreeAcid7 = new Util.ChartSeriesOption();
            CSO_FreeAcid7.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_FreeAcidValue") + "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_FreeAcid8 = new List<dynamic>();
            Util.ChartSeriesOption CSO_FreeAcid8 = new Util.ChartSeriesOption();
            CSO_FreeAcid8.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_FreeAcidValue") + "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            List<dynamic> ResultList_TotalAcidity1 = new List<dynamic>();
            Util.ChartSeriesOption CSO_TotalAcidity1 = new Util.ChartSeriesOption();
            CSO_TotalAcidity1.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_TotalAcidity") + "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_TotalAcidity2 = new List<dynamic>();
            Util.ChartSeriesOption CSO_TotalAcidity2 = new Util.ChartSeriesOption();
            CSO_TotalAcidity2.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_TotalAcidity") + "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            List<dynamic> ResultList_TotalAcidity3 = new List<dynamic>();
            Util.ChartSeriesOption CSO_TotalAcidity3 = new Util.ChartSeriesOption();
            CSO_TotalAcidity3.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_TotalAcidity") + "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_TotalAcidity4 = new List<dynamic>();
            Util.ChartSeriesOption CSO_TotalAcidity4 = new Util.ChartSeriesOption();
            CSO_TotalAcidity4.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_TotalAcidity") + "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            List<dynamic> ResultList_TotalAcidity5 = new List<dynamic>();
            Util.ChartSeriesOption CSO_TotalAcidity5 = new Util.ChartSeriesOption();
            CSO_TotalAcidity5.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_TotalAcidity") + "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_TotalAcidity6 = new List<dynamic>();
            Util.ChartSeriesOption CSO_TotalAcidity6 = new Util.ChartSeriesOption();
            CSO_TotalAcidity6.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_TotalAcidity") + "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            List<dynamic> ResultList_TotalAcidity7 = new List<dynamic>();
            Util.ChartSeriesOption CSO_TotalAcidity7 = new Util.ChartSeriesOption();
            CSO_TotalAcidity7.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_TotalAcidity") + "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_TotalAcidity8 = new List<dynamic>();
            Util.ChartSeriesOption CSO_TotalAcidity8 = new Util.ChartSeriesOption();
            CSO_TotalAcidity8.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_TotalAcidity") + "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            List<dynamic> ResultList_PromotionPoint1 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PromotionPoint1 = new Util.ChartSeriesOption();
            CSO_PromotionPoint1.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PromotionPointValue") + "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_PromotionPoint2 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PromotionPoint2 = new Util.ChartSeriesOption();
            CSO_PromotionPoint2.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PromotionPointValue") + "1 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            List<dynamic> ResultList_PromotionPoint3 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PromotionPoint3 = new Util.ChartSeriesOption();
            CSO_PromotionPoint3.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PromotionPointValue") + "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_PromotionPoint4 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PromotionPoint4 = new Util.ChartSeriesOption();
            CSO_PromotionPoint4.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PromotionPointValue") + "2 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            List<dynamic> ResultList_PromotionPoint5 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PromotionPoint5 = new Util.ChartSeriesOption();
            CSO_PromotionPoint5.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PromotionPointValue") + "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_PromotionPoint6 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PromotionPoint6 = new Util.ChartSeriesOption();
            CSO_PromotionPoint6.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PromotionPointValue") + "3 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            List<dynamic> ResultList_PromotionPoint7 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PromotionPoint7 = new Util.ChartSeriesOption();
            CSO_PromotionPoint7.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PromotionPointValue") + "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_InitialTestingTimeWord");

            List<dynamic> ResultList_PromotionPoint8 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PromotionPoint8 = new Util.ChartSeriesOption();
            CSO_PromotionPoint8.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PromotionPointValue") + "4 " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_RetestingTimeWord");

            foreach (DateTime Day in StartDate.EachDayTo(EndDate))
            {
                foreach (ListItem WorkClassItem in SelectWorkClassList)
                {
                    DataRow ValueRow = Rows.Where(Row => (DateTime)Row["PDate"] == Day && Row["PLID"].ToString().Trim() == LI.Value && Row["WorkClassID"].ToString().Trim() == WorkClassItem.Value).FirstOrDefault();

                    if (ValueRow == null)
                        continue;

                    DateTime DataResult = Day;

                    if (WorkClassItem.Value == "D")
                        DataResult = Day.AddHours(8);
                    else
                        DataResult = Day.AddHours(20);

                    if (RB_PH.Checked)
                    {
                        decimal PHValue1 = (decimal)ValueRow["PHValue1"];
                        MaxValueInRow = MaxValueInRow > PHValue1 ? MaxValueInRow : PHValue1;
                        MinValueInRow = MinValueInRow < PHValue1 ? MinValueInRow : PHValue1;
                        AddParameterValueToResultList(ResultList_PH1, PHValue1, DataResult, WorkClassItem.Value);

                        decimal PHValue2 = (decimal)ValueRow["PHValue2"];
                        MaxValueInRow = MaxValueInRow > PHValue2 ? MaxValueInRow : PHValue2;
                        MinValueInRow = MinValueInRow < PHValue2 ? MinValueInRow : PHValue2;
                        AddParameterValueToResultList(ResultList_PH2, PHValue2, DataResult, WorkClassItem.Value);

                    }
                    else if (RB_Temperature.Checked && ValueRow.Table.Columns.Contains("Temperature1") && ValueRow.Table.Columns.Contains("Temperature2") && ValueRow.Table.Columns.Contains("Temperature3") && ValueRow.Table.Columns.Contains("Temperature4"))
                    {
                        decimal Temperature1Value1 = (decimal)ValueRow["Temperature1"];
                        MaxValueInRow = MaxValueInRow > Temperature1Value1 ? MaxValueInRow : Temperature1Value1;
                        MinValueInRow = MinValueInRow < Temperature1Value1 ? MinValueInRow : Temperature1Value1;
                        AddParameterValueToResultList(ResultList_Temperature1, Temperature1Value1, DataResult, WorkClassItem.Value);

                        decimal Temperature1Value2 = (decimal)ValueRow["Temperature2"];
                        MaxValueInRow = MaxValueInRow > Temperature1Value2 ? MaxValueInRow : Temperature1Value2;
                        MinValueInRow = MinValueInRow < Temperature1Value2 ? MinValueInRow : Temperature1Value2;
                        AddParameterValueToResultList(ResultList_Temperature2, Temperature1Value2, DataResult, WorkClassItem.Value);

                        decimal Temperature1Value3 = (decimal)ValueRow["Temperature3"];
                        MaxValueInRow = MaxValueInRow > Temperature1Value3 ? MaxValueInRow : Temperature1Value3;
                        MinValueInRow = MinValueInRow < Temperature1Value3 ? MinValueInRow : Temperature1Value3;
                        AddParameterValueToResultList(ResultList_Temperature3, Temperature1Value3, DataResult, WorkClassItem.Value);

                        decimal Temperature1Value4 = (decimal)ValueRow["Temperature4"];
                        MaxValueInRow = MaxValueInRow > Temperature1Value4 ? MaxValueInRow : Temperature1Value4;
                        MinValueInRow = MinValueInRow < Temperature1Value4 ? MinValueInRow : Temperature1Value4;
                        AddParameterValueToResultList(ResultList_Temperature4, Temperature1Value4, DataResult, WorkClassItem.Value);
                    }
                    else if (RB_FreeAcid.Checked && ValueRow.Table.Columns.Contains("FreeAcid1") && ValueRow.Table.Columns.Contains("FreeAcid2")
                             && ValueRow.Table.Columns.Contains("FreeAcid3") && ValueRow.Table.Columns.Contains("FreeAcid4")
                             && ValueRow.Table.Columns.Contains("FreeAcid5") && ValueRow.Table.Columns.Contains("FreeAcid6")
                             && ValueRow.Table.Columns.Contains("FreeAcid7") && ValueRow.Table.Columns.Contains("FreeAcid8"))
                    {
                        decimal FreeAcidValue1 = (decimal)ValueRow["FreeAcid1"];
                        MaxValueInRow = MaxValueInRow > FreeAcidValue1 ? MaxValueInRow : FreeAcidValue1;
                        MinValueInRow = MinValueInRow < FreeAcidValue1 ? MinValueInRow : FreeAcidValue1;
                        AddParameterValueToResultList(ResultList_FreeAcid1, FreeAcidValue1, DataResult, WorkClassItem.Value);

                        decimal FreeAcidValue2 = (decimal)ValueRow["FreeAcid2"];
                        MaxValueInRow = MaxValueInRow > FreeAcidValue2 ? MaxValueInRow : FreeAcidValue2;
                        MinValueInRow = MinValueInRow < FreeAcidValue2 ? MinValueInRow : FreeAcidValue2;
                        AddParameterValueToResultList(ResultList_FreeAcid2, FreeAcidValue2, DataResult, WorkClassItem.Value);

                        decimal FreeAcidValue3 = (decimal)ValueRow["FreeAcid3"];
                        MaxValueInRow = MaxValueInRow > FreeAcidValue3 ? MaxValueInRow : FreeAcidValue3;
                        MinValueInRow = MinValueInRow < FreeAcidValue3 ? MinValueInRow : FreeAcidValue3;
                        AddParameterValueToResultList(ResultList_FreeAcid3, FreeAcidValue3, DataResult, WorkClassItem.Value);

                        decimal FreeAcidValue4 = (decimal)ValueRow["FreeAcid4"];
                        MaxValueInRow = MaxValueInRow > FreeAcidValue4 ? MaxValueInRow : FreeAcidValue4;
                        MinValueInRow = MinValueInRow < FreeAcidValue4 ? MinValueInRow : FreeAcidValue4;
                        AddParameterValueToResultList(ResultList_FreeAcid4, FreeAcidValue4, DataResult, WorkClassItem.Value);

                        decimal FreeAcidValue5 = (decimal)ValueRow["FreeAcid5"];
                        MaxValueInRow = MaxValueInRow > FreeAcidValue5 ? MaxValueInRow : FreeAcidValue5;
                        MinValueInRow = MinValueInRow < FreeAcidValue5 ? MinValueInRow : FreeAcidValue5;
                        AddParameterValueToResultList(ResultList_FreeAcid5, FreeAcidValue5, DataResult, WorkClassItem.Value);

                        decimal FreeAcidValue6 = (decimal)ValueRow["FreeAcid6"];
                        MaxValueInRow = MaxValueInRow > FreeAcidValue6 ? MaxValueInRow : FreeAcidValue6;
                        MinValueInRow = MinValueInRow < FreeAcidValue6 ? MinValueInRow : FreeAcidValue6;
                        AddParameterValueToResultList(ResultList_FreeAcid6, FreeAcidValue6, DataResult, WorkClassItem.Value);

                        decimal FreeAcidValue7 = (decimal)ValueRow["FreeAcid7"];
                        MaxValueInRow = MaxValueInRow > FreeAcidValue7 ? MaxValueInRow : FreeAcidValue7;
                        MinValueInRow = MinValueInRow < FreeAcidValue7 ? MinValueInRow : FreeAcidValue7;
                        AddParameterValueToResultList(ResultList_FreeAcid7, FreeAcidValue7, DataResult, WorkClassItem.Value);

                        decimal FreeAcidValue8 = (decimal)ValueRow["FreeAcid8"];
                        MaxValueInRow = MaxValueInRow > FreeAcidValue8 ? MaxValueInRow : FreeAcidValue8;
                        MinValueInRow = MinValueInRow < FreeAcidValue8 ? MinValueInRow : FreeAcidValue8;
                        AddParameterValueToResultList(ResultList_FreeAcid8, FreeAcidValue8, DataResult, WorkClassItem.Value);

                    }
                    else if (RB_TotalAcidity.Checked && ValueRow.Table.Columns.Contains("TotalAcidity1") && ValueRow.Table.Columns.Contains("TotalAcidity2")
                             && ValueRow.Table.Columns.Contains("TotalAcidity3") && ValueRow.Table.Columns.Contains("TotalAcidity4")
                             && ValueRow.Table.Columns.Contains("TotalAcidity5") && ValueRow.Table.Columns.Contains("TotalAcidity6")
                             && ValueRow.Table.Columns.Contains("TotalAcidity7") && ValueRow.Table.Columns.Contains("TotalAcidity8"))
                    {
                        decimal TotalAcidityValue1 = (decimal)ValueRow["TotalAcidity1"];
                        MaxValueInRow = MaxValueInRow > TotalAcidityValue1 ? MaxValueInRow : TotalAcidityValue1;
                        MinValueInRow = MinValueInRow < TotalAcidityValue1 ? MinValueInRow : TotalAcidityValue1;
                        AddParameterValueToResultList(ResultList_TotalAcidity1, TotalAcidityValue1, DataResult, WorkClassItem.Value);

                        decimal TotalAcidityValue2 = (decimal)ValueRow["TotalAcidity2"];
                        MaxValueInRow = MaxValueInRow > TotalAcidityValue2 ? MaxValueInRow : TotalAcidityValue2;
                        MinValueInRow = MinValueInRow < TotalAcidityValue2 ? MinValueInRow : TotalAcidityValue2;
                        AddParameterValueToResultList(ResultList_TotalAcidity2, TotalAcidityValue2, DataResult, WorkClassItem.Value);

                        decimal TotalAcidityValue3 = (decimal)ValueRow["TotalAcidity3"];
                        MaxValueInRow = MaxValueInRow > TotalAcidityValue3 ? MaxValueInRow : TotalAcidityValue3;
                        MinValueInRow = MinValueInRow < TotalAcidityValue3 ? MinValueInRow : TotalAcidityValue3;
                        AddParameterValueToResultList(ResultList_TotalAcidity3, TotalAcidityValue3, DataResult, WorkClassItem.Value);

                        decimal TotalAcidityValue4 = (decimal)ValueRow["TotalAcidity4"];
                        MaxValueInRow = MaxValueInRow > TotalAcidityValue4 ? MaxValueInRow : TotalAcidityValue4;
                        MinValueInRow = MinValueInRow < TotalAcidityValue4 ? MinValueInRow : TotalAcidityValue4;
                        AddParameterValueToResultList(ResultList_TotalAcidity4, TotalAcidityValue4, DataResult, WorkClassItem.Value);

                        decimal TotalAcidityValue5 = (decimal)ValueRow["TotalAcidity5"];
                        MaxValueInRow = MaxValueInRow > TotalAcidityValue5 ? MaxValueInRow : TotalAcidityValue5;
                        MinValueInRow = MinValueInRow < TotalAcidityValue5 ? MinValueInRow : TotalAcidityValue5;
                        AddParameterValueToResultList(ResultList_TotalAcidity5, TotalAcidityValue5, DataResult, WorkClassItem.Value);

                        decimal TotalAcidityValue6 = (decimal)ValueRow["TotalAcidity6"];
                        MaxValueInRow = MaxValueInRow > TotalAcidityValue6 ? MaxValueInRow : TotalAcidityValue6;
                        MinValueInRow = MinValueInRow < TotalAcidityValue6 ? MinValueInRow : TotalAcidityValue6;
                        AddParameterValueToResultList(ResultList_TotalAcidity6, TotalAcidityValue6, DataResult, WorkClassItem.Value);

                        decimal TotalAcidityValue7 = (decimal)ValueRow["TotalAcidity7"];
                        MaxValueInRow = MaxValueInRow > TotalAcidityValue7 ? MaxValueInRow : TotalAcidityValue7;
                        MinValueInRow = MinValueInRow < TotalAcidityValue7 ? MinValueInRow : TotalAcidityValue7;
                        AddParameterValueToResultList(ResultList_TotalAcidity7, TotalAcidityValue7, DataResult, WorkClassItem.Value);

                        decimal TotalAcidityValue8 = (decimal)ValueRow["TotalAcidity8"];
                        MaxValueInRow = MaxValueInRow > TotalAcidityValue8 ? MaxValueInRow : TotalAcidityValue8;
                        MinValueInRow = MinValueInRow < TotalAcidityValue8 ? MinValueInRow : TotalAcidityValue8;
                        AddParameterValueToResultList(ResultList_TotalAcidity8, TotalAcidityValue8, DataResult, WorkClassItem.Value);

                    }
                    else if (RB_PromotionPoint.Checked && ValueRow.Table.Columns.Contains("PromotionPoint1") && ValueRow.Table.Columns.Contains("PromotionPoint2")
                             && ValueRow.Table.Columns.Contains("PromotionPoint3") && ValueRow.Table.Columns.Contains("PromotionPoint4")
                             && ValueRow.Table.Columns.Contains("PromotionPoint5") && ValueRow.Table.Columns.Contains("PromotionPoint6")
                             && ValueRow.Table.Columns.Contains("PromotionPoint7") && ValueRow.Table.Columns.Contains("PromotionPoint8"))
                    {
                        decimal PromotionPointValue1 = (decimal)ValueRow["PromotionPoint1"];
                        MaxValueInRow = MaxValueInRow > PromotionPointValue1 ? MaxValueInRow : PromotionPointValue1;
                        MinValueInRow = MinValueInRow < PromotionPointValue1 ? MinValueInRow : PromotionPointValue1;
                        AddParameterValueToResultList(ResultList_PromotionPoint1, PromotionPointValue1, DataResult, WorkClassItem.Value);

                        decimal PromotionPointValue2 = (decimal)ValueRow["PromotionPoint2"];
                        MaxValueInRow = MaxValueInRow > PromotionPointValue2 ? MaxValueInRow : PromotionPointValue2;
                        MinValueInRow = MinValueInRow < PromotionPointValue2 ? MinValueInRow : PromotionPointValue2;
                        AddParameterValueToResultList(ResultList_PromotionPoint2, PromotionPointValue2, DataResult, WorkClassItem.Value);

                        decimal PromotionPointValue3 = (decimal)ValueRow["PromotionPoint3"];
                        MaxValueInRow = MaxValueInRow > PromotionPointValue3 ? MaxValueInRow : PromotionPointValue3;
                        MinValueInRow = MinValueInRow < PromotionPointValue3 ? MinValueInRow : PromotionPointValue3;
                        AddParameterValueToResultList(ResultList_PromotionPoint3, PromotionPointValue3, DataResult, WorkClassItem.Value);

                        decimal PromotionPointValue4 = (decimal)ValueRow["PromotionPoint4"];
                        MaxValueInRow = MaxValueInRow > PromotionPointValue4 ? MaxValueInRow : PromotionPointValue4;
                        MinValueInRow = MinValueInRow < PromotionPointValue4 ? MinValueInRow : PromotionPointValue4;
                        AddParameterValueToResultList(ResultList_PromotionPoint4, PromotionPointValue4, DataResult, WorkClassItem.Value);

                        decimal PromotionPointValue5 = (decimal)ValueRow["PromotionPoint5"];
                        MaxValueInRow = MaxValueInRow > PromotionPointValue5 ? MaxValueInRow : PromotionPointValue5;
                        MinValueInRow = MinValueInRow < PromotionPointValue5 ? MinValueInRow : PromotionPointValue5;
                        AddParameterValueToResultList(ResultList_PromotionPoint5, PromotionPointValue5, DataResult, WorkClassItem.Value);

                        decimal PromotionPointValue6 = (decimal)ValueRow["PromotionPoint6"];
                        MaxValueInRow = MaxValueInRow > PromotionPointValue6 ? MaxValueInRow : PromotionPointValue6;
                        MinValueInRow = MinValueInRow < PromotionPointValue6 ? MinValueInRow : PromotionPointValue6;
                        AddParameterValueToResultList(ResultList_PromotionPoint6, PromotionPointValue6, DataResult, WorkClassItem.Value);

                        decimal PromotionPointValue7 = (decimal)ValueRow["PromotionPoint7"];
                        MaxValueInRow = MaxValueInRow > PromotionPointValue7 ? MaxValueInRow : PromotionPointValue7;
                        MinValueInRow = MinValueInRow < PromotionPointValue7 ? MinValueInRow : PromotionPointValue7;
                        AddParameterValueToResultList(ResultList_PromotionPoint7, PromotionPointValue7, DataResult, WorkClassItem.Value);

                        decimal PromotionPointValue8 = (decimal)ValueRow["PromotionPoint8"];
                        MaxValueInRow = MaxValueInRow > PromotionPointValue8 ? MaxValueInRow : PromotionPointValue8;
                        MinValueInRow = MinValueInRow < PromotionPointValue8 ? MinValueInRow : PromotionPointValue8;
                        AddParameterValueToResultList(ResultList_PromotionPoint8, PromotionPointValue8, DataResult, WorkClassItem.Value);

                    }
                }
            }

            if (ResultList_PH1.Count > 0)
            {
                CSO_PH1.data = ResultList_PH1;

                Result.Add(CSO_PH1);
            }

            if (ResultList_PH2.Count > 0)
            {
                CSO_PH2.data = ResultList_PH2;

                Result.Add(CSO_PH2);
            }

            if (ResultList_Temperature1.Count > 0)
            {
                CSO_Temperature1.data = ResultList_Temperature1;

                Result.Add(CSO_Temperature1);
            }

            if (ResultList_Temperature2.Count > 0)
            {
                CSO_Temperature2.data = ResultList_Temperature2;

                Result.Add(CSO_Temperature2);
            }

            if (ResultList_Temperature3.Count > 0)
            {
                CSO_Temperature3.data = ResultList_Temperature3;

                Result.Add(CSO_Temperature3);
            }

            if (ResultList_Temperature4.Count > 0)
            {
                CSO_Temperature4.data = ResultList_Temperature4;

                Result.Add(CSO_Temperature4);
            }

            if (ResultList_FreeAcid1.Count > 0)
            {
                CSO_FreeAcid1.data = ResultList_FreeAcid1;

                Result.Add(CSO_FreeAcid1);
            }

            if (ResultList_FreeAcid2.Count > 0)
            {
                CSO_FreeAcid2.data = ResultList_FreeAcid2;

                Result.Add(CSO_FreeAcid2);
            }

            if (ResultList_FreeAcid3.Count > 0)
            {
                CSO_FreeAcid3.data = ResultList_FreeAcid3;

                Result.Add(CSO_FreeAcid3);
            }

            if (ResultList_FreeAcid4.Count > 0)
            {
                CSO_FreeAcid4.data = ResultList_FreeAcid4;

                Result.Add(CSO_FreeAcid4);
            }

            if (ResultList_FreeAcid5.Count > 0)
            {
                CSO_FreeAcid5.data = ResultList_FreeAcid5;

                Result.Add(CSO_FreeAcid5);
            }

            if (ResultList_FreeAcid6.Count > 0)
            {
                CSO_FreeAcid6.data = ResultList_FreeAcid6;

                Result.Add(CSO_FreeAcid6);
            }

            if (ResultList_FreeAcid7.Count > 0)
            {
                CSO_FreeAcid7.data = ResultList_FreeAcid7;

                Result.Add(CSO_FreeAcid7);
            }

            if (ResultList_FreeAcid8.Count > 0)
            {
                CSO_FreeAcid8.data = ResultList_FreeAcid8;

                Result.Add(CSO_FreeAcid8);
            }

            if (ResultList_TotalAcidity1.Count > 0)
            {
                CSO_TotalAcidity1.data = ResultList_TotalAcidity1;

                Result.Add(CSO_TotalAcidity1);
            }

            if (ResultList_TotalAcidity2.Count > 0)
            {
                CSO_TotalAcidity2.data = ResultList_TotalAcidity2;

                Result.Add(CSO_TotalAcidity2);
            }

            if (ResultList_TotalAcidity3.Count > 0)
            {
                CSO_TotalAcidity3.data = ResultList_TotalAcidity3;

                Result.Add(CSO_TotalAcidity3);
            }

            if (ResultList_TotalAcidity4.Count > 0)
            {
                CSO_TotalAcidity4.data = ResultList_TotalAcidity4;

                Result.Add(CSO_TotalAcidity4);
            }

            if (ResultList_TotalAcidity5.Count > 0)
            {
                CSO_TotalAcidity5.data = ResultList_TotalAcidity5;

                Result.Add(CSO_TotalAcidity5);
            }

            if (ResultList_TotalAcidity6.Count > 0)
            {
                CSO_TotalAcidity6.data = ResultList_TotalAcidity6;

                Result.Add(CSO_TotalAcidity6);
            }

            if (ResultList_TotalAcidity7.Count > 0)
            {
                CSO_TotalAcidity7.data = ResultList_TotalAcidity7;

                Result.Add(CSO_TotalAcidity7);
            }

            if (ResultList_TotalAcidity8.Count > 0)
            {
                CSO_TotalAcidity8.data = ResultList_TotalAcidity8;

                Result.Add(CSO_TotalAcidity8);
            }

            if (ResultList_PromotionPoint1.Count > 0)
            {
                CSO_PromotionPoint1.data = ResultList_PromotionPoint1;

                Result.Add(CSO_PromotionPoint1);
            }

            if (ResultList_PromotionPoint2.Count > 0)
            {
                CSO_PromotionPoint2.data = ResultList_PromotionPoint2;

                Result.Add(CSO_PromotionPoint2);
            }

            if (ResultList_PromotionPoint3.Count > 0)
            {
                CSO_PromotionPoint3.data = ResultList_PromotionPoint3;

                Result.Add(CSO_PromotionPoint3);
            }

            if (ResultList_PromotionPoint4.Count > 0)
            {
                CSO_PromotionPoint4.data = ResultList_PromotionPoint4;

                Result.Add(CSO_PromotionPoint4);
            }

            if (ResultList_PromotionPoint5.Count > 0)
            {
                CSO_PromotionPoint5.data = ResultList_PromotionPoint5;

                Result.Add(CSO_PromotionPoint5);
            }

            if (ResultList_PromotionPoint6.Count > 0)
            {
                CSO_PromotionPoint6.data = ResultList_PromotionPoint6;

                Result.Add(CSO_PromotionPoint6);
            }

            if (ResultList_PromotionPoint7.Count > 0)
            {
                CSO_PromotionPoint7.data = ResultList_PromotionPoint7;

                Result.Add(CSO_PromotionPoint7);
            }

            if (ResultList_PromotionPoint8.Count > 0)
            {
                CSO_PromotionPoint8.data = ResultList_PromotionPoint8;

                Result.Add(CSO_PromotionPoint8);
            }
        }
    }


    /// <summary>
    /// 指定結果集合將相關資料加入至集合中
    /// </summary>
    /// <param name="ResultList">結果集合</param>
    /// <param name="ParameterValue">圖表值</param>
    /// <param name="DataResult">圖表日期</param>
    /// <param name="WorkClassItemValue">班別值</param>
    protected void AddParameterValueToResultList(List<dynamic> ResultList, decimal ParameterValue, DateTime DataResult, string WorkClassItemValue)
    {
        if (ParameterValue > -1)
        {
            DateTime JavaScriptDateTime = new DateTime(1970, 1, 1, 0, 0, 0);

            dynamic ResultValie = new System.Dynamic.ExpandoObject();

            ResultValie.y = ParameterValue;

            ResultValie.x = (DataResult.ToUniversalTime() - JavaScriptDateTime).TotalMilliseconds;

            if (WorkClassItemValue != "D")
            {
                dynamic SymbolObject = new System.Dynamic.ExpandoObject();

                SymbolObject.symbol = "url(" + ResolveClientUrl(@"~/Image/moon.png") + ")";

                SymbolObject.enabled = true;

                ResultValie.marker = SymbolObject;
            }

            ResultList.Add(ResultValie);
        }
    }

}