<%@ WebHandler Language="C#" Class="PalletTempGetList" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class PalletTempGetList : BasePage
{
    protected string PalletNo = string.Empty;
    protected string Operator = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["PalletNo"] != null)
                PalletNo = _context.Request["PalletNo"].Trim();

            if (_context.Request["Operator"] != null)
                Operator = _context.Request["Operator"].Trim();

            if (string.IsNullOrEmpty(PalletNo) && string.IsNullOrEmpty(Operator))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage"));

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPalletTemp"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            string Query = @"Select 
                                Row_Number() Over(Order By CreateDate Asc) As RowNumber,
                                PalletNo,
                                BoxNo,
                                MATNR,
                                (Select ProductLGORT From T_TSMATNRParameters Where T_TSMATNRParameters.MATNR = T_WMProductPalletTemp.MATNR) As LGORT,
                                Case
                                    When Exists((Select Top 1 MAKTX From T_TSSAPMAPL Where T_TSSAPMAPL.MATNR = T_WMProductPalletTemp.MATNR)) Then (Select Top 1 MAKTX From T_TSSAPMAPL Where T_TSSAPMAPL.MATNR = T_WMProductPalletTemp.MATNR)
                                    Else T_WMProductPalletTemp.MATNR
                                End As MAKTX,
                                --有刻字號就找刻字號，如果沒有就帶SAP批次號
	                            Case
                                    --有刻字号的，取刻字号
		                            When (Select Count(*) From T_WMProductBoxByTicket Inner Join T_TSTicketResult On T_TSTicketResult.TicketID = T_WMProductBoxByTicket.TicketID
				                            Where T_WMProductBoxByTicket.BoxNo = T_WMProductPalletTemp.BoxNo And IsNull(Brand,'') <> '') > 0 Then
										(Select String_Agg(Brand,'、') From (Select Brand From T_WMProductBoxByTicket Inner Join T_TSTicketResult On T_TSTicketResult.TicketID = T_WMProductBoxByTicket.TicketID
			                            Where T_WMProductBoxByTicket.BoxNo = T_WMProductPalletTemp.BoxNo And IsNull(Brand,'') <> '' Group By Brand) As BrandResult)
                                    Else 
									--没刻字号，但是有半成品批号的，取半成品批号 (如果工單的物料中有半成品批號並且物料中有原材料 + 半成品的就取原材料CHARG)
										(Select String_Agg(CHARG,'、') From (Select CHARG From (
                                            (Select 
                                                Case 
											        When IsNull(SEMIFINBATCH,'') = '' Then CHARG 
											        Else SEMIFINBATCH
										        End As CHARG 
										    From T_WMProductBoxByTicket Inner Join V_TSTicketResult On V_TSTicketResult.TicketID = T_WMProductBoxByTicket.TicketID
										    Where T_WMProductBoxByTicket.BoxNo = T_WMProductPalletTemp.BoxNo And IsNull(Brand,'') = '')
										) As CHARGResult Group By CHARG) As Result)
	                            End As BrandArray,
                                Qty,
                                PackageQty
                            From T_WMProductPalletTemp";

            if (!string.IsNullOrEmpty(PalletNo))
            {
                Query += " Where PalletNo = @PalletNo";

                dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo));
            }
            else
            {
                AccountID = BaseConfiguration.GetAccountID(Operator);

                if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                    throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

                Query += " Where CreateAccountID = @CreateAccountID";

                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));
            }

            dbcb.CommandText = Query;

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

            EnumerableRowCollection<DataRow> DataRows = DT.AsEnumerable().OrderByDescending(Row => (long)Row["RowNumber"]);

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
                PalletNo = DataRows.Select(Row => Row["PalletNo"].ToString().Trim()).FirstOrDefault(),
                LGORT = DataRows.Select(Row => Row["LGORT"].ToString().Trim()).FirstOrDefault(),
                MAKTX = DataRows.Select(Row => Row["MAKTX"].ToString().Trim()).FirstOrDefault(),
                BoxNoColumnName = "BoxNo",
                IsNeedSupervisorConfirm = (DataRows.Where(Row => (int)Row["PackageQty"] != (int)Row["Qty"]).Count() > 0).ToStringValue(),
                TotalQty = DataRows.Sum(Row => (int)Row["Qty"]),
                TotalQtyText = (string)GetGlobalResourceObject("GlobalRes", "Str_SubTotal"),
                Rows = DataRows.Select(Row => new
                {
                    RowNumber = Row["RowNumber"].ToString().Trim(),
                    PalletNo = Row["PalletNo"].ToString().Trim(),
                    BoxNo = Row["BoxNo"].ToString().Trim(),
                    MATNR = Row["MATNR"].ToString().Trim(),
                    MAKTX = Row["MAKTX"].ToString().Trim(),
                    BrandArray = Row["BrandArray"].ToString().Trim(),
                    Qty = Row["Qty"].ToString().Trim(),
                    PackageQty = Row["PackageQty"].ToString().Trim()
                })
            };

            ResponseSuccessData(ResponseData);
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

    /// <summary>
    /// 指定ColumnName得到是否影藏
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否影藏</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "PalletNo":
            case "BoxNo":
            case "MATNR":
            case "MAKTX":
            case "PackageQty":
            case "LGORT":
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
            case "BrandArray":
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
            case "Qty":
                return 60;
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
            case "RowNumber":
                return "#";
            case "BrandArray":
                return (string)GetLocalResourceObject("Str_ColumnName_BrandArray");
            case "Qty":
                return (string)GetLocalResourceObject("Str_ColumnName_Qty");
            default:
                return ColumnName;
        }
    }

}