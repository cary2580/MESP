using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_RPT_006 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        string Query = @"Select 
                            T_TSDevice.MachineName,
                            Sum(WaitMinute) As WaitMinute,
                            Sum(MaintainMinuteByMachine) As MaintainMinuteByMachine,
                            Sum(MaintainMinute) As MaintainMinute,
                            Count(*) As MaintainCount
                        From T_TSTicketMaintain 
                        Inner Join T_TSTicket On T_TSTicketMaintain.TicketID = T_TSTicket.TicketID 
                        Left Join T_TSDevice On T_TSDevice.DeviceID = T_TSTicketMaintain.DeviceID
                        Where IsCancel = 0 And IsClose = 1 And T_TSTicketMaintain.IsEnd = 1
                            And T_TSTicket.AUFNR = IIF(IsNull(@AUFNR,'') = '',T_TSTicket.AUFNR,@AUFNR)
                            And Datediff(Day,IIF(IsNull(@CreateDateStart,'') = '',T_TSTicketMaintain.CreateDate,@CreateDateStart),T_TSTicketMaintain.CreateDate) >= 0 
                            And Datediff(Day,IIF(IsNull(@CreateDateEnd,'') = '',T_TSTicketMaintain.CreateDate,@CreateDateEnd),T_TSTicketMaintain.CreateDate) <= 0
                        Group By T_TSDevice.MachineName,T_TSDevice.SortID
                        Order By T_TSDevice.SortID

                        Select 
                            T_TSDevice.MachineName,
                            T_TSFaultCategory.FaultCategoryName,
                            T_TSFault.FaultName,
                            Count(*) As MaintainCount
                        From T_TSTicketMaintain 
                        Inner Join T_TSTicket On T_TSTicketMaintain.TicketID = T_TSTicket.TicketID 
                        Inner Join T_TSTicketMaintainFault On T_TSTicketMaintainFault.MaintainID = T_TSTicketMaintain.MaintainID
                        Inner Join T_TSFaultCategory On T_TSFaultCategory.FaultCategoryID = T_TSTicketMaintainFault.FaultCategoryID
                        Inner Join T_TSFault On T_TSFault.FaultID = T_TSTicketMaintainFault.FaultID
                        Left Join T_TSDevice On T_TSDevice.DeviceID = T_TSTicketMaintain.DeviceID
                        Where IsCancel = 0 And IsClose = 1 And T_TSTicketMaintain.IsEnd = 1
                            And T_TSTicket.AUFNR = IIF(IsNull(@AUFNR,'') = '',T_TSTicket.AUFNR,@AUFNR)
                            And Datediff(Day,IIF(IsNull(@CreateDateStart,'') = '',T_TSTicketMaintain.CreateDate,@CreateDateStart),T_TSTicketMaintain.CreateDate) >= 0 
                            And Datediff(Day,IIF(IsNull(@CreateDateEnd,'') = '',T_TSTicketMaintain.CreateDate,@CreateDateEnd),T_TSTicketMaintain.CreateDate) <= 0
                        Group By 
                        T_TSDevice.MachineName,
                        T_TSDevice.SortID,
                        T_TSFaultCategory.FaultCategoryName,
                        T_TSFault.FaultName
                        Order By T_TSDevice.SortID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(TB_AUFNR.Text.Trim()));

        Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        DateTime CreateDateStart = DateTime.Parse("1900/01/01");

        DateTime CreateDateEnd = DateTime.Parse("1900/01/01");

        if (!string.IsNullOrEmpty(TB_CreateDateStart.Text.Trim()))
        {
            if (!DateTime.TryParse(TB_CreateDateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out CreateDateStart))
                CreateDateStart = DateTime.Parse("1900/01/01");
        }

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(CreateDateStart, "CreateDateStart"));

        if (!string.IsNullOrEmpty(TB_CreateDateEnd.Text.Trim()))
        {
            if (!DateTime.TryParse(TB_CreateDateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out CreateDateEnd))
                CreateDateEnd = DateTime.Parse("1900/01/01");
        }

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(CreateDateEnd, "CreateDateEnd"));

        DataSet DS = CommonDB.ExecuteSelectQueryToDataSet(dbcb);

        if (DS.Tables[0].Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

            return;
        }

        DataTable DT1 = DS.Tables[0];

        DataTable DT2 = DS.Tables[1];

        List<dynamic> BarChartData = new List<dynamic>();

        foreach (DataRow Row in DT1.Rows)
        {
            dynamic DataValue = new System.Dynamic.ExpandoObject();

            DataValue.name = Row["MachineName"].ToString().Trim();

            DataValue.WaitMinute = (int)Row["WaitMinute"];

            DataValue.MaintainMinuteByMachine = (int)Row["MaintainMinuteByMachine"];

            DataValue.MaintainMinute = (int)Row["MaintainMinute"];

            DataValue.MaintainCount = (int)Row["MaintainCount"];

            BarChartData.Add(DataValue);
        }

        List<dynamic> PicChartData = new List<dynamic>();

        var MachineNameList = DT2.AsEnumerable().GroupBy(Row => new { MachineName = Row["MachineName"].ToString().Trim(), FaultCategoryName = Row["FaultCategoryName"].ToString().Trim() }).Select(item => new
        {
            MachineName = item.Key.MachineName,
            FaultCategoryName = item.Key.FaultCategoryName,
            Count = item.Count()
        }).ToList();

        foreach (var itme in MachineNameList)
        {
            dynamic ResultValue = new System.Dynamic.ExpandoObject();

            ResultValue.MachineName = itme.MachineName;

            ResultValue.name = itme.FaultCategoryName;

            int MachineCount = DT2.AsEnumerable().Where(Row => Row["MachineName"].ToString().Trim() == itme.MachineName).Count();

            ResultValue.y = (double)(itme.Count / double.Parse(MachineCount.ToString()));

            ResultValue.z = itme.Count;

            ResultValue.drilldown = itme.MachineName + "_" + itme.FaultCategoryName;

            PicChartData.Add(ResultValue);
        }

        List<dynamic> PicChartDetailData = new List<dynamic>();

        foreach (var itme in MachineNameList)
        {
            var RorwList = DT2.AsEnumerable().Where(Row => Row["MachineName"].ToString().Trim() == itme.MachineName && Row["FaultCategoryName"].ToString().Trim() == itme.FaultCategoryName).ToList();

            foreach (DataRow Row in RorwList)
            {
                dynamic ResultValue = new System.Dynamic.ExpandoObject();

                ResultValue.MachineName = itme.MachineName;

                ResultValue.id = itme.MachineName + "_" + itme.FaultCategoryName;

                int SumMaintainCount = RorwList.Sum(R => (int)R["MaintainCount"]);

                double TotleCount = double.Parse(SumMaintainCount.ToString());

                ResultValue.data = RorwList.Select(Item => new { name = Item["FaultName"].ToString().Trim(), y = (double)((int)Item["MaintainCount"] / TotleCount), z = (int)Item["MaintainCount"] }).ToList();

                PicChartDetailData.Add(ResultValue);
            }
        }

        Page.ClientScript.RegisterStartupScript(this.GetType(), "BarChartData", "<script>var BarChartData=" + Newtonsoft.Json.JsonConvert.SerializeObject(BarChartData) + ";</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "PicChartData", "<script>var PicChartData=" + Newtonsoft.Json.JsonConvert.SerializeObject(PicChartData) + ";</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "PicChartDetailData", "<script>var PicChartDetailData=" + Newtonsoft.Json.JsonConvert.SerializeObject(PicChartDetailData) + ";</script>");
    }
}