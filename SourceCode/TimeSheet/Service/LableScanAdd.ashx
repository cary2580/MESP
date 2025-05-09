<%@ WebHandler Language="C#" Class="LableScanAdd" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class LableScanAdd : BasePage
{
    protected string ScanKey = string.Empty;
    protected string TicketID = string.Empty;
    protected string LableID = string.Empty;
    protected string MachineID = string.Empty;
    protected string DeviceID = string.Empty;
    protected string WorkShiftID = string.Empty;
    protected string StatusID = string.Empty;
    protected int PackageQty = 0;
    protected string BoxNo = string.Empty;
    protected bool IsFullBox = false;
    protected bool IsStandBy = false;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (_context.Request["LableID"] != null)
                LableID = _context.Request["LableID"].Trim();

            if (_context.Request["MachineID"] != null)
                MachineID = _context.Request["MachineID"].Trim();

            if (_context.Request["WorkShiftID"] != null)
                WorkShiftID = _context.Request["WorkShiftID"].Trim();

            if (_context.Request["BoxNo"] != null)
                BoxNo = _context.Request["BoxNo"].Trim();

            if (_context.Request["IsStandBy"] != null)
            {
                if (!bool.TryParse(_context.Request["IsStandBy"], out IsStandBy))
                    IsStandBy = false;
            }

            if (!string.IsNullOrEmpty(_context.Request["PackageQty"]))
            {
                if (!int.TryParse(_context.Request["PackageQty"].Trim(), out PackageQty))
                    throw new CustomException((string)GetLocalResourceObject("Str_Error_PackageQty"));
            }

            bool IsWorkCodeVerify = false;

            try
            {
                string Result = Util.TS.CheckScanLableIDRule(LableID);

                if (!string.IsNullOrEmpty(Result))
                {
                    IsWorkCodeVerify = true;
                    throw new CustomException(Result);
                }
            }
            catch (Exception ex)
            {
                ResponseSuccessData(new
                {
                    Result = false,
                    IsWorkCodeVerify = IsWorkCodeVerify,
                    ResponseResultMessage = ex.Message
                });

                return;
            }

            if (string.IsNullOrEmpty(BoxNo))
            {
                if (string.IsNullOrEmpty(WorkShiftID) || string.IsNullOrEmpty(MachineID) || string.IsNullOrEmpty(TicketID))
                    throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

                DataRow Row = Util.TS.GetDeviceRow(MachineID);

                DeviceID = Row["DeviceID"].ToString().Trim();
            }

            LableAdd();

            if (string.IsNullOrEmpty(BoxNo))
                IsFullBox = GetIsFullBox();

            if (IsFullBox)
                BoxNoGet();

            ResponseSuccessData(new
            {
                Result = true,
                IsFullBox = IsFullBox,
                BoxNo = BoxNo
            });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 条码新增
    /// </summary>
    protected void LableAdd()
    {
        string Query = string.Empty;

        ScanKey = BaseConfiguration.SerialObject[(short)24].取號();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        if (string.IsNullOrEmpty(BoxNo))
        {
            Query = @"Insert Into T_TSLableScan (ScanKey,TicketID,LableID,DeviceID,WorkShiftID,StatusID) Values (@ScanKey,@TicketID,@LableID,@DeviceID,@WorkShiftID,@StatusID)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["ScanKey"].copy(ScanKey));
            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
            dbcb.appendParameter(Schema.Attributes["LableID"].copy(LableID));
            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));
            dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(WorkShiftID));
            dbcb.appendParameter(Schema.Attributes["StatusID"].copy(!IsStandBy ? ((short)Util.TS.LableScanStatus.NormalLable).ToString() : ((short)Util.TS.LableScanStatus.StandbyLable).ToString()));

            CommonDB.ExecuteSingleCommand(dbcb);
        }
        else
        {
            Query = @"Insert Into T_TSLableScan 
                    (ScanKey,TicketID,LableID,DeviceID,WorkShiftID,StatusID,BoxNo) 
                    Values 
                    (@ScanKey,
                    (Select Top 1 TicketID From T_TSLableScan Where BoxNo = @BoxNo Order By ScanKey Desc),
                    @LableID,
                    (Select Top 1 DeviceID From T_TSLableScan Where BoxNo = @BoxNo Order By ScanKey Desc),
                    @WorkShiftID,@StatusID,@BoxNo)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["ScanKey"].copy(ScanKey));
            dbcb.appendParameter(Schema.Attributes["LableID"].copy(LableID));
            dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(WorkShiftID));
            dbcb.appendParameter(Schema.Attributes["StatusID"].copy(!IsStandBy ? ((short)Util.TS.LableScanStatus.NormalLable).ToString() : ((short)Util.TS.LableScanStatus.StandbyLable).ToString()));
            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

            CommonDB.ExecuteSingleCommand(dbcb);
        }

    }

    /// <summary>
    /// 机台关联未成箱正常条码是否满箱
    /// </summary>
    protected bool GetIsFullBox()
    {
        string Query = @"Select LableID From T_TSLableScan Where DeviceID = @DeviceID And StatusID = @StatusID And IsNull(BoxNo,'') = ''";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        dbcb.appendParameter(Schema.Attributes["StatusID"].copy(((short)Util.TS.LableScanStatus.NormalLable).ToString()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        return (bool)(DT.Rows.Count == PackageQty);
    }

    /// <summary>
    /// 产生箱号
    /// </summary>
    protected void BoxNoGet()
    {
        BoxNo = BaseConfiguration.SerialObject[(short)25].取號();

        string Query = @"Update T_TSLableScan Set BoxNo = @BoxNo Where DeviceID = @DeviceID And IsNull(BoxNo,'') = ''";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        CommonDB.ExecuteSingleCommand(dbcb);
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}