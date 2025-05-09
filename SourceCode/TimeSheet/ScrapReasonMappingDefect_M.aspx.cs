using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
public partial class TimeSheet_ScrapReasonMappingDefect_M : System.Web.UI.Page
{
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        if (Request["DivID"] != null)
            HF_DivID.Value = Request["DivID"].Trim();

        if (!Master.IsAccountVerificationPass)
            return;

        LoadData();
    }

    protected void Page_Load(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        if (Request["ScrapReasonID"] != null)
            HF_ScrapReasonID.Value = Request["ScrapReasonID"].Trim();

        if (Request["ScrapReasonName"] != null)
            TB_ScrapReasonName.Text = Request["ScrapReasonName"].ToStringFromBase64();

        if (string.IsNullOrEmpty(HF_ScrapReasonID.Value))
            throw new Exception((string)GetLocalResourceObject("Str_Empty_ScrapReasonID"));

        string Query = @"Select '' As DefectIDValue,DefectID,DefectName From T_TSDefect Where DefectID In ( Select DefectID From T_TSScrapReasonMappingDefect Where ScrapReasonID = @ScrapReasonID)";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSScrapReasonMappingDefect"];

        dbcb.appendParameter(Schema.Attributes["ScrapReasonID"].copy(HF_ScrapReasonID.Value.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        string DefectIDColumnName = "DefectIDValue";

        var ResponseData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName)
            }),
            DefectIDColumnName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                DefectIDValue = Row["DefectID"].ToString().Trim(),
                DefectID = Row["DefectID"].ToString().Trim(),
                DefectName = Row["DefectName"].ToString().Trim(),
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
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
            case "DefectID":
                return (string)GetLocalResourceObject("Str_ColumnName_DefectID");
            case "DefectName":
                return (string)GetLocalResourceObject("Str_ColumnName_DefectName");
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
            case "DefectID":
                return 80;
            default:
                return 250;
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
            case "DefectID":
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
            case "DefectIDValue":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 取得報廢原因是否有缺陷代碼
    /// </summary>
    /// <returns>是否有缺陷代碼</returns>
    protected bool IsExistsScrapReasonIDHaveDefectID()
    {
        string Query = @"Select Count(*) From T_TSScrapReasonMappingDefect Where ScrapReasonID = @ScrapReasonID And DefectID = @DefectID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSScrapReasonMappingDefect"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ScrapReasonID"].copy(HF_ScrapReasonID.Value));
        dbcb.appendParameter(Schema.Attributes["DefectID"].copy(TB_DefectID.Text));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 取得是否有缺陷代碼
    /// </summary>
    /// <returns>是否有缺陷代碼</returns>
    protected bool IsExistsDefectID()
    {
        string Query = @"Select Count(*) From T_TSDefect Where DefectID = @DefectID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDefect"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DefectID"].copy(TB_DefectID.Text));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            //檢查Maping表是否有資料
            if (IsExistsScrapReasonIDHaveDefectID())
                throw new Exception((string)GetLocalResourceObject("Str_Exists_DefectID"));

            //沒有不可以加
            if (!IsExistsDefectID())
                throw new Exception((string)GetLocalResourceObject("Str_Empty_DefectID"));

            string Query = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSScrapReasonMappingDefect"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            Query = @"Insert Into T_TSScrapReasonMappingDefect(ScrapReasonID,DefectID)Values(@ScrapReasonID,@DefectID)";

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["ScrapReasonID"].copy(HF_ScrapReasonID.Value.Trim()));
            dbcb.appendParameter(Schema.Attributes["DefectID"].copy(TB_DefectID.Text.Trim()));

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
            //檢查Maping表是否有資料，沒資料要跳提示
            if (!IsExistsScrapReasonIDHaveDefectID())
                throw new Exception((string)GetLocalResourceObject("Str_Empty_DefectID"));

            string Query = @"Delete T_TSScrapReasonMappingDefect Where ScrapReasonID = @ScrapReasonID And DefectID = @DefectID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSScrapReasonMappingDefect"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["ScrapReasonID"].copy(HF_ScrapReasonID.Value));
            dbcb.appendParameter(Schema.Attributes["DefectID"].copy(TB_DefectID.Text));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}