<%@ WebHandler Language="C#" Class="PackingToOutside" %>


using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class PackingToOutside : BasePage
{
    protected string PackingID = string.Empty;
    protected string VBELN = string.Empty;
    protected string POSNR = string.Empty;
    protected string KUNNR = string.Empty;
    protected string KUNNR_NAME = string.Empty;
    protected string MATNR = string.Empty;
    protected string MAKTX = string.Empty;
    protected string KDMAT = string.Empty;
    protected DateTime DeliveryDate = DateTime.Parse("1900/01/01");
    protected string BSTKD = string.Empty;
    protected int KWMENG = -1;
    protected int LFIMG = -1;
    protected int AllowQty = 0;
    protected string Remark = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["PackingID"] != null)
                PackingID = _context.Request["PackingID"].Trim();
            if (_context.Request["VBELN"] != null)
                VBELN = _context.Request["VBELN"].Trim();
            if (_context.Request["POSNR"] != null)
                POSNR = _context.Request["POSNR"].Trim();
            if (_context.Request["KUNNR"] != null)
                KUNNR = _context.Request["KUNNR"].Trim();
            if (_context.Request["KUNNR_NAME"] != null)
                KUNNR_NAME = _context.Request["KUNNR_NAME"].Trim();
            if (_context.Request["MATNR"] != null)
                MATNR = _context.Request["MATNR"].Trim();
            if (_context.Request["MAKTX"] != null)
                MAKTX = _context.Request["MAKTX"].Trim();
            if (_context.Request["BSTKD"] != null)
                BSTKD = _context.Request["BSTKD"].Trim();
            if (_context.Request["KDMAT"] != null)
                KDMAT = _context.Request["KDMAT"].Trim();
            if (_context.Request["Remark"] != null)
                Remark = _context.Request["Remark"].Trim();
            if (!string.IsNullOrEmpty(_context.Request["DeliveryDate"]) && !DateTime.TryParse(_context.Request["DeliveryDate"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out DeliveryDate))
                DeliveryDate = DateTime.Parse("1900/01/01");
            if (!string.IsNullOrEmpty(_context.Request["KWMENG"]) && !int.TryParse(_context.Request["KWMENG"].Trim().Replace(",", ""), out KWMENG))
                KWMENG = -1;
            if (!string.IsNullOrEmpty(_context.Request["LFIMG"]) && !int.TryParse(_context.Request["LFIMG"].Trim().Replace(",", ""), out LFIMG))
                LFIMG = -1;
            if (!string.IsNullOrEmpty(_context.Request["AllowQty"]) && !int.TryParse(_context.Request["AllowQty"].Trim().Replace(",", ""), out AllowQty))
                AllowQty = -1;

            if (string.IsNullOrEmpty(PackingID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Empty_PackingID"));
            if (string.IsNullOrEmpty(VBELN))
                throw new CustomException("「" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_VBELN") + "」" + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (string.IsNullOrEmpty(POSNR))
                throw new CustomException("「" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_POSNR") + "」" + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (string.IsNullOrEmpty(KUNNR))
                throw new CustomException("「" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_KUNNR") + "」" + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (string.IsNullOrEmpty(KUNNR_NAME))
                throw new CustomException("「" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_KUNNR_Name") + "」" + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (string.IsNullOrEmpty(MATNR))
                throw new CustomException("「" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_MATNR") + "」" + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (string.IsNullOrEmpty(MAKTX))
                throw new CustomException("「" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_MAKTX") + "」" + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (DeliveryDate.Year < 1911)
                throw new CustomException("「" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_DeliveryDate") + "」" + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (KWMENG < 0)
                throw new CustomException("「" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_KWMENG") + "」" + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (LFIMG < 0)
                throw new CustomException("「" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_LFIMG") + "」" + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (AllowQty < 1)
                throw new CustomException("「" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_AllowQty") + "」" + (string)GetLocalResourceObject("Str_Error_AllowQty"));

            CheckBoxNoInOtherPackingList();

            int AllBoxNoQty = GetAllBoxNoQty();

            if (AllBoxNoQty > AllowQty)
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_PackingQtyOverAllowQty") + "" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_AllowQty"));

            DBAction DBA = new DBAction();

            string NewPackingID = BaseConfiguration.SerialObject[(short)30].取號();

            string Query = @"Insert Into T_WMProductPackingToOutside (PackingID,VBELN,POSNR,KUNNR,KUNNR_NAME,MATNR,MAKTX,KDMAT,DeliveryDate,BSTKD,KWMENG,LFIMG,AllowQty,Remark,SAPDeliveryNo,CreateAccountID) Values (@PackingID,@VBELN,@POSNR,@KUNNR,@KUNNR_NAME,@MATNR,@MAKTX,@KDMAT,@DeliveryDate,@BSTKD,@KWMENG,@LFIMG,@AllowQty,@Remark,@SAPDeliveryNo,@CreateAccountID)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingToOutside"];

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(NewPackingID));
            dbcb.appendParameter(Schema.Attributes["VBELN"].copy(VBELN));
            dbcb.appendParameter(Schema.Attributes["POSNR"].copy(POSNR));
            dbcb.appendParameter(Schema.Attributes["KUNNR"].copy(KUNNR));
            dbcb.appendParameter(Schema.Attributes["KUNNR_NAME"].copy(KUNNR_NAME));
            dbcb.appendParameter(Schema.Attributes["MATNR"].copy(MATNR));
            dbcb.appendParameter(Schema.Attributes["MAKTX"].copy(MAKTX));
            dbcb.appendParameter(Schema.Attributes["KDMAT"].copy(KDMAT));
            dbcb.appendParameter(Schema.Attributes["DeliveryDate"].copy(DeliveryDate));
            dbcb.appendParameter(Schema.Attributes["BSTKD"].copy(BSTKD));
            dbcb.appendParameter(Schema.Attributes["KWMENG"].copy(KWMENG));
            dbcb.appendParameter(Schema.Attributes["LFIMG"].copy(LFIMG));
            dbcb.appendParameter(Schema.Attributes["AllowQty"].copy(AllowQty));
            dbcb.appendParameter(Schema.Attributes["Remark"].copy(Remark));
            dbcb.appendParameter(Schema.Attributes["SAPDeliveryNo"].copy(string.Empty));
            dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));

            DBA.AddCommandBuilder(dbcb);

            Schema = DBSchema.currentDB.Tables["T_WMProductPackingListTemp"];

            Query = @"Update T_WMProductBox Set T_WMProductBox.PackingID = @NewPackingID
                    From T_WMProductBox Inner Join T_WMProductPackingListTemp On T_WMProductBox.BoxNo = T_WMProductPackingListTemp.BoxNo Where T_WMProductPackingListTemp.PackingID = @PackingID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(NewPackingID, "NewPackingID"));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Delete T_WMProductPackingListTemp From T_WMProductPackingListTemp Where PackingID = @PackingID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            ResponseSuccessData(new { PackingID = NewPackingID });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 取得所有箱號數量(PCS)
    /// </summary>
    /// <returns></returns>
    protected int GetAllBoxNoQty()
    {
        string Query = @"Select IsNull(Sum(Qty),0) As Qty From T_WMProductBox Where BoxNo In (Select BoxNo From T_WMProductPackingListTemp Where PackingID = @PackingID)";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingListTemp"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

        return (int)CommonDB.ExecuteScalar(dbcb);
    }

    /// <summary>
    /// 檢查箱號是否已有裝箱
    /// </summary>
    protected void CheckBoxNoInOtherPackingList()
    {
        string Query = @"Select BoxNo,PackingID From T_WMProductBox Where BoxNo In (Select BoxNo From T_WMProductPackingListTemp Where PackingID = @PackingID)";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingListTemp"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        var BoxNoList = DT.AsEnumerable().Where(Row => !string.IsNullOrEmpty(Row["PackingID"].ToString().Trim())).Select(Row => Row["BoxNo"].ToString().Trim()).ToList();

        if (BoxNoList.Count > 0)
        {
            string Message = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_RepeatBoxToPacking");

            throw new CustomException(string.Format(Message, string.Join("、", BoxNoList)));
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
