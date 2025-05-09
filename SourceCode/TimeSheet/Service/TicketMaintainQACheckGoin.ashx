<%@ WebHandler Language="C#" Class="TicketMaintainQACheckGoin" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainQACheckGoin : BasePage
{
    protected string MaintainID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["MaintainID"] != null)
                MaintainID = _context.Request["MaintainID"].Trim();

            if (string.IsNullOrEmpty(MaintainID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MaintainID"));

            //如果已經有了檢驗時間，就不允許再次產出檢驗時間
            if (IsHaveGoOutData())
                return;

            string Query = @"Update T_TSTicketMaintain Set QACheckTimeStart = GetDate(),QACheckTimeEnd = @QACheckTimeEnd,QACheckMinute = 0,QACheckAccountID = -1 Where MaintainID = @MaintainID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["QACheckTimeEnd"].copy(DateTime.Parse("1900/01/01")));

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            CommonDB.ExecuteSingleCommand(dbcb);
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 取得是否已經有檢驗結束資料
    /// </summary>
    /// <returns>是否已經有檢驗結束資料</returns>
    protected bool IsHaveGoOutData()
    {
        string Query = @"Select * From T_TSTicketMaintain Where MaintainID = @MaintainID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_NoMaintainData"));

        return (int)DT.Rows[0]["QACheckMinute"] > 0;
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}