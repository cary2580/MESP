<%@ WebHandler Language="C#" Class="ParametersDateChange" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class ParametersDateChange : BasePage
{
    protected string PID = string.Empty;

    protected short PIDType = 0;

    protected string TableName = string.Empty;

    protected DateTime TargetDate = DateTime.Parse("1900/01/01");

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["PID"] != null)
                PID = _context.Request["PID"].ToStringFromBase64();
            if (_context.Request["PIDType"] != null)
            {
                if (!short.TryParse(_context.Request["PIDType"].Trim(), out PIDType))
                    PIDType = 0;
            }

            if (_context.Request["TargetDate"] != null)
            {
                if (!DateTime.TryParse(_context.Request["TargetDate"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out TargetDate))
                    TargetDate = DateTime.Parse("1900/01/01");
            }

            if (PIDType < 1)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_AjaxAlertMessageDefaultMessage"));

            if (string.IsNullOrEmpty(PID) || TargetDate.Year < 1911)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_AjaxAlertMessageDefaultMessage"));

            TableName = Enum.GetName(typeof(Util.ED.PIDType), PIDType);

            if (string.IsNullOrEmpty(TableName))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_AjaxAlertMessageDefaultMessage"));

            DataTable DT = GetFromData();

            if (DT == null)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_AjaxAlertMessageDefaultMessage"));

            ObjectSchema Schema = DBSchema.currentDB.Tables[TableName];

            string WorkClassID = DT.Rows[0]["WorkClassID"].ToString().Trim();

            string PLID = DT.Rows[0]["PLID"].ToString().Trim();

            if (Util.ED.IsDataRepeat(Schema.ContainerName, TargetDate, WorkClassID, PLID, PID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_ED_P_DataRepeat"));

            string Query = "Update " + TableName + " Set PDate = @PDate,ModifyDate = GetDate(),ModifyAccountID = @ModifyAccountID Where PID = @PID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PID"].copy(PID));

            dbcb.appendParameter(Schema.Attributes["PDate"].copy(TargetDate));

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
        string Query = "Select * From " + TableName + " Where PID = @PID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables[TableName];

        dbcb.appendParameter(Schema.Attributes["PID"].copy(PID));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }
}