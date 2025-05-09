using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ED_WUC_WUC_Calendar : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected override void OnPreRender(EventArgs e)
    {
        HF_CalendarDataURL.Value = CalendarDataURL;

        HF_CalendarDataParameters.Value = CalendarDataParameters;

        HF_IsCanDrop.Value = IsCanCanDrop.ToStringValue();

        base.OnPreRender(e);
    }

    /// <summary>
    ///  取得或設定是否可以觸發拖拉事件
    /// </summary>
    public bool IsCanCanDrop
    { get; set; }

    /// <summary>
    /// 取得或設定載入日歷的URL
    /// </summary>
    public string CalendarDataURL
    {
        get; set;
    }

    /// <summary>
    /// 取得或設定載入日歷的傳輸參數
    /// </summary>
    public string CalendarDataParameters
    {
        get; set;
    }
}