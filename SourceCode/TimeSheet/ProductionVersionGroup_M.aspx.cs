using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_ProductionVersionGroup_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected override void OnPreRenderComplete(EventArgs e)
    {
        DataTable DT = LoadData();

        if (!IsPostBack)
        {
            if (DT.Rows.Count > 0)
            {
                TB_PVGroupName.Text = DT.Rows[0]["PVGroupName"].ToString().Trim();
                TB_SortID.Text = DT.Rows[0]["SortID"].ToString().Trim();
                DDL_ProcessType.SelectedValue = DT.Rows[0]["ProcessTypeID"].ToString().Trim();
            }
        }

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
            }),
            Rows = DT.AsEnumerable().Select(Row => new
            {
                MATNR = Row["MATNR"].ToString().Trim(),
                VERID = Row["VERID"].ToString().Trim(),
                TEXT1 = Row["TEXT1"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridPagerValue", "<script>var IsShowJQGridPagerValue='" + false.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelectValue", "<script>var IsMultiSelectValue='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");

        base.OnPreRenderComplete(e);
    }

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
                if (Request["ProductionVersionGroupID"] != null)
                    TB_PVGroupID.Text = Request["ProductionVersionGroupID"].Trim();

                HF_PVGroupID.Value = TB_PVGroupID.Text;

                HF_IsNewGroup.Value = string.IsNullOrEmpty(TB_PVGroupID.Text.Trim()).ToStringValue();

                DataTable DT = Util.GetCodeTypeData("TS_ProcessTypeID");

                DDL_ProcessType.DataValueField = "CodeID";

                DDL_ProcessType.DataTextField = "CodeName";

                DDL_ProcessType.DataSource = DT;

                DDL_ProcessType.DataBind();

                DDL_ProcessType.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
            }
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
    }

    /// <summary>
    /// 載入已設定資料
    /// </summary>
    /// <returns>已設定資料集</returns>
    private DataTable LoadData()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Query = @"Select T_TSProductionVersionGroup.PVGroupName,T_TSProductionVersionGroup.MATNR,T_TSProductionVersionGroup.VERID,T_TSSAPMKAL.TEXT1,T_TSProductionVersionGroup.ProcessTypeID,T_TSProductionVersionGroup.SortID
                From T_TSProductionVersionGroup Left Join T_TSSAPMKAL On T_TSProductionVersionGroup.MATNR = T_TSSAPMKAL.MATNR  And T_TSProductionVersionGroup.VERID = T_TSSAPMKAL.VERID
                Where T_TSProductionVersionGroup.PVGroupID = @PVGroupID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionVersionGroup"];

        bool IsCreate = HF_IsNewGroup.Value.ToBoolean();

        dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(IsCreate ? TB_PVGroupID.Text.Trim() : HF_PVGroupID.Value));

        dbcb.CommandText = Query;

        return CommonDB.ExecuteSelectQuery(dbcb);
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
            case "MATNR":
                return (string)GetLocalResourceObject("Str_ColumnName_MATNR");
            case "VERID":
                return (string)GetLocalResourceObject("Str_ColumnName_VERID");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            default:
                return ColumnName;
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
            case "MATNR":
                return 60;
            case "VERID":
                return 40;
            default:
                return 150;
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
            case "VERID":
                return "center";
            default:
                return "left";
        }
    }

    /// <summary>
    /// 指定ColumnName得到是否顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "PVGroupName":
            case "ProcessTypeID":
            case "SortID":
                return true;
            default:
                return false;
        }
    }


    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            bool IsCreate = HF_IsNewGroup.Value.ToBoolean();

            List<dynamic> PVL = Newtonsoft.Json.JsonConvert.DeserializeObject<List<dynamic>>(HF_PVL.Value);

            if (IsHaveRepeatPVGroupID(TB_PVGroupID.Text.Trim(), HF_PVGroupID.Value.Trim()))
            {
                TB_PVGroupID.Text = string.Empty;

                if (!IsCreate)
                    TB_PVGroupID.Text = HF_PVGroupID.Value.Trim();

                throw new Exception((string)GetLocalResourceObject("Str_Error_RepeatGroupID"));
            }

            DataTable DT = GetRepeatProductionVersionGroup(IsCreate ? TB_PVGroupID.Text.Trim() : HF_PVGroupID.Value.Trim(), PVL);

            if (DT.Rows.Count > 0)
            {
                string Message = (string)GetLocalResourceObject("Str_Error_RepeatProductionVersionList");

                Message += "<br>" + string.Join("<br>", DT.AsEnumerable().Select(Row => (string)GetLocalResourceObject("Str_PVGroupID") + " : " + Row["PVGroupID"].ToString().Trim() + " " + (string)GetLocalResourceObject("Str_ColumnName_MATNR") + " : " + Row["MATNR"].ToString().Trim() + " " + (string)GetLocalResourceObject("Str_ColumnName_VERID") + " : " + Row["VERID"].ToString().Trim()));

                throw new Exception(Message);
            }

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionVersionGroup"];

            //防呆用，避免UI沒有阻擋過重複選擇的資料。因此在寫入DB時候，跳除Jqgrid內的重複資料
            List<string> RecordList = new List<string>();

            string Query = string.Empty;

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            if (!IsCreate)
            {
                Query = @"Delete T_TSProductionVersionGroup Where PVGroupID = @PVGroupID";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(HF_PVGroupID.Value.Trim()));

                DBA.AddCommandBuilder(dbcb);
            }

            Query = @"Insert Into T_TSProductionVersionGroup (PVGroupID,MATNR,VERID,PVGroupName,ProcessTypeID,SortID) Values (@PVGroupID,@MATNR,@VERID,@PVGroupName,@ProcessTypeID,@SortID)";

            for (int i = 0; i < PVL.Count; i++)
            {
                if (RecordList.Contains(PVL[i].MATNR.ToString() + PVL[i].VERID.ToString()))
                    continue;

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(TB_PVGroupID.Text.Trim()));
                dbcb.appendParameter(Schema.Attributes["MATNR"].copy(PVL[i].MATNR.ToString()));
                dbcb.appendParameter(Schema.Attributes["VERID"].copy(PVL[i].VERID.ToString()));
                dbcb.appendParameter(Schema.Attributes["PVGroupName"].copy(TB_PVGroupName.Text.Trim()));
                dbcb.appendParameter(Schema.Attributes["ProcessTypeID"].copy(DDL_ProcessType.SelectedValue.Trim()));
                dbcb.appendParameter(Schema.Attributes["SortID"].copy(TB_SortID.Text.Trim()));

                DBA.AddCommandBuilder(dbcb);

                RecordList.Add(PVL[i].MATNR.ToString() + PVL[i].VERID.ToString());
            }

            Query = @"Update T_TSProductionTasks Set PVGroupID = @NewPVGroupID Where PVGroupID = @OldPVGroupID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(TB_PVGroupID.Text.Trim(), "NewPVGroupID"));

            dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(HF_PVGroupID.Value.Trim(), "OldPVGroupID"));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true, false);
        }
    }

    /// <summary>
    /// 指定新舊群組號碼是否有重複
    /// </summary>
    /// <param name="NewPVGroupID">新的群組號碼</param>
    /// <param name="OldPVGroupID">舊的群組號碼</param>
    protected bool IsHaveRepeatPVGroupID(string NewPVGroupID, string OldPVGroupID)
    {
        string Query = @"Select Count(*) From T_TSProductionVersionGroup Where PVGroupID <> @OldPVGroupID And PVGroupID = @NewPVGroupID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionVersionGroup"];

        dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(NewPVGroupID, "NewPVGroupID"));
        dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(OldPVGroupID, "OldPVGroupID"));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 指定群組號碼生產版本列表得到重複項目
    /// </summary>
    /// <param name="PVGroupID">群組號碼</param>
    /// <param name="PVL">產版本列表</param>
    protected DataTable GetRepeatProductionVersionGroup(string PVGroupID, List<dynamic> PVL)
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionVersionGroup"];

        //ED工種可以重複
        string Query = @"Select * From T_TSProductionVersionGroup Where ProcessTypeID <> '3' And PVGroupID <> @PVGroupID And ProcessTypeID = @ProcessTypeID And (MATNR + '-' + VERID) In (";

        dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(PVGroupID));

        dbcb.appendParameter(Schema.Attributes["ProcessTypeID"].copy(DDL_ProcessType.SelectedValue.Trim()));

        for (int i = 0; i < PVL.Count; i++)
        {
            string ParameterName = "ProductionVersion_" + i.ToString();

            if (i > 0)
                Query += ",";

            Query += "@" + ParameterName;

            dbcb.appendParameter(Util.GetDataAccessAttribute(ParameterName, "Nvarchar", 100, PVL[i].MATNR.ToString() + "-" + PVL[i].VERID.ToString()));
        }

        dbcb.CommandText = Query += ")";

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (IsHaveProductionTasksData())
                throw new Exception((string)GetLocalResourceObject("Str_Error_HaveTaskData"));

            string Query = @"Delete T_TSProductionVersionGroup Where PVGroupID = @PVGroupID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionVersionGroup"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(HF_PVGroupID.Value));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true, false);
        }
    }

    /// <summary>
    /// 取得是否有被生產任務資料表使用
    /// </summary>
    /// <returns>是否有被使用</returns>
    protected bool IsHaveProductionTasksData()
    {
        string Query = @"Select Count(*) From T_TSProductionTasks Where PVGroupID = @PVGroupID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionTasks"];

        dbcb.appendParameter(Schema.Attributes["PVGroupID"].copy(HF_PVGroupID.Value));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }
}