using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketReWorkEfficiency : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
            TB_CreateDateEnd.Text = DateTime.Now.ToCurrentUICultureString();

        HF_IsShowResultList.Value = false.ToStringValue();
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_GetReWorkTicketEfficiencyReport");

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(DateTime.Parse(TB_CreateDateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "TicketCreateDateStart"));

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(DateTime.Parse(TB_CreateDateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "TicketCreateDateEnd"));

        dbcb.appendParameter(Util.GetDataAccessAttribute("IsOnlyViewExpiredData", "bit", 0, DDL_IsOnlyViewExpiredData.SelectedValue));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        DataSet DS = CommonDB.ExecuteSelectQueryToDataSet(dbcb);

        DataTable DT = DS.Tables[1];

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        List<DataRow> Rows = new List<DataRow>();

        if (DDL_IsOnlyViewNotEnd.Text.ToBoolean())
            Rows = DT.AsEnumerable().Where(Row => !(bool)Row["IsEnd"]).ToList();
        else
            Rows = DT.AsEnumerable().ToList();

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
                searchoptions = GetSearchOptions(Column.ColumnName),
                classes = Column.ColumnName == "TicketID" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            TicketIDColumnName = "TicketIDValue",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = Rows.Select(Row => new
            {
                TicketIDValue = Row["TicketIDValue"].ToString().Trim(),
                TicketID = Row["TicketID"].ToString().Trim(),
                TEXT1 = Row["TEXT1"].ToString().Trim(),
                CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureStringTime(),
                CreateProcessName = Row["CreateProcessName"].ToString().Trim(),
                NextProcessName = Row["NextProcessName"].ToString().Trim(),
                LastProcessName = Row["LastProcessName"].ToString().Trim(),
                ExpiredProcessTypeName = Row["ExpiredProcessTypeName"].ToString().Trim(),
                IsEnd = (bool)Row["IsEnd"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowSubGridValue", "<script>var IsShowSubGridValue='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

        HF_IsShowResultList.Value = true.ToStringValue();
    }

    /// <summary>
    /// 指定欄位名取得搜尋選項
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>搜尋選項</returns>
    protected dynamic GetSearchOptions(string ColumnName)
    {
        dynamic StatusSearchOptions = new System.Dynamic.ExpandoObject();

        switch (ColumnName)
        {
            case "ExpiredProcessTypeName":
                StatusSearchOptions.sopt = new string[] { "cn", "ne" };
                return StatusSearchOptions;
            default:
                return null;
        }
    }

    /// <summary>
    /// 指定ColumnName得到是否顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        if (DDL_IsOnlyViewNotEnd.Text.ToBoolean() && ColumnName == "IsEnd")
            return true;

        switch (ColumnName)
        {
            case "TicketIDValue":
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
            case "CreateDate":
            case "IsEnd":
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
            case "IsEnd":
                return 60;
            case "TicketID":
                return 95;
            case "CreateDate":
                return 100;
            case "TEXT1":
                return 200;
            case "ExpiredProcessTypeName":
                return 100;
            default:
                return 120;
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
            case "TicketID":
                return (string)GetLocalResourceObject("Str_ColumnName_TicketID");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            case "CreateDate":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateDate");
            case "CreateProcessName":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateProcessName");
            case "NextProcessName":
                return (string)GetLocalResourceObject("Str_ColumnName_NextProcessName");
            case "LastProcessName":
                return (string)GetLocalResourceObject("Str_ColumnName_LastProcessName");
            case "ExpiredProcessTypeName":
                return (string)GetLocalResourceObject("Str_ColumnName_ExpiredProcessTypeName");
            case "IsEnd":
                return (string)GetLocalResourceObject("Str_ColumnName_IsEnd");
            default:
                return ColumnName;
        }
    }
}