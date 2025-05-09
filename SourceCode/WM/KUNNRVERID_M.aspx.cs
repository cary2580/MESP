using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class WM_KUNNRVERID_M : System.Web.UI.Page
{
    protected string DivID = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["KUNNR"] != null)
            {
                TB_KUNNR.Text = Request["KUNNR"].Trim();
                TB_KUNNR_Name.Text = Request["KUNNR_Name"].Trim();
                HF_KUNNR.Value = Request["KUNNR"].Trim();
            }
                
            DataTable DT = LoadData();

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
                }),
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    MATNR = Row["MATNR"].ToString().Trim(),
                    VERID = Row["VERID"].ToString().Trim(),
                    TEXT1 = Row["TEXT1"].ToString().Trim()
                })
            };

            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelect", "<script>var IsMultiSelectValue='" + true.ToStringValue() + "';</script>");

            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

            Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
        }
    }

    /// <summary>
    /// 載入已設定資料
    /// </summary>
    /// <returns>已設定資料集</returns>
    private DataTable LoadData()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMKUNNRVERID"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Query = @"Select 
                            T_WMKUNNRVERID.MATNR,
                            T_WMKUNNRVERID.VERID,
                            T_TSSAPMKAL.TEXT1
                            From T_WMKUNNRVERID Inner Join T_TSSAPMKAL On T_TSSAPMKAL.MATNR = T_WMKUNNRVERID.MATNR  And T_TSSAPMKAL.VERID = T_WMKUNNRVERID.VERID
                            Where T_WMKUNNRVERID.KUNNRID = @KUNNRID";

        dbcb.appendParameter(Schema.Attributes["KUNNRID"].copy(HF_KUNNR.Value));

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

    protected void BT_Submit_Click(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            List<dynamic> PVL = Newtonsoft.Json.JsonConvert.DeserializeObject<List<dynamic>>(HF_PVL.Value);

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMKUNNRVERID"];

            //防呆用，避免UI沒有阻擋過重複選擇的資料。因此在寫入DB時候，跳除Jqgrid內的重複資料
            List<string> RecordList = new List<string>();

            string Query = string.Empty;

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            Query = @"Delete T_WMKUNNRVERID Where KUNNRID = @KUNNRID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["KUNNRID"].copy(HF_KUNNR.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Insert Into T_WMKUNNRVERID (KUNNRID,MATNR,VERID,VERIDShort) Values (@KUNNRID,@MATNR,@VERID,@VERIDShort)";

            for (int i = 0; i < PVL.Count; i++)
            {
                if (RecordList.Contains(PVL[i].MATNR.ToString() + PVL[i].VERID.ToString()))
                    continue;

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["KUNNRID"].copy(TB_KUNNR.Text.Trim()));
                dbcb.appendParameter(Schema.Attributes["MATNR"].copy(PVL[i].MATNR.ToString()));
                dbcb.appendParameter(Schema.Attributes["VERID"].copy(PVL[i].VERID.ToString()));
                dbcb.appendParameter(Schema.Attributes["VERIDShort"].copy(PVL[i].VERID.ToString().Substring(1,3)));

                DBA.AddCommandBuilder(dbcb);

                RecordList.Add(PVL[i].MATNR.ToString() + PVL[i].VERID.ToString());
            }

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage"), true, false, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true, false);
        }
    }

}