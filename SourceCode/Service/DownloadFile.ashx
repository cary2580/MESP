<%@ WebHandler Language="C#" Class="DownloadFile" %>

using System;
using System.Web;
using System.IO;

public class DownloadFile : BasePage
{
    protected string FileName = string.Empty;
    protected byte[] FileBytes;
    protected string AccessGUID = string.Empty;
    protected string DownloadFileFullPath = string.Empty;
    protected string DownloaSaveFileName = string.Empty;
    protected bool IsDeleteDownloadFile = false;
    protected string DownloadFileContentType = "application/octet-stream";
    protected bool IsAddHeader = true;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["DownloadFileFullPath"] != null)
                DownloadFileFullPath = _context.Request["DownloadFileFullPath"].Trim().ToStringFromBase64(true);

            if (_context.Request["DownloaSaveFileName"] != null)
                DownloaSaveFileName = _context.Request["DownloaSaveFileName"].Trim().ToStringFromBase64(true);

            if (_context.Request["IsDeleteDownloadFile"] != null)
                IsDeleteDownloadFile = _context.Request["IsDeleteDownloadFile"].Trim().ToStringFromBase64(true).ToBoolean();

            if (_context.Request["AccessGUID"] != null)
                AccessGUID = _context.Request["AccessGUID"].Trim();

            if (string.IsNullOrEmpty(AccessGUID) && _context.Request.RequestContext.RouteData.Values["AccessGUID"] != null)
                AccessGUID = _context.Request.RequestContext.RouteData.Values["AccessGUID"].ToString().Trim();

            if (!string.IsNullOrEmpty(AccessGUID))
            {
                DownloadFileInfo DFI = null;

                if (_context.Session[AccessGUID] != null)
                {
                    DFI = _context.Session[AccessGUID] as DownloadFileInfo;

                    if (!DFI.IsNoClearSession)
                        Session.Remove(AccessGUID);
                }

                if (DFI == null)
                    throw new CustomException((string)GetLocalResourceObject("~/Service/DownloadFile.ashx", "Str_NoFilePath"));
                else if (string.IsNullOrEmpty(DFI.DownloadFileFullPath))
                    throw new CustomException((string)GetLocalResourceObject("~/Service/DownloadFile.ashx", "Str_NoFilePath"));

                try
                {
                    FileBytes = File.ReadAllBytes(DFI.DownloadFileFullPath);

                    if (!string.IsNullOrEmpty(DFI.SaveFileName))
                        FileName = DFI.SaveFileName;
                    else
                        FileName = Path.GetFileName(DFI.DownloadFileFullPath);
                }
                catch
                {
                    throw new CustomException((string)GetLocalResourceObject("~/Service/DownloadFile.ashx", "Str_PathNoExist"));
                }

                if (DFI.IsDeleteDownloadFile)
                {
                    File.Delete(DFI.DownloadFileFullPath);

                    if (Directory.GetFiles(Path.GetDirectoryName(DFI.DownloadFileFullPath)).Length < 1)
                        Directory.Delete(Path.GetDirectoryName(DFI.DownloadFileFullPath), true);
                }

                if (!string.IsNullOrEmpty(DFI.ContentType))
                    DownloadFileContentType = DFI.ContentType;

                IsAddHeader = DFI.IsAddHeader;
            }
            else if (!string.IsNullOrEmpty(DownloadFileFullPath))
            {
                try
                {
                    FileBytes = File.ReadAllBytes(DownloadFileFullPath);

                    if (!string.IsNullOrEmpty(DownloaSaveFileName))
                        FileName = DownloaSaveFileName;
                    else
                        FileName = Path.GetFileName(DownloadFileFullPath);

                    if (IsDeleteDownloadFile)
                    {
                        File.Delete(DownloadFileFullPath);

                        if (Directory.GetFiles(Path.GetDirectoryName(DownloadFileFullPath)).Length < 1)
                            Directory.Delete(Path.GetDirectoryName(DownloadFileFullPath), true);
                    }
                }
                catch
                {
                    throw new CustomException((string)GetLocalResourceObject("~/Service/DownloadFile.ashx", "Str_PathNoExist"));
                }
            }
            else
                throw new CustomException((string)GetLocalResourceObject("~/Service/DownloadFile.ashx", "Str_NoFilePath"));
        }
        catch (Exception ex)
        {
            FileBytes = System.Text.Encoding.UTF8.GetBytes(ex.Message);

            FileName = "Error.txt";
        }
        finally
        {
            ResponseStream(new MemoryStream(FileBytes), FileName, DownloadFileContentType, IsAddHeader);
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