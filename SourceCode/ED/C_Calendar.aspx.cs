using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ED_C_Calendar : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        WUC_Calendar.CalendarDataURL = ResolveClientUrl(@"~/ED/Service/CleanCalendar.ashx");

        if (!IsPostBack)
        {
            Util.ED.LaodWorkClass(DDL_WorkClass);

            Util.ED.LoadProductionLine(DDL_PLID);

            Util.ED.LoadCleanProcess(DDL_Process);

            DDL_PLID.Items.RemoveAt(0);

            DDL_PLID.SelectedIndex = 0;

            CalendarDataParameters CDP = new CalendarDataParameters();

            CDP.PLID = DDL_PLID.SelectedValue;

            CDP.WorkClassID = string.Empty;

            CDP.ProcessID = string.Empty;

            WUC_Calendar.CalendarDataParameters = Newtonsoft.Json.JsonConvert.SerializeObject(CDP);
        }
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        CalendarDataParameters CDP = new CalendarDataParameters();

        CDP.PLID = DDL_PLID.SelectedValue;

        CDP.WorkClassID = DDL_WorkClass.SelectedValue;

        CDP.ProcessID = DDL_Process.SelectedValue;

        WUC_Calendar.CalendarDataParameters = Newtonsoft.Json.JsonConvert.SerializeObject(CDP);
    }

    protected class CalendarDataParameters
    {
        public string PLID { get; set; }
        public string WorkClassID { get; set; }
        public string ProcessID { get; set; }
    }
}