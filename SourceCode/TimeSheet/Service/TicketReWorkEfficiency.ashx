<%@ WebHandler Language="C#" Class="TicketReWorkEfficiency" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketReWorkEfficiency : BasePage
{
    protected string TicketID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            DataTable DT = GetData();

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
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    ProcessName = Row["ProcessName"].ToString().Trim(),
                    ExecuteDay = Row["ExecuteDay"].ToString().Trim(),
                    ProcessReWorkStandardDay = Row["ProcessReWorkStandardDay"].ToString().Trim(),
                    ProcessTypeName = Row["ProcessTypeName"].ToString().Trim(),
                    ExecuteDayByProcessType = Row["ExecuteDayByProcessType"].ToString().Trim(),
                    IsExpired = (bool)Row["IsExpired"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty
                })
            };

            ResponseSuccessData(ResponseData);
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    public new bool IsReusable
    {
        get
        {
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
            case "ProcessName":
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
            case "ExecuteDay":
            case "ProcessReWorkStandardDay":
            case "ProcessTypeName":
            case "ExecuteDayByProcessType":
                return 80;
            case "IsExpired":
                return 60;
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
            case "ProcessName":
                return (string)GetLocalResourceObject("Str_ColumnName_ProcessName");
            case "ExecuteDay":
                return (string)GetLocalResourceObject("Str_ColumnName_ExecuteDay");
            case "ProcessReWorkStandardDay":
                return (string)GetLocalResourceObject("Str_ColumnName_ProcessReWorkStandardDay");
            case "ProcessTypeName":
                return (string)GetLocalResourceObject("Str_ColumnName_ProcessTypeName");
            case "ExecuteDayByProcessType":
                return (string)GetLocalResourceObject("Str_ColumnName_ExecuteDayByProcessType");
            case "IsExpired":
                return (string)GetLocalResourceObject("Str_ColumnName_IsExpired");
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
            case "TicketID":
            case "ProcessTypeID":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 取得返工效率資料
    /// </summary>
    /// <returns>返工效率資料明細表</returns>
    protected DataTable GetData()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_GetReWorkTicketEfficiencyReport");

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Util.GetDataAccessAttribute("IsOnlyViewExpiredData", "bit", 0, true));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        DataSet DS = CommonDB.ExecuteSelectQueryToDataSet(dbcb);

        return DS.Tables[0];
    }

}