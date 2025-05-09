<%@ WebHandler Language="C#" Class="DeleteUploadFile" %>

using System;
using System.Web;
using System.Linq;
using System.Collections.Generic;
using System.IO;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class DeleteUploadFile : BasePage
{
    protected string FileID = string.Empty;

    protected List<string> SerialNoS = new List<string>();

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context);

            if (_context.Request["FileID"] != null)
                FileID = _context.Request["FileID"].Trim().ToStringFromBase64();

            if (_context.Request["SerialNoS"] != null)
                SerialNoS = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(context.Request["SerialNoS"].Trim());

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_Files"];

            DbCommandBuilder dbcb = new DbCommandBuilder();

            List<FileInfo> DeleteFiles = new List<FileInfo>();

            foreach (string SerialNo in SerialNoS)
            {
                string Query = @"Select RelativePath From T_Files Where FileID = @FileID And SerialNo = @SerialNo";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["FileID"].copy(FileID));

                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(SerialNo));

                string RelativePath = CommonDB.ExecuteScalar(dbcb).ToString().Trim();

                if (string.IsNullOrEmpty(RelativePath))
                    continue;

                if (!RelativePath.StartsWith(@"\"))
                    RelativePath = @"\" + RelativePath;

                DeleteFiles.Add(new FileInfo(BaseConfiguration.SaveFileFolderInfo.FullName + RelativePath));

                dbcb = new DbCommandBuilder("Delete T_Files Where FileID = @FileID And SerialNo = @SerialNo");

                dbcb.appendParameter(Schema.Attributes["FileID"].copy(FileID));

                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(SerialNo));

                DBA.AddCommandBuilder(dbcb);
            }

            if (DBA.Count > 0)
                DBA.Execute();

            //刪除實體檔案
            foreach (FileInfo FI in DeleteFiles)
            {
                if (FI.Exists)
                    FI.Delete();

                if (FI.Directory.Exists && FI.Directory.GetFiles().Length < 1)
                    FI.Directory.Delete();
            }

            DBA = new DBAction();

            /* 下列動作是為了重新編排排序序號 */
            dbcb = new DbCommandBuilder("Select * From T_Files With (Tablockx) Where FileID = @FileID Order By CreateDate Asc");

            dbcb.appendParameter(Schema.Attributes["FileID"].copy(FileID));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            var DI = DT.ToDictionary();

            for (int i = 0; i < DI.Count; i++)
            {
                dbcb = new DbCommandBuilder("Update T_Files Set SerialNo = @SerialNo Where FileID = @FileID And SerialNo = @OriginalSerialNo");

                dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(i + 1));

                dbcb.appendParameter(Schema.Attributes["FileID"].copy(FileID));

                dbcb.appendParameter(Util.GetDataAccessAttribute("OriginalSerialNo", "int", 0, DI[i]["SerialNo"]));

                DBA.AddCommandBuilder(dbcb);
            }

            if (DBA.Count > 0)
                DBA.Execute();
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