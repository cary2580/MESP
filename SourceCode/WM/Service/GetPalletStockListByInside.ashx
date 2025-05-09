<%@ WebHandler Language="C#" Class="GetPalletStockListByInside" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class GetPalletStockListByInside : BasePage
{
    protected string PackingID = string.Empty;
    protected string MAKTX = string.Empty;
    protected string MATNR = string.Empty;
    protected string BoxNo = string.Empty;
    protected string Brand = string.Empty;
    protected string LGORT = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

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
	                            T_WMProductPallet.PalletNo,
	                            (Select Count(*) From T_WMProductBox Where T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo) As BoxQty,
	                            T_WMProductPallet.Qty As PCS,
                                T_WMProductPallet.MAKTX,
	                            Stuff(((Select '、' + Brand + '(' + Convert(nvarchar,Result.Qty) + ')' 
	                            From (
		                            Select Brand,Sum(T_WMProductBoxBrand.Qty) As Qty
		                            From T_WMProductBoxBrand Inner Join T_WMProductBox On T_WMProductBoxBrand.BoxNo = T_WMProductBox.BoxNo 
		                            Where T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo Group By Brand
	                            ) As Result Order By Result.Qty Desc For Xml Path(''))),1,1,'') AS Brand,
	                            Stuff(((Select '、' + CHARG + '(' + Convert(nvarchar,Result.CHARGQty) + ')' 
	                            From (Select CHARG,CHARGQty
		                            From T_WMProductBoxBrand Inner Join T_WMProductBox On T_WMProductBoxBrand.BoxNo = T_WMProductBox.BoxNo 
		                            Where T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo And IsNull(CHARG,'') <> ''  Group By CHARG,CHARGQty
	                            ) As Result Order By Result.CHARGQty Desc For Xml Path(''))),1,1,'') AS CHARG,
	                             Stuff(((Select '、' + CINFO + '(' + Convert(nvarchar,Result.Qty) + ')' 
	                            From (Select CINFO,Sum(T_WMProductBoxBrand.Qty) As Qty
		                            From T_WMProductBoxBrand Inner Join T_WMProductBox On T_WMProductBoxBrand.BoxNo = T_WMProductBox.BoxNo 
		                            Where T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo Group By CINFO
	                            ) As Result Order By Result.Qty Desc For Xml Path(''))),1,1,'') AS CINFO,
                                 (Select LocationName From T_WMDeliveryLocation Where T_WMDeliveryLocation.LocationID = T_WMProductPallet.DeliveryLocationID) As LocationName,
	                             (Select LGOBE From T_SAPT001L Where T_SAPT001L.LGORT = T_WMProductPallet.LGORT) As LGOBE,
	                             IsNull(Min(T_WMProductBoxBrand.CreateDate),GetDate()) As CreateDate
                            From T_WMProductPallet Inner Join T_WMProductBox On T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo
                            Left Join T_WMProductBoxBrand On T_WMProductBox.BoxNo = T_WMProductBoxBrand.BoxNo
                            Where T_WMProductPallet.IsConfirm = 1 ";

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
                    Group By T_WMProductPallet.PalletNo,T_WMProductPallet.Qty,T_WMProductPallet.MAKTX,T_WMProductPallet.DeliveryLocationID,T_WMProductPallet.LGORT
                    Order By CreateDate Asc";

            dbcb.CommandText = Query;

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPallet"];

            dbcb.appendParameter(Schema.Attributes["LGORT"].copy(LGORT));

            dbcb.appendParameter(Schema.Attributes["MAKTX"].copy(MAKTX));

            dbcb.appendParameter(Schema.Attributes["MATNR"].copy(string.IsNullOrEmpty(MATNR) ? string.Empty : Util.WM.ToMATNR(MATNR)));

            Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

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
                FilterDateTimeColumnNames = new string[] { "CreateDate" },
                PalletNoColumnName = "PalletNo",
                Rows = Rows.Select(Row => new
                {
                    PalletNo = Row["PalletNo"].ToString().Trim(),
                    BoxQty = Row["BoxQty"].ToString().Trim(),
                    PCS = Row["PCS"].ToString().Trim(),
                    MAKTX = Row["MAKTX"].ToString().Trim(),
                    Brand = Row["Brand"].ToString().Trim(),
                    CHARG = Row["CHARG"].ToString().Trim(),
                    CINFO = Row["CINFO"].ToString().Trim(),
                    LocationName = Row["LocationName"].ToString().Trim(),
                    LGOBE = Row["LGOBE"].ToString().Trim(),
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
            case "CreateDate":
            case "BoxQty":
            case "PCS":
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
            case "BoxQty":
            case "PCS":
                return 60;
            case "LocationName":
            case "CreateDate":
            case "LGOBE":
                return 100;
            case "PalletNo":
                return 80;
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
            case "BoxQty":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BoxQty");
            case "PCS":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PCS");
            case "MAKTX":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_MAKTX");
            case "Brand":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Brand");
            case "CHARG":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_CHARG");
            case "CINFO":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_CINFO");
            case "LocationName":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_DeliveryLocation");
            case "LGOBE":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_LGORT");
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
            case "BoxQty":
            case "PCS":
                StatusSearchOptions.sopt = new string[] { "eq", "ne", "lt", "le", "gt", "ge" };
                return StatusSearchOptions;
            case "CreateDate":
                StatusSearchOptions.sopt = new string[] { "eq", "le", "ge" };
                return StatusSearchOptions;
            case "Brand":
            case "CHARG":
            case "MAKTX":
            case "CINFO":
            case "LGOBE":
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
            case "BoxQty":
            case "PCS":
                return "integer";
            case "CreateDate":
                return "date";
            default:
                return null;
        }
    }
}