<%@ WebHandler Language="C#" Class="RPT_022" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class RPT_022 : BasePage
{
    protected bool IsGetChartData = false;
    protected DateTime ReportDateStart = DateTime.Parse("1900/01/01");
    protected DateTime ReportDateEnd = DateTime.Parse("1900/01/01");
    protected string GroupID = string.Empty;
    protected string ScrapReasonID = string.Empty;
    protected string AUFNR = string.Empty;
    protected string OverScrapRateSkip = string.Empty;
    protected bool IsSkipMissing = true;
    protected bool IsOnlyViewCloseMO = true;
    protected DataTable ResultDataTable1 = new DataTable();
    protected DataTable ResultDataTable2 = new DataTable();
    protected DataTable ResultDataTable3 = new DataTable();
    protected DataSet ResultDataSet = new DataSet();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            IsGetChartData = _context.Request["IsGetChartData"].ToBoolean();

            if (_context.Request["AUFNR"] != null)
                AUFNR = _context.Request["AUFNR"].Trim();

            if (_context.Request["ReportDateStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["ReportDateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDateStart))
                    ReportDateStart = DateTime.Now;
            }

            if (_context.Request["ReportDateEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["ReportDateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out ReportDateEnd))
                    ReportDateEnd = DateTime.Now;
            }

            if (string.IsNullOrEmpty(AUFNR) && (ReportDateStart.Year < 1911 || ReportDateEnd.Year < 1911))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            if (_context.Request["GroupID"] != null)
                GroupID = _context.Request["GroupID"].Trim();

            if (_context.Request["OverScrapRateSkip"] != null)
                OverScrapRateSkip = _context.Request["OverScrapRateSkip"].Trim();

            if (_context.Request["IsSkipMissing"] != null)
                IsSkipMissing = _context.Request["IsSkipMissing"].ToBoolean();

            if (_context.Request["IsOnlyViewCloseMO"] != null)
                IsOnlyViewCloseMO = _context.Request["IsOnlyViewCloseMO"].ToBoolean();

            if (_context.Request["ScrapReasonID"] != null)
                ScrapReasonID = _context.Request["ScrapReasonID"].Trim();

            if (IsGetChartData)
            {
                LoadExportData();

                if (ResultDataTable1.Rows.Count < 1 || ResultDataTable1.AsEnumerable().Sum(Row => (decimal)Row["ScrapRate"]) < (decimal)0.00001)
                    throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

                List<dynamic> ResponseData = new List<dynamic>();

                ResponseData.Add(new
                {
                    yAxisTitle = (string)GetLocalResourceObject("Str_yAxisTitle"),
                    MedianScrapRate = (decimal)ResultDataTable1.Rows[0]["MedianScrapRate"],
                    MedianScrapRateByUp50 = (decimal)ResultDataTable1.Rows[0]["MedianScrapRateByUp50"],
                    MedianScrapRateByUp100 = (decimal)ResultDataTable1.Rows[0]["MedianScrapRateByUp100"],
                    MedianScrapRateByDown50 = (decimal)ResultDataTable1.Rows[0]["MedianScrapRateByDown50"],
                    ChartValue = GetChart1Data(),
                    JqGridData = GetJqGridResponseData()
                });

                ResponseData.Add(new
                {
                    ChartValue = GetChart2Data(),
                    ChartDetailValue = GetChart3Data(),
                    DefectScrapQtyText = (string)GetLocalResourceObject("Str_ColumnName_ScrapQty")
                });

                ResponseSuccessData(ResponseData);
            }
            else
            {
                ResponseSuccessData(GetJqGridResponseDataByMO());
            }

        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 取得JqGrid資料For工單報廢清單
    /// </summary>
    /// <returns>工單報廢清單</returns>
    protected object GetJqGridResponseDataByMO()
    {
        string Query = @"Select 
                            V_TSTicketResult.ReportDate,
                            V_TSTicketResult.TicketID,
                            V_TSTicketResult.LTXA1,
                            V_TSTicketResult.CINFO,
                            V_TSTicketResult.CHARG,
                            V_TSTicketResult.Brand,
                            (Select Top 1 MachineID From T_TSDevice Where DeviceID = T_TSTicketQuarantineResult.DeviceID) As MachineID,
                            Case
	                            When (Select Count(*) From T_TSDevice Where DeviceID In (Select Top 1 DeviceID From V_TSTicketResult Where V_TSTicketResult.TicketID = T_TSTicket.ParentTicketID And V_TSTicketResult.ProcessTypeID = '3')) > 0
	                            Then (Select Top 1 MachineID From T_TSDevice Where DeviceID In (Select Top 1 DeviceID From V_TSTicketResult Where V_TSTicketResult.TicketID = T_TSTicket.ParentTicketID And V_TSTicketResult.ProcessTypeID = '3' Order By V_TSTicketResult.ProcessID Asc))
	                            Else (Select Top 1 MachineID From T_TSDevice Where DeviceID In (Select Top 1 DeviceID From V_TSTicketResult Where V_TSTicketResult.TicketID = T_TSTicket.MainTicketID And V_TSTicketResult.ProcessTypeID = '3' Order By V_TSTicketResult.ProcessID Asc))
                            End As EDMachineID,
                            T_TSScrapReason.ScrapReasonName,
                            Replace(Replace(T_TSDefect.DefectName, Char(13), ''), Char(10), '') As DefectName,
                            T_TSTicketQuarantineResultItem.ScrapQty,
                            V_TSMORouting.RawMaterialVendorName

                        From V_TSTicketResult
	                            Inner Join T_TSTicket On T_TSTicket.TicketID = V_TSTicketResult.TicketID
	                            Inner Join T_TSTicketQuarantineResult On T_TSTicketQuarantineResult.TicketID = V_TSTicketResult.TicketID And T_TSTicketQuarantineResult.ProcessID = V_TSTicketResult.ProcessID And V_TSTicketResult.ScrapQty > 0
	                            Inner Join T_TSTicketQuarantineResultItem On T_TSTicketQuarantineResultItem.TicketID = T_TSTicketQuarantineResult.TicketID
	                            Inner Join T_TSScrapReason On T_TSScrapReason.ScrapReasonID = T_TSTicketQuarantineResultItem.ScrapReasonID
	                            Inner Join T_TSDefect On T_TSDefect.DefectID = T_TSTicketQuarantineResultItem.DefectID
	                            Inner Join V_TSMORouting On V_TSMORouting.AUFNR = T_TSTicket.AUFNR And V_TSMORouting.AUFPL = T_TSTicketQuarantineResult.AUFPL And V_TSMORouting.APLZL = T_TSTicketQuarantineResult.APLZL
                        Where T_TSTicketQuarantineResult.IsJudgment = 1
                        And IsNull(V_TSTicketResult.Approver,0) > 0 And V_TSTicketResult.ApprovalTime Is Not Null 
                        And V_TSTicketResult.AUFNR = @AUFNR
                        And T_TSTicketQuarantineResultItem.ScrapReasonID = IIF(IsNull(@ScrapReasonID,'') = '',T_TSTicketQuarantineResultItem.ScrapReasonID,@ScrapReasonID)";

        if (IsSkipMissing)
            Query += " And T_TSTicketQuarantineResultItem.DefectID <> '0000' ";

        Query += " Order By T_TSScrapReason.ScrapReasonID,V_TSTicketResult.ReportDate,V_TSTicketResult.TicketID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResultItem"];

        dbcb.appendParameter(Schema.Attributes["ScrapReasonID"].copy(ScrapReasonID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        List<DataRow> Rows = DT.AsEnumerable().ToList();

        return new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName),
                searchoptions = GetSearchOptions(Column.ColumnName, Rows),
                sorttype = GetSortType(Column.ColumnName),
                classes = Column.ColumnName == "TicketID" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            FilterDateTimeColumnNames = new string[] { "ReportDate" },
            TicketIDColumnName = (string)GetLocalResourceObject("Str_ColumnName_TicketID"),
            TicketIDValueColumnName = "TicketID",
            QtyColumnName = "ScrapQty",
            SubTotalColumnName = "DefectName",
            Rows = Rows.Select(Row => new
            {
                ReportDate = ((DateTime)Row["ReportDate"]).ToCurrentUICultureString(),
                TicketID = Row["TicketID"].ToString().Trim(),
                LTXA1 = Row["LTXA1"].ToString().Trim(),
                CINFO = Row["CINFO"].ToString().Trim(),
                CHARG = Row["CHARG"].ToString().Trim(),
                Brand = Row["Brand"].ToString().Trim(),
                MachineID = Row["MachineID"].ToString().Trim(),
                EDMachineID = Row["EDMachineID"].ToString().Trim(),
                ScrapReasonName = Row["ScrapReasonName"].ToString().Trim(),
                DefectName = Row["DefectName"].ToString().Trim(),
                ScrapQty = Row["ScrapQty"].ToString().Trim(),
                RawMaterialVendorName = Row["RawMaterialVendorName"].ToString().Trim()
            })
        };
    }

    /// <summary>
    /// 載入匯出資料
    /// </summary>
    protected void LoadExportData()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_022");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateStart", "DateTime", 0, ReportDateStart));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ReportDateEnd", "DateTime", 0, ReportDateEnd));

        dbcb.appendParameter(Util.GetDataAccessAttribute("AUFNR", "Nvarchar", 50, AUFNR));

        dbcb.appendParameter(Util.GetDataAccessAttribute("GroupID", "Nvarchar", 50, GroupID));

        dbcb.appendParameter(Util.GetDataAccessAttribute("ScrapReasonID", "Nvarchar", 500, ScrapReasonID));

        dbcb.appendParameter(Util.GetDataAccessAttribute("OverScrapRateSkip", "Decimal", 0, OverScrapRateSkip));

        dbcb.appendParameter(Util.GetDataAccessAttribute("IsMoClose", "bit", 0, IsOnlyViewCloseMO));

        dbcb.appendParameter(Util.GetDataAccessAttribute("MOStatusByInProduction", "Nvarchar", 50, ((short)Util.TS.MOStatus.InProcess).ToString()));

        dbcb.appendParameter(Util.GetDataAccessAttribute("MOStatusByInClose", "Nvarchar", 50, ((short)Util.TS.MOStatus.Closed).ToString()));

        dbcb.appendParameter(Util.GetDataAccessAttribute("IsSkipMissing", "bit", 0, IsSkipMissing));

        ResultDataSet = CommonDB.ExecuteSelectQueryToDataSet(dbcb);

        ResultDataTable1 = ResultDataSet.Tables[0];

        ResultDataTable2 = ResultDataSet.Tables[1];

        ResultDataTable3 = ResultDataSet.Tables[2];
    }

    /// <summary>
    /// 取得圖表1資料
    /// </summary>
    /// <returns>圖表1資料</returns>
    protected List<Util.ChartSeriesOption> GetChart1Data()
    {
        List<Util.ChartSeriesOption> Result = new List<Util.ChartSeriesOption>();

        var VeridList = ResultDataTable1.AsEnumerable().GroupBy(Row => Row["VERID"].ToString().Trim()).Select(Item => Item.Key).ToList();

        foreach (string VERID in VeridList)
        {
            List<object> LineDataList = new List<object>();

            var ScrapRateList = ResultDataTable1.AsEnumerable().Where(Row => Row["VERID"].ToString().Trim() == VERID).Select(Row => new { AUFNR = Row["AUFNR"].ToString().Trim(), ScrapRate = (decimal)Row["ScrapRate"] }).ToList();

            for (int i = 0; i < ScrapRateList.Count(); i++)
            {
                List<object> RateValue = new List<object>();

                RateValue.Add(ScrapRateList[i].AUFNR);

                RateValue.Add(ScrapRateList[i].ScrapRate);

                LineDataList.Add(RateValue);
            }

            Result.Add(new Util.ChartSeriesOption() { name = VERID, data = LineDataList });
        }

        return Result;
    }

    /// <summary>
    /// 取得圖表2資料
    /// </summary>
    /// <returns>圖表2資料</returns>
    protected List<dynamic> GetChart2Data()
    {
        List<dynamic> Result = new List<dynamic>();

        foreach (DataRow Row in ResultDataTable2.Rows)
        {
            dynamic ResultValue = new System.Dynamic.ExpandoObject();

            ResultValue.name = Row["ScrapReasonName"].ToString().Trim();

            ResultValue.y = (decimal)Row["ScrapRate"];

            ResultValue.z = (int)Row["ScrapQty"];

            ResultValue.drilldown = Row["ScrapReasonID"].ToString().Trim();

            Result.Add(ResultValue);
        }

        return Result;
    }

    /// <summary>
    /// 取得圖表3資料
    /// </summary>
    /// <returns>圖表3資料</returns>
    protected List<dynamic> GetChart3Data()
    {
        List<dynamic> Result = new List<dynamic>();

        var ScrapReasonIDList = ResultDataTable3.AsEnumerable().GroupBy(Row => Row["ScrapReasonID"].ToString().Trim()).Select(Item => Item.Key).ToList();

        foreach (string ScrapReasonID in ScrapReasonIDList)
        {
            dynamic ResultValue = new System.Dynamic.ExpandoObject();

            var DefectList = ResultDataTable3.AsEnumerable().Where(Row => Row["ScrapReasonID"].ToString().Trim() == ScrapReasonID).Select(Row => new { ScrapReasonName = Row["ScrapReasonName"].ToString().Trim(), DefectID = Row["DefectID"].ToString().Trim(), DefectName = Row["DefectName"].ToString().Trim(), ScrapQty = (int)Row["ScrapQty"], ScrapRate = (decimal)Row["ScrapRate"] }).ToList();

            ResultValue.name = DefectList.First().ScrapReasonName;

            ResultValue.id = ScrapReasonID;

            ResultValue.data = DefectList.Select(DefectItem => new { name = DefectItem.DefectName, y = DefectItem.ScrapRate, z = DefectItem.ScrapQty }).ToList();

            Result.Add(ResultValue);
        }

        return Result;
    }

    /// <summary>
    /// 取得JqGrid資料
    /// </summary>
    /// <returns>資料來源</returns>
    protected object GetJqGridResponseData()
    {
        DataColumnCollection DCC = ResultDataTable1.Columns;

        DCC.Add("ScrapRateValue", typeof(decimal));

        IEnumerable<DataColumn> Columns = DCC.Cast<DataColumn>();

        List<DataRow> Rows = ResultDataTable1.AsEnumerable().ToList();

        return new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName),
                searchoptions = GetSearchOptions(Column.ColumnName, Rows),
                sorttype = GetSortType(Column.ColumnName),
                classes = Column.ColumnName == "AUFNR" ? BaseConfiguration.JQGridColumnClassesName : "",
            }),
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            AUFNRValueColumnName = "AUFNR",
            FilterDateTimeColumnNames = new string[] { "MOCloseDateTime" },
            ScrapRateColumnName = "ScrapRate",
            ScrapRateValueColumnName = "ScrapRateValue",
            AvgColumnName = "ScrapQty",
            Rows = Rows.Select(Row => new
            {
                VERID = Row["VERID"].ToString().Trim(),
                AUFNR = Row["AUFNR"].ToString().Trim(),
                PSMNG = ((decimal)Row["PSMNG"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapQty = ((int)Row["ScrapQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapRate = ((decimal)Row["ScrapRate"]).ToString("P3", System.Threading.Thread.CurrentThread.CurrentUICulture),
                ScrapRateValue = ((decimal)Row["ScrapRate"]).ToString("N5", System.Threading.Thread.CurrentThread.CurrentUICulture),
                MOCloseDateTime = ((DateTime)Row["MOCloseDateTime"]).ToCurrentUICultureString(),
                ReportColor = (decimal)Row["ScrapRate"] > (decimal)Row["MedianScrapRateByUp100"] ? "red" : string.Empty
            })
        };
    }

    /// <summary>
    /// 指定ColumnName得到對齊方式
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>對齊方式</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "VERID":
            case "MOCloseDateTime":
            case "LTXA1":
            case "MachineID":
            case "EDMachineID":
            case "ReportDate":
                return "center";
            case "PSMNG":
            case "ScrapQty":
            case "ScrapRate":
                return "right";
            default:
                return "left";
        }
    }

    /// <summary>
    /// 指定ColumnName得到欄位寬度
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>欄位寬度</returns>
    protected int GetWidth(string ColumnName)
    {
        switch (ColumnName)
        {
            case "VERID":
            case "PSMNG":
            case "ScrapQty":
            case "ScrapRate":
            case "MachineID":
            case "EDMachineID":
                return 40;
            case "LTXA1":
            case "ReportDate":
            case "CHARG":
            case "Brand":
                return 60;
            case "MOCloseDateTime":
            case "ScrapReasonName":
            case "TicketID":
                return 80;
            case "DefectName":
            case "CINFO":
                return 100;
            default:
                return 120;
        }
    }

    /// <summary>
    /// 指定ColumnName得到是否顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ReportColor":
            case "GroupName":
            case "MedianScrapRate":
            case "MedianScrapRateByUp50":
            case "MedianScrapRateByUp100":
            case "MedianScrapRateByDown50":
            case "ScrapRateValue":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 指定ColumnName得到顯示欄位名稱
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "AUFNR":
                return (string)GetLocalResourceObject("Str_ColumnName_AUFNR");
            case "VERID":
                return (string)GetLocalResourceObject("Str_ColumnName_VERID");
            case "PSMNG":
                return (string)GetLocalResourceObject("Str_ColumnName_PSMNG");
            case "ScrapQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQty");
            case "ScrapRate":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapRate");
            case "MOCloseDateTime":
                return (string)GetLocalResourceObject("Str_ColumnName_MOCloseDateTime");
            case "ReportDate":
                return (string)GetLocalResourceObject("Str_ColumnName_ReportDate");
            case "TicketID":
                return (string)GetLocalResourceObject("Str_ColumnName_TicketID");
            case "LTXA1":
                return (string)GetLocalResourceObject("Str_ColumnName_LTXA1");
            case "CINFO":
                return (string)GetLocalResourceObject("Str_ColumnName_CINFO");
            case "CHARG":
                return (string)GetLocalResourceObject("Str_ColumnName_CHARG");
            case "Brand":
                return (string)GetLocalResourceObject("Str_ColumnName_Brand");
            case "MachineID":
                return (string)GetLocalResourceObject("Str_ColumnName_MachineID");
            case "EDMachineID":
                return (string)GetLocalResourceObject("Str_ColumnName_EDMachineID");
            case "ScrapReasonName":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapReasonName");
            case "DefectName":
                return (string)GetLocalResourceObject("Str_ColumnName_DefectName");
            case "RawMaterialVendorName":
                return (string)GetLocalResourceObject("Str_ColumnName_RawMaterialVendorName");
            default:
                return ColumnName;
        }
    }

    /// <summary>
    /// 指定欄位名取得搜尋選項
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <param name="Rows">資料列</param>
    /// <returns>搜尋選項</returns>
    protected dynamic GetSearchOptions(string ColumnName, List<DataRow> Rows)
    {
        dynamic StatusSearchOptions = new System.Dynamic.ExpandoObject();

        switch (ColumnName)
        {
            case "ScrapRate":
            case "ScrapQty":
            case "PSMNG":
                StatusSearchOptions.sopt = new string[] { "eq", "ne", "lt", "le", "gt", "ge" };
                return StatusSearchOptions;
            case "MOCloseDateTime":
            case "ReportDate":
                StatusSearchOptions.sopt = new string[] { "eq", "le", "ge" };
                return StatusSearchOptions;
            default:
                return null;
        }
    }

    /// <summary>
    /// 指定欄位名取得搜尋型別
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <returns>搜尋型別</returns>
    protected string GetSortType(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ScrapRate":
                return "number";
            case "ScrapQty":
            case "PSMNG":
                return "integer";
            case "MOCloseDateTime":
            case "ReportDate":
                return "date";
            default:
                return null;
        }
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}