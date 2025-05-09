using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_ProductionTask_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (Request["DivID"] != null)
                DivID = Request["DivID"].Trim();

            if (!IsPostBack)
            {
                if (Request["IsInport"] != null)
                    HF_IsInport.Value = Request["IsInport"].Trim();
                if (Request["TaskDateTime"] != null)
                    TB_TaskDateTime.Text = Request["TaskDateTime"].Trim();
                if (Request["PVGroupID"] != null)
                    TB_PVGroupID.Text = Request["PVGroupID"].Trim();

                HF_TaskDateTime.Value = TB_TaskDateTime.Text;

                HF_PVGroupID.Value = TB_PVGroupID.Text;

                LoadData();

                if (HF_IsInport.Value.ToBoolean())
                    HF_DownloadFileFullPath.Value = Server.MapPath("~/TimeSheet/ReportTemplate/ProductionTasks.xlsx").ToBase64String(true);
            }
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        if (string.IsNullOrEmpty(HF_TaskDateTime.Value) || string.IsNullOrEmpty(HF_PVGroupID.Value))
            return;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionTasks"];

        string Query = @"Select TaskQty,TaskQtyExtra,TaskQtyByMonth,(Select Top 1 PVGroupName From T_TSProductionVersionGroup Where T_TSProductionVersionGroup.PVGroupID = @PVGroupID) As PVGroupName From T_TSProductionTasks Where TaskDateTime = @TaskDateTime And PVGroupID = @PVGroupID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(DateTime.Parse(HF_TaskDateTime.Value.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));

        dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(HF_PVGroupID.Value.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            TB_TaskQty.Text = DT.Rows[0]["TaskQty"].ToString().Trim();

            TB_TaskQtyExtra.Text = DT.Rows[0]["TaskQtyExtra"].ToString().Trim();

            TB_TaskQtyByMonth.Text = DT.Rows[0]["TaskQtyByMonth"].ToString().Trim();

            TB_PVGroupName.Text = DT.Rows[0]["PVGroupName"].ToString().Trim();
        }
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionTasks"];

            string Query = @"Delete T_TSProductionTasks Where TaskDateTime = @TaskDateTime And PVGroupID = @PVGroupID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            var TaskDateTimeString = string.IsNullOrEmpty(HF_TaskDateTime.Value.Trim()) ? string.Empty : DateTime.Parse(HF_TaskDateTime.Value.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture).ToDefaultString();

            dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(TaskDateTimeString));

            dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(HF_PVGroupID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(DateTime.Parse(TB_TaskDateTime.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));

            dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(TB_PVGroupID.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Insert Into T_TSProductionTasks (TaskDateTime,PVGroupID,TaskQty,TaskQtyExtra,TaskQtyByMonth) Values (@TaskDateTime,@PVGroupID,@TaskQty,@TaskQtyExtra,@TaskQtyByMonth)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(DateTime.Parse(TB_TaskDateTime.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));

            dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(TB_PVGroupID.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["TaskQty"].copy(TB_TaskQty.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["TaskQtyExtra"].copy(TB_TaskQtyExtra.Text.Trim()));

            dbcb.appendParameter(Schema.Attributes["TaskQtyByMonth"].copy(TB_TaskQtyByMonth.Text.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true, false);
        }
    }

    protected void BT_UpLoad_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!FU_File.HasFile)
            return;

        try
        {
            Spire.Xls.Workbook WB = new Spire.Xls.Workbook();

            WB.LoadFromStream(FU_File.PostedFile.InputStream);

            if (WB.Worksheets.Count < 1)
                throw new Exception((string)GetLocalResourceObject("Str_ErrorTemplate"));

            //指定到第一個試算表
            Spire.Xls.Worksheet Sheet = WB.Worksheets[0];

            DataTable DT = Sheet.ExportDataTable();

            if (DT.Rows.Count > 3000)
                throw new Exception((string)GetLocalResourceObject("Str_ErrorInportRowsOver"));

            List<string> NoExistPVGroupID = GetNoExistPVGroupID(DT.AsEnumerable().Select(Row => Row[1].ToString()).ToList());

            if (NoExistPVGroupID.Count > 0)
            {
                string Message = (string)GetLocalResourceObject("Str_ErrorInportNoExistPVGroupID");

                Message += "<br>" + string.Join("<br>", NoExistPVGroupID.Select(PVGroupID => PVGroupID));

                throw new Exception(Message);
            }

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionTasks"];

            foreach (DataRow Row in DT.Rows)
            {
                DateTime TaskDateTime = DateTime.Parse("1900/01/01");

                if (!DateTime.TryParse(Row[0].ToString().Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out TaskDateTime))
                    TaskDateTime = DateTime.Parse("1900/01/01");

                if (TaskDateTime.Year < 1911)
                    throw new Exception((string)GetLocalResourceObject("Str_ErrorInportTaskDateTime") + "<br>" + Row[0].ToString().Trim());

                double TaskQtyByMonth = 0;

                double TaskQtyExtra = 0;

                string Query = string.Empty;

                DbCommandBuilder dbcb = new DbCommandBuilder();

                if (!double.TryParse(Row[2].ToString().Trim(), out TaskQtyByMonth))
                    throw new Exception((string)GetLocalResourceObject("Str_ErrorInportTaskQtyByMonth") + "<br>" + Row[2].ToString().Trim());

                if (TaskQtyByMonth == 0)
                {
                    Query = @"Select * From T_TSProductionTasks Where TaskDateTime = @TaskDateTime And PVGroupID = @PVGroupID";

                    dbcb = new DbCommandBuilder(Query);

                    dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(TaskDateTime));

                    dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(Row[1].ToString().Trim()));

                    DataTable ProductionTasks_DT = CommonDB.ExecuteSelectQuery(dbcb);

                    if (ProductionTasks_DT.Rows.Count > 0)
                    {
                        TaskQtyExtra = (int)ProductionTasks_DT.Rows[0]["TaskQtyExtra"];

                        TaskQtyByMonth = (int)ProductionTasks_DT.Rows[0]["TaskQtyByMonth"];
                    }
                }

                double TaskQty = 0;

                if (!double.TryParse(Row[3].ToString().Trim(), out TaskQty))
                    throw new Exception((string)GetLocalResourceObject("Str_ErrorInportTaskQty") + "<br>" + Row[3].ToString().Trim());

                Query = @"Delete T_TSProductionTasks Where TaskDateTime = @TaskDateTime And PVGroupID = @PVGroupID";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(TaskDateTime));

                dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(Row[1].ToString().Trim()));

                DBA.AddCommandBuilder(dbcb);

                Query = @"Insert Into T_TSProductionTasks (TaskDateTime,PVGroupID,TaskQty,TaskQtyExtra,TaskQtyByMonth) Values (@TaskDateTime,@PVGroupID,@TaskQty,@TaskQtyExtra,@TaskQtyByMonth)";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(TaskDateTime));

                dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(Row[1].ToString().Trim()));

                //四舍五入
                dbcb.appendParameter(Schema.Attributes["TaskQty"].copy(Math.Round(TaskQty, MidpointRounding.AwayFromZero)));

                dbcb.appendParameter(Schema.Attributes["TaskQtyExtra"].copy(Math.Round(TaskQtyExtra, MidpointRounding.AwayFromZero)));

                dbcb.appendParameter(Schema.Attributes["TaskQtyByMonth"].copy(Math.Round(TaskQtyByMonth, MidpointRounding.AwayFromZero)));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_InportSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true, false);
        }
    }

    /// <summary>
    /// 指定群組號碼得到不存在資料庫的群組號
    /// </summary>
    /// <param name="PVGroupIDs">群組號碼</param>
    /// <returns>不存在資料庫的群組號</returns>
    protected List<string> GetNoExistPVGroupID(List<string> PVGroupIDs)
    {
        string Query = @"Select PVGroupID From T_TSProductionVersionGroup Where PVGroupID In (";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionVersionGroup"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        for (int i = 0; i < PVGroupIDs.Count; i++)
        {
            string ParameterName = "PVGroupID_" + i.ToString();

            if (i > 0)
                Query += ",@" + ParameterName;
            else
                Query += "@" + ParameterName;

            dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(PVGroupIDs[i], ParameterName));
        }

        dbcb.CommandText = Query += ") Group By PVGroupID";

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        return PVGroupIDs.Where(Items => DT.AsEnumerable().All(Row => Row["PVGroupID"].ToString() != Items)).ToList();
    }
}