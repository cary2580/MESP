<%@ WebHandler Language="C#" Class="WMPendingBoxGetInfoList" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class WMPendingBoxGetInfoList : BasePage
{
    protected string BoxNo = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["BoxNo"] != null)
                BoxNo = _context.Request["BoxNo"].Trim();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBoxByTicket"];

            string Query = @"Select 
                            T_TSTicket.TicketID,
                            (Select Top 1 PLNBEZ From V_TSMORouting Where AUFNR = T_TSTicket.AUFNR Order By VORNR Desc) As PLNBEZ,
                            (Select Top 1 TEXT1 From V_TSMORouting Where AUFNR = T_TSTicket.AUFNR Order By VORNR Desc) As TEXT1,
                            T_WMProductBoxByTicket.Qty,
                            T_WMProductBoxByTicket.PackageQty,
                            Base_Org.dbo.GetAccountName(T_WMProductBoxByTicket.CreateAccountID) As CreateAccountName,
                            T_WMProductBoxByTicket.CreateDate
                        From T_WMProductBoxByTicket Inner Join T_TSTicket On T_WMProductBoxByTicket.TicketID = T_TSTicket.TicketID
                        Where BoxNo = @BoxNo 
                        Order By T_WMProductBoxByTicket.CreateDate Desc";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

            var ResponseData = new
            {
                colModel = Columns.Select(Column => new
                {
                    name = Column.ColumnName,
                    index = Column.ColumnName,
                    label = GetListLabel(Column.ColumnName),
                    width = GetWidth(Column.ColumnName),
                    align = GetAlign(Column.ColumnName),
                    hidden = GetIsHidden(Column.ColumnName),
                    classes = Column.ColumnName == "TicketID" || Column.ColumnName == "TEXT1" ? BaseConfiguration.JQGridColumnClassesName : "",
                }),
                TicketIDColumnName = "TicketID",
                QtyColumnName = "Qty",
                TEXT1ColumnName = "TEXT1",
                ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    TicketID = Row["TicketID"].ToString().Trim(),
                    PLNBEZ = Row["PLNBEZ"].ToString().Trim(),
                    TEXT1 = Row["TEXT1"].ToString().Trim(),
                    Qty = Row["Qty"].ToString().Trim(),
                    PackageQty = Row["PackageQty"].ToString().Trim(),
                    CreateAccountName = Row["CreateAccountName"].ToString().Trim(),
                    CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureString()
                })
            };

            ResponseSuccessData(ResponseData);
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 指定ColumnName得到是否影藏
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否影藏</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "PLNBEZ":
                return true;
            default:
                return false;
        }
    }


    /// <summary>
    /// 指定ColumnName得到對齊方式
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>對齊方式</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "TEXT1":
                return "left";
            default:
                return "center";
        }
    }


    /// <summary>
    /// 指定ColumnName得到欄位寬度
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>欄位寬度</returns>
    protected int GetWidth(string ColumnName)
    {
        switch (ColumnName)
        {
            case "CreateDate":
                return 100;
            case "Qty":
            case "PackageQty":
                return 70;
            case "TicketID":
            case "CreateAccountName":
                return 100;
            default:
                return 250;
        }
    }


    /// <summary>
    /// 指定ColumnName得到顯示欄位名稱
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "TicketID":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_TicketID");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            case "Qty":
                return (string)GetLocalResourceObject("Str_ColumnName_Qty");
            case "PackageQty":
                return (string)GetLocalResourceObject("Str_ColumnName_PackageQty");
            case "CreateAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateAccountName");
            case "CreateDate":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateDate");
            default:
                return ColumnName;
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