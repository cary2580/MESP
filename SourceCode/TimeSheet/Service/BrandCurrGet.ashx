<%@ WebHandler Language="C#" Class="BrandCurrGet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class BrandCurrGet : BasePage
{
    protected string DeviceID = string.Empty;

    protected string Brand = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["DeviceID"] != null)
                DeviceID = _context.Request["DeviceID"].Trim();

            if (string.IsNullOrEmpty(DeviceID))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_DeviceID"));

            string Query = @"Select Top 1 * From T_TSBrand Where DeviceID = @DeviceID And IsEnable = 1 Order By SerialNo Desc";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSBrand"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count > 0)
                Brand = DT.Rows[0]["Brand"].ToString().Trim();

            ResponseSuccessData(new { Brand = Brand });
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