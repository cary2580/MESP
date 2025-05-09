<%@ WebHandler Language="C#" Class="BaseRoutingGetList" %>

using System;
using System.Web;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;
using System.Collections.Generic;
using System.Linq;

public class BaseRoutingGetList : BasePage
{
    protected string PLNNR = string.Empty;
    protected string PLNAL = string.Empty;
    protected bool ReloadData = false;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["PLNNR"] != null)
                PLNNR = _context.Request["PLNNR"].Trim();
            if (_context.Request["PLNAL"] != null)
                PLNAL = _context.Request["PLNAL"].Trim();
            if (_context.Request["ReloadData"] != null)
                ReloadData = _context.Request["ReloadData"].ToBoolean();

            if (string.IsNullOrEmpty(PLNNR) || string.IsNullOrEmpty(PLNAL))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_PLNNRPLNAL"));

            if (ReloadData)
            {
                CheckHaveReportTicket();

                DeleteTSBaseRoutingData(PLNNR, PLNAL);
            }

            DataTable ResultDT = GetTSBaseRoutingData();

            if (ResultDT.Rows.Count < 1)
            {
                Synchronize_SAPData SAPSyn = new Synchronize_SAPData();
                //如果現有表沒有資料，要先更新一次SAP Routing
                SAPSyn.SynchronizeDataRoutingByKey(PLNNR, PLNAL);

                ResultDT = GetTSProcessData();

                //先把資料寫到TSBaseRouting，因為排序需要有ProcessID
                InsertToTSBaseRoutingData(ResultDT);
            }

            IEnumerable<DataColumn> Columns = ResultDT.Columns.Cast<DataColumn>();

            List<string> ColumnList = Columns.Select(Column => Column.ColumnName).ToList();

            object ResponseData = new
            {
                colModel = ColumnList.Select(ColumnName => new
                {
                    name = ColumnName,
                    index = ColumnName,
                    label = GetListLabel(ColumnName),
                    align = GetAlign(ColumnName),
                    width = GetWidth(ColumnName),
                    hidden = GetIsHidden(ColumnName),
                    sortable = false,
                    classes = (ColumnName == "KTEXT" || ColumnName == "DeviceGroupID" || ColumnName == "ProcessTypeName" || ColumnName == "ProcessStandardDay" || ColumnName == "ProcessReWorkStandardDay" || ColumnName == "IsOutputResultMinute" || ColumnName == "IsOutputResultMinuteForMan") ? BaseConfiguration.JQGridColumnClassesName : "",
                }),
                ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
                IsTSProcessValueColumnName = "IsTSProcessValue",
                PLNNRColumnName = "PLNNR",
                PLNALColumnName = "PLNAL",
                PLNKNColumnName = "PLNKN",
                ProcessIDColumnName = "ProcessID",
                DeviceGroupIDColumnName = "DeviceGroupID",
                ProcessTypeNameColumnName = "ProcessTypeName",
                ProcessReWorkStandardDayColumnName = "ProcessReWorkStandardDay",
                ProcessStandardDayColumnName = "ProcessStandardDay",
                IsOutputResultMinuteColumnName = "IsOutputResultMinute",
                IsOutputResultMinuteForManColumnName = "IsOutputResultMinuteForMan",
                Rows = ResultDT.AsEnumerable().Select(Row => new
                {
                    PLNNR = Row["PLNNR"].ToString().Trim(),
                    PLNAL = Row["PLNAL"].ToString().Trim(),
                    PLNKN = Row["PLNKN"].ToString().Trim(),
                    VORNR = Row["VORNR"].ToString().Trim(),
                    ProcessID = Row["ProcessID"].ToString().Trim(),
                    KTEXT = Row["KTEXT"].ToString().Trim(),
                    LTXA1 = Row["LTXA1"].ToString().Trim(),
                    ARBID = Row["ARBID"].ToString().Trim(),
                    ARBPL = Row["ARBPL"].ToString().Trim(),
                    VERAN = Row["VERAN"].ToString().Trim(),
                    VERAN_KTEXT = Row["VERAN_KTEXT"].ToString().Trim(),
                    VGW01 = Row["VGW01"].ToString().Trim(),
                    VGW02 = Row["VGW02"].ToString().Trim(),
                    USR00 = Row["USR00"].ToString().Trim(),
                    IsTSProcess = (bool)Row["IsTSProcessValue"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                    IsTSProcessValue = ((bool)Row["IsTSProcessValue"]).ToStringValue(),
                    ProcessTypeName = Row["ProcessTypeName"].ToString().Trim(),
                    ProcessReWorkStandardDay = Row["ProcessReWorkStandardDay"].ToString().Trim(),
                    ProcessStandardDay = Row["ProcessStandardDay"].ToString().Trim(),
                    DeviceGroupID = Row["DeviceGroupID"].ToString().Trim(),
                    IsOutputResultMinute = (bool)Row["IsOutputResultMinute"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                    IsOutputResultMinuteForMan = (bool)Row["IsOutputResultMinuteForMan"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                })
            };

            ResponseSuccessData(ResponseData);
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }
    /// <summary>
    /// 傳入欄位名稱取得對應語系的欄位名稱
    /// </summary>
    /// <param name="ColumnName"></param>
    /// <returns>對應語系的欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "PLNNR":
                return (string)GetLocalResourceObject("Str_PLNNR");
            case "PLNAL":
                return (string)GetLocalResourceObject("Str_PLNAL");
            case "PLNKN":
                return (string)GetLocalResourceObject("Str_PLNKN");
            case "ProcessID":
                return (string)GetLocalResourceObject("Str_ProcessID");
            case "IsTSProcess":
                return (string)GetLocalResourceObject("Str_IsTSProcess");
            case "VORNR":
                return (string)GetLocalResourceObject("Str_VORNR");
            case "KTEXT":
                return (string)GetLocalResourceObject("Str_KTEXT");
            case "LTXA1":
                return (string)GetLocalResourceObject("Str_LTXA1");
            case "ARBID":
                return (string)GetLocalResourceObject("Str_ARBID");
            case "ARBPL":
                return (string)GetLocalResourceObject("Str_ARBPL");
            case "VGW01":
                return (string)GetLocalResourceObject("Str_VGW01");
            case "VGW02":
                return (string)GetLocalResourceObject("Str_VGW02");
            case "USR00":
                return (string)GetLocalResourceObject("Str_USR00");
            case "DeviceGroupID":
                return (string)GetLocalResourceObject("Str_DeviceGroupID");
            case "IsOutputResultMinute":
                return (string)GetLocalResourceObject("Str_IsOutputResultMinute");
            case "IsOutputResultMinuteForMan":
                return (string)GetLocalResourceObject("Str_IsOutputResultMinuteForMan");
            case "ProcessTypeName":
                return (string)GetLocalResourceObject("Str_ProcessTypeName");
            case "ProcessStandardDay":
                return (string)GetLocalResourceObject("Str_ProcessStandardDay");
            case "ProcessReWorkStandardDay":
                return (string)GetLocalResourceObject("Str_ProcessReWorkStandardDay");
            default:
                return ColumnName;
        }
    }
    /// <summary>
    /// 傳入欄位名稱取得對齊方式
    /// </summary>
    /// <param name="ColumnName"></param>
    /// <returns>對齊方式</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "KTEXT":
            case "LTXA1":
                return "left";
            default:
                return "center";
        }
    }
    /// <summary>
    /// 傳入欄位名稱取得欄寬
    /// </summary>
    /// <param name="ColumnName"></param>
    /// <returns>欄寬</returns>
    protected int GetWidth(string ColumnName)
    {
        switch (ColumnName)
        {
            case "KTEXT":
            case "LTXA1":
                return 150;
            case "ProcessID":
                return 50;
            case "VORNR":
            case "VGW01":
            case "VGW02":
            case "USR00":
                return 60;
            case "IsTSProcess":
            case "ARBPL":
            case "ProcessTypeName":
            case "ProcessStandardDay":
            case "ProcessReWorkStandardDay":
                return 80;
            default:
                return 100;
        }
    }
    /// <summary>
    /// 傳入欄位名稱取得是否要隱藏
    /// </summary>
    /// <param name="ColumnName"></param>
    /// <returns>是否要隱藏</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "PLNKN":
            case "ARBID":
            case "VERAN":
            case "VERAN_KTEXT":
            case "IsTSProcessValue":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 取得已設定基礎路由資料
    /// </summary>
    /// <returns>已設定基礎路由資料</returns>
    protected DataTable GetTSBaseRoutingData()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Query = @"Select 
                        T_TSBaseRouting.PLNNR,T_TSBaseRouting.PLNAL,T_TSBaseRouting.PLNKN,T_TSBaseRouting.ProcessID,T_TSBaseRouting.VORNR,
		                KTEXT,LTXA1,ARBID,ARBPL,VERAN,VERAN_KTEXT,ProcessStandardDay,ProcessReWorkStandardDay,(Select CodeName From T_Code Where CodeType = @CodeType And CodeID = T_TSBaseRouting.ProcessTypeID And UICulture = @UICulture) As ProcessTypeName,
                        VGW01,VGW02,USR00,'' As IsTSProcess,IsTSProcess As IsTSProcessValue,T_TSProcessDeviceGroup.DeviceGroupID,IsOutputResultMinute,IsOutputResultMinuteForMan
                        From T_TSBaseRouting 
                        Left Join T_TSProcessDeviceGroup On T_TSBaseRouting.PLNNR = T_TSProcessDeviceGroup.PLNNR And T_TSBaseRouting.PLNAL = T_TSProcessDeviceGroup.PLNAL And T_TSBaseRouting.PLNKN = T_TSProcessDeviceGroup.PLNKN And T_TSBaseRouting.ProcessID = T_TSProcessDeviceGroup.ProcessID
                        Where T_TSBaseRouting.PLNNR = @PLNNR And T_TSBaseRouting.PLNAL = @PLNAL
                        Order By VORNR Asc,PLNKN Desc";

        dbcb.appendParameter(Util.GetDataAccessAttribute("PLNNR", "Nvarchar", 50, PLNNR));
        dbcb.appendParameter(Util.GetDataAccessAttribute("PLNAL", "Nvarchar", 50, PLNAL));

        dbcb.appendParameter(Util.GetDataAccessAttribute("CodeType", "Nvarchar", 50, "TS_ProcessTypeID"));
        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        dbcb.CommandText = Query;

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        return DT;
    }

    /// <summary>
    /// 取得SAP工序資料
    /// </summary>
    /// <returns>SAP工序資料</returns>
    protected DataTable GetTSProcessData()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Query = @"Select 
                        V_TSProcessActivity.PLNNR,V_TSProcessActivity.PLNAL,V_TSProcessActivity.PLNKN,V_TSProcessActivity.VORNR,ROW_NUMBER() OVER(ORDER BY V_TSProcessActivity.PLNNR,V_TSProcessActivity.PLNAL,V_TSProcessActivity.VORNR,V_TSProcessActivity.PLNKN Asc) As ProcessID,
		                KTEXT,LTXA1,ARBID,ARBPL,ARBPL_KTEXT,VERAN,VERAN_KTEXT,VGW01,VGW02,USR00,@IsTSProcess As IsTSProcess,@IsTSProcess As IsTSProcessValue,'' As ProcessTypeName,Null As ProcessStandardDay,Null As ProcessReWorkStandardDay,T_TSProcessDeviceGroup.DeviceGroupID,@IsOutputResultMinute As IsOutputResultMinute,@IsOutputResultMinuteForMan As IsOutputResultMinuteForMan
                        From V_TSProcessActivity 
                        Left Join T_TSProcessDeviceGroup On V_TSProcessActivity.PLNNR = T_TSProcessDeviceGroup.PLNNR And V_TSProcessActivity.PLNAL = T_TSProcessDeviceGroup.PLNAL And V_TSProcessActivity.PLNKN = T_TSProcessDeviceGroup.PLNKN
                        Where V_TSProcessActivity.PLNNR = @PLNNR And V_TSProcessActivity.PLNAL = @PLNAL
                        Order By VORNR Asc,PLNKN Desc";

        dbcb.appendParameter(Util.GetDataAccessAttribute("PLNNR", "Nvarchar", 50, PLNNR));
        dbcb.appendParameter(Util.GetDataAccessAttribute("PLNAL", "Nvarchar", 50, PLNAL));
        dbcb.appendParameter(Util.GetDataAccessAttribute("IsTSProcess", "bit", 0, false));
        dbcb.appendParameter(Util.GetDataAccessAttribute("IsOutputResultMinute", "bit", 0, true));
        dbcb.appendParameter(Util.GetDataAccessAttribute("IsOutputResultMinuteForMan", "bit", 0, true));

        dbcb.CommandText = Query;

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        return DT;
    }

    /// <summary>
    /// 傳入找到的V_TSProcess資料寫入TSBaseRouting資料表
    /// </summary>
    /// <param name="DT">V_TSProcess資料</param>
    protected void InsertToTSBaseRoutingData(DataTable DT)
    {
        DBAction DBA = new DBAction();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

        string Query = @"Insert Into T_TSBaseRouting (PLNNR,PLNAL,PLNKN,ProcessID,VORNR,KTEXT,LTXA1,ARBID,ARBPL,ARBPL_KTEXT,VERAN,VERAN_KTEXT,VGW01,VGW02,USR00,IsTSProcess)
                        Values (@PLNNR,@PLNAL,@PLNKN,@ProcessID,@VORNR,@KTEXT,@LTXA1,@ARBID,@ARBPL,@ARBPL_KTEXT,@VERAN,@VERAN_KTEXT,@VGW01,@VGW02,@USR00,@IsTSProcess)";

        foreach (DataRow DR in DT.Rows)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(DR["PLNNR"]));
            dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(DR["PLNAL"]));
            dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(DR["PLNKN"]));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(DR["ProcessID"]));
            dbcb.appendParameter(Schema.Attributes["VORNR"].copy(DR["VORNR"]));
            dbcb.appendParameter(Schema.Attributes["KTEXT"].copy(DR["KTEXT"]));
            dbcb.appendParameter(Schema.Attributes["LTXA1"].copy(DR["LTXA1"]));
            dbcb.appendParameter(Schema.Attributes["ARBID"].copy(DR["ARBID"]));
            dbcb.appendParameter(Schema.Attributes["ARBPL"].copy(DR["ARBPL"]));
            dbcb.appendParameter(Schema.Attributes["ARBPL_KTEXT"].copy(DR["ARBPL_KTEXT"]));
            dbcb.appendParameter(Schema.Attributes["VERAN"].copy(DR["VERAN"]));
            dbcb.appendParameter(Schema.Attributes["VERAN_KTEXT"].copy(DR["VERAN_KTEXT"]));
            dbcb.appendParameter(Schema.Attributes["VGW01"].copy(DR["VGW01"]));
            dbcb.appendParameter(Schema.Attributes["VGW02"].copy(DR["VGW02"]));
            dbcb.appendParameter(Schema.Attributes["USR00"].copy(DR["USR00"]));
            dbcb.appendParameter(Schema.Attributes["IsTSProcess"].copy(DR["IsTSProcess"]));

            DBA.AddCommandBuilder(dbcb);
        }

        DBA.Execute();
    }

    /// <summary>
    /// 傳入群組、群組計數刪除報工系統BaseRouting資料
    /// </summary>
    /// <param name="PLNNR">群組</param>
    /// <param name="PLNAL">群組計數</param>
    protected void DeleteTSBaseRoutingData(string PLNNR, string PLNAL)
    {
        DBAction DBA = new DBAction();

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

        string Query = @"Delete T_TSBaseRouting Where PLNNR = @PLNNR And PLNAL = @PLNAL";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("PLNNR", "Nvarchar", 50, PLNNR));
        dbcb.appendParameter(Util.GetDataAccessAttribute("PLNAL", "Nvarchar", 50, PLNAL));

        DBA.AddCommandBuilder(dbcb);

        Schema = DBSchema.currentDB.Tables["T_TSProcessDeviceGroup"];

        Query = @"Delete T_TSProcessDeviceGroup Where PLNNR = @PLNNR And PLNAL = @PLNAL";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("PLNNR", "Nvarchar", 50, PLNNR));
        dbcb.appendParameter(Util.GetDataAccessAttribute("PLNAL", "Nvarchar", 50, PLNAL));

        DBA.AddCommandBuilder(dbcb);

        DBA.Execute();
    }

    /// <summary>
    /// 檢查此群組計數器是否有報工過
    /// </summary>
    protected void CheckHaveReportTicket()
    {
        string Query = @"Select Count(T_TSTicket.TicketID)
                        From T_TSTicket Inner Join V_TSMORouting On T_TSTicket.AUFNR = V_TSMORouting.AUFNR
                        Where V_TSMORouting.PLNNR = @PLNNR And V_TSMORouting.PLNAL = @PLNAL
                        Group By V_TSMORouting.AUFNR";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("PLNNR", "Nvarchar", 50, PLNNR));

        dbcb.appendParameter(Util.GetDataAccessAttribute("PLNAL", "Nvarchar", 50, PLNAL));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_HaveTicketReportData"));
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}