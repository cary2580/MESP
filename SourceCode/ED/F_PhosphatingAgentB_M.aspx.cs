using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;
public partial class ED_F_PhosphatingAgentB_M : System.Web.UI.Page
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
            if (Request["PADate"] != null && !string.IsNullOrEmpty(Request["PADate"].ToString()))
                TB_PADate.Text = Request["PADate"].ToString().ToStringFromBase64();
            else if (Request["PAID"] != null && !string.IsNullOrEmpty(Request["PAID"].ToString()))
                HF_PAID.Value = Request["PAID"].ToString();
            else
            {
                Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_EmptyPDateOrPIDAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }

            //如果是新增要先取號讓FileUpload元件可以有值
            if (string.IsNullOrEmpty(HF_PAID.Value))
            {
                string PAID = BaseConfiguration.SerialObject[(short)17].取號();

                HF_PAID.Value = PAID.ToBase64String();

                HF_IsNewData.Value = true.ToStringValue();
            }

            WUC_File.FileID = HF_PAID.Value;

            WUC_File.FileCategoryID = "ED".ToBase64String();

            Util.LoadDDLData(DDL_EDResultID);

            LoadData();

            BT_Delete.Visible = !(HF_IsNewData.Value.ToBoolean());
        }
    }

    /// <summary>
    /// 指定DataTable設定ToolTip，如果有DataTable資料以DataTable資料為主，否則撈標準設定
    /// </summary>
    /// <param name="DT">DataTable</param>
    protected void LoadPrametersRemark(DataTable DT)
    {
        string AgentDensityStandardMax = string.Empty;
        string AgentDensityStandardMin = string.Empty;
        string TotalAcidityStandardMax = string.Empty;
        string TotalAcidityStandardMin = string.Empty;
        string FreeAcidStandardMax = string.Empty;
        string FreeAcidStandardMin = string.Empty;
        string PHValueStandardMax = string.Empty;
        string PHValueStandardMin = string.Empty;

        if (DT.Rows.Count > 0 && !string.IsNullOrEmpty(DT.Rows[0]["AgentDensityStandardMax"].ToString()))
        {
            AgentDensityStandardMax = ((decimal)DT.Rows[0]["AgentDensityStandardMax"]).ToString("0.##");

            AgentDensityStandardMin = ((decimal)DT.Rows[0]["AgentDensityStandardMin"]).ToString("0.##");

            TotalAcidityStandardMax = ((decimal)DT.Rows[0]["TotalAcidityStandardMax"]).ToString("0.##");

            TotalAcidityStandardMin = ((decimal)DT.Rows[0]["TotalAcidityStandardMin"]).ToString("0.##");

            FreeAcidStandardMax = ((decimal)DT.Rows[0]["FreeAcidStandardMax"]).ToString("0.##");

            FreeAcidStandardMin = ((decimal)DT.Rows[0]["FreeAcidStandardMin"]).ToString("0.##");

            PHValueStandardMax = ((decimal)DT.Rows[0]["PHValueStandardMax"]).ToString("0.##");

            PHValueStandardMin = ((decimal)DT.Rows[0]["PHValueStandardMin"]).ToString("0.##");

        }
        else
        {
            DbCommandBuilder dbcb = new DbCommandBuilder("Select * From T_EDPStandardValue Where PrametersID in (Select item From Base_Org.dbo.Split(@Prameters,'|'))");

            dbcb.appendParameter(Util.GetDataAccessAttribute("Prameters", "nvarchar", 10000, "EDF11|EDF12|EDF13|EDF14"));

            DataTable EDPStandardValue_DT = CommonDB.ExecuteSelectQuery(dbcb);

            DataRow EDF11Row = EDPStandardValue_DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDF11").FirstOrDefault();
            DataRow EDF12Row = EDPStandardValue_DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDF12").FirstOrDefault();
            DataRow EDF13Row = EDPStandardValue_DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDF13").FirstOrDefault();
            DataRow EDF14Row = EDPStandardValue_DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDF14").FirstOrDefault();

            if (EDF11Row != null)
            {
                AgentDensityStandardMax = ((decimal)EDF11Row["MaxValue"]).ToString("0.##");
                AgentDensityStandardMin = ((decimal)EDF11Row["MinValue"]).ToString("0.##");

                TB_AgentDensity.Attributes.Add("data-MumberTypeMaxValue", AgentDensityStandardMax);
                TB_AgentDensity.Attributes.Add("data-MumberTypeMinValue", AgentDensityStandardMin);
            }

            if (EDF12Row != null)
            {
                TotalAcidityStandardMax = ((decimal)EDF12Row["MaxValue"]).ToString("0.##");
                TotalAcidityStandardMin = ((decimal)EDF12Row["MinValue"]).ToString("0.##");

                TB_TotalAcidity.Attributes.Add("data-MumberTypeMaxValue", TotalAcidityStandardMax);
                TB_TotalAcidity.Attributes.Add("data-MumberTypeMinValue", TotalAcidityStandardMin);
            }

            if (EDF13Row != null)
            {
                FreeAcidStandardMax = ((decimal)EDF13Row["MaxValue"]).ToString("0.##");
                FreeAcidStandardMin = ((decimal)EDF13Row["MinValue"]).ToString("0.##");

                TB_FreeAcid.Attributes.Add("data-MumberTypeMaxValue", FreeAcidStandardMax);
                TB_FreeAcid.Attributes.Add("data-MumberTypeMinValue", FreeAcidStandardMin);
            }

            if (EDF14Row != null)
            {
                PHValueStandardMax = ((decimal)EDF14Row["MaxValue"]).ToString("0.##");
                PHValueStandardMin = ((decimal)EDF14Row["MinValue"]).ToString("0.##");

                TB_PHValue.Attributes.Add("data-MumberTypeMaxValue", PHValueStandardMax);
                TB_PHValue.Attributes.Add("data-MumberTypeMinValue", PHValueStandardMin);
            }
        }

        string AgentDensityRemark = (string)GetLocalResourceObject("Str_ED_F_AgentDensity_Remark");
        string TotalAcidityRemark = (string)GetLocalResourceObject("Str_ED_F_TotalAcidity_Remark");
        string FreeAcidRemark = (string)GetLocalResourceObject("Str_ED_F_FreeAcid_Remark");
        string PHValueRemark = (string)GetLocalResourceObject("Str_ED_F_PHValue_Remark");

        TB_AgentDensity.Attributes.Add("title", string.Format(AgentDensityRemark, AgentDensityStandardMax, AgentDensityStandardMin));
        TB_AgentDensity.Attributes.Add("MaxValue", AgentDensityStandardMax);
        TB_AgentDensity.Attributes.Add("MinValue", AgentDensityStandardMin);

        TB_TotalAcidity.Attributes.Add("title", string.Format(TotalAcidityRemark, TotalAcidityStandardMax, TotalAcidityStandardMin));
        TB_TotalAcidity.Attributes.Add("MaxValue", TotalAcidityStandardMax);
        TB_TotalAcidity.Attributes.Add("MinValue", TotalAcidityStandardMin);

        TB_FreeAcid.Attributes.Add("title", string.Format(FreeAcidRemark, FreeAcidStandardMax, FreeAcidStandardMin));
        TB_FreeAcid.Attributes.Add("MaxValue", FreeAcidStandardMax);
        TB_FreeAcid.Attributes.Add("MinValue", FreeAcidStandardMin);

        TB_PHValue.Attributes.Add("title", string.Format(PHValueRemark, PHValueStandardMax, PHValueStandardMin));
        TB_PHValue.Attributes.Add("MaxValue", PHValueStandardMax);
        TB_PHValue.Attributes.Add("MinValue", PHValueStandardMin);

    }

    protected void LoadData()
    {
        DataTable T_EDPhosphatingAgentB_DT = GetPAData();

        for (int SearchRow = 0; SearchRow < T_EDPhosphatingAgentB_DT.Rows.Count; SearchRow++)
        {
            DataRow Row = T_EDPhosphatingAgentB_DT.Rows[SearchRow];

            if (SearchRow == 0)
            {

                WUC_DataCreateInfo.SetControlData(Row);

                TB_PADate.Text = ((DateTime)Row["PADate"]).ToCurrentUICultureString();

                decimal AgentDensity = decimal.Parse((string.IsNullOrEmpty(Row["AgentDensity"].ToString()) ? "-1" : Row["AgentDensity"].ToString()));

                if (AgentDensity > -1)
                    TB_AgentDensity.Text = AgentDensity.ToString();

                decimal TotalAcidityValue = decimal.Parse((string.IsNullOrEmpty(Row["TotalAcidity"].ToString()) ? "-1" : Row["TotalAcidity"].ToString()));

                if (TotalAcidityValue > -1)
                    TB_TotalAcidity.Text = TotalAcidityValue.ToString("0.##");

                decimal FreeAcidValue = decimal.Parse((string.IsNullOrEmpty(Row["FreeAcid"].ToString()) ? "-1" : Row["FreeAcid"].ToString()));

                if (FreeAcidValue > -1)
                    TB_FreeAcid.Text = FreeAcidValue.ToString("0.##");

                decimal PHValue = decimal.Parse((string.IsNullOrEmpty(Row["PHValue"].ToString()) ? "-1" : Row["PHValue"].ToString()));

                if (PHValue > -1)
                    TB_PHValue.Text = PHValue.ToString();

                DDL_EDResultID.SelectedValue = string.IsNullOrEmpty(Row["ResultID"].ToString()) ? string.Empty : Row["ResultID"].ToString();

                TB_Remark.Text = Row["ReportRemark"].ToString().Trim();
            }

            if (Row["PABID"].ToString().Trim() == L_P001.Text.Trim())
            {
                TB_P001_Qty.Text = decimal.Parse(Row["Qty"].ToString()) > -1 ? Row["Qty"].ToString() : string.Empty;
                TB_P001_LotNumber.Text = Row["LotNumber"].ToString();
                TB_P001_Remark.Text = Row["Remark"].ToString().ToString().Trim();
            }

            if (Row["PABID"].ToString().Trim() == L_N002.Text.Trim())
            {
                TB_N002_Qty.Text = decimal.Parse(Row["Qty"].ToString()) > -1 ? Row["Qty"].ToString() : string.Empty;
                TB_N002_LotNumber.Text = Row["LotNumber"].ToString();
                TB_N002_Remark.Text = Row["Remark"].ToString().ToString().Trim();
            }

            if (Row["PABID"].ToString().Trim() == L_Z003.Text.Trim())
            {
                TB_Z003_Qty.Text = decimal.Parse(Row["Qty"].ToString()) > -1 ? Row["Qty"].ToString() : string.Empty;
                TB_Z003_LotNumber.Text = Row["LotNumber"].ToString();
                TB_Z003_Remark.Text = Row["Remark"].ToString().ToString().Trim();
            }

            if (Row["PABID"].ToString().Trim() == L_C004.Text.Trim())
            {
                TB_C004_Qty.Text = decimal.Parse(Row["Qty"].ToString()) > -1 ? Row["Qty"].ToString() : string.Empty;
                TB_C004_LotNumber.Text = Row["LotNumber"].ToString();
                TB_C004_Remark.Text = Row["Remark"].ToString().ToString().Trim();
            }

            if (Row["PABID"].ToString().Trim() == L_S005.Text.Trim())
            {
                TB_S005_Qty.Text = decimal.Parse(Row["Qty"].ToString()) > -1 ? Row["Qty"].ToString() : string.Empty;
                TB_S005_LotNumber.Text = Row["LotNumber"].ToString();
                TB_S005_Remark.Text = Row["Remark"].ToString().ToString().Trim();
            }

            if (Row["PABID"].ToString().Trim() == L_I006.Text.Trim())
            {
                TB_I006_Qty.Text = decimal.Parse(Row["Qty"].ToString()) > -1 ? Row["Qty"].ToString() : string.Empty;
                TB_I006_LotNumber.Text = Row["LotNumber"].ToString();
                TB_I006_Remark.Text = Row["Remark"].ToString().ToString().Trim();
            }

            if (Row["PABID"].ToString().Trim() == L_F007.Text.Trim())
            {
                TB_F007_Qty.Text = decimal.Parse(Row["Qty"].ToString()) > -1 ? Row["Qty"].ToString() : string.Empty;
                TB_F007_LotNumber.Text = Row["LotNumber"].ToString();
                TB_F007_Remark.Text = Row["Remark"].ToString().ToString().Trim();
            }

            if (Row["PABID"].ToString().Trim() == L_H008.Text.Trim())
            {
                TB_H008_Qty.Text = decimal.Parse(Row["Qty"].ToString()) > -1 ? Row["Qty"].ToString() : string.Empty;
                TB_H008_LotNumber.Text = Row["LotNumber"].ToString();
                TB_H008_Remark.Text = Row["Remark"].ToString().ToString().Trim();
            }
        }

        LoadPrametersRemark(T_EDPhosphatingAgentB_DT);
    }

    /// <summary>
    ///  取得資料
    /// </summary>
    /// <returns></returns>
    protected DataTable GetPAData()
    {
        string Query = @"Select T_EDPhosphatingAgentB.PAID,T_EDPhosphatingAgentB.PADate,T_EDPhosphatingAgentB.CreateDate,T_EDPhosphatingAgentB.CreateAccountID,
	                            T_EDPhosphatingAgentB.ModifyDate,T_EDPhosphatingAgentB.ModifyAccountID,T_EDPhosphatingAgentB_Formula.PABID,T_EDPhosphatingAgentB_Formula.Qty,
	                            T_EDPhosphatingAgentB_Formula.LotNumber,T_EDPhosphatingAgentB_Formula.Remark,T_EDPhosphatingAgentB_Report.AgentDensityStandardMax,T_EDPhosphatingAgentB_Report.AgentDensityStandardMin,
	                            T_EDPhosphatingAgentB_Report.AgentDensity,T_EDPhosphatingAgentB_Report.TotalAcidityStandardMax,T_EDPhosphatingAgentB_Report.TotalAcidityStandardMin,
	                            T_EDPhosphatingAgentB_Report.TotalAcidity,T_EDPhosphatingAgentB_Report.FreeAcidStandardMax,T_EDPhosphatingAgentB_Report.FreeAcidStandardMin,
	                            T_EDPhosphatingAgentB_Report.FreeAcid,T_EDPhosphatingAgentB_Report.PHValueStandardMax,T_EDPhosphatingAgentB_Report.PHValueStandardMin,
	                            T_EDPhosphatingAgentB_Report.PHValue,T_EDPhosphatingAgentB_Report.Remark As ReportRemark,T_EDPhosphatingAgentB_Report.ResultID,
                                Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName
                        From T_EDPhosphatingAgentB 
                        Inner Join T_EDPhosphatingAgentB_Formula On T_EDPhosphatingAgentB.PAID = T_EDPhosphatingAgentB_Formula.PAID
                        Left Join T_EDPhosphatingAgentB_Report On T_EDPhosphatingAgentB.PAID = T_EDPhosphatingAgentB_Report.PAID
	                    Where T_EDPhosphatingAgentB.PAID=@PAID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("PAID", "Nvarchar", 50, HF_PAID.Value.ToStringFromBase64()));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            string Query = string.Empty;

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPhosphatingAgentB"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            DateTime PADate = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_PADate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out PADate))
                PADate = DateTime.Parse("1900/01/01");

            if (PADate.Year < 1911)
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if (Util.ED.IsFormulaDateRepeat(PADate, true))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_F_DataRepeat"));

            // 至少要輸入一個參數
            if (string.IsNullOrEmpty(TB_P001_Qty.Text.Trim()) &&
                string.IsNullOrEmpty(TB_N002_Qty.Text.Trim()) &&
                string.IsNullOrEmpty(TB_Z003_Qty.Text.Trim()) &&
                string.IsNullOrEmpty(TB_C004_Qty.Text.Trim()) &&
                string.IsNullOrEmpty(TB_S005_Qty.Text.Trim()) &&
                string.IsNullOrEmpty(TB_I006_Qty.Text.Trim()) &&
                string.IsNullOrEmpty(TB_F007_Qty.Text.Trim()) &&
                string.IsNullOrEmpty(TB_H008_Qty.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));

            if (HF_IsNewData.Value.ToString().ToBoolean())
            {
                Query = @"Insert Into T_EDPhosphatingAgentB(PAID,PADate,CreateAccountID)Values(@PAID,@PADate,@CreateAccountID)";

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));
            }
            else
            {
                Query = @"Update T_EDPhosphatingAgentB Set ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where PAID = @PAID";

                dbcb.appendParameter(Schema.Attributes["ModifyAccountID"].copy(Master.AccountID));
            }

            string PAID = HF_PAID.Value.ToStringFromBase64();

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));
            dbcb.appendParameter(Schema.Attributes["PADate"].copy(PADate));

            DBA.AddCommandBuilder(dbcb);

            DBA.AddCommandBuilder(GetDelete_FormulaDBCB(PAID, L_P001.Text.Trim()));
            DBA.AddCommandBuilder(GetCreate_FormulaDBCB(PAID, L_P001.Text.Trim(), TB_P001_Qty.Text.Trim(), TB_P001_LotNumber.Text.Trim(), TB_P001_Remark.Text.Trim()));

            DBA.AddCommandBuilder(GetDelete_FormulaDBCB(PAID, L_N002.Text.Trim()));
            DBA.AddCommandBuilder(GetCreate_FormulaDBCB(PAID, L_N002.Text.Trim(), TB_N002_Qty.Text.Trim(), TB_N002_LotNumber.Text.Trim(), TB_N002_Remark.Text.Trim()));

            DBA.AddCommandBuilder(GetDelete_FormulaDBCB(PAID, L_Z003.Text.Trim()));
            DBA.AddCommandBuilder(GetCreate_FormulaDBCB(PAID, L_Z003.Text.Trim(), TB_Z003_Qty.Text.Trim(), TB_Z003_LotNumber.Text.Trim(), TB_Z003_Remark.Text.Trim()));

            DBA.AddCommandBuilder(GetDelete_FormulaDBCB(PAID, L_C004.Text.Trim()));
            DBA.AddCommandBuilder(GetCreate_FormulaDBCB(PAID, L_C004.Text.Trim(), TB_C004_Qty.Text.Trim(), TB_C004_LotNumber.Text.Trim(), TB_C004_Remark.Text.Trim()));

            DBA.AddCommandBuilder(GetDelete_FormulaDBCB(PAID, L_S005.Text.Trim()));
            DBA.AddCommandBuilder(GetCreate_FormulaDBCB(PAID, L_S005.Text.Trim(), TB_S005_Qty.Text.Trim(), TB_S005_LotNumber.Text.Trim(), TB_S005_Remark.Text.Trim()));

            DBA.AddCommandBuilder(GetDelete_FormulaDBCB(PAID, L_I006.Text.Trim()));
            DBA.AddCommandBuilder(GetCreate_FormulaDBCB(PAID, L_I006.Text.Trim(), TB_I006_Qty.Text.Trim(), TB_I006_LotNumber.Text.Trim(), TB_I006_Remark.Text.Trim()));

            DBA.AddCommandBuilder(GetDelete_FormulaDBCB(PAID, L_F007.Text.Trim()));
            DBA.AddCommandBuilder(GetCreate_FormulaDBCB(PAID, L_F007.Text.Trim(), TB_F007_Qty.Text.Trim(), TB_F007_LotNumber.Text.Trim(), TB_F007_Remark.Text.Trim()));

            DBA.AddCommandBuilder(GetDelete_FormulaDBCB(PAID, L_H008.Text.Trim()));
            DBA.AddCommandBuilder(GetCreate_FormulaDBCB(PAID, L_H008.Text.Trim(), TB_H008_Qty.Text.Trim(), TB_H008_LotNumber.Text.Trim(), TB_H008_Remark.Text.Trim()));

            DBA.AddCommandBuilder(Get_ReportDBCB());

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
    /// <summary>
    /// 指定磷化劑B配置ID、配方ID得到刪除增配置明細表DBCD
    /// </summary>
    /// <param name="PAID">磷化劑B配置ID</param>
    /// <param name="PABID">配方ID</param>
    /// <returns>刪除增配置明細表DBCD</returns>
    protected DbCommandBuilder GetDelete_FormulaDBCB(string PAID, string PABID)
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPhosphatingAgentB_Formula"];

        DbCommandBuilder dbcb = new DbCommandBuilder("Delete T_EDPhosphatingAgentB_Formula Where PAID = @PAID And PABID = @PABID");

        dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));
        dbcb.appendParameter(Schema.Attributes["PABID"].copy(PABID));

        return dbcb;
    }

    /// <summary>
    /// 指定相關參數得到新增配置明細表DBCB
    /// </summary>
    /// <param name="PAID">磷化劑B配置ID</param>
    /// <param name="PABID">配方ID</param>
    /// <param name="Qty">加入量</param>
    /// <param name="LotNumber">批次號</param>
    /// <param name="Remark">備註</param>
    /// <returns>新增配置明細表DBCB</returns>
    protected DbCommandBuilder GetCreate_FormulaDBCB(string PAID, string PABID, string Qty, string LotNumber, string Remark)
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPhosphatingAgentB_Formula"];

        DbCommandBuilder dbcb = new DbCommandBuilder("Insert Into T_EDPhosphatingAgentB_Formula(PAID,PABID,Qty,LotNumber,Remark)Values(@PAID,@PABID,@Qty,@LotNumber,@Remark)");

        dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));
        dbcb.appendParameter(Schema.Attributes["PABID"].copy(PABID));

        decimal TempQty = -1;
        if (!decimal.TryParse(Qty, out TempQty))
        {
            TempQty = -1;
        }
        dbcb.appendParameter(Schema.Attributes["Qty"].copy(TempQty));
        dbcb.appendParameter(Schema.Attributes["LotNumber"].copy(LotNumber));
        dbcb.appendParameter(Schema.Attributes["Remark"].copy(Remark));

        return dbcb;
    }

    protected DbCommandBuilder Get_ReportDBCB()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPhosphatingAgentB_Report"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        bool IsCreate = false;

        string Query = string.Empty;

        string PAID = HF_PAID.Value.ToStringFromBase64();

        IsCreate = HF_IsNewData.Value.ToBoolean();

        if (!IsCreate)
        {
            dbcb = new DbCommandBuilder("Select Count(*) From T_EDPhosphatingAgentB_Report Where PAID = @PAID");

            dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));

            IsCreate = (int)CommonDB.ExecuteScalar(dbcb) < 1;
        }

        if (IsCreate)
        {
            Query = @"Insert Into T_EDPhosphatingAgentB_Report(PAID,AgentDensityStandardMax,AgentDensityStandardMin,AgentDensity,
                          TotalAcidityStandardMax,TotalAcidityStandardMin,TotalAcidity,FreeAcidStandardMax,FreeAcidStandardMin,FreeAcid,
                          PHValueStandardMax,PHValueStandardMin,PHValue,Remark,ResultID
                     )Values(
                         @PAID,@AgentDensityStandardMax,@AgentDensityStandardMin,@AgentDensity,
                         @TotalAcidityStandardMax,@TotalAcidityStandardMin,@TotalAcidity,
                         @FreeAcidStandardMax,@FreeAcidStandardMin,@FreeAcid,@PHValueStandardMax,
                         @PHValueStandardMin,@PHValue,@Remark,@ResultID
                    )";
        }
        else
        {
            Query = @"Update T_EDPhosphatingAgentB_Report Set AgentDensityStandardMax = @AgentDensityStandardMax,AgentDensityStandardMin = @AgentDensityStandardMin,AgentDensity = @AgentDensity,TotalAcidityStandardMax = @TotalAcidityStandardMax,
                        TotalAcidityStandardMin = @TotalAcidityStandardMin,TotalAcidity = @TotalAcidity,FreeAcidStandardMax = @FreeAcidStandardMax,FreeAcidStandardMin = @FreeAcidStandardMin,FreeAcid = @FreeAcid,
                        PHValueStandardMax = @PHValueStandardMax,PHValueStandardMin = @PHValueStandardMin,PHValue = @PHValue,Remark = @Remark,ResultID = @ResultID Where PAID = @PAID";
        }

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));

        dbcb.appendParameter(Schema.Attributes["AgentDensityStandardMax"].copy(TB_AgentDensity.Attributes["MaxValue"].Trim()));

        dbcb.appendParameter(Schema.Attributes["AgentDensityStandardMin"].copy(TB_AgentDensity.Attributes["MinValue"].Trim()));

        decimal TempAgentDensity = -1;

        if (!decimal.TryParse(TB_AgentDensity.Text.Trim(), out TempAgentDensity))
            TempAgentDensity = -1;

        dbcb.appendParameter(Schema.Attributes["AgentDensity"].copy(TempAgentDensity));

        dbcb.appendParameter(Schema.Attributes["TotalAcidityStandardMax"].copy(TB_TotalAcidity.Attributes["MaxValue"].Trim()));

        dbcb.appendParameter(Schema.Attributes["TotalAcidityStandardMin"].copy(TB_TotalAcidity.Attributes["MinValue"].Trim()));

        decimal TempTotalAcidity = -1;

        if (!decimal.TryParse(TB_TotalAcidity.Text.Trim(), out TempTotalAcidity))
            TempTotalAcidity = -1;

        dbcb.appendParameter(Schema.Attributes["TotalAcidity"].copy(TempTotalAcidity));

        dbcb.appendParameter(Schema.Attributes["FreeAcidStandardMax"].copy(TB_FreeAcid.Attributes["MaxValue"].Trim()));

        dbcb.appendParameter(Schema.Attributes["FreeAcidStandardMin"].copy(TB_FreeAcid.Attributes["MinValue"].Trim()));

        decimal TempFreeAcid = -1;

        if (!decimal.TryParse(TB_FreeAcid.Text.Trim(), out TempFreeAcid))
            TempFreeAcid = -1;

        dbcb.appendParameter(Schema.Attributes["FreeAcid"].copy(TempFreeAcid));

        dbcb.appendParameter(Schema.Attributes["PHValueStandardMax"].copy(TB_PHValue.Attributes["MaxValue"].Trim()));

        dbcb.appendParameter(Schema.Attributes["PHValueStandardMin"].copy(TB_PHValue.Attributes["MinValue"].Trim()));

        decimal TempPHValue = -1;

        if (!decimal.TryParse(TB_PHValue.Text.Trim(), out TempPHValue))
            TempPHValue = -1;

        dbcb.appendParameter(Schema.Attributes["PHValue"].copy(TempPHValue));

        dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

        dbcb.appendParameter(Schema.Attributes["ResultID"].copy(DDL_EDResultID.SelectedValue.Trim()));

        return dbcb;
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            DBAction DBA = new DBAction();

            string PAID = HF_PAID.Value.ToStringFromBase64();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPhosphatingAgentB"];

            string Query = @"Delete T_EDPhosphatingAgentB Where PAID = @PAID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_EDPhosphatingAgentB_Formula Where PAID = @PAID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_EDPhosphatingAgentB_Report Where PAID = @PAID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }

    }
}