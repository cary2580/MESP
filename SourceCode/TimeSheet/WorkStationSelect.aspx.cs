using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_WorkStationSelect : System.Web.UI.Page
{
    protected override void OnPreInit(EventArgs e)
    {
        if (Request["ViewInside"] != null && !string.IsNullOrEmpty(Request["ViewInside"].Trim()))
        {
            try
            {
                if (Request["ViewInside"].ToStringFromBase64(true).ToBoolean())
                    this.MasterPageFile = "~/MasterPage.master";
                else
                    (Master as TimeSheet_TimeSheet).IsPassPageVerificationAccount = true;
            }
            catch (Exception ex)
            {

            }
        }
        else
        {
            this.MasterPageFile = "~/NoFrame.master";

            (Master as BaseMasterPage).IsPassPageVerificationAccount = true;
        }

        base.OnInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            LoadData();
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadData()
    {
        string Query = @"Select * From T_TSArea Order By SortID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_Area.DataValueField = "AreaID";

        DDL_Area.DataTextField = "AreaName";

        DDL_Area.DataSource = DT;

        DDL_Area.DataBind();

        DDL_Area.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));

        Query = @"Select ResponsibleID,ResponsibleName From T_TSMaintainResponsible Order By SortID";

        dbcb = new DbCommandBuilder(Query);

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        DDL_Responsible.DataValueField = "ResponsibleID";

        DDL_Responsible.DataTextField = "ResponsibleName";

        DDL_Responsible.DataSource = DT;

        DDL_Responsible.DataBind();

        DDL_Responsible.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }
}