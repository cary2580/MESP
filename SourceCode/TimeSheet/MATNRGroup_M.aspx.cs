using System;
using System.Collections.Generic;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_MATNRGroup_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected override void OnPreRenderComplete(EventArgs e)
    {
        DataTable DT = LoadData();

        if (!IsPostBack)
        {
            if (DT.Rows.Count > 0)
            {
                TB_GroupName.Text = DT.Rows[0]["GroupName"].ToString().Trim();
                TB_SortID.Text = DT.Rows[0]["SortID"].ToString().Trim();
                DDL_Section.SelectedValue = DT.Rows[0]["SectionID"].ToString().Trim();
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
                MAKTX = Row["MAKTX"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridPagerValue", "<script>var IsShowJQGridPagerValue='" + true.ToStringValue() + "'</script>");

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
                if (Request["GroupID"] != null)
                    TB_GroupID.Text = Request["GroupID"].Trim();

                HF_GroupID.Value = TB_GroupID.Text;

                HF_IsNewGroup.Value = string.IsNullOrEmpty(TB_GroupID.Text.Trim()).ToStringValue();

                string Query = "Select SectionID,SectionName From V_TSSection Order By SortID";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

                DDL_Section.DataValueField = "SectionID";

                DDL_Section.DataTextField = "SectionName";

                DDL_Section.DataSource = DT;

                DDL_Section.DataBind();

                DDL_Section.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
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

        string Query = @"Select GroupName,MATNR,(Select Top 1 MAKTX From T_TSSAPMAPL Where T_TSSAPMAPL.MATNR = T_TSMATNRGroup.MATNR) As MAKTX,SectionID,SortID
                        From T_TSMATNRGroup
                        Where GroupID = @GroupID
                        Order By MATNR";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMATNRGroup"];

        bool IsCreate = HF_IsNewGroup.Value.ToBoolean();

        dbcb.appendParameter(Schema.Attributes["GroupID"].copy(IsCreate ? TB_GroupID.Text.Trim() : HF_GroupID.Value));

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
            case "MAKTX":
                return (string)GetLocalResourceObject("Str_ColumnName_MAKTX");
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
            case "MATNR":
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
            case "GroupName":
            case "SectionID":
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

            List<dynamic> GroupItemList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<dynamic>>(HF_GroupItem.Value);

            if (IsHaveRepeatGroupID(TB_GroupID.Text.Trim(), HF_GroupID.Value.Trim()))
            {
                TB_GroupID.Text = string.Empty;

                if (!IsCreate)
                    TB_GroupID.Text = HF_GroupID.Value.Trim();

                throw new Exception((string)GetLocalResourceObject("Str_Error_RepeatGroupID"));
            }

            DataTable DT = GetRepeatGroup(IsCreate ? TB_GroupID.Text.Trim() : HF_GroupID.Value.Trim(), GroupItemList);

            if (DT.Rows.Count > 0)
            {
                string Message = (string)GetLocalResourceObject("Str_Error_RepeatGroupList");

                Message += "<br>" + string.Join("<br>", DT.AsEnumerable().Select(Row => (string)GetLocalResourceObject("Str_GroupID") + " : " + Row["GroupID"].ToString().Trim() + " " + (string)GetLocalResourceObject("Str_ColumnName_MATNR") + " : " + Row["MATNR"].ToString().Trim() + " " + (string)GetLocalResourceObject("Str_ColumnName_MAKTX") + " : " + Row["MAKTX"].ToString().Trim()));

                throw new Exception(Message);
            }

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMATNRGroup"];

            //防呆用，避免UI沒有阻擋過重複選擇的資料。因此在寫入DB時候，跳除Jqgrid內的重複資料
            List<string> RecordList = new List<string>();

            string Query = string.Empty;

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            if (!IsCreate)
            {
                Query = @"Delete T_TSMATNRGroup Where GroupID = @GroupID";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["GroupID"].copy(HF_GroupID.Value.Trim()));

                DBA.AddCommandBuilder(dbcb);
            }

            Query = @"Insert Into T_TSMATNRGroup (GroupID,MATNR,GroupName,SectionID,SortID) Values (@GroupID,@MATNR,@GroupName,@SectionID,@SortID)";

            for (int i = 0; i < GroupItemList.Count; i++)
            {
                if (RecordList.Contains(GroupItemList[i].MATNR.ToString()))
                    continue;

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["GroupID"].copy(TB_GroupID.Text.Trim()));
                dbcb.appendParameter(Schema.Attributes["MATNR"].copy(GroupItemList[i].MATNR.ToString()));
                dbcb.appendParameter(Schema.Attributes["GroupName"].copy(TB_GroupName.Text.Trim()));
                dbcb.appendParameter(Schema.Attributes["SectionID"].copy(DDL_Section.SelectedValue.Trim()));
                dbcb.appendParameter(Schema.Attributes["SortID"].copy(TB_SortID.Text.Trim()));

                DBA.AddCommandBuilder(dbcb);

                RecordList.Add(GroupItemList[i].MATNR.ToString());
            }

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
    /// <param name="NewGroupID">新的群組號碼</param>
    /// <param name="OldGroupID">舊的群組號碼</param>
    protected bool IsHaveRepeatGroupID(string NewGroupID, string OldGroupID)
    {
        string Query = @"Select Count(*) From T_TSMATNRGroup Where GroupID <> @OldGroupID And GroupID = @NewGroupID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMATNRGroup"];

        dbcb.appendParameter(Schema.Attributes["GroupID"].copy(NewGroupID, "NewGroupID"));
        dbcb.appendParameter(Schema.Attributes["GroupID"].copy(OldGroupID, "OldGroupID"));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 指定群組號碼及群組物料列表得到重複項目
    /// </summary>
    /// <param name="GroupID">群組號碼</param>
    /// <param name="MATNRGroup">群組列表</param>
    protected DataTable GetRepeatGroup(string GroupID, List<dynamic> MATNRGroup)
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMATNRGroup"];

        string Query = @"Select *,(Select Top 1 MAKTX From T_TSSAPMAPL Where T_TSSAPMAPL.MATNR = T_TSMATNRGroup.MATNR) As MAKTX From T_TSMATNRGroup Where GroupID <> @GroupID And MATNR In (";

        dbcb.appendParameter(Schema.Attributes["GroupID"].copy(GroupID));

        for (int i = 0; i < MATNRGroup.Count; i++)
        {
            string ParameterName = "MATNR_" + i.ToString();

            if (i > 0)
                Query += ",";

            Query += "@" + ParameterName;

            dbcb.appendParameter(Util.GetDataAccessAttribute(ParameterName, "Nvarchar", 100, MATNRGroup[i].MATNR.ToString()));
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

            string Query = @"Delete T_TSMATNRGroup Where GroupID = @GroupID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSMATNRGroup"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["GroupID"].copy(HF_GroupID.Value));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true, false);
        }
    }
}