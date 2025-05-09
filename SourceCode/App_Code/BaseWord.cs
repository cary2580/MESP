using System;
using System.IO;
using System.Drawing;
using System.Web;
using Spire.Doc;
using Spire.Doc.Documents;
using Spire.Doc.Fields;

/// <summary>
/// Word 報表列印使用
/// </summary>
public partial class BasePage
{
    public WordReport WR = new WordReport();

    /// <summary>
    /// 下載報表繪製範本
    /// </summary>
    /// <param name="FromPath">來源範本路徑(Full Path)</param>
    protected void LoadWordReportTemplate(string FromPath)
    {
        WR.LoadWordReportTemplate(FromPath);
    }

    /// <summary>
    /// 指定寫入資料流將報表儲存於此資料流中
    /// </summary>
    /// <param name="ResultFileStream">寫入資料流</param>
    /// <param name="SaveFormat">儲存的格式版本</param>
    protected void WriteToWordStream(MemoryStream ResultFileStream, FileFormat SaveFormat = FileFormat.Docx)
    {
        WR.WriteToStream(ResultFileStream, SaveFormat);
    }

    /// <summary>
    /// 指定儲存路徑(Full Name)將報表儲存於此路徑中
    /// </summary>
    /// <param name="TempReportName">儲存檔名</param>
    /// <param name="SaveFormat">儲存的版本</param>
    /// <returns>儲存報表檔案路徑</returns>
    protected string WriteToWordFile(string TempReportName, FileFormat SaveFormat = FileFormat.Docx)
    {
        return WR.WriteToFile(TempReportName, SaveFormat);
    }
}

public class WordReport
{
    /// <summary>
    /// 宣告報表Word
    /// </summary>
    public Document WordDocument;
    /// <summary>
    /// 檔案暫存位置
    /// </summary>
    public DirectoryInfo TempDirectory = null;
    /// <summary>
    /// 暫存檔案路徑
    /// </summary>
    public string TempFileFullPath = string.Empty;
    /// <summary>
    /// 傳入要設定的Bookmark、Bookmark值、圖片影像、圖片寬、圖片高設定繪製Word範本
    /// </summary>
    /// <param name="BookmarkName">Bookmark名稱</param>
    /// <param name="BookmarkValue">Bookmark值</param>
    /// <param name="Image">圖片影像</param>
    /// <param name="PictureWidth">圖片寬</param>
    /// <param name="PictureHeight">圖片高</param>
    public void WritDataToBookMark(string BookmarkName, string BookmarkValue, Bitmap Image = null, int PictureWidth = 0, int PictureHeight = 0)
    {
        if (Image == null)
        {
            //處理文字
            BookmarksNavigator bookmarkNavigator = new BookmarksNavigator(WordDocument);

            bookmarkNavigator.MoveToBookmark(BookmarkName, true, true);

            bookmarkNavigator.InsertText(BookmarkValue);
        }
        else
        {
            //處理影像(QR Code)
            Bookmark bookmark = WordDocument.Bookmarks[BookmarkName];

            Paragraph bookPra = bookmark.BookmarkStart.OwnerParagraph;

            int index = bookPra.ChildObjects.IndexOf(bookmark.BookmarkStart);

            Paragraph paragraph = new Paragraph(WordDocument);

            DocPicture picture = paragraph.AppendPicture(Image);

            picture.Width = PictureWidth > 0 ? PictureWidth : 60;

            picture.Height = PictureHeight > 0 ? PictureHeight : 60;

            picture.TextWrappingStyle = TextWrappingStyle.InFrontOfText;

            picture.HorizontalAlignment = ShapeHorizontalAlignment.Center;

            picture.VerticalAlignment = ShapeVerticalAlignment.Center;

            bookPra.ChildObjects.Insert(index, picture);
        }
    }
    /// <summary>
    /// 下載報表繪製範本
    /// </summary>
    /// <param name="FromPath">來源範本路徑</param>
    public void LoadWordReportTemplate(string FromPath)
    {
        //新增一個暫存資料夾的物件，存放開啟的範本
        TempDirectory = Util.GetTempDirectory(null, string.Empty);

        string FileName = Path.GetFileName(FromPath);

        //目的地暫存範本檔路徑
        TempFileFullPath = TempDirectory.FullName + FileName;

        File.Copy(FromPath, TempFileFullPath);

        WordDocument = new Document();

        WordDocument.LoadFromFile(TempFileFullPath);
    }
    /// <summary>
    /// 重新載入暫存檔案於報表繪製範本
    /// </summary>
    public void ReLoadWordReportTemplate()
    {
        WordDocument.Close();

        WordDocument.Dispose();

        WordDocument = new Document();

        WordDocument.LoadFromFile(TempFileFullPath);
    }

    /// <summary>
    /// 指定寫入資料流將報表儲存於此資料流中
    /// </summary>
    /// <param name="ResultFileStream">寫入資料流</param>
    /// <param name="SaveFormat">儲存的格式版本</param>
    public void WriteToStream(MemoryStream ResultFileStream, FileFormat SaveFormat = FileFormat.Docx)
    {
        // Spire.doc 有bug，如果要儲存程pdf的話，如果沒有先儲存成doc的話，會發生文字中如果有空格的話會被去除。因此先把它儲存成doc後再載入儲存成pdf即可
        if (SaveFormat != FileFormat.PDF)
            WordDocument.SaveToStream(ResultFileStream, SaveFormat);
        else
            WriteToStreamByPDF(ResultFileStream);

        WordDocument.Dispose();
    }

    /// <summary>
    /// 指定儲存路徑(Full Name)將報表儲存於此路徑中
    /// </summary>
    /// <param name="TempReportName">儲存檔名</param>
    /// <param name="SaveFormat">儲存的格式版本</param>
    /// <returns>儲存報表檔案路徑</returns>
    public string WriteToFile(string TempReportName, FileFormat SaveFormat = FileFormat.Docx)
    {
        string FilePath = TempDirectory.FullName;
        FilePath = FilePath.EndsWith(@"\") ? FilePath : FilePath + "\\";
        FilePath += TempReportName;

        // Spire.doc 有bug，如果要儲存程pdf的話，如果沒有先儲存成doc的話，會發生文字中如果有空格的話會被去除。因此先把它儲存成doc後再載入儲存成pdf即可
        if (SaveFormat != FileFormat.PDF)
            WordDocument.SaveToFile(FilePath, SaveFormat);
        else
        {
            MemoryStream ms = new MemoryStream();

            WriteToStreamByPDF(ms);

            using (FileStream fs = File.Create(FilePath))
            {
                ms.WriteTo(fs);
                ms.Close();
            }
        }

        return FilePath;
    }

    /// <summary>
    /// 指定寫入資料流將報表儲存於此資料流中(僅限於PDF格式)
    /// </summary>
    /// <param name="ResultFileStream">寫入資料流</param>
    /// <returns>PDF資料流</returns>
    private void WriteToStreamByPDF(MemoryStream ResultFileStream)
    {
        MemoryStream ms = new MemoryStream();

        WordDocument.SaveToStream(ms, FileFormat.Doc);

        Document document = new Document();

        document.LoadFromStream(ms, FileFormat.Doc);

        document.SaveToStream(ResultFileStream, FileFormat.PDF);
    }
}