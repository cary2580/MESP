<%@ WebHandler Language="C#" Class="MORoutingResultGet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class MORoutingResultGet : BasePage
{
    protected string AUFNR = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["AUFNR"] != null)
                AUFNR = _context.Request["AUFNR"].Trim();

            if (string.IsNullOrEmpty(AUFNR))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AUFNR"));

            AUFNR = Util.TS.ToAUFNR(AUFNR);

            string Query = @"Select T_TSTicketRouting.LTXA1,T_TSTicketRouting.ProcessID,
                            IsNull(Sum(GoodQty),0) As GoodQty,
                            IsNull(Sum(T_TSTicketQuarantineResult.Qty) - Sum(T_TSTicketQuarantineResult.ScrapQty),0) As WaitJudgmentQty,
                            IsNull(Sum(T_TSTicketResult.ScrapQty),0) As ScrapQty,
                            0 As SumQty,
                            (Select Case When Count(*) > 0 Then Convert(bit,1) Else Convert(bit,0) End From V_TSTicketResult Where V_TSTicketResult.AUFNR = @AUFNR And ProcessID = T_TSTicketRouting.ProcessID And V_TSTicketResult.ApprovalTime Is Null) As ReportColor
                            From T_TSTicket
                            Inner Join T_TSTicketRouting On T_TSTicket.TicketID = T_TSTicketRouting.TicketID
                            Left join T_TSTicketQuarantineResult On T_TSTicketQuarantineResult.TicketID = T_TSTicket.TicketID And T_TSTicketQuarantineResult.ProcessID = T_TSTicketRouting.ProcessID And T_TSTicketQuarantineResult.IsJudgment = 0
                            Left Join T_TSTicketResult On T_TSTicketResult.TicketID = T_TSTicket.TicketID And T_TSTicketResult.ProcessID = T_TSTicketRouting.ProcessID And Datediff(Day,T_TSTicketResult.ApprovalTime,getdate()) >= 0
                            Where T_TSTicket.AUFNR = @AUFNR
                            Group By T_TSTicketRouting.LTXA1,T_TSTicketRouting.ProcessID
                            Order By T_TSTicketRouting.ProcessID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

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
                    hidden = GetIsHidden(Column.ColumnName)
                }),
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    LTXA1 = Row["LTXA1"].ToString().Trim(),
                    ProcessID = Row["ProcessID"].ToString().Trim(),
                    GoodQty = ((int)Row["GoodQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                    WaitJudgmentQty = ((int)Row["WaitJudgmentQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                    ScrapQty = ((int)Row["ScrapQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                    SumQty = ((int)Row["GoodQty"] + (int)Row["WaitJudgmentQty"] + (int)Row["ScrapQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                    ReportColor = (bool)Row["ReportColor"] ? "#D9B300" : string.Empty
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
    /// 指定ColumnName得到是否顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ProcessID":
            case "ReportColor":
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
            case "LTXA1":
                return 250;
            default:
                return 150;
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
            case "LTXA1":
                return (string)GetLocalResourceObject("Str_ColumnName_LTXA1");
            case "GoodQty":
                return (string)GetLocalResourceObject("Str_ColumnName_GoodQty");
            case "WaitJudgmentQty":
                return (string)GetLocalResourceObject("Str_ColumnName_WaitJudgmentQty");
            case "ScrapQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQty");
            case "SumQty":
                return (string)GetLocalResourceObject("Str_ColumnName_SumQty");
            default:
                return ColumnName;
        }
    }

}