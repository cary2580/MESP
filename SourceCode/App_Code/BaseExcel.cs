using System;
using System.IO;
using System.Web;
using Spire.Xls;

/// <summary>
/// Excel 報表列印使用
/// </summary>
public partial class BasePage
{
    private ExcelReport ER = new ExcelReport();

    /// <summary>
    /// 宣告報表Excel
    /// </summary>
    protected Workbook ExcelWorkBook
    {
        get { return ER.ExcelWorkBook; }
        set { ER.ExcelWorkBook = value; }
    }
    /// <summary>
    ///  指定報表試算表
    /// </summary>
    protected Worksheet Sheet
    {
        get { return ER.Sheet; }
        set { ER.Sheet = value; }
    }
    /// <summary>
    /// 報表字體
    /// </summary>
    protected string ReportFontName
    {
        get { return ER.ReportFontName; }
        set { ER.ReportFontName = value; }
    }
    /// <summary>
    /// 報表字體大小
    /// </summary>
    protected int ReportFontSize
    {
        get { return ER.ReportFontSize; }
        set { ER.ReportFontSize = value; }
    }
    /// <summary>
    /// 下載報表繪製範本
    /// </summary>
    /// <param name="FromPath">來源範本路徑</param>
    protected void LoadReportTemplate(string FromPath)
    {
        ER.LoadReportTemplate(FromPath);
    }

    /// <summary>
    /// 指定寫入資料流將報表儲存於此資料流中
    /// </summary>
    /// <param name="ResultFileStream">寫入資料流</param>
    /// <param name="SaveFormat">儲存的格式版本</param>
    protected void WriteToExcelStream(MemoryStream ResultFileStream, FileFormat SaveFormat = FileFormat.Version2016)
    {
        ER.WriteToStream(ResultFileStream, SaveFormat);
    }

    /// <summary>
    /// 指定儲存路徑(Full Name)將報表儲存於此路徑中
    /// </summary>
    /// <param name="TempReportName">儲存檔名</param>
    /// <param name="SaveFormat">儲存的版本</param>
    /// <returns>儲存報表檔案路徑</returns>
    protected string WriteToExcelFile(string TempReportName, FileFormat SaveFormat = FileFormat.Version2016)
    {
        return ER.WriteToFile(TempReportName, SaveFormat);
    }

    /// <summary>
    /// 指定欄位數字得到Excel的欄位字母 (把數字欄位轉成 Excel 的欄位字母（例如 1 -> A, 27 -> AA）)
    /// </summary>
    /// <param name="ColumnIndex">Excel的欄位數字</param>
    /// <returns>Excel的欄位字母</returns>
    public string GetColumnLetter(int ColumnIndex)
    {
        string columnString = string.Empty;

        while (ColumnIndex > 0)
        {
            int currentLetterNumber = (ColumnIndex - 1) % 26;
            char currentLetter = (char)(currentLetterNumber + 65);
            columnString = currentLetter + columnString;
            ColumnIndex = (ColumnIndex - 1) / 26;
        }
        return columnString;
    }

    /// <summary>
    /// 指定欄位欄位字母得到Excel的欄位數字(將Excel欄位字母轉成欄位數字（例如：A -> 1, AA -> 27）)
    /// </summary>
    /// <param name="ColumnLetter">Excel的欄位字母</param>
    /// <returns>Excel的欄位數字</returns>
    public int GetColumnIndex(string ColumnLetter)
    {
        if (string.IsNullOrWhiteSpace(ColumnLetter))
            throw new ArgumentNullException("ColumnLetter");

        ColumnLetter = ColumnLetter.ToUpperInvariant();

        int Sum = 0;

        for (int i = 0; i < ColumnLetter.Length; i++)
        {
            Sum *= 26;
            Sum += (ColumnLetter[i] - 'A' + 1);
        }

        return Sum;
    }

    /// <summary>
    /// 指定欄位區域將日期值填入此欄位(若年分小於1911將不會填入)
    /// </summary>
    /// <param name="Range">欄位區域</param>
    /// <param name="ReportDate">日期</param>
    /// <param name="IsShowTimeFormat">是否要顯示到時間</param>
    public void SetReportDate(CellRange Range, DateTime ReportDate, bool IsShowTimeFormat = false)
    {
        if (ReportDate.Year < 1911)
            Range.Value2 = null;
        else
        {
            // 取得日期與時間格式
            string DatePattern = System.Threading.Thread.CurrentThread.CurrentUICulture.DateTimeFormat.ShortDatePattern;
            string TimePattern = System.Threading.Thread.CurrentThread.CurrentUICulture.DateTimeFormat.LongTimePattern;

            if (IsShowTimeFormat)
            {
                Range.DateTimeValue = ReportDate;

                Range.NumberFormat = string.Format("{0} {1}", DatePattern, TimePattern);
            }
            else
            {
                Range.DateTimeValue = new DateTime(ReportDate.Year, ReportDate.Month, ReportDate.Day);

                Range.NumberFormat = DatePattern;
            }

            Range.Style.HorizontalAlignment = HorizontalAlignType.Center;
        }
    }

