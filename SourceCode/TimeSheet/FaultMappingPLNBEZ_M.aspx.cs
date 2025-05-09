using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_FaultMappingPLNBEZ_M : System.Web.UI.Page
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
            case "PLNBEZ":
                return (string)GetLocalResourceObject("Str_ColumnName_PLNBEZ");
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
            case "PLNBEZ":
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

        string Query = @"Select T_TSFaultMappingPLNBEZ.FaultCategoryID,T_TSFaultCategory.FaultCategoryName,T_TSFaultMappingPLNBEZ.PLNBEZ,Material.MAKTX 
                      From T_TSFaultCategory
                      Left Join T_TSFaultMappingPLNBEZ On T_TSFaultMappingPLNBEZ.FaultCategoryID = T_TSFaultCategory.FaultCategoryID
                      Left Join (Select MATNR,MAKTX　From T_TSSAPMAPL Group By MATNR,MAKTX) As Material On T_TSFaultMappingPLNBEZ.PLNBEZ = Material.MATNR
                      Where T_TSFaultCategory.FaultCategoryID = @FaultCategoryID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultCategory"];

        dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID.Value.Trim()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            TB_FaultCategoryName.Text = DT.Rows[0]["FaultCategoryName"].ToString();

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        string PLNBEZColumnName = "PLNBEZ";

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
            PLNBEZColumnName = PLNBEZColumnName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                PLNBEZ = Row["PLNBEZ"].ToString().Trim(),
                MAKTX = Row["MAKTX"].ToString().Trim()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
    }

    /// <summary>
    /// 取得故障分類是否有物料代碼
    /// </summary>
    /// <returns>是否有物料代碼</returns>
    protected bool IsExistsFaultCategoryIDMappingPLNBEZ()
    {
        string Query = @"Select Count(*) From T_TSFaultMappingPLNBEZ Where FaultCategoryID = @FaultCategoryID And PLNBEZ = @PLNBEZ";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultMappingPLNBEZ"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID.Value.Trim()));

        dbcb.appendParameter(Schema.Attributes["PLNBEZ"].copy(TB_PLNBEZ.Text.Trim()));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 取得是否有途程作業概觀使用的物料
    /// </summary>
    /// <returns>是否有途程作業概觀使用的物料</returns>
    protected bool IsExistsPLNBEZ()
    {
        string Query = @"Select Count(*) From T_TSSAPMAPL Where MATNR = @MATNR";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPMAPL"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["MATNR"].copy(TB_PLNBEZ.Text));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            //檢查Maping表是否有資料
            if (IsExistsFaultCategoryIDMappingPLNBEZ())
                throw new Exception((string)GetLocalResourceObject("Str_Exists_PLNBEZ"));

            //沒有不可以加
            if (!IsExistsPLNBEZ())
                throw new Exception((string)GetLocalResourceObject("Str_Empty_InMAPL"));

            string Query = string.Empty;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultMappingPLNBEZ"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            if (string.IsNullOrEmpty(HF_PLNBEZ_OLD.Value))
            {
                Query = @"Insert Into T_TSFaultMappingPLNBEZ(FaultCategoryID,PLNBEZ)Values(@FaultCategoryID,@PLNBEZ)";

                dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID.Value.Trim()));
                dbcb.appendParameter(Schema.Attributes["PLNBEZ"].copy(TB_PLNBEZ.Text.Trim()));
            }
            else
            {
                Query = @"Update T_TSFaultMappingPLNBEZ Set PLNBEZ = @NewPLNBEZ Where FaultCategoryID = @FaultCategoryID And PLNBEZ = @PLNBEZ";

                dbcb.appendParameter(Schema.Attributes["PLNBEZ"].copy(TB_PLNBEZ.Text.Trim(), "NewPLNBEZ"));
                dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID.Value.Trim()));
                dbcb.appendParameter(Schema.Attributes["PLNBEZ"].copy(HF_PLNBEZ_OLD.Value.Trim()));
            }

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
            if (!IsExistsFaultCategoryIDMappingPLNBEZ())
                throw new Exception((string)GetLocalResourceObject("Str_Empty_PLNBEZ"));

            DBAction DBA = new DBAction();

            string Query = @"Delete T_TSFaultMappingPLNBEZ Where FaultCategoryID = @FaultCategoryID And PLNBEZ = @PLNBEZ";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSFaultMappingPLNBEZ"];

            dbcb.appendParameter(Schema.Attributes["FaultCategoryID"].copy(HF_FaultCategoryID.Value.Trim()));

            dbcb.appendParameter(Schema.Attributes["PLNBEZ"].copy(TB_PLNBEZ.Text.Trim()));

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