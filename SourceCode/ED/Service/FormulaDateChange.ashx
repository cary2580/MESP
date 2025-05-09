<%@ WebHandler Language="C#" Class="FormulaDateChange" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class FormulaDateChange : BasePage
{
    protected string PAID = string.Empty;

    protected bool IsB = true;

    protected DateTime TargetDate = DateTime.Parse("1900/01/01");

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["PAID"] != null)
                PAID = _context.Request["PAID"].ToStringFromBase64();

            if (_context.Request["IsB"] != null)
                IsB = _context.Request["IsB"].ToBoolean();

            if (_context.Request["TargetDate"] != null)
            {
                if (!DateTime.TryParse(_context.Request["TargetDate"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out TargetDate))
                    TargetDate = DateTime.Parse("1900/01/01");
            }

            if (string.IsNullOrEmpty(PAID) || TargetDate.Year < 1911)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_AjaxAlertMessageDefaultMessage"));

            if (Util.ED.IsFormulaDateRepeat(TargetDate, IsB))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_F_DataRepeat"));

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDPhosphatingAgentB"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            string Query = string.Empty;

            if (IsB)
                Query = "Update T_EDPhosphatingAgentB Set PADate = @PADate,ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where PAID = @PAID";
            else
                Query = "Update T_EDPhosphatingAgentC Set PADate = @PADate,ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where PAID = @PAID";

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["PAID"].copy(PAID));

            dbcb.appendParameter(Schema.Attributes["PADate"].copy(TargetDate));

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

}