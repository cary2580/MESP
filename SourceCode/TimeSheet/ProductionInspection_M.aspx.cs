using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_ProductionInspection_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (Request["PIID"] != null)
            HF_PIID.Value = Request["PIID"].Trim();

        if (Request["TicketID"] != null)
            HF_TicketID.Value = Request["TicketID"].Trim();

        if (string.IsNullOrEmpty(TB_InspectionDate.Text))
            TB_InspectionDate.Text = DateTime.Now.ToCurrentUICultureStringTime();

        if (!IsPostBack)
            LoadData();
    }

    protected void LoadData()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspection"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Query = string.Empty;

        if (!string.IsNullOrEmpty(HF_PIID.Value))
        {
            Query = @"Select * From T_TSProductionInspection Where PIID = @PIID";

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));
        }
        else
        {
            Query = @"Select * From T_TSProductionInspection Where TicketID = @TicketID";

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(HF_TicketID.Value.Trim()));
        }

        dbcb.CommandText = Query;

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_Error_NoProductionInspectionData"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }

        HF_PIID.Value = DT.Rows[0]["PIID"].ToString().Trim();

        HF_TicketID.Value = DT.Rows[0]["TicketID"].ToString().Trim();
    }

    protected void BT_Save_Click(object sender, EventArgs e)
    {
        try
        {
            int CreateAccountID = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

            if (CreateAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(CreateAccountID))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            DBAction DBA = new DBAction();

            string Query = @"Delete From T_TSProductionInspectionNGItem Where PIID = @PIID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspection"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Update T_TSProductionInspection Set NGQty = 0,InspectionResult = '2',InspectionDate = @InspectionDate,InspectionAccountID = @InspectionAccountID Where PIID = @PIID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));

            dbcb.appendParameter(Schema.Attributes["InspectionDate"].copy(DateTime.Parse(TB_InspectionDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));

            dbcb.appendParameter(Schema.Attributes["InspectionAccountID"].copy(CreateAccountID));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            HF_IsRefresh.Value = true.ToStringValue();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            TB_InspectionDate.Text = DateTime.Now.ToCurrentUICultureStringTime();
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);
        }
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            int CreateAccountID = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

            if (CreateAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(CreateAccountID))
                throw new Exception((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            CheckNGItemRule();

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspectionNGItem"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            string Query = string.Empty;

            if (string.IsNullOrEmpty(HF_SerialNo.Value))
            {
                Query = @"Insert Into T_TSProductionInspectionNGItem (PIID,SerialNo,NGQty,InspectionDate,InspectionAccountID,HandlingMethods,ReferenceNumber,TraceQty,DefectQty,Remark) 
                            Values (@PIID,IsNull((Select Max(SerialNo) + 1 From T_TSProductionInspectionNGItem Where PIID = @PIID),1),@NGQty,@InspectionDate,@InspectionAccountID,@HandlingMethods,@ReferenceNumber,@TraceQty,@DefectQty,@Remark)";
            }
            else
            {
                Query = @"Update T_TSProductionInspectionNGItem Set InspectionAccountID = @InspectionAccountID,NGQty = @NGQty,InspectionDate = @InspectionDate,HandlingMethods = @HandlingMethods,ReferenceNumber = @ReferenceNumber,TraceQty = @TraceQty,DefectQty = @DefectQty,Remark = @Remark
                        Where PIID = @PIID And SerialNo = @SerialNo";

                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(HF_SerialNo.Value.Trim()));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));
            dbcb.appendParameter(Schema.Attributes["NGQty"].copy(TB_NGQty.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["InspectionDate"].copy(DateTime.Parse(TB_InspectionDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));
            dbcb.appendParameter(Schema.Attributes["InspectionAccountID"].copy(CreateAccountID));
            dbcb.appendParameter(Schema.Attributes["HandlingMethods"].copy(TB_HandlingMethods.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["ReferenceNumber"].copy(TB_ReferenceNumber.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["TraceQty"].copy(TB_TraceQty.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["DefectQty"].copy(TB_DefectQty.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Update T_TSProductionInspection Set NGQty = IsNull((Select Sum(NGQty) From T_TSProductionInspectionNGItem Where PIID = @PIID),0),InspectionDate = @InspectionDate,InspectionAccountID = @InspectionAccountID,InspectionResult = '3' Where PIID = @PIID";

            Schema = DBSchema.currentDB.Tables["T_TSProductionInspection"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));
            dbcb.appendParameter(Schema.Attributes["NGQty"].copy(TB_NGQty.Text.Trim()));
            dbcb.appendParameter(Schema.Attributes["InspectionDate"].copy(DateTime.Parse(TB_InspectionDate.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));
            dbcb.appendParameter(Schema.Attributes["InspectionAccountID"].copy(CreateAccountID));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            HF_SerialNo.Value = string.Empty;

            HF_IsRefresh.Value = true.ToStringValue();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_SubmitSuccessAlertMessage"), true, false);

            TB_InspectionDate.Text = DateTime.Now.ToCurrentUICultureStringTime();
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);
        }
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspectionNGItem"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            string Query = string.Empty;

            foreach (string SerialNo in HF_SerialNo.Value.Split('|'))
            {
                dbcb = new DbCommandBuilder();

                Query = @"Delete T_TSProductionInspectionNGItem Where PIID = @PIID And SerialNo = @SerialNo";

                dbcb.CommandText = Query;

                dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));
                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(SerialNo));

                DBA.AddCommandBuilder(dbcb);
            }

            dbcb = new DbCommandBuilder();

            Query = @"Update T_TSProductionInspection Set NGQty = IsNull((Select Sum(NGQty) From T_TSProductionInspectionNGItem Where PIID = @PIID),0) Where PIID = @PIID";

            dbcb.CommandText = Query;
            dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            dbcb = new DbCommandBuilder();
            Query = @"Update T_TSProductionInspection Set InspectionDate = Case When NGQty < 1 Then '1900/01/01' Else InspectionDate End,InspectionAccountID = Case When NGQty < 1 Then -1 Else InspectionAccountID End,InspectionResult = Case When NGQty < 1 Then '1' Else InspectionResult End
                     Where PIID = @PIID";

            dbcb.CommandText = Query;
            dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            DBA = new DBAction();

            /* 下列動作是為了重新編排排序序號 */
            dbcb = new DbCommandBuilder("Select * From T_TSProductionInspectionNGItem Where PIID = @PIID Order By InspectionDate Asc");

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            var DI = DT.ToDictionary();

            for (int i = 0; i < DI.Count; i++)
            {
                dbcb = new DbCommandBuilder("Update T_TSProductionInspectionNGItem Set SerialNo = @SerialNo Where PIID = @PIID And SerialNo = @OriginalSerialNo");

                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(i + 1));

                dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));

                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(DI[i]["SerialNo"], "OriginalSerialNo"));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            HF_SerialNo.Value = string.Empty;

            HF_IsRefresh.Value = true.ToStringValue();

            TB_InspectionDate.Text = DateTime.Now.ToCurrentUICultureStringTime();
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);
        }
    }

    protected void CheckNGItemRule()
    {
        string Query = @"Select InspectionQty,IsNull((Select Sum(NGQty) From T_TSProductionInspectionNGItem Where PIID = @PIID And SerialNo <> @SerialNo),0) As NGQty From T_TSProductionInspection Where PIID = @PIID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspectionNGItem"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));
        dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(HF_SerialNo.Value.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new Exception((string)GetLocalResourceObject("Str_Error_NoProductionInspectionData"));

        int InspectionQty = (int)DT.Rows[0]["InspectionQty"];
        int NGQty = (int)DT.Rows[0]["NGQty"];
        int NGQtyByCurr = int.Parse(TB_NGQty.Text.Trim());

        if ((NGQty + NGQtyByCurr) > InspectionQty)
            throw new Exception((string)GetLocalResourceObject("Str_Error_NGQtyOverInspectionQty"));
    }

    protected void BT_DeleteAllData_Click(object sender, EventArgs e)
    {
        try
        {
            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspection"];

            string Query = @"Delete T_TSProductionInspectionNGItem Where PIID = @PIID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_TSProductionInspection Where PIID = @PIID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(HF_PIID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            HF_IsRefresh.Value = true.ToStringValue();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message);
        }
    }
}