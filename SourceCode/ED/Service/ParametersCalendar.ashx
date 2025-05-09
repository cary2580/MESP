<%@ WebHandler Language="C#" Class="ParametersCalendar" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class ParametersCalendar : BasePage
{
    protected DateTime StartDate = DateTime.Parse("1900/01/01");

    protected DateTime EndDate = DateTime.Parse("1900/01/01");

    protected List<Util.CalendarEvent> RsultList = new List<Util.CalendarEvent>();

    protected string TableName = string.Empty;

    protected short PIDType = 0;

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

            if (_context.Request["PIDType"] != null)
            {
                if (!short.TryParse(_context.Request["PIDType"].Trim(), out PIDType))
                    PIDType = 0;
            }

            if (PIDType < 1)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_AjaxAlertMessageDefaultMessage"));

            TableName = Enum.GetName(typeof(Util.ED.PIDType), PIDType);

            if (string.IsNullOrEmpty(TableName))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_AjaxAlertMessageDefaultMessage"));

            if (StartDate.Year > 1911 && EndDate.Year > 1911)
            {
                DataTable DT = GetData();

                EnumerableRowCollection<DataRow> DataRows = DT.AsEnumerable();

                foreach (DateTime Day in StartDate.EachDayTo(EndDate))
                {
                    List<DataRow> RowList = DataRows.Where(Row => (DateTime)Row["PDate"] == Day).ToList();

                    if (RowList.Count < 1)
                        continue;

                    foreach (DataRow Row in RowList)
                    {
                        Util.CalendarEvent CE = new Util.CalendarEvent()
                        {
                            id = Row["PID"].ToString().ToBase64String(),
                            start = Day.ToString("o"),
                            end = Day.ToString("o"),
                            title = "<h6><strong>" + Row["WorkClassName"].ToString().Trim() + "/" + Row["PLName"].ToString().Trim() + "</strong></h6>"
                        };

                        if (Row["WorkClassID"].ToString().Trim() == "N")
                            CE.color = "#5cb85c";

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
        string Query = @" Select PID,PDate,WorkClassID,"
                       + " (Select Top 1 CodeName From T_Code Where CodeType = 'WorkClass' And CodeID = " + TableName + ".WorkClassID And UICulture = @UICulture) As WorkClassName, "
                       + " (Select Top 1 CodeName From T_Code Where CodeType = 'ProductionLine' And CodeID = " + TableName + ".PLID And UICulture = @UICulture) As PLName "
                       + " From " + TableName + " Where PDate >= @StartPDate And PDate <= @EndPdate";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPPreDegreasing"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PDate"].copy(StartDate, "StartPDate"));
        dbcb.appendParameter(Schema.Attributes["PDate"].copy(EndDate, "EndPdate"));
        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, langCookie));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }
}