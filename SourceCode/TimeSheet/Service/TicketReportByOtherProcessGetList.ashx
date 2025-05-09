<%@ WebHandler Language="C#" Class="TicketReportByOtherProcessGetList" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketReportByOtherProcessGetList : BasePage
{
    protected new string WorkCode = string.Empty;
    protected new int AccountID = -1;
    protected string ProcessID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["ProcessID"] != null)
                ProcessID = _context.Request["ProcessID"].Trim();
            if (_context.Request["WorkCode"] != null)
                WorkCode = _context.Request["WorkCode"].Trim();

            AccountID = BaseConfiguration.GetAccountID(WorkCode);

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            if (string.IsNullOrEmpty(ProcessID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_ProcessID"));

            string Query = @"Select 
                                T_TSTicketResultByOtherProcess.TicketID,
                                T_TSTicketResultByOtherProcess.SerialNo,
                                T_TSTicketResultByOtherProcess.Qty,
                                ReportDate,
                                Brand,
                                TEXT1,
                                (Select WorkShiftName From T_TSWorkShift Where WorkShiftID = T_TSTicketResultByOtherProcess.WorkShiftID) As WorkShiftName,
                                T_TSTicketResultByOtherProcess.CreateDate As CreateDateTime,
                                ProcessID,
                                WorkShiftID,
                                Base_Org.dbo.GetAccountWorkCode(Operator) As WorkCode
                            From T_TSTicketResultByOtherProcess
                            Inner Join T_TSTicket On T_TSTicket.TicketID = T_TSTicketResultByOtherProcess.TicketID
                            Inner Join T_TSSAPAFKO On T_TSSAPAFKO.AUFNR = T_TSTicket.AUFNR
                            Inner Join T_TSSAPMKAL On T_TSSAPMKAL.MATNR = T_TSSAPAFKO.PLNBEZ And T_TSSAPMKAL.VERID = T_TSSAPAFKO.VERID
                            Where ProcessID = @ProcessID And Operator = @Operator And DateDiff(Day,T_TSTicketResultByOtherProcess.CreateDate,GetDate()) < 180 
                            Order By T_TSTicketResultByOtherProcess.CreateDate Desc";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResultByOtherProcess"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

            List<DataRow> Rows = DT.AsEnumerable().ToList();

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
                    searchoptions = GetSearchOptions(Column.ColumnName, Rows),
                    sorttype = GetSortType(Column.ColumnName),
                    classes = Column.ColumnName == "TicketID" ? BaseConfiguration.JQGridColumnClassesName : "",
                }),
                ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
                FilterDateTimeColumnNames = new string[] { "CreateDateTime", "ReportDate" },
                TicketIDColumnName = (string)GetLocalResourceObject("Str_ColumnName_TicketID"),
                TicketIDValueColumnName = "TicketID",
                SerialNoColumnName = "SerialNo",
                ProcessIDColumnName = "ProcessID",
                WorkShiftIDColumnName = "WorkShiftID",
                WorkCodeColumnName = "WorkCode",
                BrandColumnName = (string)GetLocalResourceObject("Str_ColumnName_Brand"),
                BrandValueColumnName = "Brand",
                TEXT1ColumnName = (string)GetLocalResourceObject("Str_ColumnName_TEXT1"),
                TEXT1ValueColumnName = "TEXT1",
                QtyColumnName = (string)GetLocalResourceObject("Str_ColumnName_Qty"),
                QtyValueColumnName = "Qty",
                Rows = Rows.Select(Row => new
                {
                    TicketID = Row["TicketID"].ToString().Trim(),
                    SerialNo = Row["SerialNo"].ToString().Trim(),
                    Qty = Row["Qty"].ToString().Trim(),
                    ReportDate = ((DateTime)Row["ReportDate"]).ToCurrentUICultureString(),
                    Brand = Row["Brand"].ToString().Trim(),
                    TEXT1 = Row["TEXT1"].ToString().Trim(),
                    WorkShiftName = Row["WorkShiftName"].ToString().Trim(),
                    CreateDateTime = ((DateTime)Row["CreateDateTime"]).ToCurrentUICultureStringTime(),
                    ProcessID = Row["ProcessID"].ToString().Trim(),
                    WorkShiftID = Row["WorkShiftID"].ToString().Trim(),
                    WorkCode = Row["WorkCode"].ToString().Trim()
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
            case "Qty":
            case "ReportDate":
            case "CreateDate":
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
            case "Qty":
                return 60;
            case "ReportDate":
                return 80;
            default:
                return 120;
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
            case "SerialNo":
            case "ProcessID":
            case "WorkShiftID":
            case "WorkCode":
                return true;
            default:
                return false;
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
            case "Qty":
                return (string)GetLocalResourceObject("Str_ColumnName_Qty");
            case "ReportDate":
                return (string)GetLocalResourceObject("Str_ColumnName_ReportDate");
            case "Brand":
                return (string)GetLocalResourceObject("Str_ColumnName_Brand");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            case "WorkShiftName":
                return (string)GetLocalResourceObject("Str_ColumnName_WorkShiftName");
            case "CreateDateTime":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateDateTime");
            default:
                return ColumnName;
        }
    }

    /// <summary>
    /// 指定欄位名取得搜尋選項
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <param name="Rows">資料列</param>
    /// <returns>搜尋選項</returns>
    protected dynamic GetSearchOptions(string ColumnName, List<DataRow> Rows)
    {
        dynamic StatusSearchOptions = new System.Dynamic.ExpandoObject();

        switch (ColumnName)
        {
            case "CreateDateTime":
            case "ReportDate":
                StatusSearchOptions.sopt = new string[] { "eq", "le", "ge" };
                return StatusSearchOptions;
            default:
                return null;
        }
    }

    /// <summary>
    /// 指定欄位名取得搜尋型別
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <returns>搜尋型別</returns>
    protected string GetSortType(string ColumnName)
    {
        switch (ColumnName)
        {
            case "CreateDateTime":
            case "ReportDate":
                return "date";
            default:
                return null;
        }
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}