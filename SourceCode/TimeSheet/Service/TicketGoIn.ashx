<%@ WebHandler Language="C#" Class="TicketGoIn" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketGoIn : BasePage
{
    protected string TicketID = string.Empty;
    protected string TicketTypeID = string.Empty;
    protected string TicketTypeName = string.Empty;
    protected Util.TS.TicketType TicketType;
    protected int TicketQty = 0;
    protected int TicketBox = 0;
    protected int ProcessID = 0;
    protected string BoxID = string.Empty;
    protected string MainTicketID = string.Empty;
    protected string ParentTicketID = string.Empty;
    protected string ParentTicketPath = string.Empty;
    protected int CreateProcessID = 0;
    protected string CreateProcessName = string.Empty;
    protected string MachineID = string.Empty;
    protected string MachineName = string.Empty;
    protected new string WorkCode = string.Empty;
    protected new int AccountID = -1;
    protected string AUFNR = string.Empty;
    protected string AUFPL = string.Empty;
    protected string APLZL = string.Empty;
    protected string VORNR = string.Empty;
    protected string LTXA1 = string.Empty;
    protected string PLNNR = string.Empty;
    protected string PLNAL = string.Empty;
    protected string PLNKN = string.Empty;
    protected string DeviceID = string.Empty;
    protected string CurrStatusDeviceID = string.Empty;
    protected string CurrStatusMachineID = string.Empty;
    protected DateTime EntryTime = DateTime.Now;
    protected string WorkShiftID = string.Empty;
    protected int AllowQty = 0;
    protected string Brand = string.Empty;
    protected string MOBatch = string.Empty;
    protected string RoutingName = string.Empty;
    protected string MAKTX = string.Empty;
    protected string TEXT1 = string.Empty;
    protected int MOBox = 0;
    protected int ResultBox = 0;
    protected int ReWorkMainProcessID = 0;
    protected int PreviousProcessID = 0;
    protected string DeviceGroupID = string.Empty;
    protected bool IsHaveChildren = false;
    protected bool IsHaveCurrStatus = false;
    protected bool IsFirstProcess = false;
    protected bool IsReWorkTicket = false;
    protected bool IsCanCreateReWorkTicket = true;
    protected bool IsCanCreateQuarantineTicket = true;
    protected bool IsHaveMaintainTicket = false;
    protected bool IsHaveWaitReportMaintainTicket = false;
    protected bool IsBrand = false;
    protected bool IsAlertChangeBrand = false; //是否提示變更了刻字號
    protected bool IsAlertChangeAUFNR = false;//是否提示變更了刻字號(前提前一張工單並未完成全數報工)
    protected bool IsMultipleGoIn = false; //是否為可以同時多重報工設備
    protected bool IsCheckPreviousMOFinish = false; //該進工的設備，是否要檢查前一張報工工單是否已全部報工完畢
    protected bool IsCheckProductionInspection = false; //該進工的設備，是否要檢查此工單是否已有產品送檢紀錄
    protected bool IsCheckSequenceDeclare = false; // 該進工的設備，是否要檢查此是否依照流程卡序號報工(只檢查一般的流程卡)
    protected string PreviousGoInAUFNR = string.Empty; //該進工的設備前一次報工工單號碼
    protected string PreviousGoInTEXT1 = string.Empty; //該進工的設備前一次報工工單生產版本
    protected string PreviousGoInCINFO = string.Empty; //該進工的設備前一次報工工單原材料批號

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();
            if (_context.Request["MachineID"] != null)
                MachineID = _context.Request["MachineID"].Trim();
            if (_context.Request["WorkCode"] != null)
                WorkCode = _context.Request["WorkCode"].Trim();
            if (_context.Request["WorkShiftID"] != null)
                WorkShiftID = _context.Request["WorkShiftID"].Trim();

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));
            if (string.IsNullOrEmpty(MachineID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MachineID"));
            if (string.IsNullOrEmpty(WorkCode))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkCode"));
            if (string.IsNullOrEmpty(WorkShiftID))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_WorkShiftID"));

            AccountID = BaseConfiguration.GetAccountID(WorkCode);

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            CheckGoInRule();

            LoadMOInfo();

            LoadResultBox();

            LoadMaintain();

            /* 如果成立代表當前工序並未有暫存進工資料 */
            if (!IsHaveCurrStatus)
            {
                /* 如果成立代表要檢查此流程卡號，是否有依照BoxID報工 */
                if (IsCheckSequenceDeclare && TicketType == Util.TS.TicketType.General)
                {
                    /* 如果不成立代表此流程卡BoxID與推算下來的BoxID不同。不允許進工 */
                    if (!CheckBoxIDSameNextBoxID())
                        throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketBoxID"));
                }

                LoadAllowQty();

                LoadBrand();

                GoIn();

                //如果成立代表此工單必須要有產品送檢紀錄。不能把這段放到 GoIn() 之後，避免T_TSTicketCurrStatus有資料。反之如果GoIn()在之前，是為了讓後續產品送檢的時候，可以選擇順便自動開立隔離單使用
                if (IsCheckProductionInspection)
                {
                    if (!IsHaveProductionInspectionData())
                        throw new CustomException((string)GetLocalResourceObject("Str_Error_ProductionInspection"));
                }
            }
            else
            {
                if (IsCheckProductionInspection)
                {
                    if (!IsHaveProductionInspectionData())
                        throw new CustomException((string)GetLocalResourceObject("Str_Error_ProductionInspection"));
                }
            }

            LoadIsHaveChildren();

            // 如果進工的設備是可以允許設定刻字號的設備，就在檢查進工的工單號和前一個報工工單號是否一致
            if (IsBrand)
                GetIsChangeBrandAlert();

            //如果是要檢查前一張報工工單是否已全部報工完畢，就在檢查當前進工流程卡號和前報工工單號是否一致，如果不一致加上前進工工單若沒有報工完畢，就提示並要現場幹部確認後才能進工
            if (IsCheckPreviousMOFinish)
            {
                GetIsChangeAUFNRAlert();

                if (IsAlertChangeAUFNR)
                    LoadPreviousGoInAUFNRInfo();
            }

            ResponseSuccessData(new
            {
                TicketID = TicketID,
                TicketTypeID = TicketTypeID,
                TicketTypeName = LoadTicketTypeName(),
                TicketQty = TicketQty,
                MainTicketID = MainTicketID,
                ParentTicketID = ParentTicketID,
                ParentTicketPath = ParentTicketPath,
                CreateProcessName = LoadCreateProcessName(),
                EntryTime = EntryTime.ToCurrentUICultureStringTime(),
                Brand = Brand,
                MOBox = ResultBox + "/" + MOBox,
                MAKTX = MAKTX,
                TEXT1 = TEXT1, //当前进工生产版本说明
                Batch = MOBatch,
                RoutingName = RoutingName,
                ProcessName = ProcessID + "-" + VORNR + "-" + LTXA1,
                AllowQty = AllowQty,
                DeviceID = DeviceID,
                MachineID = MachineID,
                MachineName = MachineName,
                IsLastBox = TicketType == Util.TS.TicketType.General ? (TicketBox == MOBox ? true : false) : false,
                IsHaveChildren = IsHaveChildren.ToStringValue(),
                IsFirstProcess = IsFirstProcess.ToStringValue(),
                IsQuarantinekTicket = (TicketType == Util.TS.TicketType.Quarantine),
                IsReWorkTicket = (TicketType == Util.TS.TicketType.Rework),
                IsCanCreateReWorkTicket = IsCanCreateReWorkTicket,
                IsCanCreateQuarantineTicket = IsCanCreateQuarantineTicket,
                IsHaveMaintainTicket = IsHaveMaintainTicket,
                IsHaveWaitReportMaintainTicket = IsHaveWaitReportMaintainTicket,
                IsAlertChangeBrand = IsAlertChangeBrand,
                IsAlertChangeAUFNR = IsAlertChangeAUFNR,
                PreviousGoInAUFNR = PreviousGoInAUFNR,
                PreviousGoInTEXT1 = PreviousGoInTEXT1,
                PreviousGoInCINFO = PreviousGoInCINFO
            });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 允許進工
    /// </summary>
    protected void GoIn()
    {
        DBAction DBA = new DBAction();

        string Query = @"Insert Into T_TSTicketCurrStatus (TicketID,ProcessID,AUFPL,APLZL,VORNR,DeviceID,EntryTime,WorkShiftID,Operator,AllowQty,Brand) Values (@TicketID,@ProcessID,@AUFPL,@APLZL,@VORNR,@DeviceID,GetDate(),@WorkShiftID,@Operator,@AllowQty,@Brand)";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));
        dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(AUFPL));
        dbcb.appendParameter(Schema.Attributes["APLZL"].copy(APLZL));
        dbcb.appendParameter(Schema.Attributes["VORNR"].copy(VORNR));
        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
        dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(WorkShiftID));
        dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));
        dbcb.appendParameter(Schema.Attributes["AllowQty"].copy(AllowQty));
        dbcb.appendParameter(Schema.Attributes["Brand"].copy(Brand));

        DBA.AddCommandBuilder(dbcb);

        DBA.AddCommandBuilder(Util.TS.GetChangeWorkStationStatusDBCB(DeviceID, Util.TS.WorkStationStatus.InMake, DateTime.Now, AccountID, WorkShiftID));

        DBA.Execute();
    }

    /// <summary>
    /// 刪除進工
    /// </summary>
    public void GoOut()
    {
        DBAction DBA = new DBAction();

        string Query = @"Delete T_TSTicketCurrStatus Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DBA.AddCommandBuilder(Util.TS.GetChangeWorkStationStatusDBCB(DeviceID, Util.TS.WorkStationStatus.Idle, DateTime.Now, AccountID, WorkShiftID));

        DBA.Execute();
    }

    /// <summary>
    /// 載入可允許報工數量
    /// </summary>
    /// <returns></returns>
    protected void LoadAllowQty()
    {
        string Query = @"Select * From T_TSTicketResult Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 如果成立的話，代表此流程卡並未有報工資料 */
        if (DT.Rows.Count < 1)
        {
            AllowQty = TicketQty;

            if (AllowQty < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketQty"));
        }
        else
        {
            Query = @"Select Top 1 * From T_TSTicketRouting Where TicketID = @TicketID And ProcessID < @ProcessID Order By ProcessID Desc";

            Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            DT = CommonDB.ExecuteSelectQuery(dbcb);

            /* 上一個工序 報工數量 */
            int PreviousTotalQty = 0;

            /*  成立代表上一個工序已完成報工 */
            if (DT.Rows.Count > 0 && (bool)DT.Rows[0]["IsEnd"])
                PreviousProcessID = (int)DT.Rows[0]["ProcessID"];

            /* 成立代表上一個工序已完成報工 */
            if (PreviousProcessID > 0)
            {
                dbcb = new DbCommandBuilder(@"Select * From T_TSTicketResult Where TicketID = @TicketID And ProcessID = @ProcessID");

                Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(PreviousProcessID));

                DataTable TicketResultDT = CommonDB.ExecuteSelectQuery(dbcb);

                int PreviousTotalGoodQty = TicketResultDT.AsEnumerable().Sum(Row => (int)Row["GoodQty"]);

                int PreviousTotalReWorkQty = TicketResultDT.AsEnumerable().Sum(Row => (int)Row["ReWorkQty"]);

                PreviousTotalQty = PreviousTotalGoodQty + PreviousTotalReWorkQty;
            }

            Query = @"Select * From T_TSTicketResult Where TicketID = @TicketID And ProcessID = @ProcessID";

            Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            DT = CommonDB.ExecuteSelectQuery(dbcb);

            int TotalGoodQty = DT.AsEnumerable().Sum(Row => (int)Row["GoodQty"]);

            int TotalReWorkQty = DT.AsEnumerable().Sum(Row => (int)Row["ReWorkQty"]);

            int TotalScrapQty = DT.AsEnumerable().Sum(Row => (int)Row["ScrapQty"]);

            Query = @"Select IsNull(Sum(Qty),0) From T_TSTicket Where ParentTicketID = @ParentTicketID And CreateProcessID = @CreateProcessID";

            Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["ParentTicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["CreateProcessID"].copy(ProcessID));

            //  因為有可能在同工序中，有開出隔離、返工單，因此的將開出的數量再扣除
            int SubTicketQty = (int)CommonDB.ExecuteScalar(dbcb);

            /* 成立代表上一個工序已完成報工，因此將上個工序報工數 - 現在工序已報數 - 已開出的數量 = 剩餘可報工數 */
            if (PreviousProcessID > 0)
                AllowQty = PreviousTotalQty - (TotalGoodQty + TotalReWorkQty) - TotalScrapQty - SubTicketQty;
            else
                AllowQty = TicketQty - (TotalGoodQty + TotalReWorkQty) - TotalScrapQty - SubTicketQty;

            if (AllowQty < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketQty"));
        }
    }

    /// <summary>
    ///  載入刻字號
    /// </summary>
    protected void LoadBrand()
    {
        string Query = @"Select * From T_TSTicketResult Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 如果成立的話，代表此流程卡並未有報工資料 */
        if (DT.Rows.Count < 1)
        {
            /* 如果成立，就去找刻字號表有沒有設定 */
            if (string.IsNullOrEmpty(ParentTicketID))
            {
                Brand = GetBrandSetData();
            }
            else
            {
                /* 要去找母單的最後一道工序最後報工有沒有刻字號 */
                Query = @"Select Top 1 Brand From T_TSTicketResult Where TicketID = @TicketID Order By ProcessID Desc,Serialno Desc";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(ParentTicketID));

                DT = CommonDB.ExecuteSelectQuery(dbcb);

                if (DT.Rows.Count > 0)
                    Brand = DT.Rows[0]["Brand"].ToString().Trim();
            }
        }
        else
        {
            if (TicketType == Util.TS.TicketType.General)
            {
                Brand = GetBrandSetData();

                /* 如果成立的話，代表此設備並沒有設定刻字號，因此試著去以上一道完成工序去找有沒有刻字號資料，如果有就沿用繼續下去 */
                if (string.IsNullOrEmpty(Brand) && PreviousProcessID > 0)
                    Brand = GetBrandByProcessID(PreviousProcessID);
            }
            else
            {
                Query = @"Select Top 1 Brand From T_TSTicketResult Where TicketID = @TicketID Order By ProcessID Desc,Serialno Desc";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                DT = CommonDB.ExecuteSelectQuery(dbcb);

                /* 如果自己的流程卡已有刻字號的話，就延續帶下。返工和隔離單通常應該在第一道工序就會抓下來 */
                if (DT.Rows.Count > 0 && !string.IsNullOrEmpty(DT.Rows[0]["Brand"].ToString().Trim()))
                    Brand = DT.Rows[0]["Brand"].ToString().Trim();
                else
                    Brand = GetBrandSetData(); /* 會到這裡，代表在開立返工或隔離單的時候，尚未有刻字號，因此就以當下有沒有設定刻字號 */
            }
        }
    }

    /// <summary>
    /// 以工序編號取得刻字號
    /// </summary>
    /// <returns>刻字號</returns>
    protected string GetBrandByProcessID(int TargetProcessID)
    {
        string Query = @"Select * From T_TSTicketResult Where TicketID = @TicketID And ProcessID = @ProcessID Order By SerialNo Desc";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(TargetProcessID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            return DT.Rows[0]["Brand"].ToString().Trim();
        else
            return string.Empty;
    }

    /// <summary>
    /// 以當下的設備ID取得是否有設定刻字號
    /// </summary>
    /// <returns>刻字號</returns>
    protected string GetBrandSetData()
    {
        string Query = @"Select Top 1 Brand From T_TSBrand Where DeviceID = @DeviceID And IsEnable = 1 Order By SerialNo Desc";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBrand"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            return DT.Rows[0]["Brand"].ToString().Trim();
        else
            return string.Empty;
    }

    /// <summary>
    /// 載入流程卡類別名稱
    /// </summary>
    /// <returns>流程卡類別名稱</returns>
    protected string LoadTicketTypeName()
    {
        string Query = @"Select Top 1 CodeName From T_Code Where CodeType = 'TS_TicketType' And UICulture = @UICulture And CodeID = @CodeID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Code"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["CodeID"].copy(TicketTypeID));

        dbcb.appendParameter(Schema.Attributes["UICulture"].copy(System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            return DT.Rows[0]["CodeName"].ToString().Trim();
        else
            return string.Empty;
    }

    /// <summary>
    /// 載入開單工序名稱
    /// </summary>
    /// <returns>開單工序名稱</returns>
    protected string LoadCreateProcessName()
    {
        string Result = string.Empty;

        if (!string.IsNullOrEmpty(ParentTicketID) && CreateProcessID > 0)
        {
            string Query = @"Select Convert(Nvarchar,ProcessID) + '-' +  VORNR + '-'+ LTXA1 As CreateProcessName From T_TSTicketRouting Where TicketID = @TicketID And ProcessID = @ProcessID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(CreateProcessID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count > 0)
                Result = DT.Rows[0]["CreateProcessName"].ToString().Trim();
        }

        return Result;
    }

    /// <summary>
    /// 載入工單資訊
    /// </summary>
    protected void LoadMOInfo()
    {
        string Query = @"Select Top 1 CINFO,KTEXT,MAKTX,TEXT1 From V_TSMORouting Where AUFNR = @AUFNR";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            MOBatch = DT.Rows[0]["CINFO"].ToString().Trim();
            RoutingName = DT.Rows[0]["KTEXT"].ToString().Trim();
            MAKTX = DT.Rows[0]["MAKTX"].ToString().Trim();
            TEXT1 = DT.Rows[0]["TEXT1"].ToString().Trim();
        }

        Query = @"Select Convert(int,Max(BoxID)) From T_TSTicket Where AUFNR = @AUFNR And TicketTypeID = @TicketTypeID";

        Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.General).ToString()));

        MOBox = (int)CommonDB.ExecuteScalar(dbcb);
    }

    //檢查是否可以進工規則
    protected void CheckGoInRule()
    {
        CheckTicketCurrStatus();

        CheckTicket();

        CheckMO();

        CheckRouting();

        CheckDevice();

        CheckWorkStation();
    }

    /// <summary>
    /// 檢查是否有此工作站 (預設應該是要有，如果沒有就是基礎資料沒設定好)
    /// </summary>
    protected void CheckWorkStation()
    {
        string Query = @"Select Count(*) From T_TSWorkStation Where DeviceID = @DeviceID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSWorkStation"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        if ((int)CommonDB.ExecuteScalar(dbcb) < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_NoWorkStationData"));
    }

    /// <summary>
    /// 檢查此設備是否可以上工
    /// </summary>
    protected void CheckDevice()
    {
        /* 如果有成立的話，代表此工單是有指定途程的，因此要再檢查此工序是否允許讓此機台報工 */
        if (!string.IsNullOrEmpty(PLNNR) && !string.IsNullOrEmpty(PLNAL) && !string.IsNullOrEmpty(PLNKN))
        {
            string Query = @"Select Top 1 T_TSDevice.DeviceID,T_TSDevice.IsMultipleGoIn,T_TSDevice.IsCheckPreviousMOFinish,IsCheckProductionInspection,IsCheckSequenceDeclare,IsSuspension,T_TSDevice.IsBrand,T_TSDevice.MachineName
                            From T_TSDeviceGroup
                            Inner Join T_TSDevice On T_TSDeviceGroup.DeviceID = T_TSDevice.DeviceID
                            Where T_TSDeviceGroup.DeviceGroupID = @DeviceGroupID And T_TSDevice.MachineID = @MachineID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDeviceGroup"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["DeviceGroupID"].copy(DeviceGroupID));

            Schema = DBSchema.currentDB.Tables["T_TSDevice"];

            dbcb.appendParameter(Schema.Attributes["MachineID"].copy(MachineID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            /* 如果成立的話，代表目前這各工序和機台匹配不上，不許允報工 */
            if (DT.Rows.Count < 1)
                throw new CustomException(string.Format((string)GetLocalResourceObject("Str_Error_MachineID"), LTXA1, MachineID));

            DeviceID = DT.Rows[0]["DeviceID"].ToString().Trim();

            MachineName = DT.Rows[0]["MachineName"].ToString().Trim();

            IsBrand = (bool)DT.Rows[0]["IsBrand"];

            IsMultipleGoIn = (bool)DT.Rows[0]["IsMultipleGoIn"];

            IsCheckPreviousMOFinish = (bool)DT.Rows[0]["IsCheckPreviousMOFinish"];

            IsCheckProductionInspection = (bool)DT.Rows[0]["IsCheckProductionInspection"];

            IsCheckSequenceDeclare = (bool)DT.Rows[0]["IsCheckSequenceDeclare"];

            if ((bool)DT.Rows[0]["IsSuspension"])
                throw new CustomException((string)GetLocalResourceObject("Str_Error_MachineInSuspension"));
        }
        else
        {
            /* 這裡代表這個工單沒有途程，因此只要將MachineID拿到DeviceID即可 */

            DataRow DeviceRow = Util.TS.GetDeviceRow(MachineID);

            if (DeviceRow == null)
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_DeviceRow"));

            DeviceID = DeviceRow["DeviceID"].ToString().Trim();

            MachineName = DeviceRow["MachineName"].ToString().Trim();

            IsBrand = (bool)DeviceRow["IsBrand"];

            IsMultipleGoIn = (bool)DeviceRow["IsMultipleGoIn"];

            IsCheckPreviousMOFinish = (bool)DeviceRow["IsCheckPreviousMOFinish"];

            IsCheckProductionInspection = (bool)DeviceRow["IsCheckProductionInspection"];

            IsCheckSequenceDeclare = (bool)DeviceRow["IsCheckSequenceDeclare"];

            if ((bool)DeviceRow["IsSuspension"])
                throw new CustomException((string)GetLocalResourceObject("Str_Error_MachineInSuspension"));

            if (string.IsNullOrEmpty(DeviceID))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_DeviceRow"));
        }

        /* 如果成立，要再檢查報工同時間當下，只能有一台設備可以進工 */
        if (!IsHaveCurrStatus && !IsMultipleGoIn)
        {
            string Query = @"Select Count(*) From T_TSTicketCurrStatus Where DeviceID = @DeviceID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

            if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_DeviceRepeat"));
        }
        else if (CurrStatusDeviceID != DeviceID && !IsMultipleGoIn)
            throw new CustomException(string.Format((string)GetLocalResourceObject("Str_Error_DeviceRepeatReport"), CurrStatusMachineID));
    }

    /// <summary>
    /// 檢查流程卡路由
    /// </summary>
    protected void CheckRouting()
    {
        string Query = string.Empty;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        /* 如果成立的話，代表此作業群組和計數器並不存在TicketCurrStatus。因此只要找出尚未完成的工序，並以工序編號排序 */
        if (!IsHaveCurrStatus)
        {
            Query = @"Select Top 1 * From T_TSTicketRouting Where TicketID = @TicketID And IsEnd = 0 Order By ProcessID Asc";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        }
        else
        {
            Query = @"Select Top 1 * From T_TSTicketRouting Where TicketID = @TicketID And ProcessID = @ProcessID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));
        }

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 理論上不會找不到資料，如果有那就出大事了 */
        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Empty_Routing"));

        ProcessID = (int)DT.Rows[0]["ProcessID"];

        VORNR = DT.Rows[0]["VORNR"].ToString().Trim();

        LTXA1 = DT.Rows[0]["LTXA1"].ToString().Trim();

        DeviceGroupID = DT.Rows[0]["DeviceGroupID"].ToString().Trim();

        IsFirstProcess = GetIsFirstProcess();

        /* 如果是隔離單流程卡的第一道工序就必須要檢查隔離單是否已經完成判定 */
        if (IsFirstProcess && TicketType == Util.TS.TicketType.Quarantine)
            CheckQuarantineResult();

        /* 220812 經王超測試過，除了返工單未達到開立點，不允許開出隔離單。其餘都可以開出 */
        // 隔離單的第一道工序允許再開立隔離單(因為已經判定過了，所以要用正常單來看待)。或者不是第一道工序允許可以開立隔離單
        //if ((TicketType == Util.TS.TicketType.Quarantine && IsFirstProcess) || !IsFirstProcess)
        //    IsCanCreateQuarantineTicket = true;
        //else
        //    IsCanCreateQuarantineTicket = false;

        /*  如果是返工單，當前的工序如果小於開單工序就不允許就開立隔離單  */
        if (TicketType == Util.TS.TicketType.Rework && (ProcessID < ReWorkMainProcessID))
            IsCanCreateQuarantineTicket = false;

        /* 如果當前的工序是超過源頭開立的返工單的工序就可以再開立返工單。 */
        if (ReWorkMainProcessID > 0)
            IsCanCreateReWorkTicket = (ProcessID >= ReWorkMainProcessID);
        else if (TicketType != Util.TS.TicketType.Quarantine && IsFirstProcess) /* 只要是第一道工序都不允許開立反工單。除了隔離單的第一道工序允許可以開立返工單，因為判定後的第一道工序不會是真的正常單的第一道工序(因為被卡控住，第一道工序不能開立隔離單) */
            IsCanCreateReWorkTicket = false;

        AUFPL = DT.Rows[0]["AUFPL"].ToString().Trim();

        APLZL = DT.Rows[0]["APLZL"].ToString().Trim();

        Query = @"Select Top 1 * From T_TSSAPAFVC Where AUFPL = @AUFPL And APLZL = @APLZL";

        Schema = DBSchema.currentDB.Tables["T_TSSAPAFVC"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFPL"].copy(AUFPL));

        dbcb.appendParameter(Schema.Attributes["APLZL"].copy(APLZL));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 如果成立的話，代表此工單是有指定途程的，因此要再檢查此工序是否活動中 */
        if (DT.Rows.Count > 0)
        {
            PLNNR = DT.Rows[0]["PLNNR"].ToString().Trim();

            PLNAL = DT.Rows[0]["PLNAL"].ToString().Trim();

            PLNKN = DT.Rows[0]["PLNKN"].ToString().Trim();

            /* 如果成立的話，代表此工單是有指定途程的，因此要再檢查此工序是否活動中 */
            if (!string.IsNullOrEmpty(PLNNR) && !string.IsNullOrEmpty(PLNAL) && !string.IsNullOrEmpty(PLNKN))
            {
                bool IsActivity = Util.TS.MOProcessIsActivity(PLNNR, PLNAL, PLNKN);

                /* 如果成立的話，代表此工序不在途程的活動中 */
                if (!IsActivity)
                    throw new CustomException(string.Format((string)GetLocalResourceObject("Str_Error_RoutingNotActive"), PLNNR, PLNAL, VORNR + "-" + LTXA1));
            }
        }
    }

    /// <summary>
    /// 檢查工單狀態
    /// </summary>
    protected void CheckMO()
    {
        string Query = @"Select Top 1 * From T_TSSAPAFKO Where AUFNR = @AUFNR";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Empty_MO"));

        Util.TS.MOStatus MOStatus = (Util.TS.MOStatus)Enum.Parse(typeof(Util.TS.MOStatus), DT.Rows[0]["STATUS"].ToString().Trim());

        /* 如果訂單已經關結，不許允報工 */
        if (MOStatus == Util.TS.MOStatus.Closed)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_MOSTATUS"));
    }

    /// <summary>
    /// 檢查流程卡狀態
    /// </summary>
    protected void CheckTicket()
    {
        string Query = @"Select Top 1 * From T_TSTicket Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 理論上不會找不到資料，如果有那就出大事了 */
        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

        /* 成立的話，代表此流程卡已關結，不許允報工*/
        if ((bool)DT.Rows[0]["IsEnd"])
            throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketClosed"));

        AUFNR = DT.Rows[0]["AUFNR"].ToString().Trim();

        TicketTypeID = DT.Rows[0]["TicketTypeID"].ToString().Trim();

        BoxID = DT.Rows[0]["BoxID"].ToString().Trim();

        TicketType = (Util.TS.TicketType)Enum.Parse(typeof(Util.TS.TicketType), TicketTypeID);

        TicketQty = (int)DT.Rows[0]["Qty"];

        MainTicketID = DT.Rows[0]["MainTicketID"].ToString().Trim();

        ParentTicketID = DT.Rows[0]["ParentTicketID"].ToString().Trim();

        CreateProcessID = (int)DT.Rows[0]["CreateProcessID"];

        TicketBox = int.Parse(DT.Rows[0]["BoxID"].ToString().Trim());

        ReWorkMainProcessID = (int)DT.Rows[0]["ReWorkMainProcessID"];

        if (!string.IsNullOrEmpty(ParentTicketID))
        {
            Query = @"Select dbo.TS_GetParentTicketIDPath(@TicketID,@Delimiter)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            dbcb.appendParameter(Util.GetDataAccessAttribute("Delimiter", "nvarchar", 50, "/"));

            ParentTicketPath = CommonDB.ExecuteScalar(dbcb).ToString().Trim();
        }
    }

    /// <summary>
    /// 檢查流程卡和操作員當前狀態
    /// </summary>
    protected void CheckTicketCurrStatus()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        string Query = @"Select *,(Select MachineID From T_TSDevice Where DeviceID = T_TSTicketCurrStatus.DeviceID) As MachineID,Base_Org.dbo.GetAccountName(T_TSTicketCurrStatus.Operator) As OperatorName From T_TSTicketCurrStatus Where TicketID = @TicketID Or Operator = @Operator";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        dbcb.appendParameter(Schema.Attributes["Operator"].copy(AccountID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            /* 如果成立代表此工流程卡正在被報工中，但不是由資料中的Operator來做，所不允許報工 */
            DataRow RejectRow = DT.AsEnumerable().Where(Row => Row["TicketID"].ToString().Trim() == TicketID && (int)Row["Operator"] != AccountID).FirstOrDefault();
            if (RejectRow != null)
            {
                string ErrorMessage = string.Format((string)GetLocalResourceObject("Str_Error_TicketInProgress"), RejectRow["OperatorName"].ToString().Trim(), RejectRow["MachineID"].ToString().Trim());

                throw new CustomException(ErrorMessage);
            }

            /*    
                因為一人會顧多機台，所以先不卡。如果成立代表此人正在處理別張工單中，因此不許允報工
            */
            //RejectRow = DT.AsEnumerable().Where(Row => Row["TicketID"].ToString().Trim() != TicketID && (int)Row["Operator"] == AccountID).FirstOrDefault();
            //if (RejectRow != null)
            //{
            //    string ErrorMessage = string.Format((string)GetLocalResourceObject("Str_Error_OperatorInProgress"), RejectRow["TicketID"].ToString().Trim(), RejectRow["MachineID"].ToString().Trim());

            //    throw new CustomException(ErrorMessage);
            //}

            DataRow ExistRow = DT.AsEnumerable().Where(Row => Row["TicketID"].ToString().Trim() == TicketID && (int)Row["Operator"] == AccountID).FirstOrDefault();
            /* 如果成立的話，代表此流程卡上次意外關閉或登出，因此需要將當前的狀態資料載入當作進工資料 */
            if (ExistRow != null)
            {
                IsHaveCurrStatus = true;

                ProcessID = (int)ExistRow["ProcessID"];

                CurrStatusMachineID = ExistRow["MachineID"].ToString().Trim();

                CurrStatusDeviceID = ExistRow["DeviceID"].ToString().Trim();

                EntryTime = (DateTime)ExistRow["EntryTime"];

                WorkShiftID = ExistRow["WorkShiftID"].ToString().Trim();

                AllowQty = (int)ExistRow["AllowQty"];

                Brand = ExistRow["Brand"].ToString().Trim();
            }
        }

        Query = @"Select Top 1 *,Base_Org.dbo.GetAccountName(T_TSTicketCurrStatus.Operator) As OperatorName From T_TSTicketCurrStatus Where DeviceID in (Select DeviceID From T_TSDevice Where MachineID = @MachineID And IsMultipleGoIn = 0) And TicketID <> @TicketID";

        dbcb = new DbCommandBuilder(Query);

        Schema = DBSchema.currentDB.Tables["T_TSDevice"];

        dbcb.appendParameter(Schema.Attributes["MachineID"].copy(MachineID));

        Schema = DBSchema.currentDB.Tables["T_TSTicketCurrStatus"];

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 如果此機台被其他工單上工了，就不允許再被上工 */
        if (DT.Rows.Count > 0)
        {
            string ErrorMessage = string.Format((string)GetLocalResourceObject("Str_Error_MachineInProgress"), DT.Rows[0]["TicketID"].ToString(), DT.Rows[0]["OperatorName"].ToString());

            throw new CustomException(ErrorMessage);
        }
    }

    /// <summary>
    /// 載入同工序中使否有開立出返工或隔離單
    /// </summary>
    protected void LoadIsHaveChildren()
    {
        string Query = @"Select Count(*) From T_TSTicket Where ParentTicketID = @ParentTicketID And CreateProcessID = @CreateProcessID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["ParentTicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["CreateProcessID"].copy(ProcessID));

        IsHaveChildren = (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 檢查隔離單是否已經完成判定
    /// </summary>
    protected void CheckQuarantineResult()
    {
        string Query = @"Select * From T_TSTicketQuarantineResult Where TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Empty_TicketIDForQuarantineResult"));

        if (!(bool)DT.Rows[0]["IsJudgment"])
            throw new CustomException((string)GetLocalResourceObject("Str_Error_NoIsJudgmentInQuarantineResult"));
    }

    /// <summary>
    /// 取得是否為第一道工序
    /// </summary>
    /// <returns>是否為第一道工序</returns>
    protected bool GetIsFirstProcess()
    {
        string Query = @"Select Count(*) From T_TSTicketRouting Where TicketID = @TicketID And ProcessID < @ProcessID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

        return (int)CommonDB.ExecuteScalar(dbcb) < 1;
    }

    /// <summary>
    /// 載入維修資料
    /// </summary>
    protected void LoadMaintain()
    {
        string Query = @"Select * From T_TSTicketMaintain Where TicketID = @TicketID And ProcessID = @ProcessID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return;

        IsHaveMaintainTicket = true;

        IsHaveWaitReportMaintainTicket = DT.AsEnumerable().Where(Row => (bool)Row["IsEnd"] == false).Count() > 0;
    }

    /// <summary>
    /// 載入同工序已完成報工框數(僅限一般流程卡)
    /// </summary>
    protected void LoadResultBox()
    {
        string Query = @"Select T_TSTicketResult.TicketID From T_TSTicketResult Inner Join T_TSTicket On T_TSTicketResult.TicketID = T_TSTicket.TicketID
                         Where T_TSTicket.AUFNR = @AUFNR And TicketTypeID = @TicketTypeID And ProcessID = @ProcessID And T_TSTicketResult.TicketID <> @TicketID
                         Group By T_TSTicketResult.TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.General).ToString()));

        Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        ResultBox = DT.Rows.Count;
    }

    /// <summary>
    /// 取得是否提醒變更刻字號提醒
    /// </summary>
    protected void GetIsChangeBrandAlert()
    {
        if (string.IsNullOrEmpty(PreviousGoInAUFNR))
            LoadPreviousGoInAUFNR();

        //IsAlertChangeBrand = (AUFNR != PreviousGoInAUFNR);

        /* 2023/05/15 生產課長提議要改為卡控。如果刻字號不一致要強制變更後才能上崗  */

        if (!string.IsNullOrEmpty(PreviousGoInAUFNR) && AUFNR != PreviousGoInAUFNR)
        {
            // 只能用設備編號去找，如果用上一張工單號去找，有機會發生其實沒有上一張工單號
            string Query = @"Select Top 1 Brand From T_TSTicketResult Where DeviceID = @DeviceID Order By ReportTimeEnd Desc";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count > 0)
            {
                string PreviousBrand = DT.Rows[0]["Brand"].ToString().Trim();

                IsAlertChangeBrand = (Brand == PreviousBrand);
            }
        }
        else if (string.IsNullOrEmpty(PreviousGoInAUFNR) && string.IsNullOrEmpty(Brand)) // 會成立代表此設備第一次上崗生產，務必要設定好刻字號
            IsAlertChangeBrand = true;
    }

    /// <summary>
    /// 取得是否提醒工單號提醒(前提前一張工單並未完成全數報工)
    /// </summary>
    protected void GetIsChangeAUFNRAlert()
    {
        if (TicketType == Util.TS.TicketType.General && !IsHaveWaitReportMaintainTicket && !IsHaveChildren)
        {
            if (string.IsNullOrEmpty(PreviousGoInAUFNR))
                LoadPreviousGoInAUFNR();

            if (!string.IsNullOrEmpty(PreviousGoInAUFNR) && AUFNR != PreviousGoInAUFNR)
            {
                ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

                string Query = @"Select 
                                Count(Result.TicketID) As TicketReportNum,
                                (Select Count(*) From T_TSTicket Where AUFNR = @AUFNR And TicketTypeID = @TicketTypeID And T_TSTicket.IsEnd = 0) As TicketBox
                                From
                                (
	                                Select 
		                                T_TSTicketResult.TicketID
	                                From T_TSTicketResult Inner Join T_TSTicket On T_TSTicketResult.TicketID = T_TSTicket.TicketID
	                                Where T_TSTicket.AUFNR = @AUFNR And TicketTypeID = @TicketTypeID And DeviceID = @DeviceID And T_TSTicket.IsEnd = 0
	                                Group By T_TSTicketResult.TicketID,T_TSTicketResult.ProcessID
                                ) As Result";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(PreviousGoInAUFNR));

                dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.General).ToString()));

                Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

                dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

                DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

                if (DT.Rows.Count > 0)
                {
                    int TicketReportNum = (int)DT.Rows[0]["TicketReportNum"];

                    int TicketBox = (int)DT.Rows[0]["TicketBox"];

                    IsAlertChangeAUFNR = (TicketReportNum < TicketBox);
                }
            }
        }
    }

    /// <summary>
    /// 載入該設備前一個報工工單號
    /// </summary>
    /// <returns></returns>
    protected void LoadPreviousGoInAUFNR()
    {
        string Query = @"Select T_TSTicket.AUFNR From T_TSTicketResult Inner Join T_TSTicket On T_TSTicketResult.TicketID = T_TSTicket.TicketID Where T_TSTicketResult.DeviceID = @DeviceID Order By T_TSTicketResult.CreateDate Desc";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            PreviousGoInAUFNR = DT.Rows[0][0].ToString().Trim();
    }

    /// <summary>
    /// 載入該設備前一個報工工單號的相關資訊
    /// </summary>
    protected void LoadPreviousGoInAUFNRInfo()
    {
        if (string.IsNullOrEmpty(PreviousGoInAUFNR))
            return;

        string Query = @"Select Top 1 * From V_TSMORouting Where AUFNR = @AUFNR";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(PreviousGoInAUFNR));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
        {
            PreviousGoInTEXT1 = DT.Rows[0]["TEXT1"].ToString().Trim();
            PreviousGoInCINFO = DT.Rows[0]["CINFO"].ToString().Trim();
        }
    }

    /// <summary>
    /// 取得此工單是否有產品送檢紀錄
    /// </summary>
    /// <returns>是否有產品送檢紀錄</returns>
    protected bool IsHaveProductionInspectionData()
    {
        bool Result = true;

        string Query = string.Empty;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspection"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        Query = "Select AUART From T_TSSAPAFKO Where AUFNR = @AUFNR";

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        dbcb.CommandText = Query;

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows[0][0].ToString().Trim() != "ZR20")
        {
            if (string.IsNullOrEmpty(Brand))
            {
                Query = @"Select Count(*) From T_TSProductionInspection Where AUFNR = @AUFNR";

                dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));
            }
            else
            {
                Query = @"Select Count(*) From T_TSProductionInspection Where Brand = @Brand";

                dbcb.appendParameter(Schema.Attributes["Brand"].copy(Brand));
            }

            dbcb.CommandText = Query;

            Result = (int)CommonDB.ExecuteScalar(dbcb) > 0;
        }

        return Result;
    }

    /// <summary>
    /// 檢查進工的流程卡序號是否為下一個序號(只會檢查一般的流程卡)
    /// </summary>
    /// <returns></returns>
    protected bool CheckBoxIDSameNextBoxID()
    {
        string Query = @"With PreviousETC AS (
                    Select Top 1 BoxID AS PreviousBoxID, AUFNR
                    From V_TSTicketResult Inner Join T_TSTicketRouting On V_TSTicketResult.TicketID = T_TSTicketRouting.TicketID And V_TSTicketResult.ProcessID = T_TSTicketRouting.ProcessID
                    Where DeviceID = @DeviceID And AUFNR = @AUFNR And V_TSTicketResult.ProcessID = @ProcessID And TicketTypeID = @TicketTypeID And T_TSTicketRouting.IsEnd = 1
                    Order By CreateDate Desc
                )
                Select Top 1 PreviousETC.PreviousBoxID, T_TSTicket.BoxID AS NextBoxID
                From PreviousETC Left Join T_TSTicket On T_TSTicket.AUFNR = PreviousETC.AUFNR And T_TSTicket.BoxID > PreviousETC.PreviousBoxID And T_TSTicket.TicketTypeID = @TicketTypeID And T_TSTicket.IsEnd = 0
                Order By T_TSTicket.BoxID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

        Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.General).ToString()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return true;

        string NextBoxID = DT.Rows[0]["NextBoxID"].ToString().Trim();

        return (BoxID == NextBoxID);
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}