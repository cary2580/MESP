<%@ WebHandler Language="C#" Class="CleanCalendar" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class CleanCalendar : BasePage
{
    protected DateTime StartDate = DateTime.Parse("1900/01/01");

    protected DateTime EndDate = DateTime.Parse("1900/01/01");

    protected string PLID = string.Empty;

    protected string WorkClassID = string.Empty;

    protected string ProcessID = string.Empty;

    protected List<Util.CalendarEvent> RsultList = new List<Util.CalendarEvent>();

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

            if (_context.Request["PLID"] != null)
                PLID = _context.Request["PLID"].Trim();
            if (_context.Request["WorkClassID"] != null)
                WorkClassID = _context.Request["WorkClassID"].Trim();
            if (_context.Request["ProcessID"] != null)
                ProcessID = _context.Request["ProcessID"].Trim();

            if (string.IsNullOrEmpty(PLID))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_AjaxAlertMessageDefaultMessage"));

            if (StartDate.Year > 1911 && EndDate.Year > 1911)
            {
                DataTable DT = GetData();

                EnumerableRowCollection<DataRow> DataRows = DT.AsEnumerable();

                foreach (DateTime Day in StartDate.EachDayTo(EndDate))
                {
                    List<DataRow> RowList = DataRows.Where(Row => (DateTime)Row["CleanDate"] == Day).ToList();

                    if (RowList.Count < 1)
                        continue;

                    foreach (DataRow Row in RowList)
                    {
                        Util.CalendarEvent CE = new Util.CalendarEvent()
                        {
                            id = Row["CID"].ToString().ToBase64String(),
                            start = Day.ToString("o"),
                            end = Day.ToString("o"),
                            title = "<h6><strong>"
                        };

                        string Title = Row["ProcessName"].ToString().Trim();

                        if (!string.IsNullOrEmpty(Row["WorkClassName"].ToString().Trim()))
                            Title += "/" + Row["WorkClassName"].ToString().Trim();
                        if (!string.IsNullOrEmpty(Row["PLName"].ToString().Trim()))
                            Title += "/" + Row["PLName"].ToString().Trim();
                        if (((DateTime)Row["BeforeCleanDate"]).Year > 1911)
                            Title += "/" + ((DateTime)Row["BeforeCleanDate"]).ToDefaultString("yyMMdd");

                        CE.title += Title + "</strong></h6>";

                        switch (Row["ProcessID"].ToString().Trim())
                        {
                            case "1":
                            case "2":
                            case "3":
                                CE.color = "#A6A600";
                                break;
                            case "4":
                            case "5":
                            case "8":
                            case "9":
                            case "11":
                            case "12":
                            case "15":
                            case "16":
                            case "17":
                                CE.color = "#5B5B5B";
                                break;
                            case "13":
                            case "19":
                            case "20":
                            case "21":
                                CE.color = "#8600FF";
                                break;
                            case "18":
                                CE.color = "#EA7500";
                                break;
                        }

                        if ((bool)Row["IsOverTime"])
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

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

    /// <summary>
    ///  取得資料
    /// </summary>
    /// <returns></returns>
    protected DataTable GetData()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDCRecord"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Query = @"SP_GetEDCleanCalendar";

        dbcb.appendParameter(Schema.Attributes["PLID"].copy(PLID));

        dbcb.appendParameter(Schema.Attributes["CleanDate"].copy(StartDate, "StartCleanDate"));

        dbcb.appendParameter(Schema.Attributes["CleanDate"].copy(EndDate, "EndCleanDate"));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, langCookie));

        if (!string.IsNullOrEmpty(WorkClassID))
            dbcb.appendParameter(Schema.Attributes["WorkClassID"].copy(WorkClassID));

        if (!string.IsNullOrEmpty(ProcessID))
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

        dbcb.CommandText = Query;

        dbcb.DbCommandType = CommandType.StoredProcedure;

        return CommonDB.ExecuteSelectQuery(dbcb);
    }
}