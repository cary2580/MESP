<%@ WebHandler Language="C#" Class="ProductionInspectionInfoGet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class ProductionInspectionInfoGet : BasePage
{
    protected string TicketID = string.Empty;
    protected string CreateWorkCode = string.Empty;
    protected DataTable ResultDataTable = new DataTable();
    protected object Result = new object();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (_context.Request["CreateWorkCode"] != null)
            {
                CreateWorkCode = _context.Request["CreateWorkCode"].Trim();

                int CreateAccountID = BaseConfiguration.GetAccountID(CreateWorkCode);

                if (CreateAccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(CreateAccountID))
                    throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));
            }

            if (string.IsNullOrEmpty(TicketID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_TicketID"));

            CheckCanCreate();

            CheckTicketRouting();

            ResponseSuccessData(Result);
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 檢查是否可以新增送檢紀錄
    /// </summary>
    protected void CheckCanCreate()
    {
        string Brand = GetTickBrand();

        string Query = string.Empty;

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspection"];

        DbCommandBuilder dbcb = new DbCommandBuilder();

        //如果刻字號是空白的話，就檢查此工單是否已有送過
        if (string.IsNullOrEmpty(Brand))
        {
            Query = @"Select Count(*) From T_TSTicket Inner Join T_TSProductionInspection On T_TSProductionInspection.AUFNR = T_TSTicket.AUFNR Where T_TSTicket.TicketID = @TicketID";

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        }
        else
        {
            Query = @"Select Count(*) From T_TSProductionInspection Where Brand = @Brand";

            dbcb.appendParameter(Schema.Attributes["Brand"].copy(Brand.Trim()));
        }

        dbcb.CommandText = Query;

        if ((int)CommonDB.ExecuteScalar(dbcb) > 0)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_ProductionInspectionAUFNRRepeat"));
    }

    /// <summary>
    /// 取得此流程卡的刻字號
    /// </summary>
    /// <returns>刻字號</returns>
    protected string GetTickBrand()
    {
        string Query = @"Select Top 1 Brand From V_TSTicketResult Where TicketID = @TicketID And Brand <> '' Order By ReportTimeEnd";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketResult"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            return string.Empty;
        else
            return DT.Rows[0][0].ToString().Trim();
    }

    /// <summary>
    /// 檢查此流程卡路由是否可以新增送檢紀錄
    /// </summary>
    protected void CheckTicketRouting()
    {
        string Query = @"Select Top 1
	                        Case
		                        When (V_TSMORouting.AUART <> 'ZP21') Then (Select Top 1 ProcessTypeID From T_TSBaseRouting Where (T_TSBaseRouting.PLNNR + '-' + T_TSBaseRouting .PLNAL + '-' + T_TSBaseRouting .PLNKN = V_TSMORouting.PLNNR + '-' + V_TSMORouting.PLNAL + '-' + V_TSMORouting.PLNKN) And T_TSBaseRouting.ProcessID = T_TSTicketRouting.ProcessID)
		                        Else Null
	                        End AS ProcessTypeID,
	                        T_TSTicket.TicketID,
                            T_TSTicket.Qty,
	                        (Select Top 1 Brand From V_TSTicketResult Where V_TSTicketResult.TicketID = T_TSTicket.TicketID And V_TSTicketResult.Brand <> '' Order By V_TSTicketResult.ReportTimeEnd) As Brand,
	                        V_TSMORouting.*
                        From  T_TSTicket
                        Inner Join T_TSTicketRouting On T_TSTicketRouting.TicketID = T_TSTicket.TicketID
                        Inner Join V_TSMORouting On T_TSTicket.AUFNR = V_TSMORouting.AUFNR And T_TSTicketRouting.AUFPL = V_TSMORouting.AUFPL And T_TSTicketRouting.APLZL = V_TSMORouting.APLZL
                        Where T_TSTicket.TicketID = @TicketID
                        And T_TSTicketRouting.IsEnd = 0
                        Order By ProcessID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketRoutingEnd"));

        // 代表此流程卡有綁定群組計數器，就得再比對是不是已經做到全檢去了(全檢的工種ID=5)
        if (DT.Rows[0]["ProcessTypeID"].ToString().Trim() != "" && DT.Rows[0]["ProcessTypeID"].ToString().Trim() != "5")
            throw new CustomException((string)GetLocalResourceObject("Str_Error_TicketRoutingProcessTypeID"));

        Result = new
        {
            AUFNR = DT.Rows[0]["AUFNR"].ToString().Trim(),
            //流程卡號
            TicketID = DT.Rows[0]["AUFNR"].ToString().Trim(),
            //流程卡開單數量
            TicketQty = DT.Rows[0]["Qty"].ToString().Trim(),
            //物料號碼
            PLNBEZ = DT.Rows[0]["PLNBEZ"].ToString().Trim(),
            //圖號
            ZEINR = DT.Rows[0]["ZEINR"].ToString().Trim(),
            //零件號
            FERTH = DT.Rows[0]["FERTH"].ToString().Trim(),
            //生產版本
            TEXT1 = DT.Rows[0]["TEXT1"].ToString().Trim(),
            //批次屬性
            CINFO = DT.Rows[0]["CINFO"].ToString().Trim(),
            //SAP批次號
            CHARG = DT.Rows[0]["CHARG"].ToString().Trim(),
            //刻字號
            Brand = DT.Rows[0]["Brand"].ToString().Trim()
        };
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}