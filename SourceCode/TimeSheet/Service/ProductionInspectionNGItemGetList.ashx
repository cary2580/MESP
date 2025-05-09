<%@ WebHandler Language="C#" Class="ProductionInspectionNGItemGetList" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class ProductionInspectionNGItemGetList : BasePage
{
    protected string PIID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["PIID"] != null)
                PIID = _context.Request["PIID"].Trim();

            if (string.IsNullOrEmpty(PIID))
                throw new CustomException((string)GetLocalResourceObject("Str_Error_Empty_PIID"));

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSProductionInspectionNGItem"];

            string Query = @"Select 
                                SerialNo,
                                Base_Org.dbo.GetAccountName(InspectionAccountID) As InspectionAccountName,
                                NGQty,
                                InspectionDate,
                                HandlingMethods,
                                ReferenceNumber,
                                TraceQty,
                                DefectQty,
                                Remark
                            From T_TSProductionInspectionNGItem
                            Where PIID = @PIID Order By SerialNo";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PIID"].copy(PIID));

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
                    classes = Column.ColumnName == "InspectionAccountName" ? BaseConfiguration.JQGridColumnClassesName : "",
                }),
                ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
                SerialNoColumnName = "SerialNo",
                NGQtyColumnName = "NGQty",
                InspectionDateColumnName = "InspectionDate",
                TraceQtyColumnName = "TraceQty",
                DefectQtyColumnName = "DefectQty",
                ReferenceNumberColumnName = "ReferenceNumber",
                HandlingMethodsColumnName = "HandlingMethods",
                RemarkColumnName = "Remark",
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    SerialNo = Row["SerialNo"].ToString().Trim(),
                    NGQty = Row["NGQty"].ToString().Trim(),
                    InspectionDate = ((DateTime)Row["InspectionDate"]).ToCurrentUICultureStringTime(),
                    InspectionAccountName = Row["InspectionAccountName"].ToString().Trim(),
                    HandlingMethods = Row["HandlingMethods"].ToString().Trim(),
                    ReferenceNumber = Row["ReferenceNumber"].ToString().Trim(),
                    TraceQty = Row["TraceQty"].ToString().Trim(),
                    DefectQty = Row["DefectQty"].ToString().Trim(),
                    Remark = Row["Remark"].ToString().Trim()
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
            case "NGQty":
            case "InspectionDate":
            case "TraceQty":
            case "DefectQty":
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
            case "NGQty":
            case "TraceQty":
            case "DefectQty":
                return 80;
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
            case "NGQty":
                return (string)GetLocalResourceObject("Str_ColumnName_NGQty");
            case "InspectionDate":
                return (string)GetLocalResourceObject("Str_ColumnName_InspectionDate");
            case "InspectionAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_InspectionAccountName");
            case "HandlingMethods":
                return (string)GetLocalResourceObject("Str_ColumnName_HandlingMethods");
            case "ReferenceNumber":
                return (string)GetLocalResourceObject("Str_ColumnName_ReferenceNumber");
            case "TraceQty":
                return (string)GetLocalResourceObject("Str_ColumnName_TraceQty");
            case "DefectQty":
                return (string)GetLocalResourceObject("Str_ColumnName_DefectQty");
            case "Remark":
                return (string)GetLocalResourceObject("Str_ColumnName_Remark");
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
            case "SerialNo":
                return true;
            default:
                return false;
        }
    }

}