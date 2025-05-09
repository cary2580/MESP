using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ED_P_Calendar : System.Web.UI.Page
{
    protected override void OnPreLoad(EventArgs e)
    {
        string PIDType = string.Empty;

        if (Request["PIDType"] != null && !string.IsNullOrEmpty(Request["PIDType"].ToString()))
            PIDType = Request["PIDType"].ToStringFromBase64(true);

        try
        {
            HF_PIDType.Value = ((short)Enum.Parse(typeof(Util.ED.PIDType), PIDType)).ToString();
        }
        catch
        {
        }

        SetMpageURL();

        base.OnPreLoad(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        WUC_Calendar.CalendarDataURL = ResolveClientUrl(@"~/ED/Service/ParametersCalendar.ashx");

        dynamic CalendarParameters = new System.Dynamic.ExpandoObject();

        CalendarParameters.PIDType = HF_PIDType.Value;

        WUC_Calendar.CalendarDataParameters = Newtonsoft.Json.JsonConvert.SerializeObject(CalendarParameters);
    }

    /// <summary>
    /// 設定 M_Page
    /// </summary>
    protected void SetMpageURL()
    {
        switch (HF_PIDType.Value)
        {
            case "1":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_PreDegreasing.aspx");
                HF_MpageWidth.Value = "1200";
                HF_MpageHeight.Value = "810";
                return;
            case "2":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_UCDegreasing1.aspx");
                HF_MpageWidth.Value = "1200";
                HF_MpageHeight.Value = "730";
                return;
            case "3":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_UCDegreasing2.aspx");
                HF_MpageWidth.Value = "1200";
                HF_MpageHeight.Value = "730";
                return;
            case "4":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_HCL1.aspx");
                HF_MpageWidth.Value = "810";
                HF_MpageHeight.Value = "730";
                return;
            case "5":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_HCL2.aspx");
                HF_MpageWidth.Value = "810";
                HF_MpageHeight.Value = "730";
                return;
            case "6":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_Neutralizing.aspx");
                HF_MpageWidth.Value = "1010";
                HF_MpageHeight.Value = "730";
                return;
            case "7":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_SurfaceActivation.aspx");
                HF_MpageWidth.Value = "810";
                HF_MpageHeight.Value = "730";
                return;
            case "8":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_Phosphating.aspx");
                HF_MpageWidth.Value = "1200";
                HF_MpageHeight.Value = "830";
                return;
            case "9":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_ECoating.aspx");
                HF_MpageWidth.Value = "1150";
                HF_MpageHeight.Value = "820";
                return;
            case "10":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_UF1.aspx");
                HF_MpageWidth.Value = "810";
                HF_MpageHeight.Value = "650";
                return;
            case "11":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_UF2.aspx");
                HF_MpageWidth.Value = "810";
                HF_MpageHeight.Value = "650";
                return;
            case "12":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_Anolyte.aspx");
                HF_MpageWidth.Value = "810";
                HF_MpageHeight.Value = "650";
                return;
            case "13":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_RecycleTank.aspx");
                HF_MpageWidth.Value = "810";
                HF_MpageHeight.Value = "720";
                return;
            case "14":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_WaterRinsing.aspx");
                HF_MpageWidth.Value = "810";
                HF_MpageHeight.Value = "720";
                return;
            case "15":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_CoatingTestForPD.aspx");
                HF_MpageWidth.Value = "810";
                HF_MpageHeight.Value = "650";
                return;
            case "16":
                HF_MpageURL.Value = ResolveClientUrl(@"~/ED/P_Curing.aspx");
                HF_MpageWidth.Value = "810";
                HF_MpageHeight.Value = "700";
                return;
            default:
                return;
        }
    }
}