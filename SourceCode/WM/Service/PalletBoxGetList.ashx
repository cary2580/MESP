<%@ WebHandler Language="C#" Class="PalletBoxGetList" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class PalletBoxGetList : BasePage
{
    protected string PalletNo = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["PalletNo"] != null)
                PalletNo = _context.Request["PalletNo"].Trim();

            if (string.IsNullOrEmpty(PalletNo))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Empty_PalletNo"));

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

            string Query = @"Select 
                                    T_WMProductBox.BoxNo,
                                    Brand,
                                    (CHARG + Case When IsNull(CHARGLGORT,'') <> '' Then  '(' + (Select LGOBE From T_SAPT001L Where T_SAPT001L.LGORT = CHARGLGORT) + ')' Else '' End) As CHARG,
                                    TicketID,
                                    IsNull(T_WMProductBoxBrand.Qty,0) As Qty,
                                    (Select MachineID From T_TSDevice Where DeviceID = IsNull((Select Top 1 DeviceID From V_TSTicketResult Where V_TSTicketResult.TicketID = T_WMProductBoxBrand.TicketID Order By CreateDate Desc),'')) As MachineID,
                                    (Select Top 1 ReportDate From V_TSTicketResult Where V_TSTicketResult.TicketID = T_WMProductBoxBrand.TicketID Order By CreateDate Desc) As ReportDate,
                                    VERIDShort,                                    
                                    T_WMProductBoxBrand.CreateDate,
                                    (Select Top 1 Base_Org.dbo.GetAccountName(Operator) + '(' + Convert(nvarchar,Coefficient) + ')' + 
                                    Case
	                                    When Exists(Select * From T_TSTicketResultSecondOperator Where T_TSTicketResultSecondOperator.TicketID = V_TSTicketResult.TicketID And T_TSTicketResultSecondOperator.ProcessID = V_TSTicketResult.ProcessID And T_TSTicketResultSecondOperator.SerialNo = V_TSTicketResult.SerialNo) Then
		                                    '、' + Stuff(((Select '、' + Base_Org.dbo.GetAccountName(SecondOperator) + '(' + Convert(nvarchar,Coefficient) + ')' From T_TSTicketResultSecondOperator Where T_TSTicketResultSecondOperator.TicketID = V_TSTicketResult.TicketID And T_TSTicketResultSecondOperator.ProcessID = V_TSTicketResult.ProcessID And T_TSTicketResultSecondOperator.SerialNo = V_TSTicketResult.SerialNo For Xml Path(''))),1,1,'')
	                                     Else ''
                                    End From V_TSTicketResult Where V_TSTicketResult.TicketID = T_WMProductBoxBrand.TicketID Order By CreateDate Desc) As Operator
                                 From T_WMProductBox Left Join T_WMProductBoxBrand On T_WMProductBox.BoxNo = T_WMProductBoxBrand.BoxNo
                                 Where PalletNo = @PalletNo";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

            IEnumerable<DataRow> Rows = DT.AsEnumerable();

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
                    classes = Column.ColumnName == "TicketID" ? BaseConfiguration.JQGridColumnClassesName : "",
                    sorttype = GetSortType(Column.ColumnName),
                    searchoptions = GetSearchOptions(Column.ColumnName, Rows)
                }),
                ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
                BoxQtyColumnName = "Qty",
                FilterDateTimeColumnNames = new string[] { "CreateDate", "ReportDate" },
                TicketIDColumnName = (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_TicketID"),
                TicketIDValueColumnName = "TicketID",
                Rows = Rows.Select(Row => new
                {
                    BoxNo = Row["BoxNo"].ToString().Trim(),
                    Brand = Row["Brand"].ToString().Trim(),
                    CHARG = Row["CHARG"].ToString().Trim(),
                    TicketID = Row["TicketID"].ToString().Trim(),
                    VERIDShort = Row["VERIDShort"].ToString().Trim(),
                    Qty = Row["Qty"].ToString().Trim(),
                    MachineID = Row["MachineID"].ToString().Trim(),
                    Operator = Row["Operator"].ToString().Trim(),
                    CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureString(),
                    ReportDate = ((DateTime)Row["ReportDate"]).ToCurrentUICultureString()
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
            case "MachineID":
            case "ReportDate":
            case "CreateDate":
            case "Qty":
            case "VERIDShort":
                return "center";
            default:
                return "left";
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
            case "MachineID":
            case "Qty":
            case "VERIDShort":
                return 60;
            case "ReportDate":
            case "CreateDate":
                return 100;
            case "BoxNo":
            case "TicketID":
                return 100;
            case "Brand":
                return 80;
            case "CHARG":
                return 140;
            default:
                return 220;
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
            case "BoxNo":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BoxNo");
            case "Brand":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Brand");
            case "CHARG":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_CHARG");
            case "TicketID":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_TicketID");
            case "VERIDShort":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_VERID");
            case "Qty":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Qty");
            case "MachineID":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_MachineID");
            case "ReportDate":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_LastTicketReportDate");
            case "Operator":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_LastTicketOperator");
            case "CreateDate":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_FIFODay");
            default:
                return ColumnName;
        }
    }

    /// <summary>
    /// 指定欄位名取得搜尋選項
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <param name="Rows">資料列</param>
    /// <returns>搜尋選項</returns>
    protected dynamic GetSearchOptions(string ColumnName, IEnumerable<DataRow> Rows)
    {
        dynamic StatusSearchOptions = new System.Dynamic.ExpandoObject();

        switch (ColumnName)
        {
            case "Qty":
                StatusSearchOptions.sopt = new string[] { "eq", "ne", "lt", "le", "gt", "ge" };
                return StatusSearchOptions;
            case "ReportDate":
            case "CreateDate":
                StatusSearchOptions.sopt = new string[] { "eq", "le", "ge" };
                return StatusSearchOptions;
            case "Brand":
            case "CHARG":
                StatusSearchOptions.sopt = new string[] { "cn", "nc" };
                return StatusSearchOptions;
            default:
                return null;
        }
    }

    /// <summary>
    /// 指定欄位名取得搜尋型別
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <returns>搜尋型別</returns>
    protected string GetSortType(string ColumnName)
    {
        switch (ColumnName)
        {
            case "Qty":
                return "integer";
            case "ReportDate":
            case "CreateDate":
                return "date";
            default:
                return null;
        }
    }

}