<%@ WebHandler Language="C#" Class="TicketMaintainWaitReportData" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainWaitReportData : BasePage
{
    protected string MaintainID = string.Empty;

    protected DataRow MaintainRow = null;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["MaintainID"] != null)
                MaintainID = _context.Request["MaintainID"].Trim();

            if (string.IsNullOrEmpty(MaintainID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MaintainID"));

            LoadMaintainDataRow();

            string Query = @"Select Operator,Base_Org.dbo.GetAccountWorkCode(Operator) As OperatorWorkCode,Base_Org.dbo.GetAccountName(Operator) As OperatorName,MaintainStartTime,MaintainEndTime,MaintainMinute,'' As ActionButton From T_TSTicketMaintainMinute Where MaintainID = @MaintainID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainMinute"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

            DateTime MinStartTime = DateTime.Now;

            DateTime MaxEndTime = DateTime.Now;

            if (DT.Rows.Count > 0)
            {
                MinStartTime = DT.AsEnumerable().Min(Row => (DateTime)Row["MaintainStartTime"]);

                MaxEndTime = DT.AsEnumerable().Max(Row => (DateTime)Row["MaintainEndTime"]);
            }

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
                    sortable = false
                }),
                IsHaveOperator = DT.Rows.Count > 0,
                IsGoToQACheck = !(DT.AsEnumerable().Where(Row => (int)Row["MaintainMinute"] < 1).Count() > 0) && (int)MaintainRow["QACheckAccountID"] < 1,
                IsQACheckFinish = (int)MaintainRow["QACheckAccountID"] > 1,
                IsGoToPDCheck = !(bool)MaintainRow["IsEnd"] && (int)MaintainRow["MaintainMinute"] > 0 && (int)MaintainRow["PDCheckAccountID"] < 1,
                IsPDCheckFinish = (int)MaintainRow["PDCheckAccountID"] > 1,
                TotalMaintainMinute = DT.AsEnumerable().Sum(Row => (int)Row["MaintainMinute"]),
                TotalMaintainMinuteByMachine = (int)(MaxEndTime - MinStartTime).TotalMinutes,
                OperatorWorkCodeColumnName = "OperatorWorkCode",
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    Operator = Row["Operator"].ToString().Trim(),
                    OperatorName = Row["OperatorName"].ToString().Trim(),
                    MaintainStartTime = ((DateTime)Row["MaintainStartTime"]).ToCurrentUICultureStringTime(),
                    MaintainEndTime = (int)Row["MaintainMinute"] > 0 ? ((DateTime)Row["MaintainEndTime"]).ToCurrentUICultureStringTime() : string.Empty,
                    MaintainMinute = Row["MaintainMinute"].ToString().Trim(),
                    //ActionButton = (int)Row["MaintainMinute"] < 1 ? "<input type=\"button\" class=\"btn btn-warning FinishButton\" data-operator=\"" + Row["Operator"].ToString().Trim() + "\" data-operatorworkcode=\"" + Row["OperatorWorkCode"].ToString().Trim() + "\" id=\"BT_Finish_" + Row["Operator"].ToString().Trim() + "\" value=\"" + (string)GetGlobalResourceObject("GlobalRes","Str_BT_FinishName") + "\" />&nbsp;&nbsp;<input type=\"button\" class=\"btn btn-danger CancelButton\" data-operator=\"" + Row["Operator"].ToString().Trim() + "\" id=\"BT_Cancel_" + Row["Operator"].ToString().Trim() + "\" data-operatorworkcode=\"" + Row["OperatorWorkCode"].ToString().Trim() + "\" value=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_BT_CancelName") + "\" />" : string.Empty
                    // 2023/10/18 阿苟提出，維修單不能取消議題，開會討論後決議不給取消。
                    ActionButton = (int)Row["MaintainMinute"] < 1 ? "<input type=\"button\" class=\"btn btn-warning FinishButton\" data-operator=\"" + Row["Operator"].ToString().Trim() + "\" data-operatorworkcode=\"" + Row["OperatorWorkCode"].ToString().Trim() + "\" id=\"BT_Finish_" + Row["Operator"].ToString().Trim() + "\" value=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_BT_FinishName") + "\" />" : string.Empty
                })
            };

            ResponseSuccessData(ResponseData);
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
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
            case "MaintainStartTime":
            case "MaintainEndTime":
            case "MaintainMinute":
            case "ActionButton":
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
            case "MaintainStartTime":
            case "MaintainEndTime":
            case "ActionButton":
                return 80;
            case "MaintainMinute":
                return 60;
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
            case "OperatorName":
                return (string)GetLocalResourceObject("Str_ColumnName_OperatorName");
            case "MaintainStartTime":
                return (string)GetLocalResourceObject("Str_ColumnName_MaintainStartTime");
            case "MaintainEndTime":
                return (string)GetLocalResourceObject("Str_ColumnName_MaintainEndTime");
            case "MaintainMinute":
                return (string)GetLocalResourceObject("Str_ColumnName_MaintainMinute");
            case "ActionButton":
                return (string)GetLocalResourceObject("Str_ColumnName_ActionButton");
            default:
                return ColumnName;
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
            case "OperatorName":
            case "MaintainStartTime":
            case "MaintainEndTime":
            case "MaintainMinute":
            case "ActionButton":
                return false;
            default:
                return true;
        }
    }

    /// <summary>
    /// 載入維修單資料列
    /// </summary>
    protected void LoadMaintainDataRow()
    {
        string Query = @"Select * From T_TSTicketMaintain Where MaintainID = @MaintainID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainMinute"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_NoMaintainData"));

        MaintainRow = DT.Rows[0];
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}