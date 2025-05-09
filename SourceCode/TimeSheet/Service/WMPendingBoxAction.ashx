<%@ WebHandler Language="C#" Class="WMPendingBoxAction" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class WMPendingBoxAction : BasePage
{
    protected enum Action : short { Append = 0, Save, Delete };
    protected string BoxNo = string.Empty;
    protected string AppendFromBoxNo = string.Empty;
    protected string TicketID = string.Empty;
    protected string Operator = string.Empty;
    protected int Qty = -1;
    protected List<string> DeleteTicketIDList = new List<string>();
    protected Action ActionEnum;
    protected bool IsHavePendingBox = false;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["ActionID"] != null)
                ActionEnum = (Action)Enum.Parse(typeof(Action), _context.Request["ActionID"].Trim());
            if (_context.Request["BoxNo"] != null)
                BoxNo = _context.Request["BoxNo"].Trim();
            if (_context.Request["AppendFromBoxNo"] != null)
                AppendFromBoxNo = _context.Request["AppendFromBoxNo"].Trim();
            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();
            if (_context.Request["Operator"] != null)
                Operator = _context.Request["Operator"].Trim();
            if (_context.Request["Qty"] != null)
            {
                if (!int.TryParse(_context.Request["Qty"].Trim(), out Qty))
                    Qty = -1;
            }

            if (_context.Request["DeleteTicketIDs"] != null)
                DeleteTicketIDList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(context.Request["DeleteTicketIDs"].Trim());

            CheckRule();

            switch (ActionEnum)
            {
                case Action.Append:
                    Append();
                    return;
                case Action.Save:
                    Save();
                    return;
                case Action.Delete:
                    Delete();
                    return;
            }
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 增加流程卡
    /// </summary>
    protected void Append()
    {
        DBAction DBA = new DBAction();

        string Query = @"Update T_WMProductBoxByTicket Set BoxNo = @BoxNo,Qty = @Qty Where BoxNo = @AppendFromBoxNo";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        dbcb.appendParameter(Schema.Attributes["Qty"].copy(Qty));

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(AppendFromBoxNo, "AppendFromBoxNo"));

        DBA.AddCommandBuilder(dbcb);

        dbcb = new DbCommandBuilder();

        if (IsHavePendingBox)
            Query = @"Update T_WMPendingBox Set Qty = (Select Sum(Qty) From T_WMProductBoxByTicket Where BoxNo = @BoxNo) Where BoxNo = @BoxNo";
        else
        {
            Query = @"Insert Into T_WMPendingBox (BoxNo,Qty,CreateAccountID) Values (@BoxNo,(Select Sum(Qty) From T_WMProductBoxByTicket Where BoxNo = @BoxNo),@CreateAccountID)";

            dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));
        }

        dbcb.CommandText = Query;

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        DBA.AddCommandBuilder(dbcb);

        DBA.Execute();
    }

    /// <summary>
    /// 儲存資料
    /// </summary>
    protected void Save()
    {
        DBAction DBA = new DBAction();

        string Query = @"Update T_WMProductBoxByTicket Set Qty = @Qty Where BoxNo = @BoxNo And TicketID = @TicketID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        dbcb.appendParameter(Schema.Attributes["Qty"].copy(Qty));

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DBA.AddCommandBuilder(dbcb);

        dbcb = new DbCommandBuilder();

        if (IsHavePendingBox)
            Query = @"Update T_WMPendingBox Set Qty = (Select Sum(Qty) From T_WMProductBoxByTicket Where BoxNo = @BoxNo) Where BoxNo = @BoxNo";
        else
        {
            Query = @"Insert Into T_WMPendingBox (BoxNo,Qty,CreateAccountID) Values (@BoxNo,(Select Sum(Qty) From T_WMProductBoxByTicket Where BoxNo = @BoxNo),@CreateAccountID)";

            dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));
        }

        dbcb.CommandText = Query;

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        DBA.AddCommandBuilder(dbcb);

        DBA.Execute();
    }

    /// <summary>
    /// 刪除資料
    /// </summary>
    protected void Delete()
    {
        DBAction DBA = new DBAction();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        string Query = string.Empty;

        DbCommandBuilder dbcb = new DbCommandBuilder();

        foreach (string TicketID in DeleteTicketIDList)
        {
            Query = @"Delete T_WMProductBoxByTicket Where BoxNo = @BoxNo And TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);
        }

        Query = @"Update T_WMPendingBox Set Qty = (Select Sum(Qty) From T_WMProductBoxByTicket Where BoxNo = @BoxNo) Where BoxNo = @BoxNo";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        DBA.AddCommandBuilder(dbcb);

        DBA.Execute();
    }

    /// <summary>
    /// 檢查異動規則
    /// </summary>
    protected void CheckRule()
    {
        if (string.IsNullOrEmpty(Operator))
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkCode"));
        if (string.IsNullOrEmpty(BoxNo))
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Empty_BoxNo"));

        AccountID = BaseConfiguration.GetAccountID(Operator);

        if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

        if (ActionEnum != Action.Delete)
        {
            if (string.IsNullOrEmpty(TicketID))
                LoadTicketID();

            if (ActionEnum == Action.Append)
            {
                if (string.IsNullOrEmpty(AppendFromBoxNo))
                    throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Empty_BoxNo"));

                if (string.IsNullOrEmpty(TicketID))
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketNotEnd"));
                if (AppendFromBoxNoIsPending())
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_SameBoxID"));
                if (IsSameBoxAndTicket())
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_SameBoxIDAndTicket"));
                if (!IsSamePLNBEZ())
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_DifferentPLNBEZ"));
            }

            if (Qty < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_Qty"));

            int PackageQty = GetPackageQty();

            if ((Qty + GetSameBoxQty()) > PackageQty)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_QtyOverPackageQty"));

            LoadIsHavePendingBox();
        }
        else
        {
            int TicketRowCount = GetBoxTicketCount();

            if (TicketRowCount - DeleteTicketIDList.Count < 1)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_NoTicketInBox"));
        }
    }

    /// <summary>
    /// 取得是否相同物料號碼
    /// </summary>
    /// <returns>是否相同物料號碼</returns>
    protected bool IsSamePLNBEZ()
    {
        string Query = @"Select 
                        Case
	                        When T_TSTicket.PLNBEZ = (Select PLNBEZ From T_TSTicket Where TicketID = @TicketID) Then Convert(bit,1)
	                        Else Convert(bit,0)
                        End As SamePLNBEZ
                        From T_WMProductBoxByTicket Inner Join T_TSTicket On T_WMProductBoxByTicket.TicketID = T_TSTicket.TicketID
                        Where T_WMProductBoxByTicket.BoxNo = @BoxNo";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        return (bool)CommonDB.ExecuteScalar(dbcb);
    }

    /// <summary>
    /// 取得此箱號的可裝箱數量
    /// </summary>
    /// <returns>箱號的可裝箱數量</returns>
    protected int GetPackageQty()
    {
        string Query = @"Select PackageQty From T_WMProductBoxByTicket Where BoxNo = @BoxNo";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMPendingBox"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        if (!string.IsNullOrEmpty(AppendFromBoxNo))
            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(AppendFromBoxNo));
        else
            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        return (int)CommonDB.ExecuteScalar(dbcb);
    }

    /// <summary>
    /// 取得此箱是否已被拼箱
    /// </summary>
    /// <returns>此流程卡是否已被拼箱</returns>
    protected bool AppendFromBoxNoIsPending()
    {
        string Query = @"Select Count(*) From T_WMPendingBox Where BoxNo = @BoxNo";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMPendingBox"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(AppendFromBoxNo));

        return ((int)CommonDB.ExecuteScalar(dbcb)) > 0;
    }

    /// <summary>
    /// 取的箱號中目前有多少筆流程卡
    /// </summary>
    /// <returns>箱號中目前有多少筆流程卡</returns>
    protected int GetBoxTicketCount()
    {
        string Query = @"Select Count(*) From T_WMProductBoxByTicket Where BoxNo = @BoxNo";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        return (int)CommonDB.ExecuteScalar(dbcb);
    }

    /// <summary>
    /// 載入流程卡號
    /// </summary>
    protected void LoadTicketID()
    {
        string Query = @"Select TicketID From T_WMProductBoxByTicket Where BoxNo = @BoxNo";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        if (!string.IsNullOrEmpty(AppendFromBoxNo))
            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(AppendFromBoxNo));
        else
            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            TicketID = DT.Rows[0]["TicketID"].ToString().Trim();
    }

    /// <summary>
    /// 載入此箱號是否已成立
    /// </summary>
    protected void LoadIsHavePendingBox()
    {
        string Query = @"Select Count(*) From T_WMPendingBox Where BoxNo = @BoxNo";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMPendingBox"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        IsHavePendingBox = (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 取得是否有相同箱號與流程卡
    /// </summary>
    /// <returns>是否有相同箱號與流程卡</returns>
    protected bool IsSameBoxAndTicket()
    {
        string Query = @"Select Count(*) From T_WMProductBoxByTicket Where BoxNo = @BoxNo And TicketID = @TicketID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 取得實際裝箱數量(不包含自己這張流程卡)
    /// </summary>
    /// <returns></returns>
    protected int GetSameBoxQty()
    {
        string Query = @"Select IsNull(Sum(Qty),0) As Qty From T_WMProductBoxByTicket Where BoxNo = @BoxNo";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        if (ActionEnum != Action.Append)
        {
            Query += @" And TicketID <> @TicketID";

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        }

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        dbcb.CommandText = Query;

        return (int)CommonDB.ExecuteScalar(dbcb);
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}