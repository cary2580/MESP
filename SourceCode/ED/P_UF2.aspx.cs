using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;

public partial class ED_P_UF2 : System.Web.UI.Page
{
    /// <summary>
    /// 目前寫死，因此這個值必須要跟T_Code的ChemicalAdding對的上
    /// </summary>
    protected string CACategoryID = "CA16";

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

            LoadChemicalAddingTitle();

            LoadPrametersRemark();

            LoadDDLData();

            LoadData();
        }

        BT_Delete.Visible = !(string.IsNullOrEmpty(HF_PID.Value));
    }

    protected void LoadChemicalAddingTitle()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select CodeID,CodeName From T_Code Where CodeType = 'ChemicalAdding' And CodeID in (Select item From Base_Org.dbo.Split(@CodeID,'|')) And UICulture = @UICulture");

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CodeID", "nvarchar", 10000, CACategoryID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        string ChemicalAdding_HeadText = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_ChemicalAdding_HeadText");

        DataRow CA1Row = DT.AsEnumerable().Where(Row => Row["CodeID"].ToString().Trim() == CACategoryID).FirstOrDefault();

        CA16_Title.Text = ChemicalAdding_HeadText;

        if (CA1Row != null)
            CA16_Title.Text += "-" + CA1Row["CodeName"].ToString().Trim();
    }

    protected void LoadDDLData()
    {
        Util.ED.LaodWorkClass(DDL_WorkClass);

        Util.ED.LoadProductionLine(DDL_PLID);
    }

    protected void LoadPrametersRemark()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select * From T_EDPStandardValue Where PrametersID in (Select item From Base_Org.dbo.Split(@Prameters,'|'))");

        dbcb.appendParameter(Util.GetDataAccessAttribute("Prameters", "nvarchar", 10000, "EDP111|EDP112|EDP113|EDP114"));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DataRow EDP111Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP111").FirstOrDefault();

        DataRow EDP112Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP112").FirstOrDefault();

        DataRow EDP113Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP113").FirstOrDefault();

        DataRow EDP114Row = DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDP114").FirstOrDefault();

        if (EDP111Row != null)
        {
            string MaxValue = ((decimal)EDP111Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP111Row["MinValue"]).ToString("0.##");

            TB_PHValue1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_PHValue2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_PHValue2.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_PHValue1.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHValue1_Remark"), MaxValue, MinValue));
            TB_PHValue2.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_PHValue2_Remark"), MaxValue, MinValue));
        }

        if (EDP112Row != null)
        {
            string ProcessSecondRemark = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_ProcessSecondRemark");

            string MaxValue = ((decimal)EDP112Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP112Row["MinValue"]).ToString("0.##");

            TB_ProcessSecond.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_ProcessSecond.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_ProcessSecond.Attributes.Add("title", string.Format(ProcessSecondRemark, MaxValue, MinValue));
        }

        if (EDP113Row != null)
        {
            string MaxValue = ((decimal)EDP113Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP113Row["MinValue"]).ToString("0.##");

            TB_Conductivity1.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Conductivity1.Attributes.Add("data-MumberTypeMinValue", MinValue);
            TB_Conductivity2.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Conductivity2.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_Conductivity1.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Conductivity1_Remark"), MaxValue, MinValue));
            TB_Conductivity2.Attributes.Add("title", string.Format((string)GetLocalResourceObject("Str_ED_P_Conductivity2_Remark"), MaxValue, MinValue));
        }

        if (EDP114Row != null)
        {
            string SolidValueRemark = (string)GetLocalResourceObject("Str_ED_P_Solid_Remark");

            string MaxValue = ((decimal)EDP114Row["MaxValue"]).ToString("0.##");
            string MinValue = ((decimal)EDP114Row["MinValue"]).ToString("0.##");

            TB_Solid.Attributes.Add("data-MumberTypeMaxValue", MaxValue);
            TB_Solid.Attributes.Add("data-MumberTypeMinValue", MinValue);

            TB_Solid.Attributes.Add("title", string.Format(SolidValueRemark, MaxValue, MinValue));
        }

        L_PHValue1.Text += "1";
        L_PHValue2.Text += "2";

        L_Conductivity1.Text += "1";
        L_Conductivity2.Text += "2";
    }

    protected void LoadData()
    {
        if (string.IsNullOrEmpty(HF_PID.Value))
            return;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPUF2"];

        string Query = "Select *,Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName From T_EDPUF2 Where PID = @PID";

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

        decimal PHValue2 = (decimal)Row["PHValue2"];

        if (PHValue2 > -1)
            TB_PHValue2.Text = PHValue2.ToString();

        int ProcessSecond = (int)Row["ProcessSecond"];

        if (ProcessSecond > -1)
            TB_ProcessSecond.Text = ProcessSecond.ToString();

        decimal Conductivity1 = (decimal)Row["Conductivity1"];

        if (Conductivity1 > -1)
            TB_Conductivity1.Text = Conductivity1.ToString();

        decimal Conductivity2 = (decimal)Row["Conductivity2"];

        if (Conductivity2 > -1)
            TB_Conductivity2.Text = Conductivity2.ToString();

        decimal SolidValue = (decimal)Row["Solid"];

        if (SolidValue > -1)
            TB_Solid.Text = SolidValue.ToString();

        TB_Remark.Text = Row["Remark"].ToString().Trim();

        WUC_DataCreateInfo.SetControlData(Row);

        Query = "Select * From T_EDChemicalAdding Where PID = @PID Order By SerialNo Asc";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PID"].copy(HF_PID.Value.ToStringFromBase64()));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        foreach (DataRow R in DT.Rows)
        {
            if (R["CategoryID"].ToString().Trim() == CACategoryID)
            {
                if ((short)R["SerialNo"] == 1)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA16_AddDateTime1.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA16_Qty1.Text = Qty.ToString();

                    TB_CA16_LotNumber1.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 2)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA16_AddDateTime2.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA16_Qty2.Text = Qty.ToString();

                    TB_CA16_LotNumber2.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 3)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA16_AddDateTime3.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA16_Qty3.Text = Qty.ToString();

                    TB_CA16_LotNumber3.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
                else if ((short)R["SerialNo"] == 4)
                {
                    DateTime AddDateTime = (DateTime)R["AddDateTime"];

                    if (AddDateTime.Year > 1911)
                        TB_CA16_AddDateTime4.Text = AddDateTime.ToDefaultString("HH:mm:ss");

                    decimal Qty = (decimal)R["Qty"];

                    if (Qty > -1)
                        TB_CA16_Qty4.Text = Qty.ToString();

                    TB_CA16_LotNumber4.Text = R["LotNumber"].ToString().Trim();

                    continue;
                }
            }
        }
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

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPUF2"];

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
                string.IsNullOrEmpty(TB_ProcessSecond.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Conductivity1.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Conductivity2.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Solid.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));

            if (string.IsNullOrEmpty(HF_PID.Value))
            {
                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Insert Into T_EDPUF2 (PID,PDate,WorkClassID,PLID,PHValue1,PHValue2,ProcessSecond,Conductivity1,Conductivity2,Solid,Remark,CreateAccountID) 
                          Values (@PID,@PDate,@WorkClassID,@PLID,@PHValue1,@PHValue2,@ProcessSecond,@Conductivity1,@Conductivity2,@Solid,@Remark,@CreateAccountID)";

                PID = BaseConfiguration.SerialObject[(short)11].取號();

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));
            }
            else
            {
                PID = HF_PID.Value.ToStringFromBase64();

                if (Util.ED.IsDataRepeat(Schema.ContainerName, PDate, DDL_WorkClass.SelectedValue, DDL_PLID.SelectedValue, PID))
                    throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

                Query = @"Update T_EDPUF2 Set PDate = @PDate,WorkClassID = @WorkClassID,PLID = @PLID,PHValue1 = @PHValue1,PHValue2 = @PHValue2,ProcessSecond = @ProcessSecond,Conductivity1 = @Conductivity1,Conductivity2 = @Conductivity2,Solid = @Solid,
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

            decimal PHValue2 = -1;

            if (!string.IsNullOrEmpty(TB_PHValue2.Text.Trim()) && !decimal.TryParse(TB_PHValue2.Text.Trim(), out PHValue2))
                PHValue2 = -1;
            dbcb.appendParameter(Schema.Attributes["PHValue2"].copy(PHValue2));

            int ProcessSecond = -1;

            if (!string.IsNullOrEmpty(TB_ProcessSecond.Text.Trim()) && !int.TryParse(TB_ProcessSecond.Text.Trim(), out ProcessSecond))
                ProcessSecond = -1;
            dbcb.appendParameter(Schema.Attributes["ProcessSecond"].copy(ProcessSecond));

            decimal Conductivity1 = -1;

            if (!string.IsNullOrEmpty(TB_Conductivity1.Text.Trim()) && !decimal.TryParse(TB_Conductivity1.Text.Trim(), out Conductivity1))
                Conductivity1 = -1;
            dbcb.appendParameter(Schema.Attributes["Conductivity1"].copy(Conductivity1));

            decimal Conductivity2 = -1;

            if (!string.IsNullOrEmpty(TB_Conductivity2.Text.Trim()) && !decimal.TryParse(TB_Conductivity2.Text.Trim(), out Conductivity2))
                Conductivity2 = -1;
            dbcb.appendParameter(Schema.Attributes["Conductivity2"].copy(Conductivity2));

            decimal Solid = -1;

            if (!string.IsNullOrEmpty(TB_Solid.Text.Trim()) && !decimal.TryParse(TB_Solid.Text.Trim(), out Solid))
                Solid = -1;
            dbcb.appendParameter(Schema.Attributes["Solid"].copy(Solid));

            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            short SerialNo = 1;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID));

            if (!string.IsNullOrEmpty(TB_CA16_AddDateTime1.Text.Trim()) && !string.IsNullOrEmpty(TB_CA16_Qty1.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID, PDate, TB_CA16_AddDateTime1, TB_CA16_Qty1, TB_CA16_LotNumber1));
            else if (!string.IsNullOrEmpty(TB_CA16_AddDateTime1.Text.Trim() + TB_CA16_Qty1.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA16_Qty1.Text.Trim()) && double.Parse(TB_CA16_Qty1.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 2;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID));

            if (!string.IsNullOrEmpty(TB_CA16_AddDateTime2.Text.Trim()) && !string.IsNullOrEmpty(TB_CA16_Qty2.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID, PDate, TB_CA16_AddDateTime2, TB_CA16_Qty2, TB_CA16_LotNumber2));
            else if (!string.IsNullOrEmpty(TB_CA16_AddDateTime2.Text.Trim() + TB_CA16_Qty2.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA16_Qty2.Text.Trim()) && double.Parse(TB_CA16_Qty2.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 3;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID));

            if (!string.IsNullOrEmpty(TB_CA16_AddDateTime3.Text.Trim()) && !string.IsNullOrEmpty(TB_CA16_Qty3.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID, PDate, TB_CA16_AddDateTime3, TB_CA16_Qty3, TB_CA16_LotNumber3));
            else if (!string.IsNullOrEmpty(TB_CA16_AddDateTime3.Text.Trim() + TB_CA16_Qty3.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA16_Qty3.Text.Trim()) && double.Parse(TB_CA16_Qty3.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

            SerialNo = 4;

            DBA.AddCommandBuilder(Util.ED.GetDeleteCADBCB(PID, SerialNo, CACategoryID));

            if (!string.IsNullOrEmpty(TB_CA16_AddDateTime4.Text.Trim()) && !string.IsNullOrEmpty(TB_CA16_Qty4.Text.Trim()))
                DBA.AddCommandBuilder(Util.ED.GetCreateCADBCB(PID, SerialNo, CACategoryID, PDate, TB_CA16_AddDateTime4, TB_CA16_Qty4, TB_CA16_LotNumber4));
            else if (!string.IsNullOrEmpty(TB_CA16_AddDateTime4.Text.Trim() + TB_CA16_Qty4.Text.Trim()) && (!string.IsNullOrEmpty(TB_CA16_Qty4.Text.Trim()) && double.Parse(TB_CA16_Qty4.Text.Trim()) > 0))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_RequiredByCA"));

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
            Util.ED.DeletEDData(HF_PID.Value.ToStringFromBase64(), ((short)Util.ED.PIDType.T_EDPUF2), true);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}