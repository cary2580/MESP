<%@ WebHandler Language="C#" Class="PackingListConfirm" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class PackingListConfirm : BasePage
{
    protected string PackingID = string.Empty;
    protected string Operator = string.Empty;
    protected List<string> ScanBoxNo = new List<string>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["PackingID"] != null)
                PackingID = _context.Request["PackingID"].Trim();

            if (_context.Request["Operator"] != null)
                Operator = _context.Request["Operator"].Trim();

            if (_context.Request["ScanBoxNo"] != null)
                ScanBoxNo = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(_context.Request["ScanBoxNo"].Trim());

            if (string.IsNullOrEmpty(PackingID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PackingID") + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (string.IsNullOrEmpty(Operator))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_WorkCode") + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));
            if (ScanBoxNo.Count < 1)
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BoxNo") + (string)GetGlobalResourceObject("GlobalRes", "Str_Empty_MessageEnd"));

            DataTable DT = PackingBoxNo();

            if (DT.Rows.Count != ScanBoxNo.Count)
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_PackingBoxConfirm"));

            AccountID = BaseConfiguration.GetAccountID(Operator);

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            string Query = string.Empty;

            bool IsOutside = Util.WM.PackingIDIsOutside(PackingID);

            DBAction DBA = new DBAction();

            DbCommandBuilder dbcb = new DbCommandBuilder();

            ObjectSchema Schema;

            if (IsOutside)
            {
                Schema = DBSchema.currentDB.Tables["T_WMProductPackingToOutside"];

                Query = @"Update T_WMProductPackingToOutside Set IsConfirm = 1,ConfirmAccountID = @ConfirmAccountID,ConfirmDate = GetDate() Where PackingID = @PackingID";

                dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

                dbcb.appendParameter(Schema.Attributes["ConfirmAccountID"].copy(AccountID));
            }
            else
            {
                Schema = DBSchema.currentDB.Tables["T_WMProductPackingToInside"];

                Query = @"Update T_WMProductPackingToInside Set IsConfirm = 1,ConfirmAccountID = @ConfirmAccountID,ConfirmDate = GetDate(),IsSendOut = 1,SendOutDate = GetDate() Where PackingID = @PackingID";

                dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

                dbcb.appendParameter(Schema.Attributes["ConfirmAccountID"].copy(AccountID));
            }

            dbcb.CommandText = Query;

            DBA.AddCommandBuilder(dbcb);

            if (!IsOutside)
                DataMoveToHistory(DBA);

            DBA.Execute();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 取得裝箱箱號資料表
    /// </summary>
    /// <returns>裝箱箱號資料表</returns>
    protected DataTable PackingBoxNo()
    {
        string Query = @"Select BoxNo From T_WMProductBox Where PackingID = @PackingID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }


    /// <summary>
    /// 指定DBA將資料移置歷史區
    /// </summary>
    /// <param name="DBA">DBA</param>
    protected void DataMoveToHistory(DBAction DBA)
    {
        string Query = @"Select PalletNo Into #TempPallet From T_WMProductBox Where PackingID = @PackingID Group By PalletNo

                        Delete T_WMProductPalletHistory Where PalletNo In(Select PalletNo From #TempPallet)

                        Insert Into T_WMProductPalletHistory Select * From T_WMProductPallet Where PalletNo In(Select PalletNo From #TempPallet)

                        Insert Into T_WMProductBoxBrandHistory Select * From T_WMProductBoxBrand Where BoxNo In(Select BoxNo From T_WMProductBox Where PackingID = @PackingID)

                        Delete T_WMProductBoxBrand Where BoxNo In(Select BoxNo From T_WMProductBox Where PackingID = @PackingID)

                        Insert Into T_WMProductBoxHistory Select * From T_WMProductBox Where PackingID = @PackingID

                        Delete T_WMProductBox Where PackingID = @PackingID

                        Update T_WMProductPalletHistory Set Qty = (Select Sum(Qty) From T_WMProductBoxHistory Where T_WMProductBoxHistory.PalletNo = T_WMProductPalletHistory.PalletNo) Where T_WMProductPalletHistory.PalletNo In(Select PalletNo From #TempPallet)

                        Update T_WMProductPallet Set Qty = IsNull((Select Sum(Qty) From T_WMProductBox Where T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo),0) Where T_WMProductPallet.PalletNo In (Select PalletNo From #TempPallet)

                        Delete T_WMProductPallet Where T_WMProductPallet.PalletNo In (Select PalletNo From #TempPallet) And Qty < 1";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(PackingID));

        DBA.AddCommandBuilder(dbcb);
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}