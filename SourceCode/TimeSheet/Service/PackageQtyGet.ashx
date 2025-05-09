<%@ WebHandler Language="C#" Class="PackageQtyGet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class PackageQtyGet : BasePage
{
    protected string AUFNR = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["AUFNR"] != null)
                AUFNR = _context.Request["AUFNR"].Trim();

            if (!string.IsNullOrEmpty(AUFNR))
                AUFNR = Util.TS.ToAUFNR(AUFNR);

            ResponseSuccessData(new
            {
                PackageQty = CheckPackageQty()
            });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 检查这个工单的包装数量是否已经在成品包装数量表
    /// </summary>
    protected int CheckPackageQty()
    {
        string Query = "Select PackageQty From T_TSPackageQty Where AUFNR = @AUFNR";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSPackageQty"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0)
            return (int)DT.Rows[0]["PackageQty"];
        else
            return GetPackageQty();
    }

    /// <summary>
    /// 取得这个生产版本的包装数量
    /// </summary>
    /// <returns>包装数量</returns>
    protected int GetPackageQty()
    {
        string Query = @"Select Top 1 PackageQty From V_TSMORouting Where AUFNR = @AUFNR";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPAFKO"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        return (int)DT.Rows[0]["PackageQty"];
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}