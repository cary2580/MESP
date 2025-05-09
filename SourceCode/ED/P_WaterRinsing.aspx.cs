using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;

public partial class ED_P_WaterRinsing : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["PDate"] != null && !string.IsNullOrEmpty(Request["PDate"].ToString()))
                TB_PDate.Text = Request["PDate"].ToString().ToStringFromBase64();
            else if (Request["PID"] != null && !string.IsNullOrEmpty(Request["PID"].ToString()))
                HF_PID.Value = Request["PID"].ToString();
            else
            {
                Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_EmptyPDateOrPIDAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }

            LoadPrametersRemark();

            LoadDDLData();

            LoadData();
        }

        BT_Delete.Visible = !(string.IsNullOrEmpty(HF_PID.Value));
    }

    protected void LoadDDLData()
    {
        Util.ED.LaodWorkClass(DDL_WorkClass);

        Util.ED.LoadProductionLine(DDL_PLID);
    }

    protected void LoadPrametersRemark()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select * From T_EDPStandardValue Where PrametersID in (Select item From Base_Org.dbo.Split(@Prameters,'|'))");

        dbcb.appendParameter(Util.GetDataAccessAttribute("Prameters", "nvarchar", 10000, "EDP141|EDP142|EDP143|EDP144|EDP145|EDP146|EDP147|EDP148|EDP149|EDP1410|EDP1411|EDP1412|EDP1413|EDP1414|EDP1415|EDP1416|EDP1417|EDP1418|EDP1419|EDP1420|EDP1421|EDP1422"));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DataRow EDP141Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP141").FirstOrDefault();
        DataRow EDP142Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP142").FirstOrDefault();
        DataRow EDP143Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP143").FirstOrDefault();
        DataRow EDP144Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP144").FirstOrDefault();
        DataRow EDP145Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP145").FirstOrDefault();
        DataRow EDP146Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP146").FirstOrDefault();
        DataRow EDP147Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP147").FirstOrDefault();
        DataRow EDP148Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP148").FirstOrDefault();
        DataRow EDP149Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP149").FirstOrDefault();
        DataRow EDP1410Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1410").FirstOrDefault();
        DataRow EDP1411Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1411").FirstOrDefault();
        DataRow EDP1412Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1412").FirstOrDefault();
        DataRow EDP1413Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1413").FirstOrDefault();
        DataRow EDP1414Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1414").FirstOrDefault();
        DataRow EDP1415Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1415").FirstOrDefault();
        DataRow EDP1416Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1416").FirstOrDefault();
        DataRow EDP1417Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1417").FirstOrDefault();
        DataRow EDP1418Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1418").FirstOrDefault();
        DataRow EDP1419Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1419").FirstOrDefault();
        DataRow EDP1420Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1420").FirstOrDefault();
        DataRow EDP1421Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1421").FirstOrDefault();
        DataRow EDP1422Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP1422").FirstOrDefault();

        string WaterRinsing = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_WaterRinsing");

        string DIWater = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DIWater");

        L_PHValue1.Text = WaterRinsing + "1-" + L_PHValue1.Text;
        L_ProcessSecondValue1.Text = WaterRinsing + "1-" + L_ProcessSecondValue1.Text;
        L_PHValue2.Text = WaterRinsing + "2-" + L_PHValue2.Text;
        L_ProcessSecondValue2.Text = WaterRinsing + "2-" + L_ProcessSecondValue2.Text;

        L_PHValue3.Text = WaterRinsing + "3-" + L_PHValue3.Text;
        L_ProcessSecondValue3.Text = WaterRinsing + "3-" + L_ProcessSecondValue3.Text;
        L_PHValue4.Text = WaterRinsing + "4-" + L_PHValue4.Text;
        L_ProcessSecondValue4.Text = WaterRinsing + "4-" + L_ProcessSecondValue4.Text;

        L_PHValue5.Text = WaterRinsing + "5-" + L_PHValue5.Text;
        L_ProcessSecondValue5.Text = WaterRinsing + "5-" + L_ProcessSecondValue5.Text;
        L_PHValue6.Text = WaterRinsing + "6-" + L_PHValue6.Text;
        L_ProcessSecondValue6.Text = WaterRinsing + "6-" + L_ProcessSecondValue6.Text;

        L_PHValue7.Text = WaterRinsing + "7-" + L_PHValue7.Text;
        L_ProcessSecondValue7.Text = WaterRinsing + "7-" + L_ProcessSecondValue7.Text;
        L_PHValue8.Text = WaterRinsing + "8-" + L_PHValue8.Text;
        L_ProcessSecondValue8.Text = WaterRinsing + "8-" + L_ProcessSecondValue8.Text;

        L_PHValue9.Text = DIWater + "1-" + L_PHValue9.Text;
        L_ProcessSecondValue9.Text = DIWater + "1-" + L_ProcessSecondValue9.Text;
        L_TB_ConductivityValue9.Text = DIWater + "1-" + L_TB_ConductivityValue9.Text;

        L_PHValue10.Text = DIWater + "2-" + L_PHValue10.Text;
        L_ProcessSecondValue10.Text = DIWater + "2-" + L_ProcessSecondValue10.Text;
        L_TB_ConductivityValue10.Text = DIWater + "2-" + L_TB_ConductivityValue10.Text;

        string PHRemark = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_PHRemark");

        string ProcessSecondRemark = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_ProcessSecondRemark");

        if (EDP141Row != null)
        {
            string MaxValue = ((decimal)EDP141Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP141Row["MinValue"]).ToString("0.##");

            TB_PHValue1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue1.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue1.Attributes.Add("title", string.Format(PHRemark, MaxValue, MinValue));
        }

        if (EDP142Row != null)
        {
            string MaxValue = ((decimal)EDP142Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP142Row["MinValue"]).ToString("0.##");

            TB_ProcessSecondValue1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecondValue1.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecondValue1.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        if (EDP143Row != null)
        {
            string MaxValue = ((decimal)EDP143Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP143Row["MinValue"]).ToString("0.##");

            TB_PHValue2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue2.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue2.Attributes.Add("title", string.Format(PHRemark, MaxValue, MinValue));
        }

        if (EDP144Row != null)
        {
            string MaxValue = ((decimal)EDP144Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP144Row["MinValue"]).ToString("0.##");

            TB_ProcessSecondValue2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecondValue2.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecondValue2.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        if (EDP145Row != null)
        {
            string MaxValue = ((decimal)EDP145Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP145Row["MinValue"]).ToString("0.##");

            TB_PHValue3.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue3.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue3.Attributes.Add("title", string.Format(PHRemark, MaxValue, MinValue));
        }

        if (EDP146Row != null)
        {
            string MaxValue = ((decimal)EDP146Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP146Row["MinValue"]).ToString("0.##");

            TB_ProcessSecondValue3.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecondValue3.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecondValue3.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        if (EDP147Row != null)
        {
            string MaxValue = ((decimal)EDP147Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP147Row["MinValue"]).ToString("0.##");

            TB_PHValue4.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue4.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue4.Attributes.Add("title", string.Format(PHRemark, MaxValue, MinValue));
        }

        if (EDP148Row != null)
        {
            string MaxValue = ((decimal)EDP148Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP148Row["MinValue"]).ToString("0.##");

            TB_ProcessSecondValue4.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecondValue4.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecondValue4.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        if (EDP149Row != null)
        {
            string MaxValue = ((decimal)EDP149Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP149Row["MinValue"]).ToString("0.##");

            TB_PHValue5.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue5.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue5.Attributes.Add("title", string.Format(PHRemark, MaxValue, MinValue));
        }

        if (EDP1410Row != null)
        {
            string MaxValue = ((decimal)EDP1410Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1410Row["MinValue"]).ToString("0.##");

            TB_ProcessSecondValue5.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecondValue5.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecondValue5.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        if (EDP1411Row != null)
        {
            string MaxValue = ((decimal)EDP1411Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1411Row["MinValue"]).ToString("0.##");

            TB_PHValue6.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue6.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue6.Attributes.Add("title", string.Format(PHRemark, MaxValue, MinValue));
        }

        if (EDP1412Row != null)
        {
            string MaxValue = ((decimal)EDP1412Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1412Row["MinValue"]).ToString("0.##");

            TB_ProcessSecondValue6.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecondValue6.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecondValue6.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        if (EDP1413Row != null)
        {
            string MaxValue = ((decimal)EDP1413Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1413Row["MinValue"]).ToString("0.##");

            TB_PHValue7.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue7.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue7.Attributes.Add("title", string.Format(PHRemark, MaxValue, MinValue));
        }

        if (EDP1414Row != null)
        {
            string MaxValue = ((decimal)EDP1414Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1414Row["MinValue"]).ToString("0.##");

            TB_ProcessSecondValue7.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecondValue7.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecondValue7.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        if (EDP1415Row != null)
        {
            string MaxValue = ((decimal)EDP1415Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1415Row["MinValue"]).ToString("0.##");

            TB_PHValue8.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue8.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue8.Attributes.Add("title", string.Format(PHRemark, MaxValue, MinValue));
        }

        if (EDP1416Row != null)
        {
            string MaxValue = ((decimal)EDP1416Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1416Row["MinValue"]).ToString("0.##");

            TB_ProcessSecondValue8.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecondValue8.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecondValue8.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        if (EDP1417Row != null)
        {
            string MaxValue = ((decimal)EDP1417Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1417Row["MinValue"]).ToString("0.##");

            TB_PHValue9.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue9.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue9.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHRemark"), MaxValue, MinValue));
        }

        if (EDP1418Row != null)
        {
            string MaxValue = ((decimal)EDP1418Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1418Row["MinValue"]).ToString("0.##");

            TB_ConductivityValue9.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ConductivityValue9.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ConductivityValue9.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Conductivity_Remark"), MaxValue, MinValue));
        }

        if (EDP1419Row != null)
        {
            string MaxValue = ((decimal)EDP1419Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1419Row["MinValue"]).ToString("0.##");

            TB_ProcessSecondValue9.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecondValue9.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecondValue9.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        if (EDP1420Row != null)
        {
            string MaxValue = ((decimal)EDP1420Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1420Row["MinValue"]).ToString("0.##");

            TB_PHValue10.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue10.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue10.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHRemark"), MaxValue, MinValue));
        }

        if (EDP1421Row != null)
        {
            string MaxValue = ((decimal)EDP1421Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1421Row["MinValue"]).ToString("0.##");

            TB_ConductivityValue10.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ConductivityValue10.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ConductivityValue10.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Conductivity_Remark"), MaxValue, MinValue));
        }

        if (EDP1422Row != null)
        {
            string MaxValue = ((decimal)EDP1422Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP1422Row["MinValue"]).ToString("0.##");

            TB_ProcessSecondValue10.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecondValue10.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecondValue10.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }
    }

    protected void LoadData()
    {
        if (string.IsNullOrEmpty(HF_PID.Value))
            return;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPWaterRinsing"];

        string Query = "Select *,Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName From T_EDPWaterRinsing Where PID = @PID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PID"].copy(HF_PID.Value.ToStringFromBase64()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return;

        DataRow Row = DT.Rows[0];

        TB_PDate.Text = ((DateTime)Row["PDate"]).ToCurrentUICultureString();

        DDL_WorkClass.SelectedValue = Row["WorkClassID"].ToString().Trim();

        DDL_PLID.SelectedValue = Row["PLID"].ToString().Trim();

        decimal PHValue1 = (decimal)Row["PHValue1"];

        if (PHValue1 > -1)
            TB_PHValue1.Text = PHValue1.ToString();

        int ProcessSecond1 = (int)Row["ProcessSecond1"];

        if (ProcessSecond1 > -1)
            TB_ProcessSecondValue1.Text = ProcessSecond1.ToString();

        decimal PHValue2 = (decimal)Row["PHValue2"];

        if (PHValue2 > -1)
            TB_PHValue2.Text = PHValue2.ToString();

        int ProcessSecond2 = (int)Row["ProcessSecond2"];

        if (ProcessSecond2 > -1)
            TB_ProcessSecondValue2.Text = ProcessSecond2.ToString();

        decimal PHValue3 = (decimal)Row["PHValue3"];

        if (PHValue3 > -1)
            TB_PHValue3.Text = PHValue3.ToString();

        int ProcessSecond3 = (int)Row["ProcessSecond3"];

        if (ProcessSecond3 > -1)
            TB_ProcessSecondValue3.Text = ProcessSecond3.ToString();

        decimal PHValue4 = (decimal)Row["PHValue4"];

        if (PHValue4 > -1)
            TB_PHValue4.Text = PHValue4.ToString();

        int ProcessSecond4 = (int)Row["ProcessSecond4"];

        if (ProcessSecond4 > -1)
            TB_ProcessSecondValue4.Text = ProcessSecond4.ToString();

        decimal PHValue5 = (decimal)Row["PHValue5"];

        if (PHValue5 > -1)
            TB_PHValue5.Text = PHValue5.ToString();

        int ProcessSecond5 = (int)Row["ProcessSecond5"];

        if (ProcessSecond5 > -1)
            TB_ProcessSecondValue5.Text = ProcessSecond5.ToString();

        decimal PHValue6 = (decimal)Row["PHValue6"];

        if (PHValue6 > -1)
            TB_PHValue6.Text = PHValue6.ToString();

        int ProcessSecond6 = (int)Row["ProcessSecond6"];

        if (ProcessSecond6 > -1)
            TB_ProcessSecondValue6.Text = ProcessSecond6.ToString();

        decimal PHValue7 = (decimal)Row["PHValue7"];

        if (PHValue7 > -1)
            TB_PHValue7.Text = PHValue7.ToString();

        int ProcessSecond7 = (int)Row["ProcessSecond7"];

        if (ProcessSecond7 > -1)
            TB_ProcessSecondValue7.Text = ProcessSecond7.ToString();

        decimal PHValue8 = (decimal)Row["PHValue8"];

        if (PHValue8 > -1)
            TB_PHValue8.Text = PHValue8.ToString();

        int ProcessSecond8 = (int)Row["ProcessSecond8"];

        if (ProcessSecond8 > -1)
            TB_ProcessSecondValue8.Text = ProcessSecond8.ToString();

        decimal PHValue9 = (decimal)Row["PHValue9"];

        if (PHValue9 > -1)
            TB_PHValue9.Text = PHValue9.ToString();

        decimal Conductivity9 = (decimal)Row["Conductivity9"];

        if (Conductivity9 > -1)
            TB_ConductivityValue9.Text = Conductivity9.ToString();

        int ProcessSecond9 = (int)Row["ProcessSecond9"];

        if (ProcessSecond9 > -1)
            TB_ProcessSecondValue9.Text = ProcessSecond9.ToString();

        decimal PHValue10 = (decimal)Row["PHValue10"];

        if (PHValue10 > -1)
            TB_PHValue10.Text = PHValue10.ToString();

        decimal Conductivity10 = (decimal)Row["Conductivity10"];

        if (Conductivity10 > -1)
            TB_ConductivityValue10.Text = Conductivity10.ToString();

        int ProcessSecond10 = (int)Row["ProcessSecond10"];

        if (ProcessSecond10 > -1)
            TB_ProcessSecondValue10.Text = ProcessSecond10.ToString();

        TB_Remark.Text = Row["Remark"].ToString().Trim();

        WUC_DataCreateInfo.SetControlData(Row);
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            string Query = string.Empty;

            string PID = string.Empty;

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPWaterRinsing"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            DateTime PDate = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_PDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out PDate))
                PDate = DateTime.Parse("1900/01/01");

            if (PDate.Year < 1911)
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if (string.IsNullOrEmpty(DDL_WorkClass.SelectedValue) || string.IsNullOrEmpty(DDL_PLID.SelectedValue))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            // 至少要輸入一個參數
            if (string.IsNullOrEmpty(TB_PHValue1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PHValue2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PHValue3.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PHValue4.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PHValue5.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PHValue6.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PHValue7.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PHValue8.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PHValue9.Text.Trim()) &&
                string.IsNullOrEmpty(TB_PHValue10.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecondValue1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecondValue2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecondValue3.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecondValue4.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecondValue5.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecondValue6.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecondValue7.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecondValue8.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecondValue9.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ProcessSecondValue10.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ConductivityValue9.Text.Trim()) &&
                string.IsNullOrEmpty(TB_ConductivityValue10.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));

            if (string.IsNullOrEmpty(HF_PID.Value))
            {
                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Insert Into T_EDPWaterRinsing (PID,PDate,WorkClassID,PLID,PHValue1,ProcessSecond1,PHValue2,ProcessSecond2,PHValue3,ProcessSecond3,PHValue4,ProcessSecond4,PHValue5,ProcessSecond5,PHValue6,ProcessSecond6,PHValue7,ProcessSecond7,PHValue8,ProcessSecond8,
                          PHValue9,Conductivity9,ProcessSecond9,PHValue10,Conductivity10,ProcessSecond10,Remark,CreateAccountID) 
                          Values (@PID,@PDate,@WorkClassID,@PLID,@PHValue1,@ProcessSecond1,@PHValue2,@ProcessSecond2,@PHValue3,@ProcessSecond3,@PHValue4,@ProcessSecond4,@PHValue5,@ProcessSecond5,@PHValue6,@ProcessSecond6,@PHValue7,@ProcessSecond7,@PHValue8,@ProcessSecond8,
                          @PHValue9,@Conductivity9,@ProcessSecond9,@PHValue10,@Conductivity10,@ProcessSecond10,@Remark,@CreateAccountID)";

                PID = BaseConfiguration.SerialObject[(short)14].取號();

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));
            }
            else
            {
                PID = HF_PID.Value.ToStringFromBase64();

                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue, PID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Update T_EDPWaterRinsing Set PDate = @PDate,WorkClassID = @WorkClassID,PLID = @PLID,PHValue1 = @PHValue1,ProcessSecond1 = @ProcessSecond1,PHValue2 = @PHValue2,ProcessSecond2 = @ProcessSecond2,PHValue3 = @PHValue3,ProcessSecond3 = @ProcessSecond3,
                          PHValue4 = @PHValue4,ProcessSecond4 = @ProcessSecond4,PHValue5 = @PHValue5,ProcessSecond5 = @ProcessSecond5,PHValue6 = @PHValue6,ProcessSecond6 = @ProcessSecond6,PHValue7 = @PHValue7,ProcessSecond7 = @ProcessSecond7,
                          PHValue8 = @PHValue8,ProcessSecond8 = @ProcessSecond8,PHValue9 = @PHValue9,Conductivity9 = @Conductivity9,ProcessSecond9 = @ProcessSecond9,PHValue10 = @PHValue10,Conductivity10 = @Conductivity10,ProcessSecond10 = @ProcessSecond10,
                          Remark = @Remark,ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where PID = @PID";

                dbcb.appendParameter(Schema.Attributes["ModifyAccountID"].copy(Master.AccountID));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["PID"].copy(PID));
            dbcb.appendParameter(Schema.Attributes["PDate"].copy(PDate));
            dbcb.appendParameter(Schema.Attributes["WorkClassID"].copy((DDL_WorkClass.SelectedValue)));
            dbcb.appendParameter(Schema.Attributes["PLID"].copy((DDL_PLID.SelectedValue)));

            decimal PHValue1 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue1.Text.Trim()) && !decimal.TryParse(TB_PHValue1.Text.Trim(), out PHValue1))
                PHValue1 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue1"].copy(PHValue1));

            int ProcessSecond1 = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecondValue1.Text.Trim()) && !int.TryParse(TB_ProcessSecondValue1.Text.Trim(), out ProcessSecond1))
                ProcessSecond1 = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond1"].copy(ProcessSecond1));

            decimal PHValue2 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue2.Text.Trim()) && !decimal.TryParse(TB_PHValue2.Text.Trim(), out PHValue2))
                PHValue2 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue2"].copy(PHValue2));

            int ProcessSecond2 = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecondValue2.Text.Trim()) && !int.TryParse(TB_ProcessSecondValue2.Text.Trim(), out ProcessSecond2))
                ProcessSecond2 = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond2"].copy(ProcessSecond2));

            decimal PHValue3 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue3.Text.Trim()) && !decimal.TryParse(TB_PHValue3.Text.Trim(), out PHValue3))
                PHValue3 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue3"].copy(PHValue3));

            int ProcessSecond3 = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecondValue3.Text.Trim()) && !int.TryParse(TB_ProcessSecondValue3.Text.Trim(), out ProcessSecond3))
                ProcessSecond3 = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond3"].copy(ProcessSecond3));

            decimal PHValue4 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue4.Text.Trim()) && !decimal.TryParse(TB_PHValue4.Text.Trim(), out PHValue4))
                PHValue4 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue4"].copy(PHValue4));

            int ProcessSecond4 = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecondValue4.Text.Trim()) && !int.TryParse(TB_ProcessSecondValue4.Text.Trim(), out ProcessSecond4))
                ProcessSecond4 = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond4"].copy(ProcessSecond4));

            decimal PHValue5 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue5.Text.Trim()) && !decimal.TryParse(TB_PHValue5.Text.Trim(), out PHValue5))
                PHValue5 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue5"].copy(PHValue5));

            int ProcessSecond5 = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecondValue5.Text.Trim()) && !int.TryParse(TB_ProcessSecondValue5.Text.Trim(), out ProcessSecond5))
                ProcessSecond5 = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond5"].copy(ProcessSecond5));

            decimal PHValue6 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue6.Text.Trim()) && !decimal.TryParse(TB_PHValue6.Text.Trim(), out PHValue6))
                PHValue6 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue6"].copy(PHValue6));

            int ProcessSecond6 = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecondValue6.Text.Trim()) && !int.TryParse(TB_ProcessSecondValue6.Text.Trim(), out ProcessSecond6))
                ProcessSecond5 = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond6"].copy(ProcessSecond6));

            decimal PHValue7 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue7.Text.Trim()) && !decimal.TryParse(TB_PHValue7.Text.Trim(), out PHValue7))
                PHValue7 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue7"].copy(PHValue7));

            int ProcessSecond7 = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecondValue7.Text.Trim()) && !int.TryParse(TB_ProcessSecondValue7.Text.Trim(), out ProcessSecond7))
                ProcessSecond7 = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond7"].copy(ProcessSecond7));

            decimal PHValue8 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue8.Text.Trim()) && !decimal.TryParse(TB_PHValue8.Text.Trim(), out PHValue8))
                PHValue8 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue8"].copy(PHValue8));

            int ProcessSecond8 = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecondValue8.Text.Trim()) && !int.TryParse(TB_ProcessSecondValue8.Text.Trim(), out ProcessSecond8))
                ProcessSecond8 = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond8"].copy(ProcessSecond8));

            decimal PHValue9 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue9.Text.Trim()) && !decimal.TryParse(TB_PHValue9.Text.Trim(), out PHValue9))
                PHValue9 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue9"].copy(PHValue9));

            decimal ConductivityValue9 = -1;

            if (!string.IsNullOrEmpty(TB_ConductivityValue9.Text.Trim()) && !decimal.TryParse(TB_ConductivityValue9.Text.Trim(), out ConductivityValue9))
                ConductivityValue9 = -1;
            dbcb.appendParameter(Schema.Attributes["Conductivity9"].copy(ConductivityValue9));

            int ProcessSecond9 = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecondValue9.Text.Trim()) && !int.TryParse(TB_ProcessSecondValue9.Text.Trim(), out ProcessSecond9))
                ProcessSecond9 = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond9"].copy(ProcessSecond9));

            decimal PHValue10 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue10.Text.Trim()) && !decimal.TryParse(TB_PHValue10.Text.Trim(), out PHValue10))
                PHValue10 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue10"].copy(PHValue10));

            decimal ConductivityValue10 = -1;

            if (!string.IsNullOrEmpty(TB_ConductivityValue10.Text.Trim()) && !decimal.TryParse(TB_ConductivityValue10.Text.Trim(), out ConductivityValue10))
                ConductivityValue10 = -1;
            dbcb.appendParameter(Schema.Attributes["Conductivity10"].copy(ConductivityValue10));

            int ProcessSecond10 = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecondValue10.Text.Trim()) && !int.TryParse(TB_ProcessSecondValue10.Text.Trim(), out ProcessSecond10))
                ProcessSecond10 = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond10"].copy(ProcessSecond10));

            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            Util.ED.DeletEDData(HF_PID.Value.ToStringFromBase64(), ((short)Util.ED.PIDType.T_EDPWaterRinsing), false);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}