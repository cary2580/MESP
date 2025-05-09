using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_WMPendingBox : System.Web.UI.Page
{
    protected override void OnPreInit(EventArgs e)
    {
        Master.IsPassPageVerificationAccount = true;

        base.OnInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// 查询事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void BT_Search_Click(object sender, EventArgs e)
    {
        string Query = @"Select
								T_WMPendingBox.BoxNo,
								TicketIDArray,
								(Select Top 1 TEXT1 From V_TSMORouting Where AUFNR = T_TSTicket.AUFNR Order By VORNR Desc) As TEXT1,
								BrandArray,
								Result.Qty,
								PackageQty,
								Base_Org.dbo.GetAccountName(T_WMPendingBox.CreateAccountID) As CreateAccountName,
								T_WMPendingBox.CreateDate
							From
							(
									Select 
									Distinct
									T_WMPendingBox.BoxNo,
									(Select Top 1 TicketID From T_WMProductBoxByTicket  Where BoxNo = T_WMPendingBox.BoxNo Order By CreateDate Desc) As TicketID,
									Stuff((Select '、' +TicketID From T_WMProductBoxByTicket As WMProductBoxByTicket Where WMProductBoxByTicket.BoxNo = T_WMProductBoxByTicket.BoxNo Order By CreateDate Desc For Xml Path ('') ),1,1,'') As TicketIDArray,
									Stuff(
									(Select 
										'、' +Brand 
										From 
										(
											Select 
											Distinct
											T_WMPendingBox.BoxNo,
											T_TSTicketResult.Brand
											From T_WMProductBoxByTicket 
											Inner Join T_WMPendingBox On T_WMPendingBox.BoxNo = T_WMProductBoxByTicket.BoxNo
											Inner Join T_TSTicketResult On T_TSTicketResult.TicketID = T_WMProductBoxByTicket.TicketID
											Where  Brand <> '') As BoxNoBrand 
									Where BoxNoBrand.BoxNo = T_WMProductBoxByTicket.BoxNo  For Xml Path ('') ),1,1,'') As BrandArray,
									T_WMPendingBox.Qty,
									(Select Top 1 PackageQty From T_WMProductBoxByTicket  Where BoxNo = T_WMPendingBox.BoxNo Order By CreateDate Desc) As PackageQty
								From T_WMPendingBox 
								Inner Join T_WMProductBoxByTicket On T_WMProductBoxByTicket.BoxNo = T_WMPendingBox.BoxNo 
								Where T_WMPendingBox.IsGoToWarehouse = 0
							) As Result 
							Inner Join T_TSTicket On Result.TicketID = T_TSTicket.TicketID
							Inner Join T_WMPendingBox On T_WMPendingBox.BoxNo = Result.BoxNo";

        string Condition = string.Empty;

        DbCommandBuilder dbcb = new DbCommandBuilder();

        ObjectSchema T_WMPendingBox = DBSchema.currentDB.Tables["T_WMPendingBox"];

        if (!string.IsNullOrEmpty(TB_BoxNo.Text.Trim()))
        {
            Condition += " And T_WMPendingBox.BoxNo = @BoxNo";

            dbcb.appendParameter(T_WMPendingBox.Attributes["BoxNo"].copy(TB_BoxNo.Text.Trim()));
        }

        if (!string.IsNullOrEmpty(TB_CreateDateStart.Text.Trim()))
        {
            DateTime CreateDateStrat = DateTime.Parse(TB_CreateDateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture);

            Condition += " And Datediff(day,@CreateDateStrat,T_WMPendingBox.CreateDate) >= 0";

            dbcb.appendParameter(T_WMPendingBox.Attributes["CreateDate"].copy(CreateDateStrat, "CreateDateStrat"));
        }


        if (!string.IsNullOrEmpty(TB_CreateDateEnd.Text.Trim()))
        {
            DateTime CreateDateEnd = DateTime.Parse(TB_CreateDateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture);

            Condition += " And Datediff(day,@CreateDateEnd,T_WMPendingBox.CreateDate) <= 0";

            dbcb.appendParameter(T_WMPendingBox.Attributes["CreateDate"].copy(CreateDateEnd, "CreateDateEnd"));
        }

        if (!string.IsNullOrEmpty(TB_CreateWorkCode.Text.Trim()))
        {
            int CreateAccountID = BaseConfiguration.GetAccountID(TB_CreateWorkCode.Text.Trim());

            Condition += " And T_WMPendingBox.CreateAccountID = @CreateAccountID";

            dbcb.appendParameter(T_WMPendingBox.Attributes["CreateAccountID"].copy(CreateAccountID));
        }

        if (!string.IsNullOrEmpty(Condition))
            Query += " Where " + Condition.Substring(4, Condition.Length - 4);

        dbcb.CommandText = Query;

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

        var ResponseData = new
        {
            colModel = Columns.Select(Column => new
            {
                name = Column.ColumnName,
                index = Column.ColumnName,
                label = GetListLabel(Column.ColumnName),
                width = GetWidth(Column.ColumnName),
                align = GetAlign(Column.ColumnName),
                classes = Column.ColumnName == "BoxNo" ? BaseConfiguration.JQGridColumnClassesName : string.Empty,
            }),
            BoxNoColumnName = (string)GetLocalResourceObject("Str_ColumnName_BoxNo"),
            BoxNoValueColumnName = "BoxNo",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                BoxNo = Row["BoxNo"].ToString().Trim(),
                TicketIDArray = Row["TicketIDArray"].ToString().Trim(),
                TEXT1 = Row["TEXT1"].ToString().Trim(),
                BrandArray = Row["BrandArray"].ToString().Trim(),
                Qty = Row["Qty"].ToString().Trim(),
                PackageQty = Row["PackageQty"].ToString().Trim(),
                CreateAccountName = Row["CreateAccountName"].ToString().Trim(),
                CreateDate = ((DateTime)Row["CreateDate"]).ToCurrentUICultureString(),
            })
        };

        if (DT.Rows.Count > 0)
            HF_IsShowResultList.Value = true.ToStringValue();
        else
        {
            HF_IsShowResultList.Value = false.ToStringValue();

            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetLocalResourceObject("Str_NoSearchData"));

            return;
        }

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "';</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + ";</script>");
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
            case "TEXT1":
            case "TicketIDArray":
            case "BrandArray":
                return "left";
            default:
                return "center";
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
            case "TicketIDArray":
                return 200;
            case "TEXT1":
                return 120;
            case "BrandArray":
                return 120;
            default:
                return 60;
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
            case "BoxNo":
                return (string)GetLocalResourceObject("Str_ColumnName_BoxNo");
            case "TicketIDArray":
                return (string)GetLocalResourceObject("Str_ColumnName_TicketIDArray");
            case "TEXT1":
                return (string)GetLocalResourceObject("Str_ColumnName_TEXT1");
            case "BrandArray":
                return (string)GetLocalResourceObject("Str_ColumnName_BrandArray");
            case "Qty":
                return (string)GetLocalResourceObject("Str_ColumnName_Qty");
            case "PackageQty":
                return (string)GetLocalResourceObject("Str_ColumnName_PackageQty");
            case "CreateAccountName":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateAccountName");
            case "CreateDate":
                return (string)GetLocalResourceObject("Str_ColumnName_CreateDate");
            default:
                return ColumnName;
        }
    }
}