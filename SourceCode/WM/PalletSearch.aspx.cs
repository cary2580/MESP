using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class WM_PalletSearch : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            TB_PalletCreateDateEnd.Text = DateTime.Now.ToCurrentUICultureString() + " 23:59:59";
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        int AccountID = -1;

        if (!string.IsNullOrEmpty(TB_WorkCode.Text.Trim()))
        {
            AccountID = BaseConfiguration.GetAccountID(TB_WorkCode.Text.Trim());

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
            {
                Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                return;
            }
        }

        if ((DateTime.Parse(TB_PalletCreateDateEnd.Text, System.Threading.Thread.CurrentThread.CurrentUICulture) - DateTime.Parse(TB_PalletCreateDateStart.Text, System.Threading.Thread.CurrentThread.CurrentUICulture)).Days > 90)
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetLocalResourceObject("Str_Error_SearchDateOverDays"));

            return;
        }

        string Query = @"Select * From (Select 
                            PalletNo,
                            MAKTX,
                            (Select Count(*) From T_WMProductBox Where T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo) As BoxQty,
                            Qty As PCS,
                            Stuff(((Select '、' + Brand + '(' + Convert(nvarchar,Result.Qty) + ')' 
		                            From (
			                            Select Brand,Sum(T_WMProductBoxBrand.Qty) As Qty
			                            From T_WMProductBoxBrand
			                            Inner Join T_WMProductBox On T_WMProductBoxBrand.BoxNo = T_WMProductBox.BoxNo 
			                            Where T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo Group By Brand
		                            ) As Result Order By Result.Qty Desc
		                            For Xml Path(''))),1,1,'') AS Brand,
                            Stuff(((Select '、' + CHARG + '(' + Convert(nvarchar,Result.CHARGQty) + ')' 
			                            From ( Select CHARG,CHARGQty
											From T_WMProductBoxBrand
											Inner Join T_WMProductBox On T_WMProductBoxBrand.BoxNo = T_WMProductBox.BoxNo 
											Where T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo And IsNull(CHARG,'') <> ''  
											Group By CHARG,CHARGQty ) As Result 
									Order By Result.CHARGQty Desc
		                            For Xml Path(''))),1,1,'') AS CHARG,
                             Stuff(((Select '、' + CINFO + '(' + Convert(nvarchar,Result.Qty) + ')' 
		                            From (
			                            Select CINFO,Sum(T_WMProductBoxBrand.Qty) As Qty
			                            From T_WMProductBoxBrand
			                            Inner Join T_WMProductBox On T_WMProductBoxBrand.BoxNo = T_WMProductBox.BoxNo 
			                            Where T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo Group By CINFO
		                            ) As Result Order By Result.Qty Desc
		                            For Xml Path(''))),1,1,'') AS CINFO,
                            IsConfirm,
                            (Select LGOBE From T_SAPT001L Where T_SAPT001L.LGORT = T_WMProductPallet.LGORT) As LGOBE,
                            (Select LocationName From T_WMDeliveryLocation Where LocationID = DeliveryLocationID) As LocationName,
                            Base_Org.dbo.GetAccountName(CreateAccountID) As CreateAccountName,
                            CreateAccountID,
                            CreateDate,
                            Stuff(((Select '、' + BoxNo From T_WMProductBox Where T_WMProductBox.PalletNo =  T_WMProductPallet.PalletNo For Xml Path(''))),1,1,'') AS BoxNo
                        From T_WMProductPallet) As Result";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPallet"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        string Condition = string.Empty;

        if (AccountID > 0)
        {
            Condition += " And CreateAccountID = @CreateAccountID";

            dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));
        }

        if (!string.IsNullOrEmpty(TB_PalletCreateDateStart.Text.Trim()))
        {
            Condition += " And CreateDate >= @CreateDateStart";

            dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(DateTime.Parse(TB_PalletCreateDateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "CreateDateStart"));
        }

        if (!string.IsNullOrEmpty(TB_PalletCreateDateEnd.Text.Trim()))
        {
            Condition += " And CreateDate <= @CreateDateEnd";

            dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(DateTime.Parse(TB_PalletCreateDateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture), "CreateDateEnd"));
        }

        if (!string.IsNullOrEmpty(TB_MAKTX.Text.Trim()))
        {
            Condition += " And MAKTX Like '%' + @MAKTX + '%'";

            dbcb.appendParameter(Schema.Attributes["MAKTX"].copy(TB_MAKTX.Text.Trim()));
        }

        if (!string.IsNullOrEmpty(TB_BoxNo.Text.Trim()))
        {
            Condition += " And BoxNo Like '%' + @BoxNo + '%'";

            Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(TB_BoxNo.Text.Trim()));
        }

        if (!string.IsNullOrEmpty(Condition))
            Query += " Where " + Condition.Substring(4, Condition.Length - 4);

        dbcb.CommandText = Query + " Order By CreateDate Desc";

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        IEnumerable<DataRow> Rows = DT.AsEnumerable();

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
                classes = Column.ColumnName == "PalletNo" ? BaseConfiguration.JQGridColumnClassesName : "",
                sorttype = GetSortType(Column.ColumnName),
                searchoptions = GetSearchOptions(Column.ColumnName, Rows)
            }),
            PalletNoColumnName = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PalletNo"),
            PalletNoValueColumnName = "PalletNo",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            BoxQtyColumnName = "BoxQty",
            PCSColumnName = "PCS",
            FilterDateTimeColumnNames = new string[] { "CreateDate" },
            Rows = Rows.Select(Row => new
            {
                PalletNo = Row["PalletNo"].ToString().Trim(),
                MAKTX = Row["MAKTX"].ToString().Trim(),
                BoxQty = Row["BoxQty"].ToString().Trim(),
                PCS = Row["PCS"].ToString().Trim(),
                Brand = Row["Brand"].ToString().Trim(),
                CHARG = Row["CHARG"].ToString().Trim(),
                CINFO = Row["CINFO"].ToString().Trim(),
                IsConfirm = (bool)Row["IsConfirm"] ? "<span data-result=\"" + (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") + "\" class=\"fa fa-check-square fa-fw\"></span>" : string.Empty,
                LGOBE = Row["LGOBE"].ToString().Trim(),
                LocationName = Row["LocationName"].ToString().Trim(),
                CreateAccountName = Row["CreateAccountName"].ToString().Trim(),
                CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureStringTime()
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelectValue", "<script>var IsMultiSelectValue=" + true.ToStringValue() + "</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar=" + true.ToStringValue() + "</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowFooterRowValue", "<script>var IsShowFooterRowValue=" + true.ToStringValue() + ";</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowSubGridValue", "<script>var IsShowSubGridValue=" + true.ToStringValue() + ";</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
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
            case "CreateAccountID":
            case "BoxNo":
                return true;
            default:
                return false;
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
            case "IsConfirm":
            case "BoxQty":
            case "PCS":
            case "CreateAccountName":
                return 60;
            case "PalletNo":
                return 80;
            case "CreateDate":
            case "LGOBE":
            case "LocationName":
                return 100;
            default:
                return 200;
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
            case "PalletNo":
            case "BoxQty":
            case "PCS":
            case "IsConfirm":
            case "CreateAccountName":
                return "center";
            default:
                return "left";
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
            case "PalletNo":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PalletNo");
            case "MAKTX":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_MAKTX");
            case "BoxQty":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BoxQty");
            case "PCS":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PCS");
            case "Brand":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Brand");
            case "CHARG":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_CHARG");
            case "CINFO":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_CINFO");
            case "IsConfirm":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_IsConfirmGoToWarehouse");
            case "LGOBE":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_LGORT");
            case "LocationName":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_DeliveryLocation");
            case "CreateAccountName":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_CreateAccountByGoToWarehouse");
            case "CreateDate":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_CreateDateByGoToWarehouse");
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
    protected dynamic GetSearchOptions(string ColumnName, IEnumerable<DataRow> Rows)
    {
        dynamic StatusSearchOptions = new System.Dynamic.ExpandoObject();

        switch (ColumnName)
        {
            case "BoxQty":
            case "PCS":
                StatusSearchOptions.sopt = new string[] { "eq", "ne", "lt", "le", "gt", "ge" };
                return StatusSearchOptions;
            case "CreateDate":
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

    protected void BT_SynchronizeSAPData_Click(object sender, EventArgs e)
    {
        List<string> PalletNoList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(HF_PalletNoSelected.Value);

        Synchronize_SAPData.SynchronizeBaseData_PalletCHARG(PalletNoList);

        BT_Search_Click(null, null);
    }
}