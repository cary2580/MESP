<%@ WebHandler Language="C#" Class="RPT_010" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class RPT_010 : BasePage
{
    protected string MachineID = string.Empty;
    protected string DeviceID = string.Empty;
    protected string WorkShiftID = string.Empty;
    protected DataTable ExportDataTable = new DataTable();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["MachineID"] != null)
                MachineID = _context.Request["MachineID"].Trim();

            if (_context.Request["WorkShiftID"] != null)
                WorkShiftID = _context.Request["WorkShiftID"].Trim();

            if (!string.IsNullOrEmpty(MachineID))
            {
                DeviceID = Util.TS.GetDeviceID(MachineID);

                if (string.IsNullOrEmpty(DeviceID))
                    throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_DeviceID"));
            }

            LoadExportDataTable();

            List<Util.ChartSeriesOption> Result = new List<Util.ChartSeriesOption>();

            Util.ChartSeriesOption GoodQtyList = new Util.ChartSeriesOption() { name = (string)GetLocalResourceObject("Str_ChartLineName_GoodQty"), color = "#0D7EF0", data = ExportDataTable.AsEnumerable().Select(Row => Row["GoodQty"]).ToList() };

            Result.Add(GoodQtyList);

            if (ExportDataTable.AsEnumerable().Sum(Row => (int)Row["ReWorkQty"]) > 0)
            {
                Util.ChartSeriesOption ReWorkQtyList = new Util.ChartSeriesOption() { name = (string)GetLocalResourceObject("Str_ChartLineName_ReWorkQty"), color = "#f0ad4e", data = ExportDataTable.AsEnumerable().Select(Row => Row["ReWorkQty"]).ToList() };

                Result.Add(ReWorkQtyList);
            }

            if (ExportDataTable.AsEnumerable().Sum(Row => (int)Row["QuarantineQty"]) > 0)
            {
                Util.ChartSeriesOption QuarantineQtyList = new Util.ChartSeriesOption() { name = (string)GetLocalResourceObject("Str_ChartLineName_QuarantineQty"), color = "#CA04B2", data = ExportDataTable.AsEnumerable().Select(Row => Row["QuarantineQty"]).ToList() };

                Result.Add(QuarantineQtyList);
            }

            if (ExportDataTable.AsEnumerable().Sum(Row => (int)Row["ScrapQty"]) > 0)
            {
                Util.ChartSeriesOption ScrapQtyList = new Util.ChartSeriesOption() { name = (string)GetLocalResourceObject("Str_ChartLineName_ScrapQty"), color = "#EC1926", data = ExportDataTable.AsEnumerable().Select(Row => Row["ScrapQty"]).ToList() };

                Result.Add(ScrapQtyList);
            }

            ResponseSuccessData(new { ChartTilte = ExportDataTable.Rows[0]["MachineName"].ToString().Trim(), SeriesValue = Result, xAxisValue = ExportDataTable.AsEnumerable().Select(Row => ((DateTime)Row["TickDateTimeEnd"]).ToDefaultString("HH:mm")) });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 載入匯出資料
    /// </summary>
    protected void LoadExportDataTable()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_010");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("DeviceID", "Nvarchar", 50, DeviceID));

        dbcb.appendParameter(Util.GetDataAccessAttribute("WorkShiftID", "Nvarchar", 50, WorkShiftID));

        ExportDataTable = CommonDB.ExecuteSelectQuery(dbcb);

        if (ExportDataTable.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}