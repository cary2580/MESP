using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class ED_P_HCLChart : System.Web.UI.Page
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

            L_HCL1.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_HCL1");

            L_HCL2.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_HCL2");

            L_Neutralizing.Text = (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_Neutralizing");
        }
    }

    protected void LoadStandardValueToPage()
    {
        string PageFirstID = string.Empty;

        int ProcessCheckCount = 0;

        if (CB_HCL1.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "4";
        }

        if (CB_HCL2.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "5";
        }

        if (CB_Neutralizing.Checked)
        {
            ProcessCheckCount++;
            PageFirstID = "6";
        }

        /* 選取多個工序就不顯示標準值上下限 */
        if (ProcessCheckCount > 1)
            return;

        string PrametersID = "EDP" + PageFirstID;

        if (RB_PH.Checked)
            PrametersID += "1";
        else if (RB_PValue.Checked || RB_HValue.Checked)
            PrametersID += "3";
        else
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

        DataTable HCL1_DT = new DataTable();
        DataTable HCL2_DT = new DataTable();
        DataTable Neutralizing_DT = new DataTable();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPHCL1"];

        string Query = @"Select *,(Select Top 1 CodeName From T_Code Where CodeID = PLID And CodeType = 'ProductionLine' And UICulture = @UICulture) As PLName ";

        if (CB_HCL1.Checked)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.CommandText = Query + " From T_EDPHCL1 Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

            HCL1_DT = CommonDB.ExecuteSelectQuery(dbcb);
        }

        if (CB_HCL2.Checked)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.CommandText = Query + " From T_EDPHCL2 Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

            HCL2_DT = CommonDB.ExecuteSelectQuery(dbcb);
        }

        if (CB_Neutralizing.Checked)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            dbcb.CommandText = Query + " From T_EDPNeutralizing Where PDate >= @StartPDate And PDate <= @EndPDate Order By PDate Asc";

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPDate"));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

            Neutralizing_DT = CommonDB.ExecuteSelectQuery(dbcb);
        }

        if (HCL1_DT.Rows.Count < 1 && HCL2_DT.Rows.Count < 1 && Neutralizing_DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"), true, true);

            return;
        }

        List<Util.ChartSeriesOption> Result = new List<Util.ChartSeriesOption>();

        if (HCL1_DT.Rows.Count > 0)
            SetDataToResultList(Result, (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_HCL1") + " ", HCL1_DT, StartDate, EndDate);
        if (HCL2_DT.Rows.Count > 0)
            SetDataToResultList(Result, (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_HCL2") + " ", HCL2_DT, StartDate, EndDate);
        if (Neutralizing_DT.Rows.Count > 0)
            SetDataToResultList(Result, (string)HttpContext.GetLocalResourceObject("~/MasterPage.master", "Str_MenuBar_Electrophoresis_Parameter_Neutralizing") + " ", Neutralizing_DT, StartDate, EndDate);

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
            Util.ChartSeriesOption CSO1 = new Util.ChartSeriesOption();
            // 給溫度2使用
            Util.ChartSeriesOption CSO2 = new Util.ChartSeriesOption();

            List<dynamic> ResultList1 = new List<dynamic>();
            //給溫度2使用
            List<dynamic> ResultList2 = new List<dynamic>();

            CSO1.name = FirstName;

            CSO2.name = FirstName;

            if (RB_PH.Checked)
                CSO1.name += LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PHValue");
            else if (RB_PValue.Checked)
            {
                CSO1.name += LI.Text + " " + (string)GetLocalResourceObject("Str_ED_P_PValue1");
                CSO2.name += LI.Text + " " + (string)GetLocalResourceObject("Str_ED_P_PValue2");
            }
            else if (RB_HValue.Checked)
                CSO1.name += LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_HValue");
            else
            {
                CSO1.name += LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Temperature") + "1";
                CSO2.name += LI.Text + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_Temperature") + "2";
            }

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
                        decimal ParameterValue1 = (decimal)ValueRow["PHValue"];
                        MaxValueInRow = MaxValueInRow > ParameterValue1 ? MaxValueInRow : ParameterValue1;
                        MinValueInRow = MinValueInRow < ParameterValue1 ? MinValueInRow : ParameterValue1;
                        AddParameterValueToResultList(ResultList1, ParameterValue1, DataResult, WorkClassItem.Value);
                    }
                    else if (RB_PValue.Checked && ValueRow.Table.Columns.Contains("PValue1") && ValueRow.Table.Columns.Contains("PValue2"))
                    {
                        decimal ParameterValue1 = (decimal)ValueRow["PValue1"];
                        MaxValueInRow = MaxValueInRow > ParameterValue1 ? MaxValueInRow : ParameterValue1;
                        MinValueInRow = MinValueInRow < ParameterValue1 ? MinValueInRow : ParameterValue1;
                        AddParameterValueToResultList(ResultList1, ParameterValue1, DataResult, WorkClassItem.Value);

                        decimal ParameterValue2 = (decimal)ValueRow["PValue2"];
                        MaxValueInRow = MaxValueInRow > ParameterValue2 ? MaxValueInRow : ParameterValue2;
                        MinValueInRow = MinValueInRow < ParameterValue2 ? MinValueInRow : ParameterValue2;
                        AddParameterValueToResultList(ResultList2, ParameterValue2, DataResult, WorkClassItem.Value);
                    }
                    else if (RB_HValue.Checked && ValueRow.Table.Columns.Contains("HValue"))
                    {
                        decimal ParameterValue1 = (decimal)ValueRow["HValue"];
                        MaxValueInRow = MaxValueInRow > ParameterValue1 ? MaxValueInRow : ParameterValue1;
                        MinValueInRow = MinValueInRow < ParameterValue1 ? MinValueInRow : ParameterValue1;
                        AddParameterValueToResultList(ResultList1, ParameterValue1, DataResult, WorkClassItem.Value);
                    }
                    else if (RB_Temperature.Checked && ValueRow.Table.Columns.Contains("Temperature1") && ValueRow.Table.Columns.Contains("Temperature2"))
                    {
                        decimal ParameterValue1 = (decimal)ValueRow["Temperature1"];
                        MaxValueInRow = MaxValueInRow > ParameterValue1 ? MaxValueInRow : ParameterValue1;
                        MinValueInRow = MinValueInRow < ParameterValue1 ? MinValueInRow : ParameterValue1;
                        AddParameterValueToResultList(ResultList1, ParameterValue1, DataResult, WorkClassItem.Value);

                        decimal ParameterValue2 = (decimal)ValueRow["Temperature2"];
                        MaxValueInRow = MaxValueInRow > ParameterValue2 ? MaxValueInRow : ParameterValue2;
                        MinValueInRow = MinValueInRow < ParameterValue2 ? MinValueInRow : ParameterValue2;
                        AddParameterValueToResultList(ResultList2, ParameterValue2, DataResult, WorkClassItem.Value);
                    }
                }
            }

            if (ResultList1.Count > 0)
            {
                CSO1.data = ResultList1;

                Result.Add(CSO1);
            }

            if ((RB_PValue.Checked && ResultList2.Count > 0) || (RB_Temperature.Checked && ResultList2.Count > 0))
            {
                CSO2.data = ResultList2;

                Result.Add(CSO2);
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