using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;


public partial class TimeSheet_DeviceArea : System.Web.UI.Page
{
    protected string DeviceID = string.Empty;

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        if (!Master.IsAccountVerificationPass)
            return;

        LoadData();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (Request["DeviceID"] != null)
            DeviceID = Request["DeviceID"].Trim();
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select AreaID,AreaName From T_TSArea Order By SortID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_AreaID.DataValueField = "AreaID";

        DDL_AreaID.DataTextField = "AreaName";

        DDL_AreaID.DataSource = DT;

        DDL_AreaID.DataBind();

        DDL_AreaID.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceArea"];

        Query = @"Select T_TSArea.AreaID,AreaName From T_TSDeviceArea Inner Join T_TSArea On T_TSDeviceArea.AreaID = T_TSArea.AreaID Where T_TSDeviceArea.DeviceID = @DeviceID";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

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
                hidden = GetIsHidden(Column.ColumnName)
            }),
            AreaIDColumnName = "AreaID",
            Rows = DT.AsEnumerable().Select(Row => new
            {
                AreaID = Row["AreaID"].ToString().Trim(),
                AreaName = Row["AreaName"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelectValue", "<script>var IsMultiSelectValue='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
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
            case "AreaID":
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
            default:
                return 50;
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
            case "AreaName":
                return (string)GetLocalResourceObject("Str_ColumnName_AreaName");
            default:
                return ColumnName;
        }
    }

    protected void BT_Add_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceArea"];

            string Query = @"Delete T_TSDeviceArea Where AreaID = @AreaID And DeviceID = @DeviceID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["AreaID"].copy(DDL_AreaID.SelectedValue));

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Insert Into T_TSDeviceArea (DeviceID,AreaID) Values (@DeviceID,@AreaID)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

            dbcb.appendParameter(Schema.Attributes["AreaID"].copy(DDL_AreaID.SelectedValue));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_CreateSuccessAlertMessage"), true);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true);
        }
    }

    protected void BT_Delete_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceArea"];

            List<string> AreaIDList = HF_DeleteAreaID.Value.Split('|').ToList();

            foreach (string AreaID in AreaIDList)
            {
                string Query = @"Delete T_TSDeviceArea Where DeviceID = @DeviceID And AreaID = @AreaID";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

                dbcb.appendParameter(Schema.Attributes["AreaID"].copy(AreaID));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(this, ex.Message, true, true);
        }
    }
}