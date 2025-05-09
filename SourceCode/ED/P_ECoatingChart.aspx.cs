using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;


public partial class ED_P_ECoatingChart : System.Web.UI.Page
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

            L_ECoating.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_ECoating");

            L_UF1.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_UF1");

            L_UF2.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_UF2");

            L_Anolyte.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_Anolyte");

            L_RecycleTank.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_RecycleTank");
        }
    }

    protected void LoadStandardValueToPage()
    {
        string PageFirstID = string.Empty;

        int ProcessCheckCount = 0;

        if (CB_ECoating.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "9";
        }

        if (CB_UF1.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "10";
        }

        if (CB_UF2.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "11";
        }

        if (CB_Anolyte.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "12";
        }

        if (CB_RecycleTank.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "13";
        }

        /* 選取多個工序就不顯示標準值上下限 */
        if (ProcessCheckCount > 1)
            return;

        string PrametersID = "EDP" + PageFirstID;

        if (RB_PH.Checked)
            PrametersID += "1";
        else if (RB_Temperature.Checked)
            PrametersID += "7";
        else if (RB_Conductivity.Checked)
        {
            if (CB_ECoating.Checked)
                PrametersID += "6";
            else if (CB_UF1.Checked || CB_UF2.Checked)
                PrametersID += "3";
            else if (CB_Anolyte.Checked || CB_RecycleTank.Checked)
                PrametersID += "2";
        }
        else if (RB_Solid.Checked)
        {
            if (CB_ECoating.Checked)
                PrametersID += "3";
            else if (CB_UF1.Checked || CB_UF2.Checked)
                PrametersID += "4";
            else if (CB_RecycleTank.Checked)
                PrametersID += "3";
        }
        else if (RB_PH.Checked)
            PrametersID += "4";
        else if (RB_SolventHold.Checked)
            PrametersID += "5";
        else if (RB_PB.Checked)
            PrametersID += "4";

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

        DataTable ECoating_DT = new DataTable();
        DataTable UF1_DT = new DataTable();
        DataTable UF2_DT = new DataTable();
        DataTable Anolyte_DT = new DataTable();
        DataTable RecycleTank_DT = new DataTable();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPHCL1"];

        string Query = @"Select *,(Select Top 1 CodeName From T_Code Where CodeID = PLID And CodeType = 'ProductionLine' And UICulture = @UICulture) As PLName ";

        if (CB_ECoating.Checked)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.CommandText = Query + " From T_EDPECoating Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

            ECoating_DT = CommonDB.ExecuteSelectQuery(dbcb);
        }

        if (CB_UF1.Checked)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.CommandText = Query + " From T_EDPUF1 Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

            UF1_DT = CommonDB.ExecuteSelectQuery(dbcb);
        }

        if (CB_UF2.Checked)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.CommandText = Query + " From T_EDPUF2 Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

            UF2_DT = CommonDB.ExecuteSelectQuery(dbcb);
        }

        if (CB_Anolyte.Checked)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.CommandText = Query + " From T_EDPAnolyte Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

            Anolyte_DT = CommonDB.ExecuteSelectQuery(dbcb);
        }

        if (CB_RecycleTank.Checked)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.CommandText = Query + " From T_EDPRecycleTank Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

            RecycleTank_DT = CommonDB.ExecuteSelectQuery(dbcb);
        }

        if (ECoating_DT.Rows.Count < 1 && UF1_DT.Rows.Count < 1 && UF2_DT.Rows.Count < 1 && Anolyte_DT.Rows.Count < 1 && RecycleTank_DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"), true, true);

            return;
        }

        List<Util.ChartSeriesOption> Result = new List<Util.ChartSeriesOption>();

        if (ECoating_DT.Rows.Count > 0)
            SetDataToResultList(Result, (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_ECoating") + " ", ECoating_DT, StartDate, EndDate);
        if (UF1_DT.Rows.Count > 0)
            SetDataToResultList(Result, (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_UF1") + " ", UF1_DT, StartDate, EndDate);
        if (UF2_DT.Rows.Count > 0)
            SetDataToResultList(Result, (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_UF2") + " ", UF2_DT, StartDate, EndDate);
        if (Anolyte_DT.Rows.Count > 0)
            SetDataToResultList(Result, (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_Anolyte") + " ", Anolyte_DT, StartDate, EndDate);
        if (RecycleTank_DT.Rows.Count > 0)
            SetDataToResultList(Result, (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_RecycleTank") + " ", RecycleTank_DT, StartDate, EndDate);

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

            List<dynamic> ResultList_PH3 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH3 = new Util.ChartSeriesOption();
            CSO_PH3.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PHValue") + "3";

            List<dynamic> ResultList_PH4 = new List<dynamic>();
            Util.ChartSeriesOption CSO_PH4 = new Util.ChartSeriesOption();
            CSO_PH4.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PHValue") + "4";

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

            List<dynamic> ResultList_Conductivity1 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Conductivity1 = new Util.ChartSeriesOption();
            CSO_Conductivity1.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Conductivity") + "1";

            List<dynamic> ResultList_Conductivity2 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Conductivity2 = new Util.ChartSeriesOption();
            CSO_Conductivity2.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Conductivity") + "2";

            List<dynamic> ResultList_Conductivity3 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Conductivity3 = new Util.ChartSeriesOption();
            CSO_Conductivity3.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Conductivity") + "3";

            List<dynamic> ResultList_Conductivity4 = new List<dynamic>();
            Util.ChartSeriesOption CSO_Conductivity4 = new Util.ChartSeriesOption();
            CSO_Conductivity4.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Conductivity") + "4";

            List<dynamic> ResultList_Solid = new List<dynamic>();
            Util.ChartSeriesOption CSO_Solid = new Util.ChartSeriesOption();
            CSO_Solid.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Solid");

            List<dynamic> ResultList_PB = new List<dynamic>();
            Util.ChartSeriesOption CSO_PB = new Util.ChartSeriesOption();
            CSO_PB.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PB");

            List<dynamic> ResultList_SolventHold = new List<dynamic>();
            Util.ChartSeriesOption CSO_SolventHold = new Util.ChartSeriesOption();
            CSO_SolventHold.name = FirstName + " " + LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_SolventHold");

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

                        if (ValueRow.Table.Columns.Contains("PHValue3"))
                        {
                            decimal PHValue3 = (decimal)ValueRow["PHValue3"];
                            MaxValueInRow = MaxValueInRow > PHValue3 ? MaxValueInRow : PHValue3;
                            MinValueInRow = MinValueInRow < PHValue3 ? MinValueInRow : PHValue3;
                            AddParameterValueToResultList(ResultList_PH3, PHValue3, DataResult, WorkClassItem.Value);
                        }

                        if (ValueRow.Table.Columns.Contains("PHValue4"))
                        {
                            decimal PHValue4 = (decimal)ValueRow["PHValue4"];
                            MaxValueInRow = MaxValueInRow > PHValue4 ? MaxValueInRow : PHValue4;
                            MinValueInRow = MinValueInRow < PHValue4 ? MinValueInRow : PHValue4;
                            AddParameterValueToResultList(ResultList_PH4, PHValue4, DataResult, WorkClassItem.Value);
                        }
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
                    else if (RB_Conductivity.Checked && ValueRow.Table.Columns.Contains("Conductivity1") && ValueRow.Table.Columns.Contains("Conductivity2"))
                    {
                        decimal ConductivityValue1 = (decimal)ValueRow["Conductivity1"];
                        MaxValueInRow = MaxValueInRow > ConductivityValue1 ? MaxValueInRow : ConductivityValue1;
                        MinValueInRow = MinValueInRow < ConductivityValue1 ? MinValueInRow : ConductivityValue1;
                        AddParameterValueToResultList(ResultList_Conductivity1, ConductivityValue1, DataResult, WorkClassItem.Value);

                        decimal ConductivityValue2 = (decimal)ValueRow["Conductivity2"];
                        MaxValueInRow = MaxValueInRow > ConductivityValue2 ? MaxValueInRow : ConductivityValue2;
                        MinValueInRow = MinValueInRow < ConductivityValue2 ? MinValueInRow : ConductivityValue2;
                        AddParameterValueToResultList(ResultList_Conductivity2, ConductivityValue2, DataResult, WorkClassItem.Value);

                        if (ValueRow.Table.Columns.Contains("Conductivity3"))
                        {
                            decimal ConductivityValue3 = (decimal)ValueRow["Conductivity3"];
                            MaxValueInRow = MaxValueInRow > ConductivityValue3 ? MaxValueInRow : ConductivityValue3;
                            MinValueInRow = MinValueInRow < ConductivityValue3 ? MinValueInRow : ConductivityValue3;
                            AddParameterValueToResultList(ResultList_Conductivity3, ConductivityValue3, DataResult, WorkClassItem.Value);
                        }

                        if (ValueRow.Table.Columns.Contains("Conductivity4"))
                        {
                            decimal ConductivityValue4 = (decimal)ValueRow["Conductivity4"];
                            MaxValueInRow = MaxValueInRow > ConductivityValue4 ? MaxValueInRow : ConductivityValue4;
                            MinValueInRow = MinValueInRow < ConductivityValue4 ? MinValueInRow : ConductivityValue4;
                            AddParameterValueToResultList(ResultList_Conductivity4, ConductivityValue4, DataResult, WorkClassItem.Value);
                        }
                    }
                    else if (RB_Solid.Checked && ValueRow.Table.Columns.Contains("Solid"))
                    {
                        decimal SolidValue = (decimal)ValueRow["Solid"];
                        MaxValueInRow = MaxValueInRow > SolidValue ? MaxValueInRow : SolidValue;
                        MinValueInRow = MinValueInRow < SolidValue ? MinValueInRow : SolidValue;
                        AddParameterValueToResultList(ResultList_Solid, SolidValue, DataResult, WorkClassItem.Value);
                    }
                    else if (RB_PB.Checked && ValueRow.Table.Columns.Contains("PB"))
                    {
                        decimal PBValue = (decimal)ValueRow["PB"];
                        MaxValueInRow = MaxValueInRow > PBValue ? MaxValueInRow : PBValue;
                        MinValueInRow = MinValueInRow < PBValue ? MinValueInRow : PBValue;
                        AddParameterValueToResultList(ResultList_PB, PBValue, DataResult, WorkClassItem.Value);
                    }
                    else if (RB_SolventHold.Checked && ValueRow.Table.Columns.Contains("SolventHold"))
                    {
                        decimal SolventHoldValue = (decimal)ValueRow["SolventHold"];
                        MaxValueInRow = MaxValueInRow > SolventHoldValue ? MaxValueInRow : SolventHoldValue;
                        MinValueInRow = MinValueInRow < SolventHoldValue ? MinValueInRow : SolventHoldValue;
                        AddParameterValueToResultList(ResultList_SolventHold, SolventHoldValue, DataResult, WorkClassItem.Value);
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

            if (ResultList_Conductivity3.Count > 0)
            {
                CSO_Conductivity3.data = ResultList_Conductivity3;

                Result.Add(CSO_Conductivity3);
            }

            if (ResultList_Conductivity4.Count > 0)
            {
                CSO_Conductivity4.data = ResultList_Conductivity4;

                Result.Add(CSO_Conductivity4);
            }

            if (ResultList_Solid.Count > 0)
            {
                CSO_Solid.data = ResultList_Solid;

                Result.Add(CSO_Solid);
            }

            if (ResultList_PB.Count > 0)
            {
                CSO_PB.data = ResultList_PB;

                Result.Add(CSO_PB);
            }

            if (ResultList_SolventHold.Count > 0)
            {
                CSO_SolventHold.data = ResultList_SolventHold;

                Result.Add(CSO_SolventHold);
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