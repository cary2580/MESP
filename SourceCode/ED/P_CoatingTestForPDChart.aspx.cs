using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class ED_P_CoatingTestForPDChart : System.Web.UI.Page
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

            L_FilmThickness.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_CoatingTestForPD");
        }
    }

    protected void LoadStandardValueToPage()
    {
        string PageFirstID = string.Empty;

        int ProcessCheckCount = 0;

        if (CB_FilmThickness.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "15";
        }

        /* 選取多個工序就不顯示標準值上下限 */
        if (ProcessCheckCount > 1)
            return;

        string PrametersID = "EDP" + PageFirstID;

        if (CB_FilmThickness.Checked)
            PrametersID += "1";


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
            List<dynamic> ResultList_FilmThickness = new List<dynamic>();
            Util.ChartSeriesOption CSO_FilmThickness = new Util.ChartSeriesOption();
            CSO_FilmThickness.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_FilmThicknessValue");

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

                    if (RB_FilmThickness.Checked)
                    {
                        decimal FilmThickness1 = (decimal)ValueRow["FilmThickness"];
                        MaxValueInRow = MaxValueInRow > FilmThickness1 ? MaxValueInRow : FilmThickness1;
                        MinValueInRow = MinValueInRow < FilmThickness1 ? MinValueInRow : FilmThickness1;
                        AddParameterValueToResultList(ResultList_FilmThickness, FilmThickness1, DataResult, WorkClassItem.Value);

                    }
                }
            }

            if (ResultList_FilmThickness.Count > 0)
            {
                CSO_FilmThickness.data = ResultList_FilmThickness;

                Result.Add(CSO_FilmThickness);
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
            Util.RegisterStartupScriptJqueryAlert(this,
            (string)GetGlobalResourceObject("GlobalRes", "Str_DateSelectErrorAlertMessage"), true, true);

            return;
        }

        DataTable CoatingTestForPD_DT = new DataTable();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPCoatingTestForPD"];

        string Query = @"Select *,(Select Top 1 CodeName From T_Code Where CodeID = PLID And CodeType = 'ProductionLine' And UICulture = @UICulture) As PLName ";

        if (CB_FilmThickness.Checked)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.CommandText = Query + " From T_EDPCoatingTestForPD Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

            CoatingTestForPD_DT = CommonDB.ExecuteSelectQuery(dbcb);
        }


        List<Util.ChartSeriesOption> Result = new List<Util.ChartSeriesOption>();

        if (CoatingTestForPD_DT.Rows.Count > 0)
            SetDataToResultList(Result, (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_CoatingTestForPD") + " ", CoatingTestForPD_DT, StartDate, EndDate);

        int NoDataCount = Result.Where(Item => Item.data.Count < 1).Count();

        if (NoDataCount == Result.Count)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"), true, true);

            return;
        }

        Page.ClientScript.RegisterClientScriptBlock(GetType(), "ChartValue", "<script>var ChartValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(Result) + "</script>");

        LoadStandardValueToPage();

    }
}