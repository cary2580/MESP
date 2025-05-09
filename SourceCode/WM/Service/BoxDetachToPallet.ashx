<%@ WebHandler Language="C#" Class="BoxDetachToPallet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class BoxDetachToPallet : BasePage
{
    protected string PalletNo = string.Empty;
    protected string BoxNo = string.Empty;
    protected string Operator = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["PalletNo"] != null)
                PalletNo = _context.Request["PalletNo"].Trim();

            if (_context.Request["Operator"] != null)
                Operator = _context.Request["Operator"].Trim();

            if (_context.Request["BoxNo"] != null)
                BoxNo = _context.Request["BoxNo"].Trim();

            if (string.IsNullOrEmpty(PalletNo))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Empty_PalletNo"));

            if (string.IsNullOrEmpty(Operator))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkCode"));

            AccountID = BaseConfiguration.GetAccountID(Operator);

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPalletTemp"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            string Query = @"Delete T_WMProductPalletTemp Where PalletNo = @PalletNo And CreateAccountID = @CreateAccountID";

            if (!string.IsNullOrEmpty(BoxNo))
            {
                Query += @" And BoxNo = @BoxNo";

                dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));
            }

            dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo));
            dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));

            dbcb.CommandText = Query;

            CommonDB.ExecuteSingleCommand(dbcb);
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

}