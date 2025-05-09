<%@ WebHandler Language="C#" Class="FormulaCalendar" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;

public class FormulaCalendar : BasePage
{
    protected DateTime StartDate = DateTime.Parse("1900/01/01");

    protected DateTime EndDate = DateTime.Parse("1900/01/01");

    protected List<Util.CalendarEvent> RsultList = new List<Util.CalendarEvent>();

    protected bool IsB = true;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["StartDateTime"] != null)
            {
                if (!DateTime.TryParse(_context.Request["StartDateTime"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out StartDate))
                    StartDate = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["EndDateTime"] != null)
            {
                if (!DateTime.TryParse(_context.Request["EndDateTime"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out EndDate))
                    EndDate = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["IsB"] != null)
                IsB = _context.Request["IsB"].ToBoolean();

            if (StartDate.Year > 1911 && EndDate.Year > 1911)
            {
                DataTable DT = new DataTable();

                DT = GetData();

                EnumerableRowCollection<DataRow> DataRows = DT.AsEnumerable();

                foreach (DateTime Day in StartDate.EachDayTo(EndDate))
                {
                    List<DataRow> RowList = DataRows.Where(Row => (DateTime)Row["PADate"] == Day).ToList();

                    if (RowList.Count < 1)
                        continue;

                    foreach (DataRow Row in RowList)
                    {
                        Util.CalendarEvent CE = new Util.CalendarEvent()
                        {
                            id = Row["PAID"].ToString().ToBase64String(),
                            start = Day.ToString("o"),
                            end = Day.ToString("o"),
                            title = "<h6><strong>" + ((DateTime)Row["PADate"]).ToCurrentUICultureString()
                            + " " + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_F_EDResultID") + " : " + (string.IsNullOrEmpty(Row["ResultID"].ToString().Trim()) ? "--" : Row["ResultID"].ToString().Trim())
                            + "</strong></h6>"
                        };

                        if (!string.IsNullOrEmpty(Row["ResultID"].ToString()) && Row["ResultID"].ToString().ToLower().Trim() != "ok")
                            CE.color = "#EA0000";

                        RsultList.Add(CE);
                    }
                }
            }

            ResponseSuccessData(RsultList);
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    ///  取得資料
    /// </summary>
    /// <returns></returns>
    protected DataTable GetData()
    {
        string Query = string.Empty;

        if (IsB)
        {
            Query = @" Select T_EDPhosphatingAgentB.*,T_EDPhosphatingAgentB_Report.ResultID From T_EDPhosphatingAgentB 
                          Left Join T_EDPhosphatingAgentB_Report On T_EDPhosphatingAgentB.PAID = T_EDPhosphatingAgentB_Report.PAID 
                          Where T_EDPhosphatingAgentB.PADate >= @StartPADate And T_EDPhosphatingAgentB.PADate <= @EndPADate;";
        }
        else
        {
            Query = @" Select T_EDPhosphatingAgentC.*,T_EDPhosphatingAgentC_Report.ResultID From T_EDPhosphatingAgentC 
                          Left Join T_EDPhosphatingAgentC_Report On T_EDPhosphatingAgentC.PAID = T_EDPhosphatingAgentC_Report.PAID 
                          Where T_EDPhosphatingAgentC.PADate >= @StartPADate And T_EDPhosphatingAgentC.PADate <= @EndPADate;";
        }

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("StartPADate", "DateTime", 0, StartDate));

        dbcb.appendParameter(Util.GetDataAccessAttribute("EndPADate", "DateTime", 0, EndDate));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}