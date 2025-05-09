<%@ WebHandler Language="C#" Class="GetMediaFile" %>

using System;
using System.Web;
using System.IO;

public class GetMediaFile : BasePage
{
    protected string TokenID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["TokenID"] != null)
                TokenID = _context.Request["TokenID"];

            if (!string.IsNullOrEmpty(TokenID) && _context.Session[TokenID] != null)
            {
                dynamic SessionToken = Util.ConvertToDynamic(_context.Session[TokenID]);

                FileInfo FI = new FileInfo(SessionToken.MediaFilePath);

                _context.Response.Clear();

                _context.Response.ContentType = SessionToken.ContentType;

                _context.Response.Headers.Add("Last-Modified", FI.LastWriteTime.ToUniversalTime().ToString("R"));

                _context.Response.Headers.Add("Accept-Ranges", "bytes");

                _context.Response.Headers.Add("Content-Length", FI.Length.ToString());

                _context.Response.BinaryWrite(File.ReadAllBytes(FI.FullName));

                _context.Response.Flush();

                _context.Response.Close();

                _context.Session.Remove(TokenID);
            }
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