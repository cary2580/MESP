using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class OrganizationTreeView : System.Web.UI.Page
{
    protected int ShowOrgType = 1; //1. 顯示部門 + 人員資料 2.只顯示部門
    protected int SelectMode = 2; //1:single, 2:multi, 3:multi-hier
    protected string FilterSubCompanyID = string.Empty;
    protected List<string> FilterSubCompanyIDArray = new List<string>();
    protected string DefaulFilterSubCompanyIDSymbol = "|";
    protected bool IsHideDeptSelect = false;
    protected bool IsShowSelectText = false;
    protected string DefaultSelectedSplitSymbol = "|";
    protected string DefaultSelectedByUser = string.Empty;
    protected string DefaultSelectedByDept = string.Empty;
    protected List<string> DefaultSelectedByUserArray = new List<string>();
    protected List<string> DefaultSelectedByDeptArray = new List<string>();
    protected bool IsShowSearchArea = false;
    protected bool IsShowSpecialdArea = false;
    protected bool IsShowDeptCanceledArea = false;
    protected int minExpandLevel = 2;
    protected bool IsShowLeaveAccount = false;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["ShowOrgType"] != null)
        {
            if (!int.TryParse(Request["ShowOrgType"].Trim(), out ShowOrgType))
                ShowOrgType = 1;
        }

        if (Request["SelectMode"] != null)
        {
            if (!int.TryParse(Request["SelectMode"].Trim(), out SelectMode))
                SelectMode = 1;
        }

        if (Request["IsHideDeptSelect"] != null)
            IsHideDeptSelect = Request["IsHideDeptSelect"].ToBoolean();

        if (Request["IsShowSelectText"] != null)
            IsShowSelectText = Request["IsShowSelectText"].ToBoolean();

        if (Request["DefaulFilterSubCompanyIDSymbol"] != null)
            DefaulFilterSubCompanyIDSymbol = Request["DefaulFilterSubCompanyIDSymbol"].Trim();

        if (Request["FilterSubCompanyID"] != null)
            FilterSubCompanyID = Request["FilterSubCompanyID"].Trim();

        if (Request["DefaultSelectedSplitSymbol"] != null)
            DefaultSelectedSplitSymbol = Request["DefaultSelectedSplitSymbol"].Trim();

        if (Request["DefaultSelectedByUser"] != null)
            DefaultSelectedByUser = Request["DefaultSelectedByUser"].Trim();

        if (Request["DefaultSelectedByDept"] != null)
            DefaultSelectedByDept = Request["DefaultSelectedByDept"].Trim();

        if (!string.IsNullOrEmpty(DefaultSelectedByUser) && DefaultSelectedSplitSymbol.Length == 1)
            DefaultSelectedByUserArray = DefaultSelectedByUser.Split(Convert.ToChar(DefaultSelectedSplitSymbol)).ToList();

        if (!string.IsNullOrEmpty(DefaultSelectedByDept) && DefaultSelectedSplitSymbol.Length == 1)
            DefaultSelectedByDeptArray = DefaultSelectedByDept.Split(Convert.ToChar(DefaultSelectedSplitSymbol)).ToList();

        if (!string.IsNullOrEmpty(FilterSubCompanyID) && DefaulFilterSubCompanyIDSymbol.Length == 1)
            FilterSubCompanyIDArray = FilterSubCompanyID.Split(Convert.ToChar(DefaulFilterSubCompanyIDSymbol)).ToList();

        if (Request["IsShowSearchArea"] != null)
            IsShowSearchArea = Request["IsShowSearchArea"].ToBoolean();

        if (Request["IsShowSpecialdArea"] != null)
            IsShowSpecialdArea = Request["IsShowSpecialdArea"].ToBoolean();

        if (Request["IsShowDeptCanceledArea"] != null)
            IsShowDeptCanceledArea = Request["IsShowDeptCanceledArea"].ToBoolean();

        if (Request["minExpandLevel"] != null)
        {
            if (!int.TryParse(Request["minExpandLevel"], out minExpandLevel))
                minExpandLevel = 2;
        }

        if (Request["IsShowLeaveAccount"] != null)
            IsShowLeaveAccount = Request["IsShowLeaveAccount"].ToBoolean();

        List<BasePage.Organization> OrgList = GetOrganizationData();

        Page.ClientScript.RegisterStartupScript(this.GetType(), "DefaultBackgroundColor", "<script>var DefaultBackgroundColor='" + (string)GetGlobalResourceObject("GlobalRes", "DefaultBackgroundColor") + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "OrgJson", "<script>var OrgJson=" + Newtonsoft.Json.JsonConvert.SerializeObject(OrgList) + "</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "SelectMode", "<script>var SelectMode=" + SelectMode + "</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowSelectText", "<script>var IsShowSelectText='" + IsShowSelectText.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowSearchArea", "<script>var IsShowSearchArea='" + IsShowSearchArea.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowSpecialdArea", "<script>var IsShowSpecialdArea='" + IsShowSpecialdArea.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowDeptCanceledArea", "<script>var IsShowDeptCanceledArea='" + IsShowDeptCanceledArea.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "minExpandLevel", "<script>var minExpandLevel=" + minExpandLevel + "</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "ALLBUDeptID", "<script>var ALLBUDeptID=" + Newtonsoft.Json.JsonConvert.SerializeObject(BaseConfiguration.GroupAllBUDeptIDList) + "</script>");

        HF_DefaultSelectedSplitSymbol.Value = DefaultSelectedSplitSymbol;
    }

    protected List<BasePage.Organization> GetOrganizationData()
    {
        List<BasePage.Organization> Result = null;

        if (ShowOrgType == 1)
            Result = BaseConfiguration.OrganizationDeptAndEmpList.CloneList() as List<BasePage.Organization>;
        else
            Result = BaseConfiguration.OrganizationDeptList.CloneList() as List<BasePage.Organization>;

        //如果有要過濾子公司的話
        if (FilterSubCompanyIDArray.Count > 0)
            Result[0].children.RemoveAll(Item => !FilterSubCompanyIDArray.Contains(Item.CompanyID.ToString()));

        NodeValueChange(Result);

        return Result;
    }


    protected void NodeValueChange(List<BasePage.Organization> List)
    {
        /*
            0 = 试用
            1 = 正式
            2 = 临时
            3 = 试用延期
            4 = 解聘
            5 = 離職
            6 = 退休
            7 = 无效
         */

        List<string> OnlineStatus = new List<string>() { "0", "1", "2", "3" };

        for (int i = 0; i < List.Count; i++)
        {
            if (!IsShowLeaveAccount && (!List[i].IsCompany && !string.IsNullOrEmpty(List[i].Status) && !OnlineStatus.Contains(List[i].Status)))
            {
                List.RemoveAt(i);
                i--;
                continue;
            }

            if (!RBL_Canceled.SelectedValue.ToBoolean() && List[i].IsDept && List[i].IsCanceled)
            {
                List.RemoveAt(i);
                i--;
                continue;
            }

            BasePage.Organization O = List[i];

            if (O.IsRoot || O.IsCompany)
                O.hideCheckbox = true;
            else if (IsHideDeptSelect)
                O.hideCheckbox = O.IsDept;
            else
                O.hideCheckbox = false;

            if (!O.IsCompany && !O.IsDept)
                O.select = DefaultSelectedByUserArray.Contains(O.key.ToString());
            else if (O.IsDept)
                O.select = DefaultSelectedByDeptArray.Contains(O.key.ToString());

            if (O.children != null && O.children.Count() > 0)
                NodeValueChange(O.children);
        }
    }

    protected void BT_Post_Click(object sender, EventArgs e)
    {

    }
}