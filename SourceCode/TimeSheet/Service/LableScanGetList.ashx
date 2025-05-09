<%@ WebHandler Language="C#" Class="LableScanGetList" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class LableScanGetList : BasePage
{
    protected string TicketID = string.Empty;
    protected string BoxNo = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TicketID"] != null)
                TicketID = _context.Request["TicketID"].Trim();

            if (_context.Request["BoxNo"] != null)
                BoxNo = _context.Request["BoxNo"].Trim();

            if (!string.IsNullOrEmpty(BoxNo))
                CheckBoxNo();

            ResponseSuccessData(new
            {
                ItemData = LoadLableScanData(),
                ItemScrapData = LoadScarpLableScanData(),
                ItemStandByData = LoadStandByLableScanData()
            });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 载入扫描正常条码信息
    /// </summary>
    protected object LoadLableScanData()
    {
        string Query = string.Empty;

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

        if (string.IsNullOrEmpty(BoxNo))
        {
            Query = @"Select 
                            Row_Number() Over (Order By ScanTime Asc) As RowID,
                            ScanKey,
	                        TicketID,
	                        ScanTime,
	                        LableID
                        From T_TSLableScan 
                        Where TicketID = @TicketID And StatusID = @StatusID And IsNull(BoxNo,'') = ''
                        Order By ScanTime Desc";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        }
        else
        {
            Query = @"Select 
                            Row_Number() Over (Order By ScanTime Asc) As RowID,
                            ScanKey,
	                        TicketID,
	                        ScanTime,
	                        LableID
                        From T_TSLableScan 
                        Where BoxNo = @BoxNo And StatusID = @StatusID
                        Order By ScanTime Desc";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));
        }

        dbcb.appendParameter(Schema.Attributes["StatusID"].copy(((short)Util.TS.LableScanStatus.NormalLable).ToString()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        return new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName),
                classes = Column.ColumnName == "LableID" ? BaseConfiguration.JQGridColumnClassesName : ""
            }),
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            ScanKeyColumnName = "ScanKey",
            LableIDColumnName = "LableID",
            Rows = DT.AsEnumerable().Select(Row => new
            {
                RowID = Row["RowID"].ToString().Trim(),
                ScanKey = Row["ScanKey"].ToString().Trim(),
                TicketID = Row["TicketID"].ToString().Trim(),
                ScanTime = Row["ScanTime"].ToString().Trim(),
                LableID = Row["LableID"].ToString().Trim(),
            })
        };
    }


    /// <summary>
    /// 载入扫描报废条码信息
    /// </summary>
    protected object LoadScarpLableScanData()
    {
        string Query = string.Empty;

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

        if (string.IsNullOrEmpty(BoxNo))
        {
            Query = @"Select 
                            Row_Number() Over (Order By ScanTime Desc) As RowID,
	                        TicketID,
	                        ScanTime,
	                        LableID As ScrapLableID
                        From T_TSLableScan 
                        Where TicketID = @TicketID And StatusID = @StatusID And IsNull(BoxNo,'') = ''
                        Order By ScanTime Desc";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        }
        else
        {
            Query = @"Select 
                            Row_Number() Over (Order By ScanTime Desc) As RowID,
	                        TicketID,
	                        ScanTime,
	                        LableID As ScrapLableID
                        From T_TSLableScan 
                        Where BoxNo = @BoxNo And StatusID = @StatusID
                        Order By ScanTime Desc";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));
        }

        dbcb.appendParameter(Schema.Attributes["StatusID"].copy(((short)Util.TS.LableScanStatus.CancelLable).ToString()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        return new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName)
            }),
            Rows = DT.AsEnumerable().Select(Row => new
            {
                RowID = Row["RowID"].ToString().Trim(),
                TicketID = Row["TicketID"].ToString().Trim(),
                ScanTime = Row["ScanTime"].ToString().Trim(),
                ScrapLableID = Row["ScrapLableID"].ToString().Trim(),
            })
        };
    }

    /// <summary>
    /// 载入扫描备用条码信息
    /// </summary>
    protected object LoadStandByLableScanData()
    {
        string Query = string.Empty;

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

        if (string.IsNullOrEmpty(BoxNo))
        {
            Query = @"Select 
                            Row_Number() Over (Order By ScanTime Desc) As RowID,
	                        TicketID,
	                        ScanTime,
	                        LableID As StandByLableID
                        From T_TSLableScan 
                        Where TicketID = @TicketID And StatusID = @StatusID And IsNull(BoxNo,'') = ''
                        Order By ScanTime Desc";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID));
        }
        else
        {
            Query = @"Select 
                            Row_Number() Over (Order By ScanTime Desc) As RowID,
	                        TicketID,
	                        ScanTime,
	                        LableID As StandByLableID
                        From T_TSLableScan 
                        Where BoxNo = @BoxNo And StatusID = @StatusID 
                        Order By ScanTime Desc";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));
        }

        dbcb.appendParameter(Schema.Attributes["StatusID"].copy(((short)Util.TS.LableScanStatus.StandbyLable).ToString()));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        return new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName)
            }),
            Rows = DT.AsEnumerable().Select(Row => new
            {
                RowID = Row["RowID"].ToString().Trim(),
                TicketID = Row["TicketID"].ToString().Trim(),
                ScanTime = Row["ScanTime"].ToString().Trim(),
                StandByLableID = Row["StandByLableID"].ToString().Trim(),
            })
        };
    }

    /// <summary>
    /// 如果传箱号，检查箱号是否存在，防止现场打错
    /// </summary>
    protected void CheckBoxNo()
    {
        string Query = "Select BoxNo From T_TSLableScan Where BoxNo = @BoxNo";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

        dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
            throw new CustomException((string)GetLocalResourceObject("Str_Error_NotExistBoxNo"));
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
            case "TicketID":
            case "ScanTime":
            case "RowID":
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
            case "TicketID":
            case "ScanTime":
                return 80;
            case "RowID":
                return 30;
            default:
                return 100;
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
                return (string)GetLocalResourceObject("Str_ColumnName_TicketID");
            case "ScanTime":
                return (string)GetLocalResourceObject("Str_ColumnName_ScanTime");
            case "LableID":
                return (string)GetLocalResourceObject("Str_ColumnName_LableID");
            case "ScrapLableID":
                return (string)GetLocalResourceObject("Str_ColumnName_ScrapLableID");
            case "StandByLableID":
                return (string)GetLocalResourceObject("Str_ColumnName_StandByLableID");
            case "RowID":
                return (string)GetLocalResourceObject("Str_ColumnName_RowID");
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
            case "ScanKey":
                return true;
            default:
                return false;
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