<%@ WebHandler Language="C#" Class="BoxGoToPallet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class BoxGoToPallet : BasePage
{
    protected string PalletNo = string.Empty;
    protected string BoxNo = string.Empty;
    protected string Created = string.Empty;
    protected int Qty = 0;
    protected int PackageQty = 0;
    protected string MATNR = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["PalletNo"] != null)
                PalletNo = _context.Request["PalletNo"].Trim();
            if (_context.Request["BoxNo"] != null)
                BoxNo = _context.Request["BoxNo"].Trim();
            if (_context.Request["Created"] != null)
                Created = _context.Request["Created"].Trim();

            CheckRule();

            CreatePalletTempData();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 檢查規則
    /// </summary>
    protected void CheckRule()
    {
        if (string.IsNullOrEmpty(Created))
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkCode"));
        if (string.IsNullOrEmpty(BoxNo))
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Empty_BoxNo"));

        AccountID = BaseConfiguration.GetAccountID(Created);

        if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

        if (IsBoxExistsInWarehouse())
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_BoxExistsInWarehouse"));

        DataTable Box_DT = GetBoxData();

        if (Box_DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_NoBoxData"));

        DataTable Pallet_DT = GetTempPalletData();

        LoadMATNR();

        string PalletMATNR = string.Empty;

        if (IsBoxExistsInTempWarehouse())
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_ScanBoxRepeat"));
        else if (Pallet_DT.Rows.Count > 0)
            PalletMATNR = Pallet_DT.AsEnumerable().Select(Row => Row["MATNR"].ToString().Trim()).First();

        if (Pallet_DT.Rows.Count > 0 && PalletMATNR != MATNR)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_PalletDifferentMATNR"));

        Qty = Box_DT.AsEnumerable().Sum(Row => (int)Row["Qty"]);

        PackageQty = Box_DT.AsEnumerable().Select(Row => (int)Row["PackageQty"]).First();
    }

    /// <summary>
    /// 取得箱號是否已入庫
    /// </summary>
    /// <returns>箱號是否已入庫</returns>
    protected bool IsBoxExistsInWarehouse()
    {
        string Query = @"Select Count(*) From T_WMProductBox Where BoxNo = @BoxNo";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 取得箱號是否已掃描
    /// </summary>
    /// <returns></returns>
    protected bool IsBoxExistsInTempWarehouse()
    {
        string Query = @"Select Count(*) From T_WMProductPalletTemp Where BoxNo = @BoxNo";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 取得箱號資料表
    /// </summary>
    /// <returns>箱號資料表</returns>
    protected DataTable GetBoxData()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        string Query = @"Select * From T_WMProductBoxByTicket Where BoxNo = @BoxNo Order By CreateDate Desc";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 取得暫存棧板表資料
    /// </summary>
    /// <returns>暫存棧板表資料</returns>
    protected DataTable GetTempPalletData()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPalletTemp"];

        string Query = @"Select * From T_WMProductPalletTemp Where PalletNo = @PalletNo Order By CreateDate Desc";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 依照箱號載入物料代碼
    /// </summary>
    protected void LoadMATNR()
    {
        string Query = @"Select Top 1 PLNBEZ 
                            From T_WMProductBoxByTicket 
                            Inner Join T_TSTicket On T_WMProductBoxByTicket.TicketID = T_TSTicket.TicketID
                            Where BoxNo = @BoxNo 
                            Order By T_WMProductBoxByTicket.CreateDate Desc";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        MATNR = CommonDB.ExecuteScalar(dbcb).ToString().Trim();
    }

    /// <summary>
    /// 產生一筆暫存棧板資料
    /// </summary>
    protected void CreatePalletTempData()
    {
        string Query = @"Insert Into T_WMProductPalletTemp (PalletNo,BoxNo,MATNR,Qty,PackageQty,CreateAccountID) Values (@PalletNo,@BoxNo,@MATNR,@Qty,@PackageQty,@CreateAccountID)";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPalletTemp"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        if (string.IsNullOrEmpty(PalletNo))
            PalletNo = NewGuid;

        dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo));
        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));
        dbcb.appendParameter(Schema.Attributes["MATNR"].copy(MATNR));
        dbcb.appendParameter(Schema.Attributes["Qty"].copy(Qty));
        dbcb.appendParameter(Schema.Attributes["PackageQty"].copy(PackageQty));
        dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));

        CommonDB.ExecuteSingleCommand(dbcb);
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}