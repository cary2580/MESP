<%@ WebHandler Language="C#" Class="MOWaitInfo" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class MOWaitInfo : BasePage
{
    protected string AUFNR = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["AUFNR"] != null)
                AUFNR = Util.TS.ToAUFNR(_context.Request["AUFNR"].Trim());

            if (string.IsNullOrEmpty(AUFNR))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_AUFNR"));

            /*  如果工單已經生成過流程卡，就不允許創建 */
            if (Util.TS.MOTicketIsExist(AUFNR))
                throw new CustomException((string)GetLocalResourceObject("Str_Exist_AUFNR"));

            /*  避免工單剛剛在SAP開立，但是尚未同步過來。因此確保一下，還是同步一次 */
            //Synchronize_SAPData.MO.SynchronizeDataMO(AUFNR);

            DataTable DT = GetMOData();

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_MO"));

            DataRow FirstRow = DT.Rows[0];

            string AUART = FirstRow["AUART"].ToString().Trim();
            string STATUS = FirstRow["STATUS"].ToString().Trim();
            string PLNNR = FirstRow["PLNNR"].ToString().Trim();
            string PLNAL = FirstRow["PLNAL"].ToString().Trim();
            string PLNBEZ = FirstRow["PLNBEZ"].ToString().Trim();
            string VERID = FirstRow["VERID"].ToString().Trim();
            string CINFO = FirstRow["CINFO"].ToString().Trim();
            string CHARG = FirstRow["CHARG"].ToString().Trim();
            string FTRMI = ((DateTime)FirstRow["FTRMI"]).ToCurrentUICultureString();
            string GSTRP = ((DateTime)FirstRow["GSTRP"]).ToCurrentUICultureString();
            string GLTRP = ((DateTime)FirstRow["GLTRP"]).ToCurrentUICultureString();
            double MOQty = 0;

            if (!double.TryParse(FirstRow["PSMNG"].ToString().Trim(), out MOQty))
                MOQty = 0;

            Util.TS.MOStatus MOStatus = (Util.TS.MOStatus)Enum.Parse(typeof(Util.TS.MOStatus), STATUS);

            if (MOStatus == Util.TS.MOStatus.Issued && AUART != "ZP21")
                /* 系统上线初，除了試產無料號(ZP21)、輔助製程工單(ZR20)、試產有料號工單(ZP20)可以允許不發料，就可以產生流程卡 */
                /* 240711,与潘素平确认，輔助製程工單(ZR20)、試產有料號工單(ZP20)，需要加卡控发料才能打印*/
                throw new CustomException((string)GetLocalResourceObject("Str_Error_MOStatus0"));
            else if (MOStatus == Util.TS.MOStatus.Closed)
                /*  I0045 = TECO、技術完成(技术性完成)
                    I0076 = DLID(标记)、刪除旗標(删除标记)
                    I0046 = CLSD(结算)、已關閉(已结算) */
                throw new CustomException((string)GetLocalResourceObject("Str_Error_MOStatus2"));

            /*  避免工單剛剛在SAP開立，但是尚未同步過來。因此確保一下，還是同步一次 */
            //if (!string.IsNullOrEmpty(PLNNR) && !string.IsNullOrEmpty(PLNAL))
            //    Synchronize_SAPData.Routing.SynchronizeDataRouting(PLNNR, PLNAL);

            /*  避免工單剛剛在SAP開立，但是尚未同步過來。因此確保一下，還是同步一次 */
            //if (!string.IsNullOrEmpty(PLNBEZ) && !string.IsNullOrEmpty(VERID))
            //    Synchronize_SAPData.PV.SynchronizeDataProductionVersion(PLNBEZ, VERID);

            DataTable BaseRouting = new DataTable();

            // 如果有路由群組碼和計數器就還要再去檢查該路由是否活動中。有些工單是沒有路由的所以就不用檢查，因為可能是試產工單。
            // 如果是輔助製程工單也不套用群組計數器(ZR20)
            if (!string.IsNullOrEmpty(PLNNR) && !string.IsNullOrEmpty(PLNAL) && AUART != "ZR20")
            {
                /* 有指定群組和計數器，Check每个工序对应的工种是否有维护，有工序没维护的就报错提示*/
                ProcessTypeIDIsEmpty(PLNNR, PLNAL);

                DataTable ProcessActivity = GetMOProcessActivity(PLNNR, PLNAL);

                foreach (DataRow Row in DT.Rows)
                {
                    string PLNKN = Row["PLNKN"].ToString().Trim();
                    string LTXA1 = Row["LTXA1"].ToString().Trim();

                    if (ProcessActivity.AsEnumerable().Where(PARow => PARow["PLNKN"].ToString().Trim() == PLNKN).Count() < 1)
                        throw new CustomException((string)GetLocalResourceObject("Str_Error_OperationUnActivity") + "(" + LTXA1 + ")");
                }

                BaseRouting = GetBaseRouting(PLNNR, PLNAL);

                if (BaseRouting.Rows.Count < 1)
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_BaseRoutingNoRow"));
            }
            else
            {
                DataTable BRDT = new DataTable();

                //輔助製程工單，因為開單時候，可以剃除不要的工序。因此去找 BaseRouting 所有工序
                if (AUART == "ZR20")
                    BRDT = GetBaseRouting(PLNNR, PLNAL, false);

                BaseRouting.Columns.Add("ProcessID", typeof(int));
                BaseRouting.Columns.Add("VORNR");
                BaseRouting.Columns.Add("ARBPL");
                BaseRouting.Columns.Add("LTXA1");

                int ProcessID = 0;

                for (int i = 0; i < DT.Rows.Count; i++)
                {
                    DataRow NewRow = BaseRouting.NewRow();

                    string DeviceGroupID = string.Empty;

                    ProcessID++;

                    if (AUART == "ZR20")
                    {
                        string PLNKN = DT.Rows[i]["PLNKN"].ToString().Trim();

                        var BR = BRDT.AsEnumerable().Where(MORoutingRow => MORoutingRow["PLNNR"].ToString().Trim() == PLNNR && MORoutingRow["PLNAL"].ToString().Trim() == PLNAL && MORoutingRow["PLNKN"].ToString().Trim() == PLNKN).Select(MORoutingRow => new { DeviceGroupID = MORoutingRow["DeviceGroupID"].ToString().Trim(), IsOutputResultMinuteForMan = (bool)MORoutingRow["IsOutputResultMinuteForMan"] }).FirstOrDefault();

                        /* 照理說不會錯誤，但如果找不到代表，基礎路由表有設置錯誤  */
                        if (BR == null || BR.IsOutputResultMinuteForMan && string.IsNullOrEmpty(BR.DeviceGroupID))
                            throw new CustomException((string)GetLocalResourceObject("Str_Error_ProcessNull") + "<br>PLNNR : " + PLNNR + "<br>PLNAL : " + PLNAL + "<br>PLNKN : " + PLNKN);
                        else if (!BR.IsOutputResultMinuteForMan)
                        {
                            //ProcessID--;
                            continue; //如果不需要人時，就不需要報工，所以這道工序就不需要加入到 T_TSTicketRouting 
                        }
                        else
                            DeviceGroupID = BR.DeviceGroupID;
                    }

                    NewRow["ProcessID"] = ProcessID;
                    NewRow["VORNR"] = DT.Rows[i]["VORNR"].ToString().Trim();
                    NewRow["ARBPL"] = DT.Rows[i]["ARBPL"].ToString().Trim();
                    NewRow["LTXA1"] = DT.Rows[i]["LTXA1"].ToString().Trim();

                    BaseRouting.Rows.Add(NewRow);
                }
            }

            // 如果是量產工單，其中有一道製程的工作中心是 RD001 的話也不允許開單 (240814 潘素萍提出修改)
            if (AUART == "ZM20" && BaseRouting.AsEnumerable().Where(Row => Row["ARBPL"].ToString().Trim() == "RD001").Count() > 0)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_ARBPL"));

            dynamic Result = new System.Dynamic.ExpandoObject();

            IEnumerable<DataColumn> Columns = BaseRouting.Columns.Cast<DataColumn>();

            List<string> ColumnList = Columns.Select(Column => Column.ColumnName).ToList();

            Result.OperationList = new
            {
                colModel = ColumnList.Select(ColumnName => new
                {
                    name = ColumnName,
                    index = ColumnName,
                    hidden = GetIsHidden(ColumnName),
                    label = GetListLabel(ColumnName),
                    align = GetAlign(ColumnName),
                    width = GetWidth(ColumnName),
                    sortable = false
                }),
                IsShowJQGridPager = false,
                Rows = BaseRouting.AsEnumerable().Select(Row => new
                {
                    ProcessID = (int)Row["ProcessID"],
                    VORNR = Row["VORNR"].ToString().Trim(),
                    ARBPL = Row["ARBPL"].ToString().Trim(),
                    LTXA1 = Row["LTXA1"].ToString().Trim()
                })
            };

            int MaxTicketBox = 0;
            int MaxTicketBoxQty = 0;

            if (!string.IsNullOrEmpty(PLNNR) && !string.IsNullOrEmpty(PLNAL) && !string.IsNullOrEmpty(PLNBEZ))
            {
                string Query = @"Select Top 1 MaxTicketBox,MaxTicketBoxQty From T_TSSAPMAPL Where PLNNR = @PLNNR And PLNAL = @PLNAL And MATNR = @MATNR";

                ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPMAPL"];

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(PLNNR));
                dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(PLNAL));
                dbcb.appendParameter(Schema.Attributes["MATNR"].copy(PLNBEZ));

                DT = CommonDB.ExecuteSelectQuery(dbcb);

                if (DT.Rows.Count > 0)
                {
                    MaxTicketBox = (int)DT.Rows[0]["MaxTicketBox"];
                    MaxTicketBoxQty = (int)DT.Rows[0]["MaxTicketBoxQty"];
                }
            }

            Result.MOInfo = new
            {
                AUFNR = AUFNR,
                AUARTName = FirstRow["AUARTName"].ToString().Trim(),
                VERID = VERID,
                PLNBEZ = PLNBEZ,
                MAKTX = FirstRow["MAKTX"].ToString().Trim(),
                ZEINR = FirstRow["ZEINR"].ToString().Trim(),
                FERTH = FirstRow["FERTH"].ToString().Trim(),
                PLNNR = PLNNR,
                PLNAL = PLNAL,
                KTEXT = FirstRow["KTEXT"].ToString().Trim(),
                MaxTicketBox = MaxTicketBox > 0 ? MaxTicketBox : MaxTicketBoxQty > 0 ? Math.Ceiling(MOQty / MaxTicketBoxQty) : 0,
                MaxTicketBoxQty = MaxTicketBoxQty,
                PSMNG = (int)MOQty,
                FTRMI = FTRMI,
                CINFO = CINFO,
                CHARG = CHARG,
                GSTRP = GSTRP,
                GLTRP = GLTRP
            };

            ResponseSuccessData(Result);
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 欄位標題
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <returns>標題</returns>
    private string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ProcessID":
                return (string)GetLocalResourceObject("Str_ListColumnName1");
            case "VORNR":
                return (string)GetLocalResourceObject("Str_ListColumnName2");
            case "ARBPL":
                return (string)GetLocalResourceObject("Str_ListColumnName3");
            case "LTXA1":
                return (string)GetLocalResourceObject("Str_ListColumnName4");
            default:
                return string.Empty;
        }
    }

    /// <summary>
    /// 欄位是否顯示
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <returns>是否顯示</returns>
    public bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ProcessID":
            case "VORNR":
            case "ARBPL":
            case "LTXA1":
                return false;
            default:
                return true;
        }
    }

    /// <summary>
    /// 欄位寬度
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <returns>欄位寬度</returns>
    protected int GetWidth(string ColumnName)
    {
        switch (ColumnName)
        {
            case "LTXA1":
                return 200;
            default:
                return 80;
        }
    }

    /// <summary>
    /// 欄位對齊
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <returns>欄位對齊</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ProcessID":
            case "VORNR":
            case "ARBPL":
                return "center";
            default:
                return "left";
        }
    }

    /// <summary>
    /// 取得工單基本資料
    /// </summary>
    /// <returns></returns>
    private DataTable GetMOData()
    {
        string Query = @"Select * From V_TSMORouting Where AUFNR = @AUFNR Order By PLNNR,VORNR";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// Check群组中工序对应工种有没有维护好，任何一个工序未维护工种就报错
    /// </summary>
    /// <param name="PLNNR">群组码</param>
    /// <param name="PLNAL">计数器</param>
    protected void ProcessTypeIDIsEmpty(string PLNNR, string PLNAL)
    {
        string Query = @"Select Count(*) From T_TSBaseRouting Where PLNNR = @PLNNR And PLNAL = @PLNAL And IsNull(ProcessTypeID,'') = ''";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(PLNNR.Trim()));

        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(PLNAL.Trim()));

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new Exception((string)GetLocalResourceObject("Str_Error_HaveProcessTypeIDEmpty"));
    }

    /// <summary>
    /// 指定群組碼和群組計數器取得報工系統基礎路由表
    /// </summary>
    /// <param name="PLNNR">途程群組碼</param>
    /// <param name="PLNAL">途程計數器</param>
    /// <param name="IsOutputResultMinuteForMan">是否只要輸出SAP人時</param>
    /// <returns>報工系統基礎路由表</returns>
    protected DataTable GetBaseRouting(string PLNNR, string PLNAL, bool IsOutputResultMinuteForMan = true)
    {
        string Query = @"Select T_TSBaseRouting.*,'' As AUFPL,'' As APLZL ,T_TSProcessDeviceGroup.DeviceGroupID
                        From T_TSBaseRouting 
                        Inner Join T_TSProcessDeviceGroup On T_TSBaseRouting.PLNNR = T_TSProcessDeviceGroup.PLNNR And T_TSBaseRouting.PLNAL = T_TSProcessDeviceGroup.PLNAL And T_TSBaseRouting.PLNKN = T_TSProcessDeviceGroup.PLNKN And T_TSBaseRouting.ProcessID = T_TSProcessDeviceGroup.ProcessID
                        Where T_TSBaseRouting.PLNNR = @PLNNR And T_TSBaseRouting.PLNAL = @PLNAL ";

        if (IsOutputResultMinuteForMan)
        {
            Query += @"  And T_TSBaseRouting.IsOutputResultMinuteForMan = 1  /*只需要人時報工的部分才需要報工。目前只有機時不需要用人時的只有ED這道工序*/
                        Order By T_TSBaseRouting.ProcessID Asc";
        }
        else
            Query += @" Order By T_TSBaseRouting.VORNR Asc";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBaseRouting"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(PLNNR.Trim()));

        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(PLNAL.Trim()));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 指定群組和計數器取得訂單途程啟用中工序資料表
    /// </summary>
    /// <returns>訂單途程啟用中工序資料表</returns>
    protected DataTable GetMOProcessActivity(string PLNNR, string PLNAL)
    {
        string Query = @"Select * From V_TSProcessActivity Where PLNNR = @PLNNR And PLNAL = @PLNAL";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPPLAS"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(PLNNR.Trim()));
        dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(PLNAL.Trim()));

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