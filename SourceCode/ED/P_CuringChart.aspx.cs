using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;


public partial class ED_P_CuringChart : System.Web.UI.Page
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

            L_Zone1Fan1.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_Zone1Fan1");

            L_Zone2Fan2.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_Zone2Fan2");

            L_Combustor.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_Combustor");
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

        DataTable EDCuring_DT = new DataTable();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDCuring"];

        string Query = @"Select *,(Select Top 1 CodeName From T_Code Where CodeID = PLID And CodeType = 'ProductionLine' And UICulture = @UICulture) As PLName 
                         From T_EDCuring Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

        DbCommandBuilder dbcb = new DbCommandBuilder();

        dbcb.CommandText = Query;

        dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

        dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

        EDCuring_DT = CommonDB.ExecuteSelectQuery(dbcb);

        List<Util.ChartSeriesOption> Result = new List<Util.ChartSeriesOption>();

        if (EDCuring_DT.Rows.Count > 0)
            SetDataToResultList(Result, EDCuring_DT, StartDate, EndDate);

        int NoDataCount = Result.Where(Item => Item.data.Count < 1).Count();

        if (NoDataCount == Result.Count)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"), true, true);

            return;
        }

        Page.ClientScript.RegisterClientScriptBlock(GetType(), "ChartValue", "<script>var ChartValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(Result) + "</script>");

        LoadStandardValueToPage();

    }

    protected void LoadStandardValueToPage()
    {
        string PageFirstID = "16";

        int ProcessCheckCount = 0;

        if (CB_Zone1Fan1.Checked)
            ProcessCheckCount++;

        if (CB_Zone2Fan2.Checked)
            ProcessCheckCount++;

        if (CB_Combustor.Checked)
            ProcessCheckCount++;

        /* 選取多個工序就不顯示標準值上下限 */
        if (ProcessCheckCount > 1)
            return;

        string PrametersID = "EDP" + PageFirstID;

        if (CB_Zone1Fan1.Checked)
            PrametersID += "1";
        else if (CB_Zone2Fan2.Checked)
            PrametersID += "2";
        else if (CB_Combustor.Checked)
            PrametersID += "3";

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
    protected void SetDataToResultList(List<Util.ChartSeriesOption> Result, DataTable DT, DateTime StartDate, DateTime EndDate)
    {
        EnumerableRowCollection<DataRow> Rows = DT.AsEnumerable();

        List<ListItem> SelectProductionLineList = CBL_PLID.Items.Cast<ListItem>().Where(item => item.Selected).ToList();

        List<ListItem> SelectWorkClassList = CBL_WorkClass.Items.Cast<ListItem>().Where(item => item.Selected).ToList();

        string Zone1Fan1Temperature1 = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Zone1Fan1Temperature1");

        string Zone1Fan1Temperature2 = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Zone1Fan1Temperature2");

        string Zone2Fan2Temperature1 = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Zone2Fan2Temperature1");

        string Zone2Fan2Temperature2 = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Zone2Fan2Temperature2");

        string CombustorTemperature1 = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_CombustorTemperature1");

        string CombustorTemperature2 = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_CombustorTemperature2");

        foreach (ListItem LI in SelectProductionLineList)
        {
            List<dynamic> ResultList_Zone1Fan1Temperature1 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Zone1Fan1Temperature1 = new Util.ChartSeriesOption();
            CSO_Zone1Fan1Temperature1.name = Zone1Fan1Temperature1 + " " + LI.Text;

            List<dynamic> ResultList_Zone1Fan1Temperature2 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Zone1Fan1Temperature2 = new Util.ChartSeriesOption();
            CSO_Zone1Fan1Temperature2.name = Zone1Fan1Temperature2 + " " + LI.Text;

            List<dynamic> ResultList_Zone2Fan2Temperature1 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Zone2Fan2Temperature1 = new Util.ChartSeriesOption();
            CSO_Zone2Fan2Temperature1.name = Zone2Fan2Temperature1 + " " + LI.Text;

            List<dynamic> ResultList_Zone2Fan2Temperature2 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Zone2Fan2Temperature2 = new Util.ChartSeriesOption();
            CSO_Zone2Fan2Temperature2.name = Zone2Fan2Temperature2 + " " + LI.Text;

            List<dynamic> ResultList_CombustorTemperature1 = new List<dynamic>();
            Util.ChartSeriesOption CSO_CombustorTemperature1 = new Util.ChartSeriesOption();
            CSO_CombustorTemperature1.name = CombustorTemperature1 + " " + LI.Text;

            List<dynamic> ResultList_CombustorTemperature2 = new List<dynamic>();
            Util.ChartSeriesOption CSO_CombustorTemperature2 = new Util.ChartSeriesOption();
            CSO_CombustorTemperature2.name = CombustorTemperature2 + " " + LI.Text;

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

                    if (RB_Temperature.Checked)
                    {
                        if (CB_Zone1Fan1.Checked)
                        {
                            int Zone1Fan1Temperature1Value = (int)ValueRow["Zone1Fan1Temperature1"];
                            MaxValueInRow = MaxValueInRow > Zone1Fan1Temperature1Value ? MaxValueInRow : Zone1Fan1Temperature1Value;
                            MinValueInRow = MinValueInRow < Zone1Fan1Temperature1Value ? MinValueInRow : Zone1Fan1Temperature1Value;
                            AddParameterValueToResultList(ResultList_Zone1Fan1Temperature1, Zone1Fan1Temperature1Value, DataResult, WorkClassItem.Value);

                            int Zone1Fan1Temperature2Value = (int)ValueRow["Zone1Fan1Temperature2"];
                            MaxValueInRow = MaxValueInRow > Zone1Fan1Temperature2Value ? MaxValueInRow : Zone1Fan1Temperature2Value;
                            MinValueInRow = MinValueInRow < Zone1Fan1Temperature2Value ? MinValueInRow : Zone1Fan1Temperature2Value;
                            AddParameterValueToResultList(ResultList_Zone1Fan1Temperature2, Zone1Fan1Temperature2Value, DataResult, WorkClassItem.Value);

                        }
                        if (CB_Zone2Fan2.Checked)
                        {
                            int Zone2Fan2Temperature1Value = (int)ValueRow["Zone2Fan2Temperature1"];
                            MaxValueInRow = MaxValueInRow > Zone2Fan2Temperature1Value ? MaxValueInRow : Zone2Fan2Temperature1Value;
                            MinValueInRow = MinValueInRow < Zone2Fan2Temperature1Value ? MinValueInRow : Zone2Fan2Temperature1Value;
                            AddParameterValueToResultList(ResultList_Zone2Fan2Temperature1, Zone2Fan2Temperature1Value, DataResult, WorkClassItem.Value);

                            int Zone2Fan2Temperature2Value = (int)ValueRow["Zone2Fan2Temperature2"];
                            MaxValueInRow = MaxValueInRow > Zone2Fan2Temperature2Value ? MaxValueInRow : Zone2Fan2Temperature2Value;
                            MinValueInRow = MinValueInRow < Zone2Fan2Temperature2Value ? MinValueInRow : Zone2Fan2Temperature2Value;
                            AddParameterValueToResultList(ResultList_Zone2Fan2Temperature2, Zone2Fan2Temperature2Value, DataResult, WorkClassItem.Value);
                        }
                        if (CB_Combustor.Checked)
                        {
                            int CombustorTemperature1Value = (int)ValueRow["CombustorTemperature1"];
                            MaxValueInRow = MaxValueInRow > CombustorTemperature1Value ? MaxValueInRow : CombustorTemperature1Value;
                            MinValueInRow = MinValueInRow < CombustorTemperature1Value ? MinValueInRow : CombustorTemperature1Value;
                            AddParameterValueToResultList(ResultList_CombustorTemperature1, CombustorTemperature1Value, DataResult, WorkClassItem.Value);

                            int CombustorTemperature2Value = (int)ValueRow["CombustorTemperature2"];
                            MaxValueInRow = MaxValueInRow > CombustorTemperature2Value ? MaxValueInRow : CombustorTemperature2Value;
                            MinValueInRow = MinValueInRow < CombustorTemperature2Value ? MinValueInRow : CombustorTemperature2Value;
                            AddParameterValueToResultList(ResultList_CombustorTemperature2, CombustorTemperature2Value, DataResult, WorkClassItem.Value);
                        }
                    }
                }
            }

            if (ResultList_Zone1Fan1Temperature1.Count > 0)
            {
                CSO_Zone1Fan1Temperature1.data = ResultList_Zone1Fan1Temperature1;

                Result.Add(CSO_Zone1Fan1Temperature1);
            }

            if (ResultList_Zone1Fan1Temperature2.Count > 0)
            {
                CSO_Zone1Fan1Temperature2.data = ResultList_Zone1Fan1Temperature2;

                Result.Add(CSO_Zone1Fan1Temperature2);
            }

            if (ResultList_Zone2Fan2Temperature1.Count > 0)
            {
                CSO_Zone2Fan2Temperature1.data = ResultList_Zone2Fan2Temperature1;

                Result.Add(CSO_Zone2Fan2Temperature1);
            }

            if (ResultList_Zone2Fan2Temperature2.Count > 0)
            {
                CSO_Zone2Fan2Temperature2.data = ResultList_Zone2Fan2Temperature2;

                Result.Add(CSO_Zone2Fan2Temperature2);
            }

            if (ResultList_CombustorTemperature1.Count > 0)
            {
                CSO_CombustorTemperature1.data = ResultList_CombustorTemperature1;

                Result.Add(CSO_CombustorTemperature1);
            }

            if (ResultList_CombustorTemperature2.Count > 0)
            {
                CSO_CombustorTemperature2.data = ResultList_CombustorTemperature2;

                Result.Add(CSO_CombustorTemperature2);
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