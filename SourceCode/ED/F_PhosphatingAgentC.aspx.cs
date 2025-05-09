using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ED_F_PhosphatingAgentC : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        WUC_Calendar.CalendarDataURL = ResolveClientUrl(@"~/ED/Service/FormulaCalendar.ashx?IsB=0");
    }
}