using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_TicketParameter : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        LoadData();
    }
    /// <summary>
    /// 载入打印参数资料
    /// </summary>
    private void LoadData()
    {
        string Query = @"Select 
                        '' As MATNRValue,
                        '' As PLNNRValue,
                        '' As PLNALValue,
                        PLNNR,
                        PLNAL,
                        MATNR,
                        MAKTX,
                        MaxTicketBox,
                        MaxTicketBoxQty,
                        (Select CodeName From T_Code Where CodeID = TicketPrintSize And CodeType = 'TicketPrintSize' And UICulture = @UICulture) As TicketPrintSize 
                        From T_TSSAPMAPL 
                        Order By MAKTX";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, Master.LangCookie));

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
                hidden = GetIsHidden(Column.ColumnName),
                classes = Column.ColumnName == "MATNR" ? BaseConfiguration.JQGridColumnClassesName : string.Empty,
            }),
            TicketParameterColumnNameByMATNRValue = "MATNRValue",
            TicketParameterColumnNameByPLNNRValue = "PLNNRValue",
            TicketParameterColumnNameByPLNALValue = "PLNALValue",
            ColumnClassesName = BaseConfiguration.JQGridColumnClassesName,
            Rows = DT.AsEnumerable().Select(Row => new
            {
                MATNRValue = Row["MATNR"].ToString().Trim(),
                PLNNRValue = Row["PLNNR"].ToString().Trim(),
                PLNALValue = Row["PLNAL"].ToString().Trim(),
                PLNNR = Row["PLNNR"].ToString().Trim(),
                PLNAL = Row["PLNAL"].ToString().Trim(),
                MATNR = Row["MATNR"].ToString().Trim(),
                MAKTX = Row["MAKTX"].ToString().Trim(),
                MaxTicketBox = Row["MaxTicketBox"].ToString().Trim(),
                MaxTicketBoxQty = Row["MaxTicketBoxQty"].ToString().Trim(),
                TicketPrintSize = Row["TicketPrintSize"].ToString().Trim(),
            })
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
    }

    // <summary>
    // 指定ColumnName得到是否顯示
    // </summary>
    // <param name = "ColumnName" > DB ColumnName</param>
    // <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "MATNRValue":
            case "PLNNRValue":
            case "PLNALValue":
                return true;
            default:
                return false;
        }
    }

    // <summary>
    // 指定ColumnName得到顯示欄位名稱
    // </summary>
    // <param name = "ColumnName" > DB ColumnName</param>
    // <returns>顯示欄位名稱</returns>
    protected string GetListLabel(string ColumnName)
    {
        switch (ColumnName)
        {
            case "PLNNR":
                return (string)GetLocalResourceObject("Str_ColumnName_PLNNR");
            case "PLNAL":
                return (string)GetLocalResourceObject("Str_ColumnName_PLNAL");
            case "MATNR":
                return (string)GetLocalResourceObject("Str_ColumnName_MATNR");
            case "MAKTX":
                return (string)GetLocalResourceObject("Str_ColumnName_MAKTX");
            case "MaxTicketBox":
                return (string)GetLocalResourceObject("Str_ColumnName_MaxTicketBoxName");
            case "MaxTicketBoxQty":
                return (string)GetLocalResourceObject("Str_ColumnName_MaxTicketBoxQtyName");
            case "TicketPrintSize":
                return (string)GetLocalResourceObject("Str_ColumnName_TicketPrintSizeName");
            default:
                return ColumnName;
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
            case "PLNNR":
            case "PLNAL":
            case "MaxTicketBox":
            case "MaxTicketBoxQty":
            case "TicketPrintSize":
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
            case "MAKTX":
                return 150;
            case "PLNNR":
            case "PLNAL":
                return 40;
            case "MaxTicketBox":
            case "MaxTicketBoxQty":
            case "TicketPrintSize":
                return 80;
            default:
                return 100;
        }
    }

}