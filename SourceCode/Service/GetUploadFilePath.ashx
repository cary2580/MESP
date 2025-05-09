<%@ WebHandler Language="C#" Class="GetUploadFilePath" %>

using System;
using System.Web;
using System.IO;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class GetUploadFilePath : BasePage
{
    protected string FileID = string.Empty;
    protected int SerialNo = -1;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["FileID"] != null)
                FileID = _context.Request["FileID"].ToStringFromBase64();
            if (_context.Request["SerialNo"] != null)
            {
                if (!int.TryParse(_context.Request["SerialNo"].Trim(), out SerialNo))
                    SerialNo = -1;
            }

            string Query = @"Select RelativePath,FileName From T_Files Where FileID = @FileID And SerialNo = @SerialNo";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_Files"];

            dbcb.appendParameter(Schema.Attributes["FileID"].copy(FileID));

            dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(SerialNo));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            DownloadFileInfo DFI = new DownloadFileInfo();

            if (DT.Rows.Count > 0)
            {
                string RelativePath = DT.Rows[0]["RelativePath"].ToString().Trim();

                if (!string.IsNullOrEmpty(RelativePath))
                {
                    if (!RelativePath.StartsWith(@"\"))
                        RelativePath = @"\" + RelativePath;

                    string FileFullPath = BaseConfiguration.SaveFileFolderInfo.FullName + RelativePath;

                    if (File.Exists(FileFullPath))
                    {
                        DFI.DownloadFileFullPath = FileFullPath;
                        DFI.SaveFileName = DT.Rows[0]["FileName"].ToString().Trim();
                        DFI.IsDeleteDownloadFile = false;
                    }
                }
            }

            string AccessGUID = NewGuid;

            _context.Session.Add(AccessGUID, DFI);

            ResponseSuccessData(new { Result = true, AccessGUID = AccessGUID });
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

}