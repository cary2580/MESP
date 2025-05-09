<%@ WebHandler Language="C#" Class="CleanDateChange" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class CleanDateChange : BasePage
{
    protected string CID = string.Empty;

    protected DateTime TargetDate = DateTime.Parse("1900/01/01");

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["CID"] != null)
                CID = _context.Request["CID"].ToStringFromBase64();

            if (_context.Request["TargetDate"] != null)
            {
                if (!DateTime.TryParse(_context.Request["TargetDate"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out TargetDate))
                    TargetDate = DateTime.Parse("1900/01/01");
            }

            if (string.IsNullOrEmpty(CID) || TargetDate.Year < 1911)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_AjaxAlertMessageDefaultMessage"));

            DataTable DT = GetFromData();

            if (DT == null)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_AjaxAlertMessageDefaultMessage"));

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDCRecord"];

            string ProcessID = DT.Rows[0]["ProcessID"].ToString().Trim();

            string PLID = DT.Rows[0]["PLID"].ToString().Trim();

            if (Util.ED.IsCleanDateRepeat(TargetDate, PLID, ProcessID, CID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_C_DataRepeat"));

            string Query = "Update T_EDCRecord Set CleanDate = @CleanDate,ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where CID = @CID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["CID"].copy(CID));

            dbcb.appendParameter(Schema.Attributes["CleanDate"].copy(TargetDate));

            dbcb.appendParameter(Schema.Attributes["ModifyAccountID"].copy(AccountID));

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

    /// <summary>
    /// 取得來源資料
    /// </summary>
    /// <returns>來源資料</returns>
    protected DataTable GetFromData()
    {
        string Query = "Select * From T_EDCRecord Where CID = @CID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDCRecord"];

        dbcb.appendParameter(Schema.Attributes["CID"].copy(CID));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }
}