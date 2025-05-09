using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_WorkHourException : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
       
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        string Query = @"Select 
                         T_TSWorkHourException.WorkDate,
                         T_TSWorkHourException.SectionID,
	                     V_TSSection.SectionName,
	                     T_TSWorkHourException.IIPHour,
	                     T_TSWorkHourException.SampleHour,
	                     T_TSWorkHourException.BorrowHour,
	                     T_TSWorkHourException.Remark
                         From T_TSWorkHourException Inner Join V_TSSection On V_TSSection.SectionID = T_TSWorkHourException.SectionID
                         Where T_TSWorkHourException.WorkDate >= @WorkDateStart And T_TSWorkHourException.WorkDate <= @WorkDateEnd";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSWorkHourException"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(TB_WorkDateStart.Text, "WorkDateStart"));

        dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(TB_WorkDateEnd.Text, "WorkDateEnd"));

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
                classes = Column.ColumnName == "SectionName" ? BaseConfiguration.JQGridColumnClassesName : string.Empty,
            }),
            SectionNameColumnName = "SectionName",
            WorkDateColumnName = (string)GetLocalResourceObject("Str_ColumnName_WorkDate"),
            WorkDateValueColumnName = "WorkDate",
            SectionIDColumnName = "SectionID",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                WorkDate = ((DateTime)Row["WorkDate"]).ToCurrentUICultureString(),
                SectionID = Row["SectionID"].ToString().Trim(),
                SectionName = Row["SectionName"].ToString().Trim(),
                IIPHour = Row["IIPHour"].ToString().Trim(),
                SampleHour = Row["SampleHour"].ToString().Trim(),
                BorrowHour = Row["BorrowHour"].ToString().Trim(),
                Remark = Row["Remark"].ToString().Trim(),
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
            case "SectionID":
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
            case "SectionName":
            case "Remark":
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
            case "SectionName":
            case "WorkDate":
                return 80;
            case "Remark":
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
            case "WorkDate":
                return (string)GetLocalResourceObject("Str_ColumnName_WorkDate");
            case "SectionName":
                return (string)GetLocalResourceObject("Str_ColumnName_SectionName");
            case "IIPHour":
                return (string)GetLocalResourceObject("Str_ColumnName_IIPHour");
            case "SampleHour":
                return (string)GetLocalResourceObject("Str_ColumnName_SampleHour");
            case "BorrowHour":
                return (string)GetLocalResourceObject("Str_ColumnName_BorrowHour");
            case "Remark":
                return (string)GetLocalResourceObject("Str_ColumnName_Remark");
            default:
                return ColumnName;
        }
    }
}