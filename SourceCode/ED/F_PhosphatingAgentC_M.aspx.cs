using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;

public partial class ED_F_PhosphatingAgentC_M : System.Web.UI.Page
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
                Util.RegisterStartupScriptJqueryAlert(this,
                    (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_EmptyPDateOrPIDAlertMessage"),
                    true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

                return;
            }

            //如果是新增要先取號讓FileUpload元件可以有值
            if (string.IsNullOrEmpty(HF_PAID.Value))
            {
                string PAID = BaseConfiguration.SerialObject[(short)18].取號();

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
        string PHValueStandardMax = string.Empty;
        string PHValueStandardMin = string.Empty;
        string ColorStatusStandard = string.Empty;

        if (DT.Rows.Count > 0 && !string.IsNullOrEmpty(DT.Rows[0]["AgentDensityStandardMax"].ToString()))
        {
            AgentDensityStandardMax = ((decimal)DT.Rows[0]["AgentDensityStandardMax"]).ToString("0.##");

            AgentDensityStandardMin = ((decimal)DT.Rows[0]["AgentDensityStandardMin"]).ToString("0.##");

            PHValueStandardMax = ((decimal)DT.Rows[0]["PHValueStandardMax"]).ToString("0.##");

            PHValueStandardMin = ((decimal)DT.Rows[0]["PHValueStandardMin"]).ToString("0.##");

            ColorStatusStandard = DT.Rows[0]["ColorStatusStandard"].ToString().Trim();
        }
        else
        {
            DbCommandBuilder dbcb = new DbCommandBuilder("Select * From T_EDPStandardValue Where PrametersID in (Select item From Base_Org.dbo.Split(@Prameters,'|'))");

            dbcb.appendParameter(Util.GetDataAccessAttribute("Prameters", "nvarchar", 10000, "EDF21|EDF22"));

            DataTable EDPStandardValue_DT = CommonDB.ExecuteSelectQuery(dbcb);

            DataRow EDF21Row = EDPStandardValue_DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDF21").FirstOrDefault();
            DataRow EDF22Row = EDPStandardValue_DT.AsEnumerable().Where(Row => Row["PrametersID"].ToString().Trim() == "EDF22").FirstOrDefault();

            if (EDF21Row != null)
            {
                AgentDensityStandardMax = ((decimal)EDF21Row["MaxValue"]).ToString("0.##");
                AgentDensityStandardMin = ((decimal)EDF21Row["MinValue"]).ToString("0.##");

                TB_AgentDensity.Attributes.Add("data-MumberTypeMaxValue", AgentDensityStandardMax);
                TB_AgentDensity.Attributes.Add("data-MumberTypeMinValue", AgentDensityStandardMin);
            }

            if (EDF22Row != null)
            {
                PHValueStandardMax = ((decimal)EDF22Row["MaxValue"]).ToString("0.##");
                PHValueStandardMin = ((decimal)EDF22Row["MinValue"]).ToString("0.##");

                TB_PHValue.Attributes.Add("data-MumberTypeMaxValue", PHValueStandardMax);
                TB_PHValue.Attributes.Add("data-MumberTypeMinValue", PHValueStandardMin);
            }

            ColorStatusStandard = GetLocalResourceObject("Str_ED_F_EDF23").ToString().Trim();
        }

        string AgentDensityRemark = (string)GetLocalResourceObject("Str_ED_F_AgentDensity_Remark");
        string PHValueRemark = (string)GetLocalResourceObject("Str_ED_F_PHValue_Remark");
        string ColorStatusRemark = (string)GetLocalResourceObject("Str_ED_F_EDF23_Remark");

        TB_AgentDensity.Attributes.Add("title", string.Format(AgentDensityRemark, AgentDensityStandardMax, AgentDensityStandardMin));
        TB_AgentDensity.Attributes.Add("MaxValue", AgentDensityStandardMax);
        TB_AgentDensity.Attributes.Add("MinValue", AgentDensityStandardMin);

        TB_PHValue.Attributes.Add("title", string.Format(PHValueRemark, PHValueStandardMax, PHValueStandardMin));
        TB_PHValue.Attributes.Add("MaxValue", PHValueStandardMax);
        TB_PHValue.Attributes.Add("MinValue", PHValueStandardMin);

        TB_ColorStatus.Attributes.Add("ColorStatusStandard", ColorStatusStandard);
        TB_ColorStatus.Attributes.Add("title", string.Format(ColorStatusRemark, ColorStatusStandard));
    }

    /// <summary>
    /// 
    /// </summary>
    protected void LoadData()
    {
        DataTable T_EDPhosphatingAgentC_DT = GetPAData();

        for (int SearchRow = 0; SearchRow < T_EDPhosphatingAgentC_DT.Rows.Count; SearchRow++)
        {
            DataRow Row = T_EDPhosphatingAgentC_DT.Rows[SearchRow];

            if (SearchRow == 0)
            {
                WUC_DataCreateInfo.SetControlData(Row);

                TB_PADate.Text = ((DateTime)Row["PADate"]).ToCurrentUICultureString();

                decimal AgentDensity = decimal.Parse((string.IsNullOrEmpty(Row["AgentDensity"].ToString()) ? "-1" : Row["AgentDensity"].ToString()));

                if (AgentDensity > -1)
                    TB_AgentDensity.Text = AgentDensity.ToString();

                decimal PHValue = decimal.Parse((string.IsNullOrEmpty(Row["PHValue"].ToString()) ? "-1" : Row["PHValue"].ToString()));

                if (PHValue > -1)
                    TB_PHValue.Text = PHValue.ToString();

                DDL_EDResultID.SelectedValue = string.IsNullOrEmpty(Row["ResultID"].ToString()) ? string.Empty : Row["ResultID"].ToString();

                TB_Remark.Text = Row["ReportRemark"].ToString().Trim();

                TB_ColorStatus.Text = Row["ColorStatus"].ToString().Trim();
            }

            if (Row["PACID"].ToString().Trim() == L_Y001.Text.Trim())
            {
                TB_Y001_Qty.Text = decimal.Parse(Row["Qty"].ToString()) > -1 ? Row["Qty"].ToString() : string.Empty;
                TB_Y001_LotNumber.Text = Row["LotNumber"].ToString();
                TB_Y001_Remark.Text = Row["Remark"].ToString().ToString().Trim();
            }
        }

        LoadPrametersRemark(T_EDPhosphatingAgentC_DT);
    }

    /// <summary>
    ///  取得資料
    /// </summary>
    /// <returns></returns>
    protected DataTable GetPAData()
    {
        string Query = @"Select T_EDPhosphatingAgentC.PAID,T_EDPhosphatingAgentC.PADate,T_EDPhosphatingAgentC.CreateDate,T_EDPhosphatingAgentC.CreateAccountID,
	                            T_EDPhosphatingAgentC.ModifyDate,T_EDPhosphatingAgentC.ModifyAccountID,T_EDPhosphatingAgentC_Formula.PACID,T_EDPhosphatingAgentC_Formula.Qty,
	                            T_EDPhosphatingAgentC_Formula.LotNumber,T_EDPhosphatingAgentC_Formula.Remark,T_EDPhosphatingAgentC_Report.AgentDensityStandardMax,T_EDPhosphatingAgentC_Report.AgentDensityStandardMin,
	                            T_EDPhosphatingAgentC_Report.AgentDensity,T_EDPhosphatingAgentC_Report.PHValueStandardMax,T_EDPhosphatingAgentC_Report.PHValueStandardMin,
	                            T_EDPhosphatingAgentC_Report.PHValue,T_EDPhosphatingAgentC_Report.ColorStatusStandard,T_EDPhosphatingAgentC_Report.ColorStatus,
								T_EDPhosphatingAgentC_Report.Remark As ReportRemark,T_EDPhosphatingAgentC_Report.ResultID,
                                Base_Org.dbo.GetAccountName(CreateAccountID) AS CreateAccountName,Base_Org.dbo.GetAccountName(ModifyAccountID) AS ModifyAccountName
                        From T_EDPhosphatingAgentC 
                        Inner Join T_EDPhosphatingAgentC_Formula On T_EDPhosphatingAgentC.PAID = T_EDPhosphatingAgentC_Formula.PAID
                        Left Join T_EDPhosphatingAgentC_Report On T_EDPhosphatingAgentC.PAID = T_EDPhosphatingAgentC_Report.PAID
	                    Where T_EDPhosphatingAgentC.PAID=@PAID";

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

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPhosphatingAgentC"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            DateTime PADate = DateTime.Parse("1900/01/01");

            if (!DateTime.TryParse(TB_PADate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out PADate))
                PADate = DateTime.Parse("1900/01/01");

            if (PADate.Year < 1911)
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if (Util.ED.IsFormulaDateRepeat(PADate, false))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_F_DataRepeat"));

            // 至少要輸入一個參數
            if (string.IsNullOrEmpty(TB_Y001_Qty.Text.Trim()))
                throw new Exception((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));

            if (HF_IsNewData.Value.ToString().ToBoolean())
            {
                Query = @"Insert Into T_EDPhosphatingAgentC(PAID,PADate,CreateAccountID)Values(@PAID,@PADate,@CreateAccountID)";

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));
            }
            else
            {
                Query = @"Update T_EDPhosphatingAgentC Set ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where PAID = @PAID";

                dbcb.appendParameter(Schema.Attributes["ModifyAccountID"].copy(Master.AccountID));
            }

            string PAID = HF_PAID.Value.ToStringFromBase64();

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));
            dbcb.appendParameter(Schema.Attributes["PADate"].copy(PADate));

            DBA.AddCommandBuilder(dbcb);

            DBA.AddCommandBuilder(GetDelete_FormulaDBCB(PAID, L_Y001.Text.Trim()));
            DBA.AddCommandBuilder(GetCreate_FormulaDBCB(PAID, L_Y001.Text.Trim(), TB_Y001_Qty.Text.Trim(), TB_Y001_LotNumber.Text.Trim(), TB_Y001_Remark.Text.Trim()));

            DBA.AddCommandBuilder(Get_ReportDBCB());

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"),
                true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }

    protected DbCommandBuilder Get_ReportDBCB()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPhosphatingAgentC_Report"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        bool IsCreate = false;

        string Query = string.Empty;

        string PAID = HF_PAID.Value.ToStringFromBase64();

        IsCreate = HF_IsNewData.Value.ToBoolean();

        if (!IsCreate)
        {
            dbcb = new DbCommandBuilder("Select Count(*) From T_EDPhosphatingAgentC_Report Where PAID = @PAID");

            dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));

            IsCreate = (int)CommonDB.ExecuteScalar(dbcb) < 1;
        }

        if (IsCreate)
        {
            Query = @"Insert Into T_EDPhosphatingAgentC_Report(PAID,AgentDensityStandardMax,AgentDensityStandardMin,AgentDensity,
                          PHValueStandardMax,PHValueStandardMin,PHValue,ColorStatusStandard,ColorStatus,Remark,ResultID
                     )Values(
                         @PAID,@AgentDensityStandardMax,@AgentDensityStandardMin,@AgentDensity,
                         @PHValueStandardMax,@PHValueStandardMin,@PHValue,@ColorStatusStandard,@ColorStatus,@Remark,@ResultID
                    )";
        }
        else
        {
            Query = @"Update T_EDPhosphatingAgentC_Report Set AgentDensityStandardMax = @AgentDensityStandardMax,AgentDensityStandardMin = @AgentDensityStandardMin,AgentDensity = @AgentDensity,
                        PHValueStandardMax = @PHValueStandardMax,PHValueStandardMin = @PHValueStandardMin,PHValue = @PHValue,ColorStatusStandard = @ColorStatusStandard,ColorStatus = @ColorStatus,Remark = @Remark,ResultID = @ResultID Where PAID = @PAID";
        }

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));

        dbcb.appendParameter(Schema.Attributes["AgentDensityStandardMax"].copy(TB_AgentDensity.Attributes["MaxValue"].Trim()));

        dbcb.appendParameter(Schema.Attributes["AgentDensityStandardMin"].copy(TB_AgentDensity.Attributes["MinValue"].Trim()));

        decimal TempAgentDensity = -1;

        if (!decimal.TryParse(TB_AgentDensity.Text.Trim(), out TempAgentDensity))
            TempAgentDensity = -1;

        dbcb.appendParameter(Schema.Attributes["AgentDensity"].copy(TempAgentDensity));

        dbcb.appendParameter(Schema.Attributes["PHValueStandardMax"].copy(TB_PHValue.Attributes["MaxValue"].Trim()));

        dbcb.appendParameter(Schema.Attributes["PHValueStandardMin"].copy(TB_PHValue.Attributes["MinValue"].Trim()));

        decimal TempPHValue = -1;

        if (!decimal.TryParse(TB_PHValue.Text.Trim(), out TempPHValue))
            TempPHValue = -1;

        dbcb.appendParameter(Schema.Attributes["PHValue"].copy(TempPHValue));

        dbcb.appendParameter(Schema.Attributes["ColorStatusStandard"].copy(TB_ColorStatus.Attributes["ColorStatusStandard"].Trim()));

        dbcb.appendParameter(Schema.Attributes["ColorStatus"].copy(TB_ColorStatus.Text.Trim()));

        dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

        dbcb.appendParameter(Schema.Attributes["ResultID"].copy(DDL_EDResultID.SelectedValue.Trim()));

        return dbcb;
    }

    /// <summary>
    /// 指定磷化劑B配置ID、配方ID得到刪除增配置明細表DBCD
    /// </summary>
    /// <param name="PAID">磷化劑B配置ID</param>
    /// <param name="PACID">配方ID</param>
    /// <returns>刪除增配置明細表DBCD</returns>
    protected DbCommandBuilder GetDelete_FormulaDBCB(string PAID, string PACID)
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPhosphatingAgentC_Formula"];

        DbCommandBuilder dbcb = new DbCommandBuilder("Delete T_EDPhosphatingAgentC_Formula Where PAID = @PAID And PACID = @PACID");

        dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));
        dbcb.appendParameter(Schema.Attributes["PACID"].copy(PACID));

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
    protected DbCommandBuilder GetCreate_FormulaDBCB(string PAID, string PACID, string Qty, string LotNumber, string Remark)
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPhosphatingAgentC_Formula"];

        DbCommandBuilder dbcb = new DbCommandBuilder("Insert Into T_EDPhosphatingAgentC_Formula(PAID,PACID,Qty,LotNumber,Remark)Values(@PAID,@PACID,@Qty,@LotNumber,@Remark)");

        dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));
        dbcb.appendParameter(Schema.Attributes["PACID"].copy(PACID));

        decimal TempQty = -1;

        if (!decimal.TryParse(Qty, out TempQty))
            TempQty = -1;

        dbcb.appendParameter(Schema.Attributes["Qty"].copy(TempQty));
        dbcb.appendParameter(Schema.Attributes["LotNumber"].copy(LotNumber));
        dbcb.appendParameter(Schema.Attributes["Remark"].copy(Remark));

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

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPhosphatingAgentC"];

            string Query = @"Delete T_EDPhosphatingAgentC Where PAID = @PAID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_EDPhosphatingAgentC_Formula Where PAID = @PAID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_EDPhosphatingAgentC_Report Where PAID = @PAID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"),
                true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }

    }
}