<%@ WebHandler Language="C#" Class="GetQRCodeInfo" %>

using System;
using System.Web;

public class GetQRCodeInfo : BasePage
{
    protected string QRCode = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["QRCode"] != null)
                QRCode = _context.Request["QRCode"].Trim();

            if (string.IsNullOrEmpty(QRCode))
                throw new CustomException("QRCode Info Empty !!");

            Uri URI;

            try
            {
                URI = new Uri(QRCode);
            }
            catch
            {
                throw new CustomException((string)GetLocalResourceObject("Str_Error_QRCodeContent"));
            }

            var QueryDictionary = HttpUtility.ParseQueryString(URI.Query);

            Util.QRCodeInfo QRCI = new Util.QRCodeInfo();

            foreach (string ParameterKey in QueryDictionary.AllKeys)
            {
                System.Reflection.PropertyInfo PI = QRCI.GetType().GetProperty(ParameterKey.ToUpper());

                if (PI != null)
                {
                    string ParameterValue = string.Empty;

                    try
                    {
                        ParameterValue = QueryDictionary[ParameterKey].Trim();
                    }
                    catch
                    {
                        throw new CustomException((string)GetLocalResourceObject("Str_Error_QRCodeContent"));

                    }

                    PI.SetValue(QRCI, ParameterValue);
                }
            }

            QRCI.LoadData();

            ResponseSuccessData(QRCI);
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