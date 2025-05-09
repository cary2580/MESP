<%@ WebHandler Language="C#" Class="PackageQtySet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class PackageQtySet : BasePage
{
    protected string AUFNR = string.Empty;
    protected int PackageQty = 0;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["AUFNR"] != null)
                AUFNR = _context.Request["AUFNR"].Trim();

            if (!string.IsNullOrEmpty(AUFNR))
                AUFNR = Util.TS.ToAUFNR(AUFNR);

            if (_context.Request["PackageQty"] != null)
            {
                if (!int.TryParse(_context.Request["PackageQty"].Trim(), out PackageQty))
                    PackageQty = -1;
            }

            if (!CheckAUFNRIsExists())
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_AUFNR"));

            if (PackageQty < 1)
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_PackageQty"));

            if (CheckWMProductBox())
                throw new CustomException((string)GetLocalResourceObject("Str_Error_WMProductBox"));

            SetPackageQty();

        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 修改包装数量
    /// </summary>
    protected void SetPackageQty()
    {
        try
        {
            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSPackageQty"];

            string Query = @"Delete From T_TSPackageQty Where AUFNR = @AUFNR";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

            DBA.AddCommandBuilder(dbcb);

            Query = @"Insert Into T_TSPackageQty(AUFNR,PackageQty) Values(@AUFNR,@PackageQty)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

            dbcb.appendParameter(Schema.Attributes["PackageQty"].copy(PackageQty));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 检查这个工单是否已经有包装入库
    /// </summary>
    /// <returns>是否允许修改成品包装数量</returns>
    protected bool CheckWMProductBox()
    {
        string Query = @"Select
                               Count(*) 
                         From T_TSTicket 
                         Where T_TSTicket.AUFNR = @AUFNR And T_TSTicket.TicketID In (Select TicketID From T_WMProductBoxByTicket)";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        return (int)CommonDB.ExecuteScalar(dbcb) > 0;
    }

    /// <summary>
    /// 檢查工單號碼是否存在
    /// </summary>
    /// <returns></returns>
    protected bool CheckAUFNRIsExists()
    {
        string Query = @"Select Count(*) From T_TSSAPAFKO Where AUFNR = @AUFNR";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

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