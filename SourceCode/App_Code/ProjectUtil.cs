using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Data;

/// <summary>
/// ProjectUtil 的摘要描述
/// </summary>
public static partial class Util
{
    /// <summary>
    /// 日歷事件的摘要描述
    /// </summary>
    public class CalendarEvent
    {
        /// <summary>
        /// 唯一碼
        /// </summary>
        public string id = string.Empty;
        /// <summary>
        /// 事件標題
        /// </summary>
        public string title = string.Empty;
        /// <summary>
        /// 開始時間
        /// </summary>
        public string start = string.Empty;
        /// <summary>
        /// 截止時間
        /// </summary>
        public string end = string.Empty;
        /// <summary>
        ///  是否為整天
        /// </summary>
        public bool allDay = true;
        /// <summary>
        /// 是否可以編輯
        /// </summary>
        public bool editable = true;
        /// <summary>
        /// 事件背景顏色
        /// </summary>
        public string color = string.Empty;
        /// <summary>
        /// 文字顏色
        /// </summary>
        public string textColor = string.Empty;
    }

    /// <summary>
    /// 圖表所需的摘要描述(highcharts)
    /// </summary>
    public class ChartSeriesOption
    {
        public string type { get; set; }
        public string name { get; set; }
        public string color { get; set; }
        public List<object> data { get; set; }

        private bool _visible = true;

        public bool visible { get { return _visible; } set { _visible = value; } }
    }

    /// <summary>
    /// QRCode摘要描述
    /// </summary>
    public class QRCodeInfo
    {
        /// <summary>
        /// 工單號碼
        /// </summary>
        public string A1 { get; set; }
        /// <summary>
        /// 工單流程卡號
        /// </summary>
        public string A2 { get; set; }
        /// <summary>
        /// 工單流程卡框號
        /// </summary>
        public string A3 { get; set; }
        /// <summary>
        /// 設備編號
        /// </summary>
        public string A4 { get; set; }
        /// <summary>
        /// 機台編號
        /// </summary>
        public string A5 { get; set; }
        /// <summary>
        /// 機台名稱
        /// </summary>
        public string A6 { get; set; }
        /// <summary>
        /// 棧板號
        /// </summary>
        public string A7 { get; set; }

        /// <summary>
        /// 裝箱號(PackingID)
        /// </summary>
        public string A8 { get; set; }

        /// <summary>
        /// 指定QRCode內容得到QRCode圖檔資料流
        /// </summary>
        /// <param name="QRCodeContent">QRCode內容</param>
        /// <param name="BarcodeModule">條碼模組</param>
        /// <param name="ImageSize">影像大小</param>
        /// <returns>QRCode圖檔資料流</returns>
        public static System.IO.Stream QRCodeGenerator(string QRCodeContent, float BarcodeModule, System.Drawing.Size ImageSize)
        {
            Spire.Barcode.BarcodeSettings BS = new Spire.Barcode.BarcodeSettings();

            BS.Type = Spire.Barcode.BarCodeType.QRCode;

            BS.Data = QRCodeContent;

            BS.ShowText = false;
            BS.QRCodeDataMode = Spire.Barcode.QRCodeDataMode.Auto;
            BS.X = BarcodeModule;
            BS.Unit = System.Drawing.GraphicsUnit.Millimeter;
            BS.QRCodeECL = Spire.Barcode.QRCodeECL.H;

            Spire.Barcode.BarCodeGenerator generator = new Spire.Barcode.BarCodeGenerator(BS);

            System.Drawing.Image image;

            if (ImageSize == null)
                image = generator.GenerateImage();
            else
                image = generator.GenerateImage(ImageSize);

            var Result = new System.IO.MemoryStream();
            image.Save(Result, System.Drawing.Imaging.ImageFormat.Jpeg);
            Result.Position = 0;
            image.Dispose();

            return Result;
        }

