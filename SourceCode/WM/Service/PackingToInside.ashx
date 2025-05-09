<%@ WebHandler Language="C#" Class="PackingToInside" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class PackingToInside : BasePage
{
    protected string PackingID = string.Empty;
    protected string Remark = string.Empty;

    protected string MATNR = string.Empty;
    protected string MAKTX = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["PackingID"] != null)
                PackingID = _context.Request["PackingID"].Trim();
            if (_context.Request["Remark"] != null)
                Remark = _context.Request["Remark"].Trim();

            CheckBoxNoInOtherPackingList();

            LoadData();

            DBAction DBA = new DBAction();

            string NewPackingID = BaseConfiguration.SerialObject[(short)31].取號();

            string Query = @"Insert Into T_WMProductPackingToInside (PackingID,MATNR,MAKTX,Remark,CreateAccountID) Values (@PackingID,@MATNR,@MAKTX,@Remark,@CreateAccountID)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingToInside"];

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(NewPackingID));
            dbcb.appendParameter(Schema.Attributes["MATNR"].copy(MATNR));
            dbcb.appendParameter(Schema.Attributes["MAKTX"].copy(MAKTX));
            dbcb.appendParameter(Schema.Attributes["Remark"].copy(Remark));
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
    /// 檢查箱號是否已有裝箱
    /// </summary>
    protected void CheckBoxNoInOtherPackingList()
    {
        string Query = @"Select BoxNo, PackingID From T_WMProductBox Where BoxNo In(Select BoxNo From T_WMProductPackingListTemp Where PackingID = @PackingID)";

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

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select Top 1 T_WMProductPallet.MATNR,T_WMProductPallet.MAKTX
                            From T_WMProductPackingListTemp Inner Join T_WMProductBox On T_WMProductBox.BoxNo = T_WMProductPackingListTemp.BoxNo
                            Inner Join T_WMProductPallet On T_WMProductPallet.PalletNo = T_WMProductBox.PalletNo
                            Where T_WMProductPackingListTemp.PackingID = @PackingID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingListTemp"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException("「" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_MAKTX") + "」" + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));

        MATNR = DT.Rows[0]["MATNR"].ToString().Trim();

        MAKTX = DT.Rows[0]["MAKTX"].ToString().Trim();
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}