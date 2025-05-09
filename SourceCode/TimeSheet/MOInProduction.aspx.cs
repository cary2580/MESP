using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_MOInProduction : System.Web.UI.Page
{
    protected override void OnPreRenderComplete(EventArgs e)
    {
        LoadData();

        base.OnPreRenderComplete(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            System.Reflection.PropertyInfo AccountID = Master.GetType().GetProperty("AccountID");

            System.Reflection.PropertyInfo IsAdmin = Master.GetType().GetProperty("IsAdmin");

            if ((AccountID != null && IsAdmin != null && (int)AccountID.GetValue(Master) > -1 && BaseConfiguration.OnlineAccount.ContainsKey((int)AccountID.GetValue(Master))) && ((bool)IsAdmin.GetValue(Master) || BaseConfiguration.OnlineAccount[(int)AccountID.GetValue(Master)].UseModule.Contains("TS.PMCadmin")))
            {
                HF_IsPMC.Value = "1";

                BT_Recalculate.Visible = true;
            }
            else
            {
                HF_IsPMC.Value = "0";

                BT_Recalculate.Visible = false;
            }
        }
    }

    protected void LoadData()
    {
        string Query = @"Select 
                        '' As AUFNRID,
                        AUFNR,
                        AUARTName,
                        (Select Top 1 CodeName From T_Code Where CodeType = 'TS_MOStatus' And CodeID = T_TSSAPAFKO.[STATUS] And UICulture = @UICulture) As StatusName,
                        IsPreClose,
                        (Select Top 1 TEXT1 From T_TSSAPMKAL Where MATNR = T_TSSAPAFKO.PLNBEZ And VERID = T_TSSAPAFKO.VERID And IsLock = 0 And DATEDIFF(day,ADATU,getdate()) > -1 And DATEDIFF(day,BDATU,getdate()) < -1) As TEXT1,
                        (Select Top 1 Brand From V_TSTicketResult Where V_TSTicketResult.AUFNR = T_TSSAPAFKO.AUFNR And IsNull(Brand,'') <> '' Order By CreateDate) As Brand,
                        (Select Top 1 CINFO From V_TSMORouting Where V_TSMORouting.AUFNR = T_TSSAPAFKO.AUFNR) As CINFO,
                        Convert(int,PSMNG) As PSMNG,
                        IsNull((Select Sum(Qty) From T_TSTicket Where AUFNR = T_TSSAPAFKO.AUFNR And TicketTypeID = @TicketTypeID),0) As TicketQty,
                        IsNull((Select Top 1 IsNull(Sum(GoodQty),0) From T_TSTicket 
                        Inner Join T_TSTicketRouting On T_TSTicket.TicketID = T_TSTicketRouting.TicketID
                        Left Join T_TSTicketResult On T_TSTicketResult.TicketID = T_TSTicket.TicketID And T_TSTicketResult.ProcessID = T_TSTicketRouting.ProcessID And Datediff(Day,T_TSTicketResult.ApprovalTime,getdate()) >= 0
                        Where T_TSTicket.AUFNR = T_TSSAPAFKO.AUFNR
                        Group By T_TSTicketRouting.VORNR,T_TSTicketRouting.ProcessID
                        Order By T_TSTicketRouting.ProcessID Desc
                        ),0) As LastProcessGoodQty,
                        IsNull((Select Sum(ScrapQty) From T_TSTicketResult Where TicketID In (Select TicketID From T_TSTicket Where AUFNR = T_TSSAPAFKO.AUFNR) And Datediff(Day,T_TSTicketResult.ApprovalTime,getdate()) >= 0),0) As ScrapQty,
                        Convert(int,WEMNG) As WEMNG,
                        '' As CompletionRate,
                        '' As CompletionRateValue,
                        GSTRP,
                        GLTRP
                        From T_TSSAPAFKO
                        Where [STATUS] = @MOStatus
                        Order By GSTRP";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        string MOStatus = DDL_IsInProduction.SelectedValue == "1" ? ((short)Util.TS.MOStatus.InProcess).ToString() : ((short)Util.TS.MOStatus.Issued).ToString();

        dbcb.appendParameter(Util.GetDataAccessAttribute("MOStatus", "nvarchar", 50, MOStatus));

        dbcb.appendParameter(Schema.Attributes["TicketTypeID"].copy(((short)Util.TS.TicketType.General).ToString()));

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        var ResponseData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName),
                searchoptions = GetSearchOptions(Column.ColumnName),
                sorttype = GetSorttype(Column.ColumnName),
                classes = Column.ColumnName == "AUFNR" || Column.ColumnName == "AUARTName" ? BaseConfiguration.JQGridColumnClassesName : string.Empty
            }),
            AUFNRIDColumnName = "AUFNRID",
            AUFNRColumnName = "AUFNR",
            AUARTNameColumnName = "AUARTName",
            PSMNGColumnName = "PSMNG",
            TicketQtyColumnName = "TicketQty",
            LastProcessGoodQtyColumnName = "LastProcessGoodQty",
            WEMNGColumnName = "WEMNG",
            CompletionRateColumnName = "CompletionRate",
            CompletionRateValueColumnName = "CompletionRateValue",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            ShortHideFields = new List<string> { "AUARTName", "IsPreClose", "TEXT1" },
            CustiomFormatterLocalizedNumericColumnNames = new List<string> { "PSMNG", "TicketQty", "LastProcessGoodQty", "ScrapQty", "WEMNG" },
            IsMultiSelect = HF_IsPMC.Value.ToBoolean(),
            Rows = DT.AsEnumerable().Select(Row => new
            {
                AUFNRID = Row["AUFNR"].ToString().Trim(),
                AUFNR = Row["AUFNR"].ToString().Trim(),
                AUARTName = Row["AUARTName"].ToString().Trim(),
                StatusName = Row["StatusName"].ToString().Trim(),
                IsPreClose = (bool)Row["IsPreClose"] ? (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_IsPreClose_True") : (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_IsPreClose_False"),
                TEXT1 = Row["TEXT1"].ToString().Trim(),
                Brand = Row["Brand"].ToString().Trim(),
                CINFO = Row["CINFO"].ToString().Trim(),
                PSMNG = ((int)Row["PSMNG"]).ToString().Trim(),
                TicketQty = ((int)Row["TicketQty"]).ToString().Trim(),
                LastProcessGoodQty = ((int)Row["LastProcessGoodQty"]).ToString().Trim(),
                ScrapQty = ((int)Row["ScrapQty"]).ToString().Trim(),
                WEMNG = ((int)Row["WEMNG"]).ToString().Trim(),
                CompletionRate = double.Parse(Row["TicketQty"].ToString()) > 1 ? ((double.Parse(Row["WEMNG"].ToString()) + double.Parse(Row["ScrapQty"].ToString())) / double.Parse(Row["TicketQty"].ToString())).ToString("P", System.Threading.Thread.CurrentThread.CurrentUICulture) : 0.00.ToString("P", System.Threading.Thread.CurrentThread.CurrentUICulture),
                CompletionRateValue = double.Parse(Row["TicketQty"].ToString()) > 1 ? (double.Parse(Row["WEMNG"].ToString()) + double.Parse(Row["ScrapQty"].ToString())) / double.Parse(Row["TicketQty"].ToString()) : 0,
                GSTRP = ((DateTime)Row["GSTRP"]).ToCurrentUICultureString(),
                GLTRP = ((DateTime)Row["GLTRP"]).ToCurrentUICultureString()
            })
        };

        if (DDL_IsInProduction.SelectedValue == "1")
            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowSubGridValue", "<script>var IsShowSubGridValue='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");
    }

    /// <summary>
    /// 指定欄位名取得排序或搜尋型別
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>排序或搜尋型別</returns>
    protected string GetSorttype(string ColumnName)
    {
        switch (ColumnName)
        {
            case "AUFNR":
            case "PSMNG":
            case "TicketQty":
            case "LastProcessGoodQty":
            case "ScrapQty":
            case "WEMNG":
            case "CompletionRate":
                return "number";
            default:
                return "string";
        }
    }

    /// <summary>
    /// 指定欄位名取得搜尋選項
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>搜尋選項</returns>
    protected dynamic GetSearchOptions(string ColumnName)
    {
        dynamic StatusSearchOptions = new System.Dynamic.ExpandoObject();

        switch (ColumnName)
        {
            case "PSMNG":
            case "TicketQty":
            case "LastProcessGoodQty":
            case "ScrapQty":
            case "WEMNG":
            case "CompletionRate":
                StatusSearchOptions.sopt = new string[] { "ge", "le", "eq", "ne" };
                return StatusSearchOptions;
            default:
                return null;
        }
    }

    /// <summary>
    /// 指定ColumnName得到是否影藏顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否影藏顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "AUFNRID":
            case "StatusName":
            case "CompletionRateValue":
                return true;
            case "IsPreClose":
                if (DDL_IsInProduction.SelectedValue == "0")
                    return true;
                else
                    return false;
            case "Brand":
                if (DDL_IsInProduction.SelectedValue == "0")
                    return true;
                else
                    return false;
            case "CINFO":
                if (DDL_IsInProduction.SelectedValue == "1")
                    return true;
                else
                    return false;
            default:
                return false;
        }
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
            case "StatusName":
            case "IsPreClose":
            case "PSMNG":
            case "TicketQty":
            case "LastProcessGoodQty":
            case "ScrapQty":
            case "WEMNG":
            case "Brand":
            case "CompletionRate":
            case "AUARTName":
            case "GSTRP":
            case "GLTRP":
                return "center";
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
            case "AUARTName":
            case "StatusName":
            case "IsPreClose":
            case "PSMNG":
            case "TicketQty":
            case "LastProcessGoodQty":
            case "ScrapQty":
            case "WEMNG":
            case "CompletionRate":
            case "GSTRP":
            case "GLTRP":
                return 80;
            case "Brand":
                return 110;
            case "AUFNR":
                return 120;
            case "TEXT1":
            case "CINFO":
                return 250;
            default:
                return 150;
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
            case "AUARTName":
                return (string)GetLocalResourceObject("Str_ColumnName_AUARTName");
            case "StatusName":
                return (string)GetLocalResourceObject("Str_ColumnName_StatusName");
            case "IsPreClose":
                return (string)GetLocalResourceObject("Str_ColumnName_IsPreClose");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            case "Brand":
                return (string)GetLocalResourceObject("Str_ColumnName_Brand");
            case "CINFO":
                return (string)GetLocalResourceObject("Str_ColumnName_CINFO");
            case "PSMNG":
                return (string)GetLocalResourceObject("Str_ColumnName_PSMNG");
            case "TicketQty":
                return (string)GetLocalResourceObject("Str_ColumnName_TicketQty");
            case "LastProcessGoodQty":
                return (string)GetLocalResourceObject("Str_ColumnName_LastProcessGoodQty");
            case "ScrapQty":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapQty");
            case "WEMNG":
                return (string)GetLocalResourceObject("Str_ColumnName_WEMNG");
            case "CompletionRate":
                return (string)GetLocalResourceObject("Str_ColumnName_CompletionRate");
            case "GSTRP":
                return (string)GetLocalResourceObject("Str_ColumnName_GSTRP");
            case "GLTRP":
                return (string)GetLocalResourceObject("Str_ColumnName_GLTRP");
            default:
                return ColumnName;
        }
    }

    protected void BT_Recalculate_Click(object sender, EventArgs e)
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_SetDailyReportForProductionGroupTaskQty");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("TargetDate", "DateTime", 0, DateTime.Now));

        CommonDB.ExecuteSingleCommand(dbcb);

        dbcb = new DbCommandBuilder("SP_TS_SetMODeliverQty");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        CommonDB.ExecuteSingleCommand(dbcb);

        dbcb = new DbCommandBuilder("SP_TS_SetMOPSMNG");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        CommonDB.ExecuteSingleCommand(dbcb);
    }
}