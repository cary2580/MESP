using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class WM_PackingInfo : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        BT_SaveRemark.Text = (string)GetGlobalResourceObject("GlobalRes", "Str_BT_SubmitName") + (string)GetGlobalResourceObject("GlobalRes", "Str_Remark");

        BT_PrintPacking.Text = (string)GetGlobalResourceObject("GlobalRes", "Str_BT_PrintName") + (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PackingID");

        HF_IsShowResult.Value = false.ToStringValue();
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        if (!Master.IsAccountVerificationPass)
            return;

        if (IsPostBack)
            LoadSearchData();
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        LoadSearchData();
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    protected void LoadSearchData()
    {
        if (!Master.IsAccountVerificationPass)
            return;

        TB_PackingID.Text = Util.WM.ToPackingID(TB_PackingID.Text.Trim());

        HF_PackingID.Value = TB_PackingID.Text.Trim();

        string Query = @"Select *,Base_Org.dbo.GetAccountName(CreateAccountID) As CreateAccountName,Base_Org.dbo.GetAccountName(ConfirmAccountID) As ConfirmAccountName From T_WMProductPackingToOutside Where PackingID = @PackingID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingToOutside"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(HF_PackingID.Value));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

            return;
        }

        TB_VBELN.Text = DT.Rows[0]["VBELN"].ToString().Trim();

        TB_POSNR.Text = DT.Rows[0]["POSNR"].ToString().Trim();

        TB_KUNNR.Text = DT.Rows[0]["KUNNR"].ToString().Trim();

        TB_KUNNR_Name.Text = DT.Rows[0]["KUNNR_NAME"].ToString().Trim();

        TB_MATNR.Text = DT.Rows[0]["MATNR"].ToString().Trim();

        TB_MAKTX.Text = DT.Rows[0]["MAKTX"].ToString().Trim();

        TB_DeliveryDate.Text = ((DateTime)DT.Rows[0]["DeliveryDate"]).ToCurrentUICultureString();

        TB_KDMAT.Text = DT.Rows[0]["KDMAT"].ToString().Trim();

        TB_BSTKD.Text = DT.Rows[0]["BSTKD"].ToString().Trim();

        TB_KWMENG.Text = ((int)DT.Rows[0]["KWMENG"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        TB_LFIMG.Text = ((int)DT.Rows[0]["LFIMG"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        TB_AllowQty.Text = ((int)DT.Rows[0]["AllowQty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture);

        TB_SAPDeliveryNo.Text = DT.Rows[0]["SAPDeliveryNo"].ToString().Trim();

        TB_Remark.Text = DT.Rows[0]["Remark"].ToString().Trim();

        TB_CreateAccountName.Text = DT.Rows[0]["CreateAccountName"].ToString().Trim();

        TB_CreateDate.Text = ((DateTime)DT.Rows[0]["CreateDate"]).ToCurrentUICultureStringTime();

        TB_SendOutDate.Text = ((DateTime)DT.Rows[0]["SendOutDate"]).ToCurrentUICultureStringTime();

        TB_IsConfirm.Text = (bool)DT.Rows[0]["IsConfirm"] ? (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") : (string)GetGlobalResourceObject("GlobalRes", "Str_No");

        TB_IsSendOut.Text = (bool)DT.Rows[0]["IsSendOut"] ? (string)GetGlobalResourceObject("GlobalRes", "Str_Yes") : (string)GetGlobalResourceObject("GlobalRes", "Str_No");

        BT_RemovePacking.Visible = false;

        BT_SendOut.Visible = false;

        TB_ConfirmAccountName.Text = DT.Rows[0]["ConfirmAccountName"].ToString().Trim();

        TB_ConfirmDate.Text = ((DateTime)DT.Rows[0]["ConfirmDate"]).ToCurrentUICultureStringTime();

        if (!(bool)DT.Rows[0]["IsConfirm"] && !(bool)DT.Rows[0]["IsSendOut"])
        {
            BT_RemovePacking.Visible = true;

            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsMultiSelect", "<script>var IsMultiSelectValue='" + true.ToStringValue() + "';</script>");
        }

        if ((bool)DT.Rows[0]["IsConfirm"] && !(bool)DT.Rows[0]["IsSendOut"])
        {
            BT_SendOut.Visible = true;
        }

        if (!(bool)DT.Rows[0]["IsSendOut"])
        {
            Query = @"Select * From (
                    Select 
	                    T_WMProductBox.PalletNo,
	                    T_WMProductBox.BoxNo,
	                    STRING_AGG(Brand,'/') As Brand,
	                    STRING_AGG(CHARG,'/') + '(' + (Select LGOBE From T_SAPT001L Where T_SAPT001L.LGORT = T_WMProductPallet.LGORT) + ')' As CHARG,
	                    STRING_AGG(VERIDShort,'/') As VERIDShort,
	                    T_WMProductBox.Qty,
	                    IsNull(Min(T_WMProductBoxBrand.CreateDate),GetDate()) As CreateDate
	                From T_WMProductPallet 
	                    Inner Join T_WMProductBox On T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo
	                    Left Join T_WMProductBoxBrand On T_WMProductBox.BoxNo = T_WMProductBoxBrand.BoxNo
	                Where T_WMProductPallet.IsConfirm = 1 And T_WMProductBox.PackingID = @PackingID
                        And LGORT In ('FG10','FG20','FG30','RD00')
	                    Group By T_WMProductBox.PalletNo,T_WMProductBox.BoxNo,T_WMProductPallet.LGORT,T_WMProductBox.Qty,IsNull(T_WMProductBoxBrand.CreateDate,GetDate())
                    ) As Result
                    Order By CreateDate Asc";
        }
        else
        {
            Query = @"Select * From (
                    Select 
	                    T_WMProductBoxHistory.PalletNo,
	                    T_WMProductBoxHistory.BoxNo,
	                    STRING_AGG(Brand,'/') As Brand,
	                    STRING_AGG(CHARG,'/') + '(' + (Select LGOBE From T_SAPT001L Where T_SAPT001L.LGORT = T_WMProductPalletHistory.LGORT) + ')' As CHARG,
	                    STRING_AGG(VERIDShort,'/') As VERIDShort,
	                    T_WMProductBoxHistory.Qty,
	                    IsNull(Min(T_WMProductBoxBrandHistory.CreateDate),GetDate()) As CreateDate
	                From T_WMProductPalletHistory 
	                    Inner Join T_WMProductBoxHistory On T_WMProductBoxHistory.PalletNo = T_WMProductPalletHistory.PalletNo
	                    Left Join T_WMProductBoxBrandHistory On T_WMProductBoxHistory.BoxNo = T_WMProductBoxBrandHistory.BoxNo
	                Where T_WMProductPalletHistory.IsConfirm = 1 And T_WMProductBoxHistory.PackingID = @PackingID
                        And LGORT In ('FG10','FG20','FG30','RD00')
	                    Group By T_WMProductBoxHistory.PalletNo,T_WMProductBoxHistory.BoxNo,T_WMProductPalletHistory.LGORT,T_WMProductBoxHistory.Qty,IsNull(T_WMProductBoxBrandHistory.CreateDate,GetDate())
                    ) As Result
                    Order By CreateDate Asc";
        }

        dbcb = new DbCommandBuilder(Query);

        Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(HF_PackingID.Value));

        DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        IEnumerable<DataRow> Rows = DT.AsEnumerable();

        var ResponseData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                hidden = GetIsHidden(Column.ColumnName),
                sorttype = GetSortType(Column.ColumnName),
                searchoptions = GetSearchOptions(Column.ColumnName, Rows)
            }),
            FilterDateTimeColumnNames = new string[] { "CreateDate" },
            Rows = Rows.Select(Row => new
            {
                PalletNo = Row["PalletNo"].ToString().Trim(),
                BoxNo = Row["BoxNo"].ToString().Trim(),
                Brand = Row["Brand"].ToString().Trim(),
                CHARG = Row["CHARG"].ToString().Trim(),
                VERIDShort = Row["VERIDShort"].ToString().Trim(),
                Qty = ((int)Row["Qty"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureString()
            })
        };

        HF_PackingQty.Value = Rows.Sum(Row => (int)Row["Qty"]).ToString();

        Page.ClientScript.RegisterStartupScript(this.GetType(), "BoxNoColumnName", "<script>var BoxNoColumnName='BoxNo';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridRowNumValue", "<script>var JQGridRowNumValue=100000000;</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");

        HF_IsShowResult.Value = true.ToStringValue();
    }

    /// <summary>
    /// 指定ColumnName得到是否影藏
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否影藏</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            default:
                return false;
        }
    }

    /// <summary>
    /// 指定ColumnName得到對齊方式
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>對齊方式</returns>
    protected string GetAlign(string ColumnName)
    {
        switch (ColumnName)
        {
            case "CreateDate":
            case "Qty":
            case "VERIDShort":
                return "center";
            default:
                return "left";
        }
    }

    /// <summary>
    /// 指定ColumnName得到欄位寬度
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>欄位寬度</returns>
    protected int GetWidth(string ColumnName)
    {
        switch (ColumnName)
        {
            case "Qty":
            case "VERIDShort":
                return 60;
            case "CreateDate":
            case "Brand":
                return 100;
            case "BoxNo":
            case "PalletNo":
                return 80;
            case "CHARG":
                return 160;
            default:
                return 220;
        }
    }

    /// <summary>
    /// 指定ColumnName得到顯示欄位名稱
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "PalletNo":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_PalletNo");
            case "BoxNo":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BoxNo");
            case "Brand":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Brand");
            case "CHARG":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_CHARG");
            case "VERIDShort":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_VERID");
            case "Qty":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Qty");
            case "Operator":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_LastTicketOperator");
            case "CreateDate":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_FIFODay");
            default:
                return ColumnName;
        }
    }

    /// <summary>
    /// 指定欄位名取得搜尋選項
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <param name="Rows">資料列</param>
    /// <returns>搜尋選項</returns>
    protected dynamic GetSearchOptions(string ColumnName, IEnumerable<DataRow> Rows)
    {
        dynamic StatusSearchOptions = new System.Dynamic.ExpandoObject();

        switch (ColumnName)
        {
            case "Qty":
                StatusSearchOptions.sopt = new string[] { "eq", "ne", "lt", "le", "gt", "ge" };
                return StatusSearchOptions;
            case "CreateDate":
                StatusSearchOptions.sopt = new string[] { "eq", "le", "ge" };
                return StatusSearchOptions;
            case "Brand":
            case "CHARG":
                StatusSearchOptions.sopt = new string[] { "cn", "nc" };
                return StatusSearchOptions;
            default:
                return null;
        }
    }

    /// <summary>
    /// 指定欄位名取得搜尋型別
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <returns>搜尋型別</returns>
    protected string GetSortType(string ColumnName)
    {
        switch (ColumnName)
        {
            case "Qty":
                return "integer";
            case "CreateDate":
                return "date";
            default:
                return null;
        }
    }

    protected void BT_RemovePacking_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        try
        {
            List<string> BoxNoList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<string>>(HF_RemovePackingBoxNoList.Value);

            DBAction DBA = new DBAction();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

            string Query = string.Empty;

            DbCommandBuilder dbcb;

            foreach (string BoxNo in BoxNoList)
            {
                Query = "Update T_WMProductBox Set PackingID = '' Where BoxNo = @BoxNo";

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["BoxNo"].copy(BoxNo));

                DBA.AddCommandBuilder(dbcb);
            }

            Query = @"Delete From T_WMProductPackingToOutside Where PackingID = @PackingID And Not Exists(Select * From T_WMProductBox Where PackingID = @PackingID)";

            dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(HF_PackingID.Value.Trim()));

            DBA.AddCommandBuilder(dbcb);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_DeleteSuccessAlertMessage"), true, false);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, false);
        }
    }

    protected void BT_SaveRemark_Click(object sender, EventArgs e)
    {
        try
        {
            string Query = @"Update T_WMProductPackingToOutside Set Remark = @Remark Where PackingID = @PackingID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPackingToOutside"];

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(HF_PackingID.Value.Trim()));

            dbcb.appendParameter(Schema.Attributes["Remark"].copy(TB_Remark.Text.Trim()));

            CommonDB.ExecuteSingleCommand(dbcb);

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_SubmitSuccessAlertMessage"), true, false);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, false);
        }
    }

    protected void BT_SendOut_Click(object sender, EventArgs e)
    {
        try
        {
            string Query = @"Select 
                            T_WMProductBoxBrand.CHARG,
                            T_WMProductBoxBrand.CHARGLGORT,
                            Sum(T_WMProductBoxBrand.Qty) As Qty
                        From T_WMProductBox Left Join T_WMProductBoxBrand On T_WMProductBox.BoxNo = T_WMProductBoxBrand.BoxNo
                        Where T_WMProductBox.PackingID = @PackingID
                        Group By T_WMProductBoxBrand.CHARG,T_WMProductBoxBrand.CHARGLGORT";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(HF_PackingID.Value.Trim()));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            SAPBAPI.WM_BatchQty[] BatchQtyList = DT.AsEnumerable().Select(Row => new SAPBAPI.WM_BatchQty
            {
                Batch = Row["CHARG"].ToString().Trim(),
                Qty = (int)Row["Qty"],
                LGORT = Row["CHARGLGORT"].ToString().Trim()

            }).ToArray();

            SAPBAPI.WM WM = new SAPBAPI.WM();

            WM.Timeout = (60 * 1000) * 5;

            SAPBAPI.WM_Result Result = WM.Create_OUTB_DELIVERY(TB_VBELN.Text.Trim(), TB_POSNR.Text.Trim(), int.Parse(HF_PackingQty.Value), BatchQtyList);

            if (!Result.Result)
                throw new Exception(Result.Message);

            DBAction DBA = new DBAction();

            Query = @"Update T_WMProductPackingToOutside Set SAPDeliveryNo = @SAPDeliveryNo,IsSendOut = 1,SendOutDate = GetDate() Where PackingID = @PackingID";

            dbcb = new DbCommandBuilder(Query);

            Schema = DBSchema.currentDB.Tables["T_WMProductPackingToOutside"];

            dbcb.appendParameter(Schema.Attributes["PackingID"].copy(HF_PackingID.Value.Trim()));

            dbcb.appendParameter(Schema.Attributes["SAPDeliveryNo"].copy(Result.DeliveryNo));

            DBA.AddCommandBuilder(dbcb);

            DataMoveToHistory(DBA);

            DBA.Execute();

            Util.RegisterStartupScriptJqueryAlert(Page, ((Button)sender).Text + (string)GetGlobalResourceObject("GlobalRes", "Str_Finish"), true, false);
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, false);
        }
    }

    /// <summary>
    /// 指定DBA將資料移置歷史區
    /// </summary>
    /// <param name="DBA">DBA</param>
    protected void DataMoveToHistory(DBAction DBA)
    {
        string Query = @"Select PalletNo Into #TempPallet From T_WMProductBox Where PackingID = @PackingID Group By PalletNo

                        Delete T_WMProductPalletHistory Where PalletNo In(Select PalletNo From #TempPallet)

                        Insert Into T_WMProductPalletHistory Select * From T_WMProductPallet Where PalletNo In(Select PalletNo From #TempPallet)

                        Insert Into T_WMProductBoxBrandHistory Select * From T_WMProductBoxBrand Where BoxNo In(Select BoxNo From T_WMProductBox Where PackingID = @PackingID)

                        Delete T_WMProductBoxBrand Where BoxNo In(Select BoxNo From T_WMProductBox Where PackingID = @PackingID)

                        Insert Into T_WMProductBoxHistory Select * From T_WMProductBox Where PackingID = @PackingID

                        Delete T_WMProductBox Where PackingID = @PackingID

                        Update T_WMProductPalletHistory Set Qty = (Select Sum(Qty) From T_WMProductBoxHistory Where T_WMProductBoxHistory.PalletNo = T_WMProductPalletHistory.PalletNo) Where T_WMProductPalletHistory.PalletNo In(Select PalletNo From #TempPallet)

                        Update T_WMProductPallet Set Qty = IsNull((Select Sum(Qty) From T_WMProductBox Where T_WMProductBox.PalletNo = T_WMProductPallet.PalletNo),0) Where T_WMProductPallet.PalletNo In (Select PalletNo From #TempPallet)

                        Delete T_WMProductPallet Where T_WMProductPallet.PalletNo In (Select PalletNo From #TempPallet) And Qty < 1";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductBox"];

        dbcb.appendParameter(Schema.Attributes["PackingID"].copy(HF_PackingID.Value.Trim()));

        DBA.AddCommandBuilder(dbcb);
    }
}