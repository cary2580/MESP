<%@ WebHandler Language="C#" Class="GetUploadFileList" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class GetUploadFileList : BasePage
{
    protected object ResponseData;

    protected string FileID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["FileID"] != null)
                FileID = _context.Request["FileID"].ToStringFromBase64();

            string Query = @"Select SerialNo,FileName As FileFullName,FileSize,CreateDate,Base_Org.dbo.GetAccountName(CreateAccountID) As CreateAccountName From T_Files Where FileID = @FileID Order By CreateDate,SerialNo Desc";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_Files"];

            dbcb.appendParameter(Schema.Attributes["FileID"].copy(FileID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

            List<string> ColumnList = Columns.Select(Column => Column.ColumnName).ToList();

            ResponseData = new
            {
                colNames = ColumnList,
                colModel = ColumnList.Select(ColumnName => new
                {
                    name = ColumnName,
                    index = ColumnName,
                    label = GetListLabel(ColumnName),
                    align = GetListAlign(ColumnName),
                    hidden = ColumnName == "SerialNo" ? true : false,
                    sorttype = ColumnName == "CreateDate" ? "datetime" : "string",
                    classes = ColumnName == "FileFullName" ? BaseConfiguration.JQGridColumnClassesName : ""
                }),
                sortname = "CreateDate",
                sortorder = "Desc",
                FileSerialNoColumnName = "SerialNo",
                ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
                Rows = DT.AsEnumerable().Select(Row => new
                {
                    SerialNo = (int)Row["SerialNo"],
                    FileFullName = Row["FileFullName"].ToString(),
                    FileSize = ((decimal)Row["FileSize"] / 1024).ToString("N2") + " KB",
                    CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureStringTime(),
                    CreateAccountName = Row["CreateAccountName"].ToString()
                })
            };

            ResponseSuccessData(ResponseData);
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "FileFullName":
                return (string)GetLocalResourceObject("Str_FileFullName");
            case "FileSize":
                return (string)GetLocalResourceObject("Str_FileSize");
            case "CreateDate":
                return (string)GetLocalResourceObject("Str_CreateDate");
            case "CreateAccountName":
                return (string)GetLocalResourceObject("Str_CreateAccountName");
            default:
                return ColumnName;
        }
    }

    protected string GetListAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "CreateDate":
            case "CreateAccountName":
            case "FileSize":
                return "center";
            default:
                return "left";
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