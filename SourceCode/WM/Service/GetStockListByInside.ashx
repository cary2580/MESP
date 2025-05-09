<%@ WebHandler Language="C#" Class="GetStockListByInside" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class GetStockListByInside : BasePage
{
    protected string PackingID = string.Empty;
    protected string MAKTX = string.Empty;
    protected string MATNR = string.Empty;
    protected string BoxNo = string.Empty;
    protected string Brand = string.Empty;
    protected string LGORT = string.Empty;
    protected string PalletNo = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["PalletNo"] != null)
                PalletNo = _context.Request["PalletNo"].Trim();

            if (_context.Request["PackingID"] != null)
                PackingID = _context.Request["PackingID"].Trim();
            if (_context.Request["MAKTX"] != null)
                MAKTX = _context.Request["MAKTX"].Trim();
            if (_context.Request["MATNR"] != null)
                MATNR = _context.Request["MATNR"].Trim();
            if (_context.Request["BoxNo"] != null)
                BoxNo = _context.Request["BoxNo"].Trim();
            if (_context.Request["Brand"] != null)
                Brand = _context.Request["Brand"].Trim();
            if (_context.Request["LGORT"] != null)
                LGORT = _context.Request["LGORT"].Trim();

            if (string.IsNullOrEmpty(MAKTX) && string.IsNullOrEmpty(MATNR) && string.IsNullOrEmpty(BoxNo) && string.IsNullOrEmpty(Brand) && string.IsNullOrEmpty(LGORT))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredOneAlertMessage"));

            DbCommandBuilder dbcb = new DbCommandBuilder();

            string Query = @"Select
	                            	T_WMProductBox.BoxNo,
	                                Brand,
                                    (CHARG + Case When IsNull(CHARGLGORT,'') <> '' Then  '(' + (Select LGOBE From T_SAPT001L Where T_SAPT001L.LGORT = CHARGLGORT) + ')' Else '' End) As CHARG,	                                                             
	                                IsNull(T_WMProductBoxBrand.Qty,0) As Qty,
                                    VERIDShort,
								    (Select Top 1 ReportDate From V_TSTicketResult Where V_TSTicketResult.TicketID = T_WMProductBoxBrand.TicketID Order By CreateDate Desc) As ReportDate,
	                                T_WMProductBoxBrand.CreateDate
                            From T_WMProductPallet Inner Join T_WMProductBox On T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo
                            Left Join T_WMProductBoxBrand On T_WMProductBox.BoxNo = T_WMProductBoxBrand.BoxNo
                            Where T_WMProductPallet.IsConfirm = 1 And T_WMProductBox.PalletNo = @PalletNo ";

            if (!string.IsNullOrEmpty(PackingID))
            {
                Query += " And T_WMProductBox.BoxNo Not In (Select BoxNo From T_WMProductPackingListTemp Where PackingID = @PackingID) ";

                ObjectSchema SchemaPackingListTemp = DBSchema.currentDB.Tables["T_WMProductPackingListTemp"];

                dbcb.appendParameter(SchemaPackingListTemp.Attributes["PackingID"].copy(PackingID));
            }

            Query += @"And IsNull(T_WMProductBox.PackingID,'') = ''
	                   And T_WMProductPallet.LGORT = IIF(IsNull(@LGORT,'') = '',T_WMProductPallet.LGORT,@LGORT)
	                   And T_WMProductBox.BoxNo = IIF(IsNull(@BoxNo,'') = '',T_WMProductBox.BoxNo,@BoxNo)
	                   And T_WMProductBoxBrand.Brand = IIF(IsNull(@Brand,'') = '',T_WMProductBoxBrand.Brand,@Brand)
	                   And T_WMProductPallet.MAKTX Like '%' + IIF(IsNull(@MAKTX,'') = '',T_WMProductPallet.MAKTX,@MAKTX) + '%'
                       And T_WMProductPallet.MATNR = IIF(IsNull(@MATNR,'') = '',T_WMProductPallet.MATNR,@MATNR)
                    Order By CreateDate Asc";

            dbcb.CommandText = Query;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPallet"];

            dbcb.appendParameter(Schema.Attributes["LGORT"].copy(LGORT));

            dbcb.appendParameter(Schema.Attributes["MAKTX"].copy(MAKTX));

            dbcb.appendParameter(Schema.Attributes["MATNR"].copy(string.IsNullOrEmpty(MATNR) ? string.Empty : Util.WM.ToMATNR(MATNR)));

            Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

            dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo));

            Schema = DBSchema.currentDB.Tables["T_WMProductBoxBrand"];

            dbcb.appendParameter(Schema.Attributes["Brand"].copy(Brand));

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
                    sorttype = GetSortType(Column.ColumnName),
                    searchoptions = GetSearchOptions(Column.ColumnName, Rows)
                }),
                FilterDateTimeColumnNames = new string[] { "CreateDate", "ReportDate" },
                BoxNoColumnName = "BoxNo",
                BoxQtyColumnName = "Qty",
                Rows = Rows.Select(Row => new
                {
                    BoxNo = Row["BoxNo"].ToString().Trim(),
                    Brand = Row["Brand"].ToString().Trim(),
                    CHARG = Row["CHARG"].ToString().Trim(),
                    VERIDShort = Row["VERIDShort"].ToString().Trim(),
                    Qty = Row["Qty"].ToString().Trim(),
                    ReportDate = ((DateTime)Row["ReportDate"]).ToCurrentUICultureString(),
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
            case "BoxNo":
            case "CreateDate":
            case "ReportDate":
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
            case "ReportDate":
            case "Brand":
                return 100;
            case "BoxNo":
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
            case "BoxNo":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BoxNo");
            case "Brand":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Brand");
            case "CHARG":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_CHARG");
            case "VERIDShort":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_VERID");
            case "Qty":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Qty");
            case "Operator":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_LastTicketOperator");
            case "ReportDate":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_LastTicketReportDate");
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
            case "ReportDate":
                StatusSearchOptions.sopt = new string[] { "eq", "le", "ge" };
                return StatusSearchOptions;
            case "Brand":
            case "CHARG":
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