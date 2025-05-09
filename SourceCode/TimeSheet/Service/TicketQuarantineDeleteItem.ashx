<%@ WebHandler Language="C#" Class="TicketQuarantineDeleteItem" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketQuarantineDeleteItem : BasePage
{
    protected string TicketID = string.Empty;
    protected List<string> SerialNoList = new List<string>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (_context.Request["SerialNoS"] != null)
                SerialNoList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(context.Request["SerialNoS"].Trim());

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            if (!IsCanDelete())
                throw new CustomException((string)GetLocalResourceObject("Str_Error_DeleteRule"));

            string Query = string.Empty;

            DbCommandBuilder dbcb = new DbCommandBuilder();

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResultItem"];

            foreach (string SerialNo in SerialNoList)
            {
                Query = @"Delete T_TSTicketQuarantineResultItem Where TicketID = @TicketID And SerialNo = @SerialNo";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(SerialNo));

                DBA.AddCommandBuilder(dbcb);
            }

            Query = @"Update T_TSTicketQuarantineResult Set ScrapQty = IsNull((Select Sum(ScrapQty) From T_TSTicketQuarantineResultItem Where T_TSTicketQuarantineResultItem.TicketID = @TicketID),0) Where T_TSTicketQuarantineResult.TicketID = @TicketID";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }


    /// <summary>
    /// 是否可以刪除報廢項目
    /// </summary>
    protected bool IsCanDelete()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketQuarantineResult"];

        string Query = @"Select IsJudgment From T_TSTicketQuarantineResult Where TicketID = @TicketID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        return !(bool)CommonDB.ExecuteScalar(dbcb);
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}