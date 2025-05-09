using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
public partial class TimeSheet_FaultMapping_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!Master.IsAccountVerificationPass)
            return;

        LoadData();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
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
            case "FaultID":
                return (string)GetLocalResourceObject("Str_ColumnName_FaultID");
            case "FaultName":
                return (string)GetLocalResourceObject("Str_ColumnName_FaultName");
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
            case "FaultID":
                return 50;
            default:
                return 100;
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
            case "FaultCategoryID":
            case "FaultID":
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
            case "FaultCategoryID":
            case "FaultCategoryName":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        if (Request["FaultCategoryID"] != null)
            HF_FaultCategoryID.Value = Request["FaultCategoryID"].Trim().ToStringFromBase64(true);

        if (string.IsNullOrEmpty(HF_FaultCategoryID.Value))
            throw new Exception((string)GetLocalResourceObject("Str_Empty_FaultCategoryID"));

        string Query = @"Select T_TSFaultMapping.FaultCategoryID,T_TSFaultCategory.FaultCategoryName,T_TSFaultMapping.FaultID,T_TSFault.FaultName 
                      From T_TSFaultCategory
                      Left Join T_TSFaultMapping On T_TSFaultMapping.FaultCategoryID = T_TSFaultCategory.FaultCategoryID
                      Left Join T_TSFault On T_TSFaultMapping.FaultID = T_TSFault.FaultID
                      Where T_TSFaultCategory.FaultCategoryID = @FaultCategoryID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultCategory"];

        dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID.Value.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            TB_FaultCategoryName.Text = DT.Rows[0]["FaultCategoryName"].ToString();

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        string FaultIDColumnName = "FaultID";

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
            FaultIDColumnName = FaultIDColumnName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                FaultID = Row["FaultID"].ToString().Trim(),
                FaultName = Row["FaultName"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
    }

    /// <summary>
    /// 取得是否有故障代碼
    /// </summary>
    /// <returns>是否有故障代碼</returns>
    protected bool IsExistsFaultID()
    {
        string Query = @"Select Count(*) From T_TSFault Where FaultID = @FaultID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFault"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["FaultID"].copy(TB_FaultID.Text));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 取得故障分類是否有故障代碼
    /// </summary>
    /// <returns>是否有故障代碼</returns>
    protected bool IsExistsFaultCategoryIDMappingFaultID()
    {
        string Query = @"Select Count(*) From T_TSFaultMapping Where FaultCategoryID = @FaultCategoryID And FaultID = @FaultID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultMapping"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID.Value.Trim()));

        dbcb.appendParameter(Schema.Attributes["FaultID"].copy(TB_FaultID.Text.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            //檢查Maping表是否有資料
            if (IsExistsFaultCategoryIDMappingFaultID())
                throw new Exception((string)GetLocalResourceObject("Str_Exists_FaultID"));

            //沒有不可以加
            if (!IsExistsFaultID())
                throw new Exception((string)GetLocalResourceObject("Str_Empty_FaultID"));

            string Query = @"Insert Into T_TSFaultMapping(FaultCategoryID,FaultID)Values(@FaultCategoryID,@FaultID)";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultMapping"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            if (string.IsNullOrEmpty(HF_FaultID_OLD.Value))
            {
                Query = @"Insert Into T_TSFaultMapping(FaultCategoryID,FaultID)Values(@FaultCategoryID,@FaultID)";

                dbcb.appendParameter(Schema.Attributes["FaultID"].copy(TB_FaultID.Text.Trim()));
            }               
            else
            {
                Query = @"Update T_TSFaultMapping Set FaultID = @NewFaultID Where FaultCategoryID = @FaultCategoryID And FaultID = @FaultID";

                dbcb.appendParameter(Schema.Attributes["FaultID"].copy(TB_FaultID.Text.Trim(), "NewFaultID"));

                dbcb.appendParameter(Schema.Attributes["FaultID"].copy(HF_FaultID_OLD.Value.Trim()));
            }

            dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID.Value.Trim()));

            dbcb.CommandText = Query;

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, true);
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
            //不存在要跳提示
            if (!IsExistsFaultCategoryIDMappingFaultID())
                throw new Exception((string)GetLocalResourceObject("Str_Empty_FaultID"));

            DBAction DBA = new DBAction();

            string Query = @"Delete T_TSFaultMapping Where FaultCategoryID = @FaultCategoryID And FaultID = @FaultID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultMapping"];

            dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID.Value.Trim()));

            dbcb.appendParameter(Schema.Attributes["FaultID"].copy(TB_FaultID.Text.Trim()));

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