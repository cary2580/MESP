<%@ WebHandler Language="C#" Class="MODelete" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class MODelete : BasePage
{
    protected List<string> AUFNRList = new List<string>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            base.processRequest(context);

            if (_context.Request["AUFNRList"] != null)
                AUFNRList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(_context.Request["AUFNRList"].Trim());

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

            DBAction DBA = new DBAction();

            foreach (string MOID in AUFNRList)
            {
                string AUFNR = Util.TS.ToAUFNR(MOID);

                if (IsHaveTicket(AUFNR))
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_HaveTicket") + AUFNR);

                string Query = @"Delete T_TSSAPAFKO Where AUFNR = @AUFNR";

                DbCommandBuilder dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

                dbcb.appendParameter(Schema.Attributes["STATUS"].copy(((short)Util.TS.MOStatus.InProcess).ToString()));

                DBA.AddCommandBuilder(dbcb);

                Query = @"Delete T_TSSAPAFVC Where AUFNR = @AUFNR";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

                DBA.AddCommandBuilder(dbcb);

                Query = @"Delete T_TSSAPAUFM Where AUFNR = @AUFNR";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 指定工單號得到是否已有流程卡
    /// </summary>
    /// <param name="AUFNR">工單號</param>
    /// <returns>是否已有流程卡</returns>
    protected bool IsHaveTicket(string AUFNR)
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        string Query = @"Select Count(*) From T_TSTicket Where AUFNR = @AUFNR";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }
}