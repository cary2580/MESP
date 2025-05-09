using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class ED_WUC_WUC_DataCreateInfo : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// 指定資料列將資料設定至UIControl
    /// </summary>
    /// <param name="Row">資料列</param>
    public void SetControlData(DataRow Row)
    {
        TB_CreateAccountName.Text = Row["CreateAccountName"].ToString().Trim();
        TB_CreateDate.Text = ((DateTime)Row["CreateDate"]).ToCurrentUICultureStringTime();
        TB_ModifyAccountName.Text = Row["ModifyAccountName"].ToString().Trim();
        TB_ModifyDate.Text = ((DateTime)Row["ModifyDate"]).ToCurrentUICultureStringTime();
    }
}