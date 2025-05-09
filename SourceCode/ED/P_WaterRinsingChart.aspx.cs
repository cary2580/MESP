using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class ED_P_WaterRinsingChart : System.Web.UI.Page
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

            string WaterRinsing = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_WaterRinsing");

            string DIWater = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DIWater");

            L_WaterRinsing1.Text = WaterRinsing + "1";
            L_WaterRinsing2.Text = WaterRinsing + "2";
            L_WaterRinsing3.Text = WaterRinsing + "3";
            L_WaterRinsing4.Text = WaterRinsing + "4";
            L_WaterRinsing5.Text = WaterRinsing + "5";
            L_WaterRinsing6.Text = WaterRinsing + "6";
            L_WaterRinsing7.Text = WaterRinsing + "7";
            L_WaterRinsing8.Text = WaterRinsing + "8";

            L_DIWater1.Text = DIWater + "1";
            L_DIWater2.Text = DIWater + "2";
        }
    }

    protected void LoadStandardValueToPage()
    {
        string PageFirstID = string.Empty;

        int ProcessCheckCount = 0;

        if (CB_WaterRinsing1.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "141";
        }

        if (CB_WaterRinsing2.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "143";
        }

        if (CB_WaterRinsing3.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "145";
        }

        if (CB_WaterRinsing4.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "147";
        }

        if (CB_WaterRinsing5.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "149";
        }

        if (CB_WaterRinsing6.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "1411";
        }

        if (CB_WaterRinsing7.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "1413";
        }

        if (CB_WaterRinsing8.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "1415";
        }

        if (CB_DIWater1.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "14";
        }

        if (CB_DIWater2.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "14";
        }

        /* 選取多個工序就不顯示標準值上下限 */
        if (ProcessCheckCount > 1)
            return;

        string PrametersID = "EDP" + PageFirstID;

        if (CB_DIWater1.Checked && RB_PH.Checked)
            PrametersID += "17";
        else if (CB_DIWater2.Checked && RB_PH.Checked)
            PrametersID += "20";
        else if (CB_DIWater1.Checked && RB_Conductivity.Checked)
            PrametersID += "18";
        else if (CB_DIWater2.Checked && RB_Conductivity.Checked)
            PrametersID += "21";

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

        DataTable WaterRinsing_DT = new DataTable();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPWaterRinsing"];

        string Query = @"Select *,(Select Top 1 CodeName From T_Code Where CodeID = PLID And CodeType = 'ProductionLine' And UICulture = @UICulture) As PLName ";

        DbCommandBuilder dbcb = new DbCommandBuilder();

        dbcb.CommandText = Query + " From T_EDPWaterRinsing Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

        dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

        dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

        WaterRinsing_DT = CommonDB.ExecuteSelectQuery(dbcb);

        List<Util.ChartSeriesOption> Result = new List<Util.ChartSeriesOption>();

        if (WaterRinsing_DT.Rows.Count > 0)
            SetDataToResultList(Result, WaterRinsing_DT, StartDate, EndDate);

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
    protected void SetDataToResultList(List<Util.ChartSeriesOption> Result, DataTable DT, DateTime StartDate, DateTime EndDate)
    {
        EnumerableRowCollection<DataRow> Rows = DT.AsEnumerable();

        List<ListItem> SelectProductionLineList = CBL_PLID.Items.Cast<ListItem>().Where(item => item.Selected).ToList();

        List<ListItem> SelectWorkClassList = CBL_WorkClass.Items.Cast<ListItem>().Where(item => item.Selected).ToList();

        string WaterRinsing = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_WaterRinsing");

        string PHText = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PHValue");

        string DIWaterText = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DIWater");

        string ConductivityText = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Conductivity");

        foreach (ListItem LI in SelectProductionLineList)
        {
            List<dynamic> ResultList_PH1 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH1 = new Util.ChartSeriesOption();
            CSO_PH1.name = WaterRinsing + "1 " + LI.Text + " " + PHText;

            List<dynamic> ResultList_PH2 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH2 = new Util.ChartSeriesOption();
            CSO_PH2.name = WaterRinsing + "2 " + LI.Text + " " + PHText;

            List<dynamic> ResultList_PH3 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH3 = new Util.ChartSeriesOption();
            CSO_PH3.name = WaterRinsing + "3 " + LI.Text + " " + PHText;

            List<dynamic> ResultList_PH4 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH4 = new Util.ChartSeriesOption();
            CSO_PH4.name = WaterRinsing + "4 " + LI.Text + " " + PHText;

            List<dynamic> ResultList_PH5 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH5 = new Util.ChartSeriesOption();
            CSO_PH5.name = WaterRinsing + "5 " + LI.Text + " " + PHText;

            List<dynamic> ResultList_PH6 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH6 = new Util.ChartSeriesOption();
            CSO_PH6.name = WaterRinsing + "6 " + LI.Text + " " + PHText;

            List<dynamic> ResultList_PH7 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH7 = new Util.ChartSeriesOption();
            CSO_PH7.name = WaterRinsing + "7 " + LI.Text + " " + PHText;

            List<dynamic> ResultList_PH8 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH8 = new Util.ChartSeriesOption();
            CSO_PH8.name = WaterRinsing + "8 " + LI.Text + " " + PHText;

            List<dynamic> ResultList_PH9 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH9 = new Util.ChartSeriesOption();
            CSO_PH9.name = DIWaterText + "1-" + LI.Text + " " + PHText;

            List<dynamic> ResultList_PH10 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH10 = new Util.ChartSeriesOption();
            CSO_PH10.name = DIWaterText + "2-" + LI.Text + " " + PHText;

            List<dynamic> ResultList_Conductivity1 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Conductivity1 = new Util.ChartSeriesOption();
            CSO_Conductivity1.name = DIWaterText + "1-" + LI.Text + " " + ConductivityText;

            List<dynamic> ResultList_Conductivity2 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Conductivity2 = new Util.ChartSeriesOption();
            CSO_Conductivity2.name = DIWaterText + "2-" + LI.Text + " " + ConductivityText;

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
                        if (CB_WaterRinsing1.Checked)
                        {
                            decimal PHValue1 = (decimal)ValueRow["PHValue1"];
                            MaxValueInRow = MaxValueInRow > PHValue1 ? MaxValueInRow : PHValue1;
                            MinValueInRow = MinValueInRow < PHValue1 ? MinValueInRow : PHValue1;
                            AddParameterValueToResultList(ResultList_PH1, PHValue1, DataResult, WorkClassItem.Value);
                        }

                        if (CB_WaterRinsing2.Checked)
                        {
                            decimal PHValue2 = (decimal)ValueRow["PHValue2"];
                            MaxValueInRow = MaxValueInRow > PHValue2 ? MaxValueInRow : PHValue2;
                            MinValueInRow = MinValueInRow < PHValue2 ? MinValueInRow : PHValue2;
                            AddParameterValueToResultList(ResultList_PH2, PHValue2, DataResult, WorkClassItem.Value);
                        }

                        if (CB_WaterRinsing3.Checked)
                        {
                            decimal PHValue3 = (decimal)ValueRow["PHValue3"];
                            MaxValueInRow = MaxValueInRow > PHValue3 ? MaxValueInRow : PHValue3;
                            MinValueInRow = MinValueInRow < PHValue3 ? MinValueInRow : PHValue3;
                            AddParameterValueToResultList(ResultList_PH3, PHValue3, DataResult, WorkClassItem.Value);
                        }

                        if (CB_WaterRinsing4.Checked)
                        {
                            decimal PHValue4 = (decimal)ValueRow["PHValue4"];
                            MaxValueInRow = MaxValueInRow > PHValue4 ? MaxValueInRow : PHValue4;
                            MinValueInRow = MinValueInRow < PHValue4 ? MinValueInRow : PHValue4;
                            AddParameterValueToResultList(ResultList_PH4, PHValue4, DataResult, WorkClassItem.Value);
                        }

                        if (CB_WaterRinsing5.Checked)
                        {
                            decimal PHValue5 = (decimal)ValueRow["PHValue5"];
                            MaxValueInRow = MaxValueInRow > PHValue5 ? MaxValueInRow : PHValue5;
                            MinValueInRow = MinValueInRow < PHValue5 ? MinValueInRow : PHValue5;
                            AddParameterValueToResultList(ResultList_PH5, PHValue5, DataResult, WorkClassItem.Value);
                        }

                        if (CB_WaterRinsing6.Checked)
                        {
                            decimal PHValue6 = (decimal)ValueRow["PHValue6"];
                            MaxValueInRow = MaxValueInRow > PHValue6 ? MaxValueInRow : PHValue6;
                            MinValueInRow = MinValueInRow < PHValue6 ? MinValueInRow : PHValue6;
                            AddParameterValueToResultList(ResultList_PH6, PHValue6, DataResult, WorkClassItem.Value);
                        }

                        if (CB_WaterRinsing7.Checked)
                        {
                            decimal PHValue7 = (decimal)ValueRow["PHValue7"];
                            MaxValueInRow = MaxValueInRow > PHValue7 ? MaxValueInRow : PHValue7;
                            MinValueInRow = MinValueInRow < PHValue7 ? MinValueInRow : PHValue7;
                            AddParameterValueToResultList(ResultList_PH7, PHValue7, DataResult, WorkClassItem.Value);
                        }

                        if (CB_WaterRinsing8.Checked)
                        {
                            decimal PHValue8 = (decimal)ValueRow["PHValue8"];
                            MaxValueInRow = MaxValueInRow > PHValue8 ? MaxValueInRow : PHValue8;
                            MinValueInRow = MinValueInRow < PHValue8 ? MinValueInRow : PHValue8;
                            AddParameterValueToResultList(ResultList_PH8, PHValue8, DataResult, WorkClassItem.Value);
                        }

                        if (CB_DIWater1.Checked)
                        {
                            decimal PHValue9 = (decimal)ValueRow["PHValue9"];
                            MaxValueInRow = MaxValueInRow > PHValue9 ? MaxValueInRow : PHValue9;
                            MinValueInRow = MinValueInRow < PHValue9 ? MinValueInRow : PHValue9;
                            AddParameterValueToResultList(ResultList_PH9, PHValue9, DataResult, WorkClassItem.Value);
                        }

                        if (CB_DIWater2.Checked)
                        {
                            decimal PHValue10 = (decimal)ValueRow["PHValue10"];
                            MaxValueInRow = MaxValueInRow > PHValue10 ? MaxValueInRow : PHValue10;
                            MinValueInRow = MinValueInRow < PHValue10 ? MinValueInRow : PHValue10;
                            AddParameterValueToResultList(ResultList_PH10, PHValue10, DataResult, WorkClassItem.Value);
                        }
                    }
                    else if (RB_Conductivity.Checked)
                    {
                        if (CB_DIWater1.Checked)
                        {
                            decimal ConductivityValue1 = (decimal)ValueRow["Conductivity9"];
                            MaxValueInRow = MaxValueInRow > ConductivityValue1 ? MaxValueInRow : ConductivityValue1;
                            MinValueInRow = MinValueInRow < ConductivityValue1 ? MinValueInRow : ConductivityValue1;
                            AddParameterValueToResultList(ResultList_Conductivity1, ConductivityValue1, DataResult, WorkClassItem.Value);
                        }

                        if (CB_DIWater2.Checked)
                        {
                            decimal ConductivityValue2 = (decimal)ValueRow["Conductivity10"];
                            MaxValueInRow = MaxValueInRow > ConductivityValue2 ? MaxValueInRow : ConductivityValue2;
                            MinValueInRow = MinValueInRow < ConductivityValue2 ? MinValueInRow : ConductivityValue2;
                            AddParameterValueToResultList(ResultList_Conductivity2, ConductivityValue2, DataResult, WorkClassItem.Value);
                        }
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

            if (ResultList_PH3.Count > 0)
            {
                CSO_PH3.data = ResultList_PH3;

                Result.Add(CSO_PH3);
            }

            if (ResultList_PH4.Count > 0)
            {
                CSO_PH4.data = ResultList_PH4;

                Result.Add(CSO_PH4);
            }

            if (ResultList_PH5.Count > 0)
            {
                CSO_PH5.data = ResultList_PH5;

                Result.Add(CSO_PH5);
            }

            if (ResultList_PH6.Count > 0)
            {
                CSO_PH6.data = ResultList_PH6;

                Result.Add(CSO_PH6);
            }

            if (ResultList_PH7.Count > 0)
            {
                CSO_PH7.data = ResultList_PH7;

                Result.Add(CSO_PH7);
            }

            if (ResultList_PH8.Count > 0)
            {
                CSO_PH8.data = ResultList_PH8;

                Result.Add(CSO_PH8);
            }

            if (ResultList_PH9.Count > 0)
            {
                CSO_PH9.data = ResultList_PH9;

                Result.Add(CSO_PH9);
            }

            if (ResultList_PH10.Count > 0)
            {
                CSO_PH10.data = ResultList_PH10;

                Result.Add(CSO_PH10);
            }

            if (ResultList_Conductivity1.Count > 0)
            {
                CSO_Conductivity1.data = ResultList_Conductivity1;

                Result.Add(CSO_Conductivity1);
            }

            if (ResultList_Conductivity2.Count > 0)
            {
                CSO_Conductivity2.data = ResultList_Conductivity2;

                Result.Add(CSO_Conductivity2);
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