        /// <summary>
        /// 指定QRCode內容得到BarCode圖檔資料流
        /// </summary>
        /// <param name="CodeContent">條碼內容</param>
        /// <param name="BarcodeModule">條碼模組</param>
        /// <param name="BarHeight">條碼高度</param>
        /// <param name="BarCodeType">條碼編碼模式</param>
        /// <param name="TextFont">顯示文字樣式(不顯示就不要傳入值)</param>
        /// <returns>BarCode圖檔資料流</returns>
        public static System.IO.Stream BarCodeGenerator(string CodeContent, float BarcodeModule, float BarHeight, Spire.Barcode.BarCodeType BarCodeType, string TopText = "", System.Drawing.Font TextFont = null)
        {
            Spire.Barcode.BarcodeSettings BS = new Spire.Barcode.BarcodeSettings();

            BS.BarHeight = BarHeight;
            BS.Type = BarCodeType;
            BS.Data = CodeContent;

            if (TextFont != null)
            {
                BS.ShowText = true;
                BS.ShowTextOnBottom = true;
                BS.TextFont = TextFont;
                BS.TextRenderingHint = System.Drawing.Text.TextRenderingHint.ClearTypeGridFit;
                BS.ShowTopText = true;

                if (!string.IsNullOrEmpty(TopText))
                {
                    BS.TopText = TopText;
                    BS.TopTextAligment = System.Drawing.StringAlignment.Center;
                    BS.TopTextFont = TextFont;
                }
            }
            else
                BS.ShowText = false;

            BS.X = BarcodeModule;
            BS.Unit = System.Drawing.GraphicsUnit.Millimeter;

            Spire.Barcode.BarCodeGenerator generator = new Spire.Barcode.BarCodeGenerator(BS);

            System.Drawing.Image image = generator.GenerateImage();

            var Result = new System.IO.MemoryStream();
            image.Save(Result, System.Drawing.Imaging.ImageFormat.Jpeg);
            Result.Position = 0;
            image.Dispose();

            return Result;
        }

        /// <summary>
        /// 將參數載入
        /// </summary>
        public void LoadData()
        {
            LaodDeviceID();
        }

        /// <summary>
        /// 載入設備編號
        /// </summary>
        private void LaodDeviceID()
        {
            if (string.IsNullOrEmpty(A5) || !string.IsNullOrEmpty(A4))
                return;

            string Query = @"Select Top 1 DeviceID,MachineName From T_TSDevice Where MachineID = @MachineID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDevice"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MachineID"].copy(A5));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count > 0)
            {
                A4 = DT.Rows[0]["DeviceID"].ToString().Trim();
                A6 = DT.Rows[0]["MachineName"].ToString().Trim();
            }
        }
    }

    public static class ED
    {
        /// <summary>
        /// 標準值最大上限值
        /// </summary>
        public static decimal StandardMaxValue = 99999;
        /// <summary>
        /// 標準值最小上限值
        /// </summary>
        public static decimal StandardMinValue = -99999;
        /// <summary>
        /// 參數ID種類對應資料庫表
        /// </summary>
        public enum PIDType : short
        {
            T_EDPPreDegreasing = 1,
            T_EDPUCDegreasing1,
            T_EDPUCDegreasing2,
            T_EDPHCL1,
            T_EDPHCL2,
            T_EDPNeutralizing,
            T_EDPSurfaceActivation,
            T_EDPPhosphating,
            T_EDPECoating,
            T_EDPUF1,
            T_EDPUF2,
            T_EDPAnolyte,
            T_EDPRecycleTank,
            T_EDPWaterRinsing,
            T_EDPCoatingTestForPD,
            T_EDCuring
        };
        /// <summary>
        /// 指定資料表名稱、日期、班別、線別得到是否已有該筆資料
        /// </summary>
        /// <param name="TableName">資料表名稱</param>
        /// <param name="PDate">日期</param>
        /// <param name="WorkClassID">班別</param>
        /// <param name="PLID">線別</param>
        /// <param name="PID">PID</param>
        /// <returns>是否已有該筆資料</returns>
        public static bool IsDataRepeat(string TableName, DateTime PDate, string WorkClassID, string PLID, string PID = "")
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            string Query = "Select Count(*) From " + TableName + " Where PDate = @PDate And WorkClassID = @WorkClassID And PLID = @PLID";

            if (!string.IsNullOrEmpty(PID))
            {
                Query += " And PID <> @PID";

                dbcb.appendParameter(GetDataAccessAttribute("PID", "nvarchar", 50, PID));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(GetDataAccessAttribute("PDate", "datetime", 0, PDate));
            dbcb.appendParameter(GetDataAccessAttribute("WorkClassID", "nvarchar", 50, WorkClassID));
            dbcb.appendParameter(GetDataAccessAttribute("PLID", "nvarchar", 50, PLID));

            return (int)CommonDB.ExecuteScalar(dbcb) > 0;
        }

