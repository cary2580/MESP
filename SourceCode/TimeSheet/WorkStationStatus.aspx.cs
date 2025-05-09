using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Speech.Synthesis;
using System.Threading.Tasks;

public partial class TimeSheet_WorkStationStatus : System.Web.UI.Page
{
    protected enum SortMethodEmun : short
    {
        BySortID = 0,
        ByStatusIDThenBySortID
    }
    protected enum SortTypeEmun : short
    {
        Asc = 0,
        Desc
    }

    protected SortMethodEmun SortMethod;
    protected SortTypeEmun SortType;
    protected string AreaID = string.Empty;
    protected string ResponsibleID = string.Empty;
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["AreaID"] != null)
            AreaID = Request["AreaID"].Trim();
        if (Request["ResponsibleID"] != null)
            ResponsibleID = Request["ResponsibleID"].Trim();

        if (Request["SortMethod"] != null)
        {
            if (!Enum.TryParse(Request["SortMethod"].Trim(), out SortMethod))
                SortMethod = SortMethodEmun.BySortID;
        }

        if (Request["SortType"] != null)
        {
            if (!Enum.TryParse(Request["SortType"].Trim(), out SortType))
                SortType = SortTypeEmun.Asc;
        }

        LoadData();
    }

    protected void LoadData()
    {
        string Query = @"SP_TS_GetWorkStationStatus";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSArea"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Schema.Attributes["AreaID"].copy(AreaID));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_NoData"), true, false, "window.close();");

            return;
        }

        EnumerableRowCollection<DataRow> Rows;

        if (!string.IsNullOrEmpty(ResponsibleID))
            Rows = DT.AsEnumerable().Where(Row => ResponsibleID.Split('|').Intersect(Row["ResponsibleID"].ToString().Split('|')).Any() || ((Row["StatusID"].ToString().Trim() == "3" || Row["StatusID"].ToString().Trim() == "2") && string.IsNullOrEmpty(Row["ResponsibleID"].ToString().Trim())));
        else
            Rows = DT.AsEnumerable();

        if (SortMethod == SortMethodEmun.BySortID)
            Rows = SortType == SortTypeEmun.Asc ? Rows.OrderBy(Row => (double)Row["SortID"]) : Rows.OrderByDescending(Row => (double)Row["SortID"]);
        else
            Rows = SortType == SortTypeEmun.Asc ? Rows.OrderByDescending(Row => (bool)Row["IsSuspension"]).ThenByDescending(Row => Row["StatusID"].ToString().Trim() == "99" ? "0" : Row["StatusID"].ToString().Trim()).ThenBy(Row => (double)Row["SortID"]) : Rows.OrderByDescending(Row => Row["StatusID"].ToString().Trim() == "99" ? "0" : Row["StatusID"].ToString().Trim()).ThenByDescending(Row => (double)Row["SortID"]);

        var ResponseData = Rows.Select(Row => new
        {
            StatusName = Row["StatusName"].ToString().Trim() + "  " + ((int)Row["MachineMaintainQty"] < 0 ? string.Empty : "(" + (string)GetLocalResourceObject("Str_MachineMaintainQty") + ":" + Row["MachineMaintainQty"].ToString().Trim() + ")"),
            DeviceID = Row["DeviceID"].ToString().Trim(),
            MachineName = !string.IsNullOrEmpty(Row["MachineAlias"].ToString().Trim()) && System.Threading.Thread.CurrentThread.CurrentUICulture.Name.ToUpper() == "PL" ? Row["MachineAlias"].ToString().Trim() : Row["MachineName"].ToString().Trim(),
            OperatorWorkCode = Row["OperatorWorkCode"].ToString().Trim() + (string.IsNullOrEmpty(Row["SecondOperatorWorkCode"].ToString().Trim()) ? string.Empty : "、" + Row["SecondOperatorWorkCode"].ToString().Trim() + ""),
            OperatorName = Row["OperatorName"].ToString().Trim() + (string.IsNullOrEmpty(Row["SecondOperatorName"].ToString().Trim()) ? string.Empty : "、" + Row["SecondOperatorName"].ToString().Trim() + ""),
            EventTime = ((DateTime)Row["EventTime"]).Year > 1911 ? ((DateTime)Row["EventTime"]).ToDefaultString("HH:mm:ss") : string.Empty,
            EventMinute = ((DateTime)Row["EventTime"]).Year > 1911 ? "(" + Row["EventMinute"].ToString().Trim() + ")" : string.Empty,
            WorkShiftName = Row["WorkShiftName"].ToString().Trim(),
            StatusID = Row["StatusID"].ToString().Trim(),
            TicketID = Row["TicketID"].ToString().Trim(),
            ProcessName = !string.IsNullOrEmpty(Row["ProcessID"].ToString().Trim()) ? Row["ProcessID"].ToString().Trim() + "-" + Row["VORNR"].ToString().Trim() + "-" + Row["LTXA1"].ToString().Trim() : string.Empty,
            TEXT1 = string.IsNullOrEmpty(Row["TEXT1"].ToString().Trim()) ? Row["PLNBEZ"].ToString().Trim() : Row["TEXT1"].ToString().Trim(),
            TotalGoodQty = ((int)Row["TotalGoodQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
            TotalReWorkQty = ((int)Row["TotalReWorkQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
            TotalScrapQty = ((int)Row["TotalScrapQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
            ColorClass = GetColorClass((bool)Row["IsSuspension"] ? "-1" : Row["StatusID"].ToString().Trim()),
            ResponsibleName = Row["ResponsibleName"].ToString().Trim()
        }).ToList();

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsViewShortTemplet", "<script>var IsViewShortTemplet=" + Request["IsViewShortTemplet"].ToBoolean().ToStringValue() + ";</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "WorkStationDataValue", "<script>var WorkStationDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

        var WaitMaintainMachineList = Rows.Where(Row => Row["StatusID"].ToString().Trim() == "3").Select(Row =>
            (dynamic)new
            {
                MachineID = Row["MachineID"].ToString().Replace("-", ""),
                MachineName = Row["MachineName"].ToString().Replace("-", ""),
                MachineAlias = Row["MachineName"].ToString().Replace("-", ""),
                EventMinute = (int)Row["EventMinute"]
            }
        ).ToList();

        if (WaitMaintainMachineList.Count > 0)
            TTS(WaitMaintainMachineList);
    }

    /// <summary>
    /// 指定狀態代碼得到顏色Class
    /// </summary>
    /// <param name="StatusID">狀態代碼</param>
    /// <returns>顏色Class</returns>
    protected string GetColorClass(string StatusID)
    {
        switch (StatusID)
        {
            case "-1":
                return "panel panel-gray";
            case "1":
                return "panel panel-green";
            case "2":
                return "panel panel-red";
            case "3":
                return "panel panel-yellow";
            default:
                return "panel panel-info";
        }
    }

    /// <summary>
    /// 指定待維修機台文字清單轉化成語音檔案
    /// </summary>
    /// <param name="WaitMaintainMachineList">待維修機器播放文字列表</param>
    public void TTS(List<dynamic> WaitMaintainMachineList)
    {
        System.IO.DirectoryInfo di = Util.GetTempDirectory();

        string FilePath = di.FullName + System.IO.Path.GetRandomFileName() + ".wav";

        string TokenID = BaseConfiguration.NewGuid();

        Session.Add(TokenID, new { MediaFilePath = FilePath, ContentType = "audio/wav" });

        Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "TokenID", "<script language=\"javascript\">var TokenID = '" + TokenID + "'</script>");

        string AlterAudioEventMinuteStartText = (string)GetLocalResourceObject("Str_AlterAudioEventMinuteStartText");

        string AlterAudioEventMinuteEndText = (string)GetLocalResourceObject("Str_AlterAudioEventMinuteEndText");

        string AlterAudioEndText = (string)GetLocalResourceObject("Str_AlterAudioEndText");

        System.Globalization.CultureInfo Culture = System.Threading.Thread.CurrentThread.CurrentUICulture;

        Task task = Task.Run(() =>
        {
            try
            {
                using (SpeechSynthesizer speechSynthesizer = new SpeechSynthesizer())
                {
                    PromptBuilder PB = new PromptBuilder();

                    foreach (var Machine in WaitMaintainMachineList)
                    {
                        PromptBuilder CulturePB = new PromptBuilder(Culture);

                        PB.StartVoice(Culture);

                        CulturePB.AppendText(Machine.MachineAlias + AlterAudioEventMinuteStartText + Machine.EventMinute + AlterAudioEventMinuteEndText);

                        PB.AppendPromptBuilder(CulturePB);

                        PB.AppendBreak(new TimeSpan(0, 0, 1));

                        PB.EndVoice();
                    }

                    PB.StartVoice(Culture);

                    PB.AppendBreak(new TimeSpan(0, 0, 2));

                    PB.AppendText(AlterAudioEndText);

                    PB.AppendBreak(new TimeSpan(0, 0, 10));

                    PB.EndVoice();

                    speechSynthesizer.Rate = -2;

                    speechSynthesizer.Volume = 100;

                    speechSynthesizer.SetOutputToWaveFile(FilePath);

                    speechSynthesizer.Speak(PB);
                }

                foreach (string ForderPath in System.IO.Directory.GetDirectories(Server.MapPath(@"~\" + BaseConfiguration.TempFolderPath)))
                {
                    System.IO.DirectoryInfo TempFolder = new System.IO.DirectoryInfo(ForderPath);

                    if ((DateTime.Now - TempFolder.CreationTime).TotalHours > 1)
                        TempFolder.Delete(true);
                }
            }
            catch (Exception ex)
            {
                System.IO.File.WriteAllText(di.FullName + "Error.txt", ex.ToString());
            }
        });
    }
}