using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class WUC_WUC_File : System.Web.UI.UserControl
{
    protected override void OnPreRender(EventArgs e)
    {
        HF_JQGridElementID.Value = Guid.NewGuid().ToString().Replace("-", "");
        HF_JQGridContainerTableName.Value = Guid.NewGuid().ToString().Replace("-", "");
        HF_JQGridContainerPagerName.Value = Guid.NewGuid().ToString().Replace("-", "");
    }

    protected void Page_Load(object sender, EventArgs e)
    {

    }

    public string FileID
    {
        get { return HF_FileID.Value; }
        set { HF_FileID.Value = value; }
    }

    public string FileCategoryID
    {
        get { return HF_FileCategoryID.Value; }
        set { HF_FileCategoryID.Value = value; }
    }

    public string GetJQGridElementID
    {
        get { return HF_JQGridElementID.Value; }
    }

    public string GetJQGridContainerTableName
    {
        get { return HF_JQGridContainerTableName.Value; }
    }

    public string GetJQGridContainerPagerName
    {
        get { return HF_JQGridContainerPagerName.Value; }

    }
}