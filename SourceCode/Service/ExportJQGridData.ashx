<%@ WebHandler Language="C#" Class="ExportJQGridData" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using Spire.Xls;

public class ExportJQGridData : BasePage
{
    protected string ReportFolderPath = HttpContext.Current.Server.MapPath(@"~\ReportTemplate\");
    protected string ReportTemplateName = "Export.xlsx";
    protected Newtonsoft.Json.Linq.JObject JQGridDataValue = null;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (string.IsNullOrEmpty(_context.Request["JQGridDataValue"].Trim()))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

            JQGridDataValue = Newtonsoft.Json.JsonConvert.DeserializeObject<Newtonsoft.Json.Linq.JObject>(_context.Request["JQGridDataValue"].Trim());

            if (!JQGridDataValue.ContainsKey("colModel") || !JQGridDataValue.ContainsKey("Rows"))
                throw new CustomException((string)GetGlobalResourceObject("GlobalRes", "Str_NoDataMessage"));

            string SaveFullPath = WritToExcel();

            string GID = NewGuid;

            DownloadFileInfo RI = new DownloadFileInfo { IsNoClearSession = false, IsDeleteDownloadFile = true, DownloadFileFullPath = SaveFullPath, SaveFileName = "Export_" + DateTime.Now.ToString("yyMMddHHmmss") + ".xlsx" };

            _context.Session.Add(GID, RI);

            ResponseSuccessData(new { Result = true, GUID = GID });

        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

    /// <summary>
    /// 將資料寫入至XLS
    /// </summary>
    /// <returns>報表檔案路徑</returns>
    protected string WritToExcel()
    {
        LoadReportTemplate(ReportFolderPath + @"\" + ReportTemplateName);

        Worksheet worksheet = ExcelWorkBook.Worksheets["RPT"];

        int ReportRowIndex = 1;
        int ReportColumnIndex = 1;

        CellStyle CellStyle = ExcelWorkBook.Styles.Add(NewGuid);
        CellStyle.Font.FontName = "微軟正黑體";
        CellStyle.Font.Size = 12;
        CellStyle.Borders[BordersLineType.EdgeLeft].LineStyle = LineStyleType.Thin;
        CellStyle.Borders[BordersLineType.EdgeRight].LineStyle = LineStyleType.Thin;
        CellStyle.Borders[BordersLineType.EdgeTop].LineStyle = LineStyleType.Thin;
        CellStyle.Borders[BordersLineType.EdgeBottom].LineStyle = LineStyleType.Thin;

        for (int i = 0; i < JQGridDataValue["colModel"].Count(); i++)
        {
            if (JQGridDataValue["colModel"][i].Value<bool>("hidden"))
                continue;

            worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = JQGridDataValue["colModel"][i].Value<string>("label");
            worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
            worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;
            worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
            ReportColumnIndex++;
        }

        var ColumnNames = JQGridDataValue["colModel"].Where(itme => !itme.Value<bool>("hidden")).Select(itme => itme.Value<string>("name")).ToList();

        for (int i = 0; i < JQGridDataValue["Rows"].Count(); i++)
        {
            ReportRowIndex++;
            ReportColumnIndex = 1;

            foreach (string Column in ColumnNames)
            {
                string Value = JQGridDataValue["Rows"][i].Value<string>(Column);

                if (Value.Contains("class=\"fa fa-check-square fa-fw\""))
                    Value = "V";

                worksheet.Range[ReportRowIndex, ReportColumnIndex].Text = Value;
                worksheet.Range[ReportRowIndex, ReportColumnIndex].IgnoreErrorOptions = IgnoreErrorType.NumberAsText;
                worksheet.Range[ReportRowIndex, ReportColumnIndex].Style = CellStyle;

                string Align = JQGridDataValue["colModel"].Where(itme => itme.Value<string>("name") == Column).Select(itme => itme.Value<string>("align")).FirstOrDefault();

                if (!string.IsNullOrEmpty(Align))
                {
                    switch (Align.ToUpper())
                    {
                        case "LEFT":
                            worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Left;
                            break;
                        case "RIGHT":
                            worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Right;
                            break;
                        case "CENTER":
                            worksheet.Range[ReportRowIndex, ReportColumnIndex].Style.HorizontalAlignment = HorizontalAlignType.Center;
                            break;
                    }
                }

                ReportColumnIndex++;
            }
        }

        return WriteToExcelFile(ReportTemplateName);
    }

}