        /// <summary>
        /// 指定清潔日期、線別、工序得到是否已有該筆資料
        /// </summary>
        /// <param name="CleanDate">清潔日期</param>
        /// <param name="PLID">線別</param>
        /// <param name="ProcessID">工序</param>
        /// <param name="CID">清潔紀錄ID</param>
        /// <returns>是否已有該筆資料</returns>
        public static bool IsCleanDateRepeat(DateTime CleanDate, string PLID, string ProcessID, string CID = "")
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDCRecord"];

            string Query = @"Select Count(*) From T_EDCRecord Where CleanDate = @CleanDate And PLID = @PLID And ProcessID = @ProcessID";

            if (!string.IsNullOrEmpty(CID))
            {
                Query += " And CID <> @CID";

                dbcb.appendParameter(Schema.Attributes["CID"].copy(CID));
            }

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["CleanDate"].copy(CleanDate));
            dbcb.appendParameter(Schema.Attributes["PLID"].copy(PLID));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            return (int)CommonDB.ExecuteScalar(dbcb) > 0;
        }

        /// <summary>
        /// 指定日期、得到磷化劑是否已有該筆資料
        /// </summary>
        /// <param name="PDate">日期</param>
        /// <param name="IsB">是否為B劑</param>
        /// <returns>是否已有該筆資料</returns>
        public static bool IsFormulaDateRepeat(DateTime PADate, bool IsB)
        {
            DbCommandBuilder dbcb = new DbCommandBuilder();

            string TableName = IsB ? "T_EDPhosphatingAgentB" : "T_EDPhosphatingAgentC";

            ObjectSchema Schema = DBSchema.currentDB.Tables[TableName];

            string Query = "Select Count(*) From " + TableName + " Where PADate = @PADate";

            dbcb.CommandText = Query;

            dbcb.appendParameter(Schema.Attributes["PADate"].copy(PADate));

            return (int)CommonDB.ExecuteScalar(dbcb) > 0;
        }

        /// <summary>
        /// 指定控制項將班別資料載入
        /// </summary>
        /// <param name="DDL">班別控制項</param>
        public static void LaodWorkClass(DropDownList DDL)
        {
            DataTable DT = GetCodeTypeData("WorkClass");

            DDL.DataValueField = "CodeID";

            DDL.DataTextField = "CodeName";

            DDL.DataSource = DT;

            DDL.DataBind();

            DDL.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
        }

        /// <summary>
        /// 指定控制項將班別資料載入
        /// </summary>
        /// <param name="CBL">班別控制項</param>
        public static void LaodWorkClass(CheckBoxList CBL)
        {
            DataTable DT = GetCodeTypeData("WorkClass");

            foreach (DataRow Row in DT.Rows)
            {
                ListItem Item = new ListItem("&nbsp;&nbsp;" + Row["CodeName"].ToString().Trim() + "&nbsp;&nbsp;", Row["CodeID"].ToString().Trim());

                CBL.Items.Add(Item);
            }
        }

        /// <summary>
        /// 指定控制項將線別資料載入
        /// </summary>
        /// <param name="DDL">線別控制項</param>
        public static void LoadProductionLine(DropDownList DDL)
        {
            DataTable DT = GetCodeTypeData("ProductionLine");

            DDL.DataValueField = "CodeID";

            DDL.DataTextField = "CodeName";

            DDL.DataSource = DT;

            DDL.DataBind();

            DDL.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
        }

        /// <summary>
        /// 指定控制項將線別資料載入
        /// </summary>
        /// <param name="CBL">線別控制項</param>
        public static void LoadProductionLine(CheckBoxList CBL)
        {
            DataTable DT = GetCodeTypeData("ProductionLine");

            foreach (DataRow Row in DT.Rows)
            {
                ListItem Item = new ListItem("&nbsp;&nbsp;" + Row["CodeName"].ToString().Trim() + "&nbsp;&nbsp;", Row["CodeID"].ToString().Trim());

                CBL.Items.Add(Item);
            }
        }

        /// <summary>
        /// 取的清潔工序資料
        /// </summary>
        private static DataTable GetCleanProcess()
        {
            string Query = @"Select CodeID,CodeName From T_Code Where CodeType = 'EDCleanProcess' And UICulture = @UICulture Order By Convert(int,CodeID)";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_Code"];

            dbcb.appendParameter(Schema.Attributes["UICulture"].copy(System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

            return CommonDB.ExecuteSelectQuery(dbcb);
        }

        /// <summary>
        /// 指定控制項將清潔工序資料載入
        /// </summary>
        /// <param name="DDL">清潔工序控制項</param>
        public static void LoadCleanProcess(DropDownList DDL)
        {
            DataTable DT = GetCleanProcess();

            DDL.DataValueField = "CodeID";

            DDL.DataTextField = "CodeName";

            DDL.DataSource = DT;

            DDL.DataBind();

            DDL.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
        }

        /// <summary>
        /// 指定控制項將清潔工序資料載入
        /// </summary>
        /// <param name="CBL">清潔工序控制項</param>
        public static void LoadCleanProcess(CheckBoxList CBL)
        {
            DataTable DT = GetCleanProcess();

            foreach (DataRow Row in DT.Rows)
            {
                ListItem Item = new ListItem("&nbsp;&nbsp;" + Row["CodeName"].ToString().Trim() + "&nbsp;&nbsp;", Row["CodeID"].ToString().Trim());

                CBL.Items.Add(Item);
            }
        }

        /// <summary>
        /// 指定PID、序號、CACategoryID得到刪除指令
        /// </summary>
        /// <param name="PID">PID</param>
        /// <param name="SerialNo">SerialNo</param>
        /// <param name="CACategoryID">CACategoryID</param>
        /// <returns>dbcb</returns>
        public static DbCommandBuilder GetDeleteCADBCB(string PID, short SerialNo, string CACategoryID)
        {
            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDChemicalAdding"];

            DbCommandBuilder dbcb = new DbCommandBuilder("Delete T_EDChemicalAdding Where PID = @PID And CategoryID = @CategoryID And SerialNo = @SerialNo");

            dbcb.appendParameter(Schema.Attributes["PID"].copy(PID));
            dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(CACategoryID));
            dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(SerialNo));

            return dbcb;
        }

        /// <summary>
        ///  指定PID、序號、CACategoryID、Qty控制項、LotNumber控制項得到新增指令
        /// </summary>
        /// <param name="PID">PID</param>
        /// <param name="SerialNo">SerialNo</param>
        /// <param name="CACategoryID">CACategoryID</param>
        /// <param name="PDate">參數日期</param>
        /// <param name="TB_AddDateTime">時間</param>
        /// <param name="TB_Qty">數量控制項</param>
        /// <param name="TB_LotNumber">批次號控制項</param>
        /// <returns>dbcb</returns>
        public static DbCommandBuilder GetCreateCADBCB(string PID, short SerialNo, string CACategoryID, DateTime PDate, TextBox TB_AddDateTime, TextBox TB_Qty, TextBox TB_LotNumber)
        {
            ObjectSchema Schema = DBSchema.currentDB.Tables["T_EDChemicalAdding"];

            DbCommandBuilder dbcb = new DbCommandBuilder("Insert Into T_EDChemicalAdding (PID,SerialNo,CategoryID,AddDateTime,Qty,LotNumber) Values (@PID,@SerialNo,@CategoryID,@AddDateTime,@Qty,@LotNumber)");

            dbcb.appendParameter(Schema.Attributes["PID"].copy(PID));
            dbcb.appendParameter(Schema.Attributes["SerialNo"].copy(SerialNo));
            dbcb.appendParameter(Schema.Attributes["CategoryID"].copy(CACategoryID));

            dbcb.appendParameter(Schema.Attributes["AddDateTime"].copy(PDate.ToDefaultString() + " " + TB_AddDateTime.Text.Trim()));

            decimal Qty = -1;

            if (!string.IsNullOrEmpty(TB_Qty.Text.Trim()) && !decimal.TryParse(TB_Qty.Text.Trim(), out Qty))
                Qty = -1;

            dbcb.appendParameter(Schema.Attributes["Qty"].copy(Qty));

            dbcb.appendParameter(Schema.Attributes["LotNumber"].copy(TB_LotNumber.Text.Trim()));

            return dbcb;
        }

        /// <summary>
        /// 指定參數ID、資料表ID、是否刪除化學添加劑資料表參數後，刪除指定資料
        /// </summary>
        /// <param name="PID">參數ID</param>
        /// <param name="PIDType">資料表ID</param>
        /// <param name="IsDeleteEDChemicalAdding">是否刪除化學添加劑資料表</param>
        public static void DeletEDData(string PID, short PIDType, bool IsDeleteEDChemicalAdding)
        {
            DBAction DBA = new DBAction();

            string TableName = Enum.GetName(typeof(Util.ED.PIDType), PIDType);

            string Query = @"Delete " + TableName + " Where PID = @PID";

            ObjectSchema Schema = DBSchema.currentDB.Tables[TableName];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PID"].copy(PID));

            DBA.AddCommandBuilder(dbcb);

            if (IsDeleteEDChemicalAdding)
            {
                Query = @"Delete T_EDChemicalAdding Where PID = @PID";

                Schema = DBSchema.currentDB.Tables["T_EDChemicalAdding"];

                dbcb = new DbCommandBuilder(Query);

                dbcb.appendParameter(Schema.Attributes["PID"].copy(PID));

                DBA.AddCommandBuilder(dbcb);
            }

            DBA.Execute();
        }
    }

    public static class TS
    {
        /// <summary>
        /// 工單號碼長度
        /// </summary>
        public static readonly int AUFNRLength = 12;
        /// <summary>
        /// 流程卡編號長度
        /// </summary>
        public static readonly int TicketIDLength = 17;
        /// <summary>
        /// 登入資訊(次要人員)
        /// </summary>
        public class LoginInfo
        {
            /// <summary>
            /// 員工工號
            /// </summary>
            public string WorkCode { get; set; }
            /// <summary>
            /// 員工ID
            /// </summary>
            public int AccountID { get; set; }
            /// <summary>
            /// 員工姓名
            /// </summary>
            public string AccountName { get; set; }

            /// <summary>
            /// 占比係數
            /// </summary>
            public double Coefficient { get; set; }
        }

        /// <summary>
        /// 工單狀態(T_Code.CodeType= TS_MOStatus)
        /// </summary>
        public enum MOStatus : short
        {
            Issued = 0,
            InProcess,
            Closed
        }

        /// <summary>
        /// 流程卡流程卡類型(T_Code.CodeType= TS_TicketType)
        /// </summary>
        public enum TicketType : short
        {
            General = 1,
            Quarantine,
            Rework
        }

        /// <summary>
        /// 工作站狀態類型(T_Code.CodeType= TS_WorkStationStatus)
        /// </summary>
        public enum WorkStationStatus : short
        {
            InMake = 1,
            InMaintain = 2,
            WaitMaintain = 3,
            Idle = 99
        }

        /// <summary>
        /// 标签扫描状态(T_Code.CodeType= LableScanStatus)
        /// </summary>
        public enum LableScanStatus : short
        {
            NormalLable = 1,
            CancelLable,
            StandbyLable,
            ExcessiveLable
        }

        /// <summary>
        /// 將字串轉為生產工單編號
        /// </summary>
        /// <param name="AUFNR">生產工單編號(為轉換過的)</param>
        /// <returns>生產工單編號</returns>
        public static string ToAUFNR(string AUFNR)
        {
            return AUFNR.PadLeft(AUFNRLength, '0').Trim();
        }

        /// <summary>
        /// 將字串轉為流程卡編號
        /// </summary>
        /// <param name="TicketID">流程卡編號(為轉換過的)</param>
        /// <returns>流程卡編號</returns>
        public static string ToTicketID(string TicketID)
        {
            return TicketID.PadLeft(TicketIDLength, '0').Trim();
        }

        /// <summary>
        ///  指定機台編號得到設備編號
        /// </summary>
        /// <param name="MachineID">機台編號</param>
        /// <returns>設備編號</returns>
        public static string GetDeviceID(string MachineID)
        {
            DataRow Row = GetDeviceRow(MachineID);

            if (Row != null)
                return Row["DeviceID"].ToString().Trim();
            else
                return string.Empty;
        }

        /// <summary>
        /// 指定機台編號得到設備資料列
        /// </summary>
        /// <param name="MachineID">機台編號</param>
        /// <returns>設備資料列</returns>
        public static DataRow GetDeviceRow(string MachineID)
        {
            string Query = @"Select Top 1 * From T_TSDevice Where MachineID = @MachineID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDevice"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["MachineID"].copy(MachineID.Trim()));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count < 1)
                return null;

            return DT.Rows[0];
        }

        /// <summary>
        /// 指定工單號碼得到所屬流程卡是否已經創立
        /// </summary>
        /// <param name="AUFNR">工單號碼</param>
        /// <returns>流程卡是否已經創立</returns>
        public static bool MOTicketIsExist(string AUFNR)
        {
            string Query = @"Select Count(*) From T_TSTicket Where AUFNR = @AUFNR";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR.Trim()));

            return (int)CommonDB.ExecuteScalar(dbcb) > 0;
        }

        /// <summary>
        /// 指定路由群組碼、路由群組計數器、工作清單節點號碼得到該作業是否活動中
        /// </summary>
        /// <param name="PLNNR">路由群組碼</param>
        /// <param name="PLNAL">路由群組計數器</param>
        /// <param name="PLNKN">工作清單節點號碼</param>
        /// <returns>作業是否活動中</returns>
        public static bool MOProcessIsActivity(string PLNNR, string PLNAL, string PLNKN)
        {
            string Query = @"Select Count(*) From V_TSProcessActivity Where PLNNR = @PLNNR And PLNAL = @PLNAL And PLNKN = @PLNKN";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPPLAS"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(PLNNR.Trim()));
            dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(PLNAL.Trim()));
            dbcb.appendParameter(Schema.Attributes["PLNKN"].copy(PLNKN.Trim()));

            return (int)CommonDB.ExecuteScalar(dbcb) > 0;
        }

        /// <summary>
        /// 指定流程卡號碼、不包含的工序編號得到流程卡是否已結束
        /// </summary>
        /// <param name="TicketID">工單號碼</param>
        /// <param name="ProcessID">不包含的工序編號</param>
        /// <returns>流程卡是否已結束</returns>
        public static bool IsTicketAllProcessEnd(string TicketID, string ProcessID)
        {
            /*
               如果此流程卡的所有工序都已經完成報工，就代表這流程卡都已完成

               但是不能包含自己的工序，因為DB尚未將當前的工序更新已結束

            */
            string Query = @"Select Count(*) From T_TSTicketRouting Where TicketID = @TicketID And IsEnd = 0 And ProcessID <> @ProcessID";

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicketRouting"];

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID.Trim()));
            dbcb.appendParameter(Schema.Attributes["ProcessID"].copy(ProcessID));

            return (int)CommonDB.ExecuteScalar(dbcb) < 1;
        }

        /// <summary>
        /// 指定流程卡號得到生產版本文字說明
        /// </summary>
        /// <param name="TicketID">流程卡號</param>
        /// <returns>生產版本文字說明</returns>
        public static string GetTEXT1(string TicketID)
        {
            string Query = @"Select Top 1 T_TSSAPMKAL.TEXT1
                            From T_TSTicket 
                            Inner Join T_TSSAPAFKO On T_TSSAPAFKO.AUFNR = T_TSTicket.AUFNR
                            Inner Join T_TSSAPMKAL On T_TSSAPMKAL.MATNR = T_TSSAPAFKO.PLNBEZ And T_TSSAPMKAL.VERID = T_TSSAPAFKO.VERID
                            Where T_TSTicket.TicketID = @TicketID ";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSTicket"];

            dbcb.appendParameter(Schema.Attributes["TicketID"].copy(TicketID.Trim()));

            return CommonDB.ExecuteScalar(dbcb).ToString().Trim();
        }

        /// <summary>
        ///  指定設備編號、狀態列舉取得設定工作站狀態dbcb
        /// </summary>
        /// <param name="DeviceID">設備編號</param>
        /// <param name="WSS">狀態</param>
        /// <param name="EventTime">進入時間</param>
        /// <param name="Operator">操作人員ID</param>
        /// <param name="WorkShiftID">班別ID</param>
        /// <returns>設定工作站狀態dbcb</returns>
        public static DbCommandBuilder GetChangeWorkStationStatusDBCB(string DeviceID, WorkStationStatus WSS, DateTime EventTime, int Operator = 0, string WorkShiftID = "")
        {
            string Query = @"Update T_TSWorkStation Set StatusID = @StatusID,WorkShiftID = @WorkShiftID,EventTime = @EventTime,Operator = @Operator Where DeviceID = @DeviceID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSWorkStation"];

            dbcb.appendParameter(Schema.Attributes["DeviceID"].copy(DeviceID.Trim()));

            dbcb.appendParameter(Schema.Attributes["StatusID"].copy(((short)WSS).ToString().Trim()));

            if (string.IsNullOrEmpty(WorkShiftID))
                dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(DBNull.Value));
            else
                dbcb.appendParameter(Schema.Attributes["WorkShiftID"].copy(WorkShiftID.Trim()));

            if (WSS == WorkStationStatus.Idle)
            {
                dbcb.appendParameter(Schema.Attributes["EventTime"].copy(EventTime));
                dbcb.appendParameter(Schema.Attributes["Operator"].copy(DBNull.Value));
            }
            else
            {
                dbcb.appendParameter(Schema.Attributes["EventTime"].copy(EventTime));
                dbcb.appendParameter(Schema.Attributes["Operator"].copy(Operator));
            }

            return dbcb;
        }

        /// <summary>
        /// 指定同步類型執行新增同步log
        /// </summary>
        /// <param name="SynchronizeType">同步類型</param>
        /// <param name="AUFNR">工單號碼</param>
        /// <param name="PLNNR">途層群組號</param>
        /// <param name="PLNAL">途層群組計數器</param>
        /// <returns>GUID</returns>
        public static string CreateSynchronizeDataLog(string SynchronizeType, string AUFNR = "", string PLNNR = "", string PLNAL = "")
        {
            string GUID = BaseConfiguration.NewGuid();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPSynchronizeDataLog"];

            DbCommandBuilder dbcb = new DbCommandBuilder("Insert Into T_TSSAPSynchronizeDataLog (GUID,StartTime,SynchronizeType,AUFNR,PLNNR,PLNAL) Values (@GUID,getdate(),@SynchronizeType,@AUFNR,@PLNNR,@PLNAL)");

            dbcb.appendParameter(Schema.Attributes["GUID"].copy(GUID));
            dbcb.appendParameter(Schema.Attributes["SynchronizeType"].copy(SynchronizeType));
            dbcb.appendParameter(Schema.Attributes["AUFNR"].copy(AUFNR));
            dbcb.appendParameter(Schema.Attributes["PLNNR"].copy(PLNNR));
            dbcb.appendParameter(Schema.Attributes["PLNAL"].copy(PLNAL));

            CommonDB.ExecuteSingleCommand(dbcb);

            return GUID;
        }

        /// <summary>
        /// 指定GUID將同步紀錄截止時間更新
        /// </summary>
        /// <param name="GUID">GUID</param>
        public static void UpdateSynchronizeDataLog(string GUID)
        {
            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSSAPSynchronizeDataLog"];

            DbCommandBuilder dbcb = new DbCommandBuilder("Update T_TSSAPSynchronizeDataLog Set EndTime = getdate() Where GUID = @GUID");

            dbcb.appendParameter(Schema.Attributes["GUID"].copy(GUID));

            CommonDB.ExecuteSingleCommand(dbcb);
        }

        /// <summary>
        /// 刪除同步紀錄資料表(一個月前資料)
        /// </summary>
        public static void DeleteSynchronizeDataLog()
        {
            string Query = @"Delete T_TSSAPSynchronizeDataLog Where DATEDIFF(Day,StartTime,GetDate()) > 14 ";

            CommonDB.ExecuteSingleCommand(Query);
        }

        /// <summary>
        /// 指定班别的DropDownList，载入班别资料
        /// </summary>
        /// <param name="DDL">班别的DropDownList</param>
        /// <param name="IsFilterCurrWorkShift">是否要過濾當前時間2小時前的班別</param>
        /// <param name="IsBackgroundColor">是否要加入背景顏色</param>
        public static void LoadDDLWorkShift(DropDownList DDL, bool IsFilterCurrWorkShift = true, bool IsBackgroundColor = true)
        {
            string Query = @"Select * From V_TSWorkShift ";

            if (IsFilterCurrWorkShift)
                Query += @" Where DateAdd(Hour,-2,StartTime) <= GetDate() And GetDate() <= EndTime ";

            Query += @" Order By SortID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            DDL.DataValueField = "WorkShiftID";

            DDL.DataTextField = "WorkShiftName";

            DDL.DataSource = DT;

            DDL.DataBind();

            DDL.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));

            if (IsBackgroundColor)
                SetDDLItemColor(DDL, 1);
        }

        /// <summary>
        /// 指定DDL和起始Item索引設定DDL Item背景顏色
        /// </summary>
        /// <param name="DDL">DropDownList</param>
        /// <param name="StartItem">起始索引</param>
        public static void SetDDLItemColor(DropDownList DDL, int StartItem)
        {
            List<string> BackgroundColorList = new List<string>();

            BackgroundColorList.Add("background-color: #46A3FF !important;");
            BackgroundColorList.Add("background-color: #00BB00 !important;");
            BackgroundColorList.Add("background-color: #FFDC35 !important;");
            BackgroundColorList.Add("background-color: #FF8040 !important;");
            BackgroundColorList.Add("background-color: #B9B973 !important;");
            BackgroundColorList.Add("background-color: #C07AB8 !important;");
            BackgroundColorList.Add("background-color: #00CED1 !important;");
            BackgroundColorList.Add("background-color: #FFFF30 !important;");

            int BackgroundColorIndex = 0;

            for (int i = StartItem; i < DDL.Items.Count; i++)
            {
                if (BackgroundColorIndex > 7)
                    BackgroundColorIndex = 0;

                DDL.Items[i].Attributes.Add("style", BackgroundColorList[BackgroundColorIndex]);

                BackgroundColorIndex++;
            }
        }

        /// <summary>
        /// 全检标签防重(長度限11碼)
        /// </summary>
        /// <param name="LableID">标签条码</param>
        public static string CheckScanLableIDRule(string LableID)
        {
            if (LableID.Length != 11)
                throw new Exception((string)HttpContext.GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_ScanBarcodeLength"));

            string Result = string.Empty;

            string Query = @"Select 
                                LableID,
                                BoxNo,
                                (Select CodeName From T_Code Where CodeType = 'TS_LableStatusID' And CodeID = StatusID And UICulture = @UICulture) As CodeName
                            From
                            (
                                Select LableID,BoxNo,StatusID From T_TSLableScan
                                Union All
                                Select LableID,Null,StatusID From T_TSLableScrap
                            ) As Result
                        Where LableID = @LableID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSLableScan"];

            dbcb.appendParameter(Schema.Attributes["LableID"].copy(LableID));

            dbcb.appendParameter(Util.GetDataAccessAttribute("UICulture", "nvarchar", 50, System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            if (DT.Rows.Count > 0)
            {
                string BoxNo = DT.Rows[0]["BoxNo"].ToString().Trim();

                string CodeName = DT.Rows[0]["CodeName"].ToString().Trim();

                Result = (string)HttpContext.GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Error_ScanLableRepeat");

                Result += string.IsNullOrEmpty(BoxNo) ? "Empty" : BoxNo;

                Result += CodeName;
            }

            return Result;
        }
    }

    public static class WM
    {
        /// <summary>
        ///  箱號長度
        /// </summary>
        public static readonly int BoxNoLegth = 11;
        /// <summary>
        /// 棧板號長度
        /// </summary>
        public static readonly int PalletNoLegth = 9;
        /// <summary>
        /// 裝箱編號長度
        /// </summary>
        public static readonly int PackingIDLegth = 10;
        /// <summary>
        /// 物料號碼長度
        /// </summary>
        public static readonly int MATNRLegth = 18;


        /// <summary>
        /// 將字串轉為裝箱編號
        /// </summary>
        /// <param name="PackingID">裝箱編號(為轉換過的)</param>
        /// <returns>裝箱編號</returns>
        public static string ToPackingID(string PackingID)
        {
            return PackingID.PadLeft(PackingIDLegth, '0').Trim();
        }

        /// <summary>
        /// 指定裝箱編號得到此裝箱編號是否為廠外出貨
        /// </summary>
        /// <param name="PackingID">裝箱編號</param>
        /// <returns>此裝箱編號是否為廠外出貨</returns>
        public static bool PackingIDIsOutside(string PackingID)
        {
            return PackingID.StartsWith("1");
        }

        /// <summary>
        /// 將字串轉為物料號碼
        /// </summary>
        /// <param name="MATNR">物料號碼字串</param>
        /// <returns>物料號碼</returns>
        public static string ToMATNR(string MATNR)
        {
            return MATNR.PadLeft(MATNRLegth, '0').Trim();
        }

        /// <summary>
        /// 指定PBNO得到是否為箱號
        /// </summary>
        /// <param name="PBNO">PBNO</param>
        /// <returns>是否為箱號</returns>
        public static bool IsBoxNo(string PBNO)
        {
            //棧板號長度 = 9
            //箱號長度 = 11
            return (PBNO.Length != PalletNoLegth);
        }
    }
}