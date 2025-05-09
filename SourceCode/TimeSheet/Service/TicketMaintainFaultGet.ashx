<%@ WebHandler Language="C#" Class="TicketMaintainFaultGet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class TicketMaintainFaultGet : BasePage
{
    protected string MaintainID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["MaintainID"] != null)
                MaintainID = _context.Request["MaintainID"].Trim();

            if (string.IsNullOrEmpty(MaintainID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MaintainID"));

            string Query = @"Select 
                            T_TSFaultCategory.FaultCategoryID,
                            T_TSFaultCategory.FaultCategoryName,
                            T_TSFault.FaultID,
                            T_TSFault.FaultName
                            From T_TSTicketMaintainFault 
                            Inner Join T_TSFaultCategory On T_TSTicketMaintainFault.FaultCategoryID = T_TSFaultCategory.FaultCategoryID 
                            Inner Join T_TSFault On T_TSTicketMaintainFault.FaultID = T_TSFault.FaultID
                            Where T_TSTicketMaintainFault.MaintainID = @MaintainID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintainFault"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

            bool IsCancel = GetMaintainIsCancel();

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
                }),
                FaultCategoryIDColumnName = "FaultCategoryID",
                FaultIDColumnName = "FaultID",
                IsCancel = IsCancel.ToStringValue(),
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    FaultCategoryID = Row["FaultCategoryID"].ToString().Trim(),
                    FaultCategoryName = Row["FaultCategoryName"].ToString().Trim(),
                    FaultID = Row["FaultID"].ToString().Trim(),
                    FaultName = Row["FaultName"].ToString().Trim()
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
    /// 取得維修單是否取消維修
    /// </summary>
    /// <returns></returns>
    protected bool GetMaintainIsCancel()
    {
        string Query = @"Select IsCancel From T_TSTicketMaintain Where MaintainID = @MaintainID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketMaintain"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["MaintainID"].copy(MaintainID));

        return (bool)CommonDB.ExecuteScalar(dbcb);
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
            case "FaultCategoryName":
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
            case "FaultCategoryName":
                return 120;
            default:
                return 300;
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
            case "FaultCategoryName":
                return (string)GetLocalResourceObject("Str_ColumnName_FaultCategoryName");
            case "FaultName":
                return (string)GetLocalResourceObject("Str_ColumnName_FaultName");
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
            case "FaultCategoryName":
            case "FaultName":
                return false;
            default:
                return true;
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