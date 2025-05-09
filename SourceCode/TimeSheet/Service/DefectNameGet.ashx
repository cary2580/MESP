<%@ WebHandler Language="C#" Class="DefectNameGet" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class DefectNameGet : BasePage
{
    protected string ScrapReasonID = string.Empty;
    protected string DefectID = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["ScrapReasonID"] != null)
                ScrapReasonID = _context.Request["ScrapReasonID"].Trim();
            if (_context.Request["DefectID"] != null)
                DefectID = _context.Request["DefectID"].Trim().TrimStart();

            if (string.IsNullOrEmpty(DefectID))
                throw new CustomException((string)GetLocalResourceObject("Str_Empty_DefectID"));

            string Query = string.Empty;

            DbCommandBuilder dbcb = new DbCommandBuilder();

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSDefect"];

            if (!string.IsNullOrEmpty(ScrapReasonID))
            {
                Query = @"Select DefectName
                            From T_TSScrapReasonMappingDefect Inner Join T_TSDefect On T_TSScrapReasonMappingDefect.DefectID = T_TSDefect.DefectID
                            Where T_TSScrapReasonMappingDefect.ScrapReasonID = @ScrapReasonID And T_TSScrapReasonMappingDefect.DefectID = @DefectID And T_TSDefect.IsEnable = 1";

                Schema = DBSchema.currentDB.Tables["T_TSScrapReasonMappingDefect"];

                dbcb.appendParameter(Schema.Attributes["ScrapReasonID"].copy(ScrapReasonID));
            }
            else
                Query = @"Select DefectName From T_TSDefect Where DefectID = @DefectID And IsEnable = 1";

            dbcb.appendParameter(Schema.Attributes["DefectID"].copy(DefectID));

            dbcb.CommandText = Query;

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            string DefectName = string.Empty;

            if (DT.Rows.Count > 0)
                DefectName = DT.Rows[0]["DefectName"].ToString().Trim();

            if (string.IsNullOrEmpty(ScrapReasonID))
                ScrapReasonID = GetScrapReasonID();

            ResponseSuccessData(new { DefectName = DefectName, ScrapReasonID = ScrapReasonID });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 取得對應的報廢原因(如果對應到多個報廢原因就回傳空白)
    /// </summary>
    /// <returns>對應的報廢原因</returns>
    protected string GetScrapReasonID()
    {
        ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSScrapReasonMappingDefect"];

        string Query = @"Select * From T_TSScrapReasonMappingDefect Where DefectID = @DefectID";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["DefectID"].copy(DefectID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        if (DT.Rows.Count == 1)
            return DT.Rows[0]["ScrapReasonID"].ToString().Trim();
        else
            return string.Empty;
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}