<%@ WebHandler Language="C#" Class="LableScanGoIn" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class LableScanGoIn : BasePage
{
    protected string TicketID = string.Empty;
    protected int PackageQty = 0;
    protected string TEXT1 = string.Empty;
    protected bool IsSample = true;
    protected string MachineID = string.Empty;
    protected string DeviceID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (_context.Request["MachineID"] != null)
                MachineID = _context.Request["MachineID"].Trim();

            //检查设备是否存在
            DataRow Row = Util.TS.GetDeviceRow(MachineID);

            if (Row == null)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_MachineID"));

            DeviceID = Row["DeviceID"].ToString().Trim();

            CheckCanGoIn();

            CheckProductionVersionAndLoadData();

            ResponseSuccessData(new
            {
                PackageQty = PackageQty,
                TEXT1 = TEXT1,
                IsSample = IsSample
            });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 检查流程卡进工状态,是不是进工到最后一个工序
    /// </summary>
    protected void CheckCanGoIn()
    {
        string Query = @"Select 
	                            AUART,
	                            Max(V_TSMORouting.VORNR) As LastVORNR,
	                            IsNull((Select VORNR From T_TSTicketCurrStatus Where TicketID = @TicketID) ,'') As TicketCurrStatusVORNR
                        From V_TSMORouting 
                        Where V_TSMORouting.AUFNR In
                        (Select Top 1 AUFNR From T_TSTicket Where TicketID = @TicketID)
                        Group By AUART";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        /* 如果成立的話，代表无此流程卡 */
        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

        /*试样无料号工单不用检查*/
        if (DT.Rows[0]["AUART"].ToString() != "ZP21")
        {
            /*如果成立的话，代表流程卡未进工到最后工序*/
            if (DT.Rows[0]["LastVORNR"].ToString().Trim() != DT.Rows[0]["TicketCurrStatusVORNR"].ToString().Trim())
                throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketProcessID"));
        }
    }

    /// <summary>
    /// 检查扫进去的流程卡，与未产生箱号资料的流程卡关联生产版本是否不一样,检查OK后，载入资料
    /// </summary>
    protected void CheckProductionVersionAndLoadData()
    {
        string Query = @"Select 
                               Top 1
	                           T_TSSAPAFKO.PLNBEZ + '-' + T_TSSAPAFKO.VERID As OldVERID,
	                           (Select SAPAFKO.PLNBEZ + '-' + SAPAFKO.VERID From T_TSTicket As Ticket Inner Join T_TSSAPAFKO As SAPAFKO On SAPAFKO.AUFNR = Ticket.AUFNR  Where Ticket.TicketID = @TicketID) As NewVERID
                        From T_TSLableScan 
                        Inner Join T_TSTicket On T_TSTicket.TicketID = T_TSLableScan.TicketID
                        Inner Join T_TSSAPAFKO On T_TSSAPAFKO.AUFNR = T_TSTicket.AUFNR
                        Where IsNull(T_TSLableScan.BoxNo,'') = '' And T_TSLableScan.DeviceID = @DeviceID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count > 0 && !string.IsNullOrEmpty(DT.Rows[0]["OldVERID"].ToString().Trim()) && DT.Rows[0]["OldVERID"].ToString().Trim() != DT.Rows[0]["NewVERID"].ToString().Trim())
            throw new CustomException((string)GetLocalResourceObject("Str_Error_VERID"));

        Query = @"Select T_TSSAPMKAL.TEXT1,
                         T_TSSAPMKAL.PackageQty,
                         T_TSSAPAFKO.AUART,
                         T_TSSAPAFKO.KTEXT
                  From T_TSTicket 
                  Inner Join T_TSSAPAFKO On T_TSSAPAFKO.AUFNR = T_TSTicket.AUFNR
                  left Join T_TSSAPMKAL On T_TSSAPMKAL.MATNR = T_TSSAPAFKO.PLNBEZ And T_TSSAPMKAL.VERID = T_TSSAPAFKO.VERID 
                  Where T_TSTicket.TicketID = @TicketID";

        Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows[0]["AUART"].ToString().Trim() == "ZP21")
        {
            IsSample = false;

            TEXT1 = DT.Rows[0]["KTEXT"].ToString().Trim();

            PackageQty = 0;
        }
        else
        {
            TEXT1 = DT.Rows[0]["TEXT1"].ToString().Trim();

            PackageQty = (int)DT.Rows[0]["PackageQty"];

            if (PackageQty <= 0)
                throw new CustomException((string)GetLocalResourceObject("Str_Error_PackageQty"));
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