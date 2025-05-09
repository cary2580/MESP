<%@ WebHandler Language="C#" Class="GetPackingListByConfirm" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class GetPackingListByConfirm : BasePage
{
    protected string PackingID = string.Empty;
    protected string PBNO = string.Empty;
    protected bool IsConfirmed = false;
    protected int PackingIDTotalBoxNo = 0;
    protected string MAKTX = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["PackingID"] != null)
                PackingID = _context.Request["PackingID"].Trim();
            if (_context.Request["PBNO"] != null)
                PBNO = _context.Request["PBNO"].Trim();

            if (string.IsNullOrEmpty(PackingID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PackingID") + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (string.IsNullOrEmpty(PBNO))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PBNO") + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));

            bool IsOutside = Util.WM.PackingIDIsOutside(PackingID);

            if (IsOutside)
                LoadPackingInfoByOutside();
            else
                LoadPackingInfoByInside();

            if (IsConfirmed)
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PackingConfirmed"));
            if (string.IsNullOrEmpty(MAKTX))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_SearchNullStart") + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PackingID"));

            DataTable PackingPallet = GetPackingByFullPallet();

            //PBNO 如果是拖盤號，必須要在檢查是不是整拖出庫
            if (!Util.WM.IsBoxNo(PBNO) && (PackingPallet.AsEnumerable().Where(Row => Row["PalletNo"].ToString().Trim() == PBNO).Count() < 1))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_PalletNoNotInPacking"));
            //PBNO 如果是箱號，必須要在檢查是不是散箱出庫
            else if ((PackingPallet.AsEnumerable().Where(Row => Row["BoxNo"].ToString().Trim() == PBNO).Count() > 0))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_BoxNoNotInPacking"));

            DataTable DT = new DataTable();

            DT = GetPackingLint();

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_PackingConfirmNoBox"));

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
                    hidden = GetIsHidden(Column.ColumnName)
                }),
                MAKTX = MAKTX,
                TotalQtyText = (string)GetGlobalResourceObject("GlobalRes", "Str_SubTotal"),
                PackingIDTotalBoxNo = PackingIDTotalBoxNo.ToString(),
                Rows = Rows.Select(Row => new
                {
                    RowNumber = "",
                    PalletNo = Row["PalletNo"].ToString().Trim(),
                    BoxNo = Row["BoxNo"].ToString().Trim(),
                    Brand = Row["Brand"].ToString().Trim(),
                    Qty = Row["Qty"].ToString().Trim(),
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
    /// 指定ColumnName得到是否影藏
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否影藏</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            //case "Brand":
            //    return true;
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
            default:
                return "center";
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
                return 60;
            default:
                return 250;
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
            case "RowNumber":
                return "#";
            case "PalletNo":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PalletNo");
            case "BoxNo":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BoxNo");
            case "Brand":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Brand");
            case "Qty":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Qty");
            default:
                return ColumnName;
        }
    }

    /// <summary>
    /// 載入裝箱資訊(廠外)
    /// </summary>
    protected void LoadPackingInfoByOutside()
    {
        string Query = @"Select *,IsNull((Select Count(BoxNo) From T_WMProductBox Where T_WMProductBox.PackingID = @PackingID),0) As BoxCount From T_WMProductPackingToOutside Where PackingID = @PackingID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingToOutside"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        IsConfirmed = (bool)DT.Rows[0]["IsConfirm"];

        MAKTX = DT.Rows[0]["MAKTX"].ToString().Trim();

        PackingIDTotalBoxNo = (int)DT.Rows[0]["BoxCount"];
    }

    /// <summary>
    /// 載入裝箱資訊(廠內)
    /// </summary>
    protected void LoadPackingInfoByInside()
    {
        string Query = @"Select *,IsNull((Select Count(BoxNo) From T_WMProductBox Where T_WMProductBox.PackingID = @PackingID),0) As BoxCount From T_WMProductPackingToInside Where PackingID = @PackingID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingToInside"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

        IsConfirmed = (bool)DT.Rows[0]["IsConfirm"];

        MAKTX = DT.Rows[0]["MAKTX"].ToString().Trim();

        PackingIDTotalBoxNo = (int)DT.Rows[0]["BoxCount"];
    }

    /// <summary>
    /// 取得發貨資料表
    /// </summary>
    /// <returns>取得發貨資料表</returns>
    protected DataTable GetPackingLint()
    {
        string Query = @"Select 
                            '' As RowNumber,
                            T_WMProductBox.PalletNo,
                            T_WMProductBox.BoxNo,
                            STRING_AGG(Brand,'/') + '(' + (Select LGOBE From T_SAPT001L Where T_SAPT001L.LGORT = T_WMProductPallet.LGORT) + ')' As Brand,
                            T_WMProductBox.Qty
                        From T_WMProductBox
                        Inner Join T_WMProductPallet On T_WMProductPallet.PalletNo = T_WMProductBox.PalletNo
                        Left Join T_WMProductBoxBrand On T_WMProductBox.BoxNo = T_WMProductBoxBrand.BoxNo
                        Where T_WMProductBox.PackingID = @PackingID";

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

        bool IsBoxNo = Util.WM.IsBoxNo(PBNO);

        if (IsBoxNo)
        {
            Query += " And T_WMProductBox.BoxNo = @BoxNo";

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(PBNO));
        }
        else
        {
            Query += " And T_WMProductBox.PalletNo = @PalletNo";

            dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PBNO));
        }

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

        Query += " Group By T_WMProductBox.PalletNo,T_WMProductBox.BoxNo,T_WMProductPallet.LGORT,T_WMProductBox.Qty";

        dbcb.CommandText = Query;

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 取得裝箱棧板資料表(是滿整拖的才會出現)
    /// </summary>
    /// <returns>裝箱棧板資料表</returns>
    protected DataTable GetPackingByFullPallet()
    {
        string Query = @"Select Result.PalletNo,T_WMProductBox.BoxNo From
                        (
	                        Select 
		                        T_WMProductBox.PalletNo,
		                        Sum(T_WMProductBox.Qty) As PackingQty,
		                        (Select Qty From T_WMProductPallet As P Where P.PalletNo = T_WMProductBox.PalletNo) As PalletQty
	                        From T_WMProductBox
	                        Inner Join T_WMProductPallet On T_WMProductPallet.PalletNo = T_WMProductBox.PalletNo
	                        Where T_WMProductBox.PackingID = @PackingID
	                        Group By T_WMProductBox.PalletNo
                        ) As Result Inner Join T_WMProductBox On T_WMProductBox.PalletNo = Result.PalletNo
                        Where Result.PackingQty = Result.PalletQty";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

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