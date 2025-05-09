using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class UploadFile : System.Web.UI.Page
{
    protected string DivID = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (Request["DivID"] != null)
            DivID = Request["DivID"].Trim();

        if (!IsPostBack)
        {
            if (Request["FileID"] != null && !string.IsNullOrEmpty(Request["FileID"].ToString()))
                HF_FileID.Value = Request["FileID"].ToString();
            if (Request["FileCategoryID"] != null && !string.IsNullOrEmpty(Request["FileCategoryID"].ToString()))
                HF_FileCategoryID.Value = Request["FileCategoryID"].ToString();
        }

        if (string.IsNullOrEmpty(HF_FileID.Value) || string.IsNullOrEmpty(HF_FileCategoryID.Value))
        {
            Util.RegisterStartupScriptJqueryAlert(this, (string)GetGlobalResourceObject("GlobalRes", "Str_AjaxAlertMessageDefaultMessage"), true, true, "parent.$(\"#" + DivID + "\" ).dialog(\"close\");");

            return;
        }
    }
    protected void BT_UpLoad_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!FU_File.HasFile)
            return;

        string FileID = HF_FileID.Value.ToStringFromBase64();

        string FileCategoryID = HF_FileCategoryID.Value.ToStringFromBase64();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Files"];

        DBAction DBA = new DBAction();

        List<DirectoryInfo> SaveForderList = new List<DirectoryInfo>();

        foreach (HttpPostedFile UploadedFile in FU_File.PostedFiles)
        {
            DirectoryInfo di = BaseConfiguration.SaveFileFolderInfo.CreateSubdirectory(FileCategoryID + @"\" + DateTime.Now.ToString("yyyy") + @"\" + FileID);

            try
            {
                string FileSavePath = Util.GetSaveFileName(di, UploadedFile.FileName);

                DbCommandBuilder dbcb = new DbCommandBuilder("Insert Into T_Files (FileID,SerialNo,FileSize,FileName,FileExtension,RelativePath,CreateDeptID,CreateAccountID) Values (@FileID,(Select IsNull(Max(SerialNo) + 1,1) From T_Files Where FileID = @FileID),@FileSize,@FileName,@FileExtension,@RelativePath,@CreateDeptID,@CreateAccountID)");

                dbcb.appendParameter(Schema.Attributes["FileID"].copy(FileID));

                string FileName = UploadedFile.FileName.Trim();

                // 如果上傳的檔名中如果有逗號會無法下載
                dbcb.appendParameter(Schema.Attributes["FileName"].copy(Path.GetFileName(UploadedFile.FileName.Replace(",", string.Empty))));
                dbcb.appendParameter(Schema.Attributes["FileExtension"].copy(Path.GetExtension(UploadedFile.FileName)));
                dbcb.appendParameter(Schema.Attributes["FileSize"].copy(UploadedFile.ContentLength));
                dbcb.appendParameter(Schema.Attributes["RelativePath"].copy(FileSavePath.Replace(BaseConfiguration.SaveFileFolderInfo.FullName, string.Empty)));
                dbcb.appendParameter(Schema.Attributes["CreateDeptID"].copy(BaseConfiguration.OnlineAccount[Master.AccountID].DeptID));
                dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(Master.AccountID));

                DBA.AddCommandBuilder(dbcb);

                UploadedFile.SaveAs(FileSavePath);

                SaveForderList.Add(di);
            }
            catch
            {
                di.Delete(true);
            }
        }

        if (!DBA.Execute())
        {
            foreach (DirectoryInfo di in SaveForderList)
            {
                if (di.Exists)
                    di.Delete(true);
            }
        }

        string CloseWindow = "<script>$(function(){parent.$(\"#" + DivID + "\" ).dialog(\"close\");});</script>";

        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "CloseWindow", CloseWindow);

    }
}