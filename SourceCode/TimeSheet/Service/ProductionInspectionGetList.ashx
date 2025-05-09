<%@ WebHandler Language="C#" Class="ProductionInspectionGetList" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class ProductionInspectionGetList : BasePage
{
    protected string TicketID = string.Empty;
    protected DateTime CreateDateStart = DateTime.Parse("1900/01/01");
    protected DateTime CreateDateEnd = DateTime.Parse("1900/01/01");
    protected string InspectionResult = string.Empty;
    protected string TEXT1 = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (_context.Request["CreateDateStart"] != null)
            {
                if (!DateTime.TryParse(_context.Request["CreateDateStart"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out CreateDateStart))
                    CreateDateStart = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["CreateDateEnd"] != null)
            {
                if (!DateTime.TryParse(_context.Request["CreateDateEnd"].Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture, System.Globalization.DateTimeStyles.None, out CreateDateEnd))
                    CreateDateEnd = DateTime.Parse("1900/01/01");
            }

            if (_context.Request["InspectionResult"] != null)
                InspectionResult = _context.Request["InspectionResult"].Trim();

            if (_context.Request["TEXT1"] != null)
                TEXT1 = _context.Request["TEXT1"].Trim();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspection"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            string Query = @"Select 
                                    PIID,
                                    T_TSProductionInspection.AUFNR,
                                    TEXT1,
                                    CINFO,
                                    CHARG,
                                    SEMIFINBATCH,
                                    Brand,
                                    InspectionQty,
                                    Base_Org.dbo.GetAccountName(CreateAccountID) As CreateAccountName,
                                    CreateDate,
                                    NGQty,
                                    InspectionDate,
                                    Base_Org.dbo.GetAccountName(InspectionAccountID) As InspectionAccountName,
                                    CodeName As InspectionResult
                                    From T_TSProductionInspection Inner Join T_Code On T_Code.CodeType = 'TS_ProductionInspectionResult' And T_Code.UICulture = @UICulture And T_Code.CodeID = T_TSProductionInspection.InspectionResult
                                    Inner Join (Select AUFNR,TEXT1,CINFO,CHARG,SEMIFINBATCH From V_TSMORouting Group By AUFNR,TEXT1,CINFO,CHARG,SEMIFINBATCH) As MR On MR.AUFNR = T_TSProductionInspection.AUFNR  ";

            string Conditions = string.Empty;

            if (!string.IsNullOrEmpty(TicketID))
            {
                Conditions += " And T_TSProductionInspection.TicketID = @TicketID";

                dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
            }

            if (CreateDateStart.Year > 1911)
            {
                Conditions += " And DateDiff(SS,@CreateDate,CreateDate) > -1";

                dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(CreateDateStart));
            }

            if (CreateDateEnd.Year > 1911)
            {
                Conditions += " And DateDiff(SS,CreateDate,@CreateDateEnd) > -1";

                dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(CreateDateEnd, "CreateDateEnd"));
            }

            if (!string.IsNullOrEmpty(InspectionResult))
            {
                Conditions += " And InspectionResult = @InspectionResult";

                dbcb.appendParameter(Schema.Attributes["InspectionResult"].copy(InspectionResult));
            }

            if (!string.IsNullOrEmpty(TEXT1))
                Conditions += " And TEXT1 Like '%" + TEXT1.Trim() + "%'";

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

            dbcb.CommandText = Query;

            if (!string.IsNullOrEmpty(Conditions))
                dbcb.CommandText += " Where " + Conditions.Substring(4, Conditions.Length - 4);

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

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
                    classes = Column.ColumnName == "AUFNR" ? BaseConfiguration.JQGridColumnClassesName : "",
                }),
                ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
                PIIDColumnName = "PIID",
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    PIID = Row["PIID"].ToString().Trim(),
                    AUFNR = Row["AUFNR"].ToString().Trim(),
                    TEXT1 = Row["TEXT1"].ToString().Trim(),
                    CINFO = Row["CINFO"].ToString().Trim(),
                    CHARG = Row["CHARG"].ToString().Trim(),
                    SEMIFINBATCH = Row["SEMIFINBATCH"].ToString().Trim(),
                    Brand = Row["Brand"].ToString().Trim(),
                    InspectionQty = Row["InspectionQty"].ToString().Trim(),
                    CreateAccountName = Row["CreateAccountName"].ToString().Trim(),
                    CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureStringTime(),
                    NGQty = Row["NGQty"].ToString().Trim(),
                    InspectionDate = ((DateTime)Row["InspectionDate"]).ToCurrentUICultureStringTime(),
                    InspectionAccountName = Row["InspectionAccountName"].ToString().Trim(),
                    InspectionResult = Row["InspectionResult"].ToString().Trim()
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
    /// 指定ColumnName得到對齊方式
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>對齊方式</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "InspectionQty":
            case "CreateAccountName":
            case "InspectionAccountName":
            case "CreateDate":
            case "NGQty":
            case "InspectionResult":
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
            case "AUFNR":
            case "CHARG":
            case "SEMIFINBATCH":
                return 80;
            case "InspectionQty":
                return 50;
            case "CreateAccountName":
            case "InspectionAccountName":
            case "CreateDate":
                return 100;
            case "NGQty":
            case "InspectionResult":
                return 60;
            case "TEXT1":
                return 180;
            default:
                return 120;
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
            case "AUFNR":
                return (string)GetLocalResourceObject("Str_ColumnName_AUFNR");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            case "CINFO":
                return (string)GetLocalResourceObject("Str_ColumnName_CINFO");
            case "CHARG":
                return (string)GetLocalResourceObject("Str_ColumnName_CHARG");
            case "SEMIFINBATCH":
                return (string)GetLocalResourceObject("Str_ColumnName_SEMIFINBATCH");
            case "Brand":
                return (string)GetLocalResourceObject("Str_ColumnName_Brand");
            case "InspectionQty":
                return (string)GetLocalResourceObject("Str_ColumnName_InspectionQty");
            case "CreateAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateAccountName");
            case "CreateDate":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateDate");
            case "NGQty":
                return (string)GetLocalResourceObject("Str_ColumnName_NGQty");
            case "InspectionDate":
                return (string)GetLocalResourceObject("Str_ColumnName_InspectionDate");
            case "InspectionAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_InspectionAccountName");
            case "InspectionResult":
                return (string)GetLocalResourceObject("Str_ColumnName_InspectionResult");
            default:
                return ColumnName;
        }
    }

    /// <summary>
    /// 指定ColumnName得到是否顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "PIID":
                return true;
            default:
                return false;
        }
    }

}