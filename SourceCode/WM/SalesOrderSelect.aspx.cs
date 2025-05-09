using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Sap.Data.Hana;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class WM_SalesOrderSelect : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!Master.IsAccountVerificationPass)
                return;

            if (Request["DivID"] != null)
                HF_DivID.Value = Request["DivID"].Trim();

            DataTable DT = LoadData();

            IEnumerable<DataColumn> Columns = DT.Columns.Cast<DataColumn>();

            IEnumerable<DataRow> Rows = DT.AsEnumerable();

            List<string> SalseOrderIDList = Rows.Select(Row => Row["VBELN"].ToString().Trim() + "-" + Row["POSNR"].ToString().Trim()).ToList();

            DataTable ProductBox = GetInProductBoxQty(SalseOrderIDList);

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
                }),
                KUNNRColumnName = "KUNNR",
                KUNNR_NAMEColumnName = "KUNNR_NAME",
                VBELNColumnName = "VBELN",
                POSNRColumnName = "POSNR",
                MATNRColumnName = "MATNR",
                MAKTXColumnName = "MAKTX",
                KDMATColumnName = "KDMAT",
                KWMENGColumnName = "KWMENG",
                LFIMGColumnName = "LFIMG",
                BSTKDColumnName = "BSTKD",
                CMTD_DELIV_DATEColumnName = "CMTD_DELIV_DATE",
                ALLOWQTYColumnName = "ALLOWQTY",
                Rows = Rows.Select(Row => new
                {
                    KUNNR = Row["KUNNR"].ToString().Trim(),
                    KUNNR_NAME = Row["KUNNR_NAME"].ToString().Trim(),
                    VBELN = Row["VBELN"].ToString().Trim(),
                    POSNR = Row["POSNR"].ToString().Trim(),
                    MATNR = Row["MATNR"].ToString().Trim(),
                    MAKTX = Row["MAKTX"].ToString().Trim(),
                    KDMAT = Row["KDMAT"].ToString().Trim(),
                    KWMENG = ((decimal)Row["KWMENG"]).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                    LFIMG = (((decimal)Row["LFIMG"]) + ProductBox.AsEnumerable().Where(PBRow => PBRow["SalseOrderID"].ToString().Trim() == Row["VBELN"].ToString().Trim() + "-" + Row["POSNR"].ToString().Trim()).Sum(PBRow => (int)PBRow["Qty"])).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture),
                    BSTKD = Row["BSTKD"].ToString().Trim(),
                    CMTD_DELIV_DATE = ((DateTime)Row["CMTD_DELIV_DATE"]).ToCurrentUICultureString(),
                    ALLOWQTY = (((decimal)Row["KWMENG"]) - (((decimal)Row["LFIMG"]) +
                        ProductBox.AsEnumerable().Where(PBRow => PBRow["SalseOrderID"].ToString().Trim() == Row["VBELN"].ToString().Trim() + "-" + Row["POSNR"].ToString().Trim())
                        .Sum(PBRow => (int)PBRow["Qty"]))).ToString("N0", System.Threading.Thread.CurrentThread.CurrentUICulture)
                })
            };

            Page.ClientScript.RegisterStartupScript(this.GetType(), "IsShowJQGridShowFilterToolbar", "<script>var IsShowJQGridFilterToolbar='" + true.ToStringValue() + "'</script>");

            Page.ClientScript.RegisterStartupScript(this.GetType(), "JQGridDataValue", "<script>var JQGridDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(ResponseData) + "</script>");
        }
        catch (Exception ex)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, ex.Message, true, true, "parent.$(\"#" + HF_DivID.Value + "\" ).dialog(\"close\");");
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
            case "KUNNR":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_KUNNR");
            case "KUNNR_NAME":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_KUNNR_Name");
            case "VBELN":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_VBELN");
            case "POSNR":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_POSNR");
            case "MATNR":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_MATNR");
            case "MAKTX":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_MAKTX");
            case "KDMAT":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_KDMAT");
            case "KWMENG":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_KWMENG");
            case "LFIMG":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_LFIMG");
            case "BSTKD":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BSTKD");
            case "CMTD_DELIV_DATE":
                return (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_DeliveryDate");
            default:
                return ColumnName;
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
            case "KUNNR":
            case "VBELN":
            case "KWMENG":
            case "LFIMG":
            case "CMTD_DELIV_DATE":
                return 100;
            case "POSNR":
                return 80;
            case "MATNR":
                return 120;
            default:
                return 180;
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
            case "KWMENG":
            case "LFIMG":
                return "right";
            case "KUNNR":
            case "VBELN":
            case "POSNR":
            case "CMTD_DELIV_DATE":
                return "center";
            default:
                return "left";
        }
    }

    /// <summary>
    /// 指定ColumnName得到是否顯示
    /// </summary>
    /// <param name="ColumnName">DB ColumnName</param>
    /// <returns>是否顯示</returns>
    protected bool GetIsHidden(string ColumnName)
    {
        switch (ColumnName)
        {
            case "ISUSE":
            case "ALLOWQTY":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 載入資料
    /// </summary>
    /// <returns></returns>
    private DataTable LoadData()
    {
        string Query = @"Select *,Result.KWMENG - Result.LFIMG As ALLOWQTY From (
	                         Select 
	                          VBAK.KUNNR,--客户号码（显示）
                              BUT000.NAME_ORG1 As KUNNR_NAME,--客户名称（显示）
	                          VBAP.VBELN,--销售单号（显示）
	                          VBAP.POSNR,--销售行项目（显示）
	                          VBAP.MATNR,--物料号码（显示）
	                          VBAP.ARKTX As MAKTX,--物料说明（显示）
                              VBAP.KDMAT,
                              VBAP.KWMENG,--订单数量（显示）
	                          IfNull((Select Sum(LIPS.LFIMG) From LIPS Where LIPS.MANDT = VBAP.MANDT And LIPS.VGBEL = VBAP.VBELN And LIPS.VGPOS = VBAP.POSNR),0) As LFIMG,--交货数量（显示）
                              IfNull(VBKD.BSTKD,'') As BSTKD,--客户订单号（显示）
                              TO_DATE(VBAP.CMTD_DELIV_DATE) AS CMTD_DELIV_DATE,--请求交货日期（显示）
	                          Case
		                        When AUART_ANA <> 'ZSFR' And VBAP.NETWR <= 0 Then 0
	                            Else 1
	                          End As ISUSE--当销售单类型不等于免费样品订单且价格<=0的情况
	                        From VBAP 
	                        Inner Join VBAK On VBAK.MANDT = VBAP.MANDT And VBAK.VBELN = VBAP.VBELN
	                        Inner Join BUT000 On BUT000.CLIENT = VBAK.MANDT And BUT000.PARTNER = VBAK.KUNNR
	                        Left Join VBKD On VBKD.MANDT = VBAP.MANDT And VBKD.VBELN = VBAP.VBELN And VBKD.POSNR = VBAP.POSNR
	                        Where VBAP.MANDT = ? --客户端
	                        And VBAP.WERKS = ? --工厂
	                        And VBAP.LSSTA <> 'C' --交货冻结状态不等于冻结
	                        And VBAP.LFSTA <> 'C' --交货完成状态不等于完全收货
                            And VBAP.LFGSA <> 'C' --整體交貨狀態不等于完全處理
	                        And VBAP.AUART_ANA In ('ZKB','ZOR','ZS','ZSFR') --销售单类型在这些订单类型中
                            And VBAP.BESTA = 'C' --销售单行项目的确认状态等于完全处理
                        ) As Result 
                        Where Result.ISUSE = 1 --当销售单类型不等于免费样品订单且价格=0时价格大于0
                        And Result.KWMENG - Result.LFIMG > 0 -- 訂單數量必須還要大於交貨數量
                        Order By Result.CMTD_DELIV_DATE Asc";

        HanaCommand Command = new HanaCommand(Query);

        Command.Parameters.Add("MANDT", global::System.Configuration.ConfigurationManager.AppSettings["SAPClientID"].Trim());
        Command.Parameters.Add("WERKS", global::System.Configuration.ConfigurationManager.AppSettings["SAPWERKS"].Trim());

        return SAP.GetSelectSAPData(Command);
    }

    /// <summary>
    /// 指定訂單號碼得到成品資料表所屬訂單號碼和行項目數量表
    /// </summary>
    /// <param name="SalseOrderIDList"></param>
    /// <returns>成品資料表所屬訂單號碼和行項目數量表</returns>
    private DataTable GetInProductBoxQty(List<string> SalseOrderIDList)
    {
        string Query = @"Select T_WMProductPackingToOutside.VBELN + '-' + T_WMProductPackingToOutside.POSNR As SalseOrderID,Sum(T_WMProductBox.Qty) As Qty 
                    From T_WMProductPackingToOutside Inner Join T_WMProductBox On T_WMProductBox.PackingID = T_WMProductPackingToOutside.PackingID
                    Where T_WMProductPackingToOutside.VBELN + '-' + T_WMProductPackingToOutside.POSNR In (";

        DbCommandBuilder dbcb = new DbCommandBuilder();

        for (int i = 0; i < SalseOrderIDList.Count; i++)
        {
            if (string.IsNullOrEmpty(SalseOrderIDList[i].Trim()))
                continue;

            if (i > 0)
                Query += ",";

            string Parameter = "SalseOrderID_" + i.ToString();

            Query += "@" + Parameter;

            dbcb.appendParameter(Util.GetDataAccessAttribute(Parameter, "Nvarchar", 100, SalseOrderIDList[i].Trim()));
        }

        Query += ") Group By T_WMProductPackingToOutside.VBELN + '-' + T_WMProductPackingToOutside.POSNR";

        dbcb.CommandText = Query;

        return CommonDB.ExecuteSelectQuery(dbcb);
    }
}