    /// <summary>
    /// 指定起始RowIndex、ColumnIndex 將此Sheet設定預設格式包含框線
    /// </summary>
    public void SetReportDefaultStyle(int StartRowIndex = 1, int StrtColumnIndex = 1)
    {
        CellRange Range = Sheet.Range[StartRowIndex, StrtColumnIndex, Sheet.LastRow, Sheet.LastColumn];

        Range.BorderInside(LineStyleType.Thin);

        Range.BorderAround(LineStyleType.Thin);

        Range.Style.Font.FontName = "微軟正黑體";

        Range.Style.Font.Size = 12;

        Range.IgnoreErrorOptions = IgnoreErrorType.NumberAsText;

        // 逐欄自動調整寬度
        for (int col = 1; col <= Sheet.LastColumn; col++)
        {
            Sheet.AutoFitColumn(col);
        }
    }
}

public class ExcelReport
{
    /// <summary>
    /// 宣告報表Excel
    /// </summary>
    public Workbook ExcelWorkBook;
    /// <summary>
    /// 指定報表試算表
    /// </summary>
    public Worksheet Sheet;
    /// <summary>
    /// 檔案暫存位置
    /// </summary>
    public DirectoryInfo TempDirectory = null;
    /// <summary>
    /// 暫存檔案路徑
    /// </summary>
    public string TempFileFullPath = string.Empty;
    /// <summary>
    /// 報表字體
    /// </summary>
    public string ReportFontName = "微軟正黑體";
    /// <summary>
    /// 報表字體大小
    /// </summary>
    public int ReportFontSize = 12;
    /// <summary>
    /// 下載報表繪製範本
    /// </summary>
    /// <param name="FromPath">來源範本路徑</param>
    public void LoadReportTemplate(string FromPath)
    {
        //新增一個暫存資料夾的物件，存放開啟的範本
        TempDirectory = Util.GetTempDirectory(null, string.Empty);

        string FileName = Path.GetFileName(FromPath);

        //目的地暫存範本檔路徑
        TempFileFullPath = TempDirectory.FullName + FileName;

        File.Copy(FromPath, TempFileFullPath);

        if (!File.Exists(TempFileFullPath))
            throw new Exception("Template:" + FileName + ",Find Null !!");

        FileStream FS = new FileStream(TempFileFullPath, FileMode.Open, FileAccess.Read);

        ExcelWorkBook = new Workbook();

        ExcelWorkBook.LoadFromStream(FS);

        //指定到第一個試算表
        Sheet = ExcelWorkBook.Worksheets[0];

        FS.Close();
    }

    /// <summary>
    /// 重新載入暫存檔案於報表繪製範本
    /// </summary>
    public void ReLoadWordReportTemplate()
    {
        FileStream FS = new FileStream(TempFileFullPath, FileMode.Open, FileAccess.Read);

        ExcelWorkBook.Dispose();

        ExcelWorkBook = new Workbook();

        ExcelWorkBook.LoadFromStream(FS);

        FS.Close();
    }

    /// <summary>
    /// 指定寫入資料流將報表儲存於此資料流中
    /// </summary>
    /// <param name="ResultFileStream">寫入資料流</param>
    /// <param name="SaveFormat">儲存的格式版本</param>
    public void WriteToStream(MemoryStream ResultFileStream, FileFormat SaveFormat = FileFormat.Version2016)
    {
        ExcelWorkBook.SaveToStream(ResultFileStream, SaveFormat);

        ExcelWorkBook.Dispose();
    }

    /// <summary>
    /// 指定儲存路徑(Full Name)將報表儲存於此路徑中
    /// </summary>
    /// <param name="TempReportName">儲存檔名</param>
    /// <param name="SaveFormat">儲存的版本</param>
    /// <returns>儲存報表檔案路徑</returns>
    public string WriteToFile(string TempReportName, FileFormat SaveFormat = FileFormat.Version2016)
    {
        string FilePath = TempDirectory.FullName;
        FilePath = FilePath.EndsWith(@"\") ? FilePath : FilePath + "\\";
        FilePath += TempReportName;

        MemoryStream ms = new MemoryStream();

        ExcelWorkBook.SaveToStream(ms, SaveFormat);

        ExcelWorkBook.Dispose();

        FileStream ExcelFile = new FileStream(FilePath, FileMode.Create, FileAccess.Write);
        ms.WriteTo(ExcelFile);
        ExcelFile.Close();
        ms.Close();

        return FilePath;
    }
}