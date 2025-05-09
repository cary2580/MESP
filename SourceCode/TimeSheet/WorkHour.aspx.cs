using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_WorkHour : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void BT_UpLoad_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!FU_File.HasFile)
            return;

        try
        {
            Spire.Xls.Workbook WB = new Spire.Xls.Workbook();

            WB.LoadFromStream(FU_File.PostedFile.InputStream);

            if (WB.Worksheets.Count < 1)
                throw new Exception((string)GetLocalResourceObject("Str_ErrorTemplate"));

            //指定到第一個試算表
            Spire.Xls.Worksheet Sheet = WB.Worksheets[0];

            DataTable DT = Sheet.ExportDataTable();

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSWorkHour"];

            foreach (DataRow Row in DT.Rows)
            {
                DateTime WorkDate = DateTime.Parse("1900/01/01");

                if (!DateTime.TryParse(Row[0].ToString().Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out WorkDate))
                    WorkDate = DateTime.Parse("1900/01/01");

                if (WorkDate.Year < 1911)
                    throw new Exception((string)GetLocalResourceObject("Str_ErrorInportWorkDate") + "<br>" + WorkDate.ToCurrentUICultureString());

                int EmployeeID = BaseConfiguration.GetAccountID(Row[1].ToString().Trim());

                if(EmployeeID < 0)
                    throw new Exception((string)GetLocalResourceObject("Str_ErrorInportEmployeeID") + "<br>" + Row[1].ToString().Trim());

                double WorkHour = 0;

                if (!double.TryParse(Row[2].ToString().Trim(), out WorkHour))
                    throw new Exception((string)GetLocalResourceObject("Str_ErrorInportWorkHour") + "<br>" + WorkDate + "-" + Row[1].ToString().Trim());

                double OverWorkDayHour = 0;

                if (!double.TryParse(Row[3].ToString().Trim(), out OverWorkDayHour))
                    throw new Exception((string)GetLocalResourceObject("Str_ErrorInportOverWorkDayHour") + "<br>" + WorkDate + "-" + Row[1].ToString().Trim());

                double OverHolidayHour = 0;

                if (!double.TryParse(Row[4].ToString().Trim(), out OverHolidayHour))
                    throw new Exception((string)GetLocalResourceObject("Str_ErrorInportOverHolidayHour") + "<br>" + WorkDate + "-" + Row[1].ToString().Trim());

                double ResultHour = 0;

                if (!double.TryParse(Row[5].ToString().Trim(), out ResultHour))
                    throw new Exception((string)GetLocalResourceObject("Str_ErrorInportResultHour") + "<br>" + WorkDate + "-" + Row[1].ToString().Trim());

                string Query = @"Delete T_TSWorkHour Where WorkDate = @WorkDate And EmployeeID = @EmployeeID";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(WorkDate));

                dbcb.appendParameter(Schema.Attributes["EmployeeID"].copy(EmployeeID));

                DBA.AddCommandBuilder(dbcb);

                Query = @"Insert Into T_TSWorkHour (WorkDate,EmployeeID,WorkHour,OverWorkDayHour,OverHolidayHour,ResultHour) Values (@WorkDate,@EmployeeID,@WorkHour,@OverWorkDayHour,@OverHolidayHour,@ResultHour)";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["WorkDate"].copy(WorkDate));

                dbcb.appendParameter(Schema.Attributes["EmployeeID"].copy(EmployeeID));

                dbcb.appendParameter(Schema.Attributes["WorkHour"].copy(WorkHour));

                dbcb.appendParameter(Schema.Attributes["OverWorkDayHour"].copy(OverWorkDayHour));

                dbcb.appendParameter(Schema.Attributes["OverHolidayHour"].copy(OverHolidayHour));

                dbcb.appendParameter(Schema.Attributes["ResultHour"].copy(ResultHour));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_InportSuccessAlertMessage"), true, false);
        }
        catch (Exception Ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, Ex.Message, true, false);
        }
    }
}