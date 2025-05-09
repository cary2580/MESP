using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_ProductionTaskList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
        {
            DateTime DateStart = DateTime.Parse("1900/01/01");

            DateTime DateEnd = DateTime.Now;

            if (Request["DateStart"] != null)
            {
                if (!DateTime.TryParse(Request["DateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out DateStart))
                    DateStart = DateTime.Parse("1900/01/01");
            }

            if (Request["DateEnd"] != null)
            {
                if (!DateTime.TryParse(Request["DateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out DateEnd))
                    DateEnd = DateTime.Parse("1900/01/01");
            }

            TB_TaskDateStart.Text = DateStart.ToCurrentUICultureString();

            TB_TaskDateEnd.Text = DateEnd.ToCurrentUICultureString();
        }

        HF_IsShowResultList.Value = false.ToStringValue();
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionTasks"];

        string Query = @"Select '' As TaskDateTimeValue,TaskDateTime,'' As PVGroupIDValue,PVGroupID,(Select Top 1 PVGroupName From T_TSProductionVersionGroup Where PVGroupID = T_TSProductionTasks.PVGroupID) As PVGroupName,TaskQtyByMonth,TaskQty,TaskQtyExtra From T_TSProductionTasks 
                        Where Datediff(day,@StartDate,TaskDateTime) >= 0 And Datediff(day,TaskDateTime,@EndDate) >= 0 ";

        if (!string.IsNullOrEmpty(TB_PVGroupID.Text.Trim()))
        {
            Query += " And PVGroupID = @PVGroupID";

            dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(TB_PVGroupID.Text.Trim()));
        }

        dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(DateTime.Parse(TB_TaskDateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "StartDate"));
        dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(DateTime.Parse(TB_TaskDateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "EndDate"));

        dbcb.CommandText = Query += " Order By TaskDateTime Desc,PVGroupID Asc";

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        var ResponseData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName),
                classes = Column.ColumnName == "PVGroupID" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            TaskDateTimeColumnName = "TaskDateTimeValue",
            PVGroupIDColumnName = "PVGroupIDValue",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                TaskDateTimeValue = ((DateTime)Row["TaskDateTime"]).ToCurrentUICultureString(),
                TaskDateTime = ((DateTime)Row["TaskDateTime"]).ToCurrentUICultureString(),
                PVGroupIDValue = Row["PVGroupID"].ToString().Trim(),
                PVGroupID = Row["PVGroupID"].ToString().Trim(),
                PVGroupName = Row["PVGroupName"].ToString().Trim(),
                TaskQtyByMonth = ((int)Row["TaskQtyByMonth"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                TaskQty = ((int)Row["TaskQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                TaskQtyExtra = ((int)Row["TaskQtyExtra"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture)
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelect", "<script>var IsMultiSelectValue='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

        HF_IsShowResultList.Value = true.ToStringValue();
    }

    /// <summary>
    /// 指定ColumnName得到是否影藏
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否影藏</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "TaskDateTimeValue":
            case "PVGroupIDValue":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 指定ColumnName得到對齊方式
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>對齊方式</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "TaskDateTime":
            case "PVGroupID":
            case "TaskQty":
            case "TaskQtyExtra":
            case "TaskQtyByMonth":
                return "center";
            default:
                return "left";
        }
    }

    /// <summary>
    /// 指定ColumnName得到欄位寬度
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>欄位寬度</returns>
    protected int GetWidth(string ColumnName)
    {
        switch (ColumnName)
        {
            case "TaskDateTime":
            case "PVGroupID":
            case "TaskQty":
            case "TaskQtyExtra":
            case "TaskQtyByMonth":
                return 80;
            default:
                return 250;
        }
    }

    /// <summary>
    /// 指定ColumnName得到顯示欄位名稱
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "TaskDateTime":
                return (string)GetLocalResourceObject("Str_ColumnName_TaskDateTime");
            case "PVGroupID":
                return (string)GetLocalResourceObject("Str_ColumnName_PVGroupID");
            case "PVGroupName":
                return (string)GetLocalResourceObject("Str_ColumnName_PVGroupName");
            case "TaskQty":
                return (string)GetLocalResourceObject("Str_ColumnName_TaskQty");
            case "TaskQtyExtra":
                return (string)GetLocalResourceObject("Str_ColumnName_TaskQtyExtra");
            case "TaskQtyByMonth":
                return (string)GetLocalResourceObject("Str_ColumnName_TaskQtyByMonth");
            default:
                return ColumnName;
        }
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            List<dynamic> TaskList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<dynamic>>(HF_DeleteProductionTasks.Value);

            DBAction DBA = new DBAction();

            string Query = @"Delete T_TSProductionTasks Where TaskDateTime = @TaskDateTime And PVGroupID = @PVGroupID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionTasks"];

            for (int i = 0; i < TaskList.Count; i++)
            {
                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TaskDateTime"].copy(DateTime.Parse(TaskList[i].TaskDateTime.ToString(), System.Threading.Thread.CurrentThread.CurrentUICulture)));
                dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(TaskList[i].PVGroupID.ToString()));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            HF_DeleteProductionTasks.Value = string.Empty;

            BT_Search_Click(null, null);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, false);
        }
    }
}