<%@ WebHandler Language="C#" Class="GetPackingListTemp" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class GetPackingListTemp : BasePage
{
    protected string PackingID = string.Empty;

    protected bool IsHiddenMAKTX = true;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["PackingID"] != null)
                PackingID = _context.Request["PackingID"].Trim();

            IsHiddenMAKTX = _context.Request["IsHiddenMAKTX"].ToBoolean();

            string Query = @"Select * From (
                                Select 
	                                T_WMProductBox.PalletNo,
	                                T_WMProductBox.BoxNo,
	                                STRING_AGG(Brand,'/') As Brand,
	                                STRING_AGG(CHARG,'/') + '(' + (Select LGOBE From T_SAPT001L Where T_SAPT001L.LGORT = T_WMProductPallet.LGORT) + ')' As CHARG,
                                    T_WMProductPallet.MAKTX,
	                                STRING_AGG(VERIDShort,'/') As VERIDShort,
	                                T_WMProductBox.Qty,
	                                IsNull(Min(T_WMProductBoxBrand.CreateDate),GetDate()) As CreateDate
	                            From T_WMProductPallet Inner Join T_WMProductBox On T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo
	                                Left Join T_WMProductBoxBrand On T_WMProductBox.BoxNo = T_WMProductBoxBrand.BoxNo
	                            Where T_WMProductPallet.IsConfirm = 1 And T_WMProductBox.BoxNo In (Select BoxNo From T_WMProductPackingListTemp Where PackingID = @PackingID)
	                                Group By T_WMProductBox.PalletNo,T_WMProductBox.BoxNo,T_WMProductPallet.MAKTX,T_WMProductPallet.LGORT,T_WMProductBox.Qty,IsNull(T_WMProductBoxBrand.CreateDate,GetDate())
                                ) As Result
                                Order By CreateDate Asc";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingListTemp"];

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

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
                    classes = Column.ColumnName == "TicketID" ? BaseConfiguration.JQGridColumnClassesName : "",
                    sorttype = GetSortType(Column.ColumnName),
                    searchoptions = GetSearchOptions(Column.ColumnName, Rows)
                }),
                FilterDateTimeColumnNames = new string[] { "CreateDate" },
                PalletNoColumnName = "PalletNo",
                BoxNoColumnName = "BoxNo",
                BoxQtyColumnName = "Qty",
                Rows = Rows.Select(Row => new
                {
                    PalletNo = Row["PalletNo"].ToString().Trim(),
                    BoxNo = Row["BoxNo"].ToString().Trim(),
                    Brand = Row["Brand"].ToString().Trim(),
                    CHARG = Row["CHARG"].ToString().Trim(),
                    MAKTX = Row["MAKTX"].ToString().Trim(),
                    VERIDShort = Row["VERIDShort"].ToString().Trim(),
                    Qty = Row["Qty"].ToString().Trim(),
                    CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureString()
                })
            };

            ResponseSuccessData(ResponseData);
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

    /// <summary>
    /// 指定ColumnName得到是否影藏
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否影藏</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "MAKTX":
                return IsHiddenMAKTX;
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
            case "CreateDate":
            case "Qty":
            case "VERIDShort":
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
            case "Qty":
            case "VERIDShort":
                return 60;
            case "CreateDate":
            case "Brand":
                return 100;
            case "BoxNo":
            case "PalletNo":
                return 80;
            case "CHARG":
                return 160;
            default:
                return 220;
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
            case "BoxNo":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BoxNo");
            case "Brand":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Brand");
            case "CHARG":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_CHARG");
            case "MAKTX":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_MAKTX");
            case "VERIDShort":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_VERID");
            case "Qty":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Qty");
            case "Operator":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_LastTicketOperator");
            case "CreateDate":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_FIFODay");
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
            case "Qty":
                StatusSearchOptions.sopt = new string[] { "eq", "ne", "lt", "le", "gt", "ge" };
                return StatusSearchOptions;
            case "CreateDate":
                StatusSearchOptions.sopt = new string[] { "eq", "le", "ge" };
                return StatusSearchOptions;
            case "Brand":
            case "CHARG":
            case "MAKTX":
                StatusSearchOptions.sopt = new string[] { "cn", "nc" };
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
            case "Qty":
                return "integer";
            case "CreateDate":
                return "date";
            default:
                return null;
        }
    }
}