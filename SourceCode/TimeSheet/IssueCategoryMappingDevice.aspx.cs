using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_IssueCategoryMappingDevice : System.Web.UI.Page
{
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        if (Request["CategoryID"] != null)
            HF_CategoryID.Value = Request["CategoryID"].Trim();

        if (!Master.IsAccountVerificationPass)
            return;

        HF_DeviceID.Value = string.Empty;

        TB_MachineName.Text = string.Empty;

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
        string Query = @"Select 
                            T_TSIssueCategory.CategoryName,
                            T_TSDevice.DeviceID,
                            T_TSDevice.MachineID,
                            T_TSDevice.MachineName
                        From T_TSIssueCategory
                        Inner Join T_TSIssueCategoryDevice On T_TSIssueCategoryDevice.CategoryID = T_TSIssueCategory.CategoryID
                        Inner Join T_TSDevice On T_TSDevice.DeviceID = T_TSIssueCategoryDevice.DeviceID
                        Where T_TSIssueCategory.CategoryID = @CategoryID
                        Order By T_TSDevice.SortID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueCategory"];

        dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(HF_CategoryID.Value.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            TB_CategoryName.Text = DT.Rows[0]["CategoryName"].ToString();

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
            DeviceIDColumnName = "DeviceID",
            MachineNameColumnName = "MachineName",
            Rows = DT.AsEnumerable().Select(Row => new
            {
                DeviceID = Row["DeviceID"].ToString().Trim(),
                MachineID = Row["MachineID"].ToString().Trim(),
                MachineName = Row["MachineName"].ToString().Trim(),
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
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
            default:
                return 100;
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
            case "MachineID":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineID");
            case "MachineName":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineName");
            default:
                return ColumnName;
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
            default:
                return "center";
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
            case "DeviceID":
            case "CategoryName":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 取得分類是否有設備代碼
    /// </summary>
    /// <returns>是否有設備代碼</returns>
    protected bool IsExistsCategoryIDMappingDeviceID()
    {
        string Query = @"Select Count(*) From T_TSIssueCategoryDevice Where CategoryID = @CategoryID And DeviceID = @DeviceID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueCategoryDevice"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(HF_CategoryID.Value.Trim()));

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            //檢查Maping表是否有資料
            if (!IsExistsCategoryIDMappingDeviceID())
            {
                string Query = @"Insert Into T_TSIssueCategoryDevice (CategoryID,DeviceID) Values (@CategoryID,@DeviceID)";

                ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueCategoryDevice"];

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(HF_CategoryID.Value.Trim()));

                dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

                dbcb.CommandText = Query;

                CommonDB.ExecuteSingleCommand(dbcb);
            }

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
            string Query = @"Delete T_TSIssueCategoryDevice Where CategoryID = @CategoryID And DeviceID = @DeviceID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueCategoryDevice"];

            dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(HF_CategoryID.Value.Trim()));

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(HF_DeviceID.Value.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, true);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true);
        }
    }
}