using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;


public partial class TimeSheet_SupervisorWorkCenter : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        int Operator = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

        string Query = @"Select 
                             Format(ReportDate,'yyyy/MM') As ReportDate,
                             Base_Org.dbo.GetAccountWorkCode(Operator) As OperatorWorkCode,
                             Base_Org.dbo.GetAccountName(Operator) As OperatorName,
                            (Select Top 1 ARBPL_KTEXT From T_TSSAPPLPO Where T_TSSAPPLPO.ARBPL = T_TSSupervisorWorkCenter.ARBPL And T_TSSAPPLPO.ARBPL_KTEXT <> '') As ARBPL_KTEXT,
                             T_TSSupervisorWorkCenter.ARBPL
                        From 
                        T_TSSupervisorWorkCenter 
                        Where ReportDate = @ReportDate And Operator = @Operator";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSupervisorWorkCenter"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ReportDate"].copy(TB_ReportMonths.Text + "/01"));

        dbcb.appendParameter(Schema.Attributes["Operator"].copy(Operator, "Operator"));

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
                classes = Column.ColumnName == "OperatorWorkCode" ? BaseConfiguration.JQGridColumnClassesName : string.Empty,
            }),
            ARBPLColumnName = "ARBPL",
            ReportDateColumnName = (string)GetLocalResourceObject("Str_ColumnName_ReportDate"),
            ReportDateValueColumnName = "ReportDate",
            OperatorWorkCodeColumnName = (string)GetLocalResourceObject("Str_ColumnName_OperatorWorkCode"),
            OperatorWorkCodeValueColumnName = "OperatorWorkCode",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                ReportDate = Row["ReportDate"].ToString().Trim(),
                OperatorWorkCode = Row["OperatorWorkCode"].ToString().Trim(),
                OperatorName = Row["OperatorName"].ToString().Trim(),
                ARBPL_KTEXT = Row["ARBPL_KTEXT"].ToString().Trim(),
                ARBPL = Row["ARBPL"].ToString().Trim()
            })
        };

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
            case "ARBPL":
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
            case "ARBPL_KTEXT":
                return "left";
            default:
                return "center";
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
            case "ReportDate":
                return 80;
            case "ARBPL_KTEXT":
                return 200;
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
            case "ReportDate":
                return (string)GetLocalResourceObject("Str_ColumnName_ReportDate");
            case "OperatorWorkCode":
                return (string)GetLocalResourceObject("Str_ColumnName_OperatorWorkCode");
            case "OperatorName":
                return (string)GetLocalResourceObject("Str_ColumnName_OperatorName");
            case "ARBPL_KTEXT":
                return (string)GetLocalResourceObject("Str_ColumnName_ARBPL_KTEXT");
            default:
                return ColumnName;
        }
    }
}