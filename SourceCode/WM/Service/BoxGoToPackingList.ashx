<%@ WebHandler Language="C#" Class="BoxGoToPackingList" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class BoxGoToPackingList : BasePage
{
    protected string ActionID = string.Empty;
    protected string PackingID = string.Empty;
    protected int AllowQty = 0;
    protected List<string> PalletNoList = new List<string>();
    protected List<string> BoxNoList = new List<string>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["ActionID"] != null)
                ActionID = _context.Request["ActionID"].Trim();

            if (_context.Request["PackingID"] != null)
                PackingID = _context.Request["PackingID"].Trim();

            if (!string.IsNullOrEmpty(_context.Request["AllowQty"]) && !int.TryParse(_context.Request["AllowQty"].Trim().Replace(",", ""), out AllowQty))
                AllowQty = -1;

            if (_context.Request["PalletNoList"] != null)
                PalletNoList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(_context.Request["PalletNoList"].Trim());

            if (_context.Request["BoxNoList"] != null)
                BoxNoList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(_context.Request["BoxNoList"].Trim());

            if (ActionID != "1" && string.IsNullOrEmpty(PackingID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Empty_PackingID"));
            else if (string.IsNullOrEmpty(PackingID))
                PackingID = NewGuid;

            AddPalletBoxNoList();

            if (ActionID == "1")
                GoToPackingList();
            else
                RemovePackingList();

            ResponseSuccessData(new { PackingID = PackingID });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 加入裝箱清單
    /// </summary>
    protected void GoToPackingList()
    {
        int AllBoxNoQty = GetAllBoxNoQty();

        if (AllBoxNoQty > AllowQty)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_PackingQtyOverAllowQty") + "" + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_AllowQty"));

        CheckMATNR();

        DBAction DBA = new DBAction();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingListTemp"];

        var BoxNoListGroup = BoxNoList.GroupBy(BoxNo => BoxNo).Select(item => item.Key).ToList();

        foreach (string BoxNo in BoxNoListGroup)
        {
            DBA.AddCommandBuilder(GetDeleteDBCB(BoxNo));

            string Query = "Insert Into T_WMProductPackingListTemp (PackingID,BoxNo,CreateAccountID) Values (@PackingID,@BoxNo,@CreateAccountID)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

            dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));

            DBA.AddCommandBuilder(dbcb);
        }

        DBA.Execute();
    }

    /// <summary>
    /// 移除裝箱清單
    /// </summary>
    protected void RemovePackingList()
    {
        DBAction DBA = new DBAction();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingListTemp"];

        var BoxNoListGroup = BoxNoList.GroupBy(BoxNo => BoxNo).Select(item => item.Key).ToList();

        foreach (string BoxNo in BoxNoListGroup)
        {
            DBA.AddCommandBuilder(GetDeleteDBCB(BoxNo));

            string Query = "Delete T_WMProductPackingListTemp Where PackingID = @PackingID And BoxNo = @BoxNo";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

            DBA.AddCommandBuilder(dbcb);
        }

        DBA.Execute();
    }

    /// <summary>
    /// 指定箱號取得刪除異動指令
    /// </summary>
    /// <param name="BoxNo">箱號</param>
    /// <returns></returns>
    protected DbCommandBuilder GetDeleteDBCB(string BoxNo)
    {
        string Query = @"Delete T_WMProductPackingListTemp Where PackingID = @PackingID And BoxNo = @BoxNo";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingListTemp"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        return dbcb;
    }

    /// <summary>
    /// 取得棧板號所屬箱號
    /// </summary>
    protected void AddPalletBoxNoList()
    {
        if (PalletNoList.Count < 1)
            return;

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

        string Query = @"Select BoxNo From T_WMProductBox Where IsNull(PackingID,'') = '' And PalletNo In (";

        for (int i = 0; i < PalletNoList.Count; i++)
        {
            if (string.IsNullOrEmpty(PalletNoList[i].Trim()))
                continue;

            if (i > 0)
                Query += ",";

            string Parameter = "PalletNo_" + i.ToString();

            Query += "@" + Parameter;

            dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNoList[i].Trim(), Parameter));
        }

        Query += ") Group By BoxNo";

        dbcb.CommandText = Query;

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        BoxNoList.AddRange(DT.AsEnumerable().Where(Row => !BoxNoList.Contains(Row["BoxNo"].ToString().Trim())).Select(Row => Row["BoxNo"].ToString().Trim()).ToList());
    }

    /// <summary>
    /// 取得所有箱號數量(PCS)
    /// </summary>
    /// <returns></returns>
    protected int GetAllBoxNoQty()
    {
        string Query = @"Select IsNull(Sum(Qty),0) As Qty From T_WMProductBox Where BoxNo In (";

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

        for (int i = 0; i < BoxNoList.Count; i++)
        {
            if (i > 0)
                Query += ",";

            string Parameter = "BoxNo_" + i.ToString();

            Query += "@" + Parameter;

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNoList[i].Trim(), Parameter));
        }

        Query += ")";

        dbcb.CommandText = Query;

        return (int)CommonDB.ExecuteScalar(dbcb);
    }

    protected void CheckMATNR()
    {
        string Query = @"Select * From (
	                        Select T_WMProductPallet.MATNR From T_WMProductPackingListTemp Inner Join T_WMProductBox On T_WMProductBox.BoxNo = T_WMProductPackingListTemp.BoxNo
	                        Inner Join T_WMProductPallet On T_WMProductPallet.PalletNo = T_WMProductBox.PalletNo
	                        Where T_WMProductPackingListTemp.PackingID = @PackingID
	                        Union All
	                        Select T_WMProductPallet.MATNR From T_WMProductBox Inner Join T_WMProductPallet On T_WMProductPallet.PalletNo = T_WMProductBox.PalletNo
	                        Where T_WMProductBox.BoxNo In (";

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

        for (int i = 0; i < BoxNoList.Count; i++)
        {
            if (i > 0)
                Query += ",";

            string Parameter = "BoxNo_" + i.ToString();

            Query += "@" + Parameter;

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNoList[i].Trim(), Parameter));
        }

        Query += " )) As Result Group By MATNR";

        dbcb.CommandText = Query;

        Schema = DBSchema.currentDB.Tables["T_WMProductPackingListTemp"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 1)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_PackingMATNRNotSame"));
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}