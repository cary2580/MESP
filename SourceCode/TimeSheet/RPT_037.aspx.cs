using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using DataAccess.Data;
using DataAccess.Data.Schema;

public partial class TimeSheet_RPT_037 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        if (!IsPostBack)
        {
            string Query = @"Select T_TSIssueCategory.CategoryID,T_TSIssueCategory.CategoryName 
                        From T_TSIssueCategory Order By SortID";

            DbCommandBuilder dbcb = new DbCommandBuilder(Query);

            ObjectSchema Schema = DBSchema.currentDB.Tables["T_TSIssueCategoryDevice"];

            DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

            DDL_Category.DataValueField = "CategoryID";

            DDL_Category.DataTextField = "CategoryName";

            DDL_Category.DataSource = DT;

            DDL_Category.DataBind();

            DDL_Category.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
        }
    }

    protected void BT_Search_Click(object sender, EventArgs e)
    {
        if (!Master.IsAccountVerificationPass)
            return;

        DbCommandBuilder dbcb = new DbCommandBuilder("SP_TS_RPT_037");

        dbcb.DbCommandType = CommandType.StoredProcedure;

        dbcb.appendParameter(Util.GetDataAccessAttribute("IssueDateStart", "datetime", 0, DateTime.Parse(TB_DateStart.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));
        dbcb.appendParameter(Util.GetDataAccessAttribute("IssueDateEnd", "datetime", 0, DateTime.Parse(TB_DateEnd.Text.Trim(), System.Threading.Thread.CurrentThread.CurrentUICulture)));
        dbcb.appendParameter(Util.GetDataAccessAttribute("CategoryID", "nvarchar", 50, DDL_Category.SelectedValue));

        DataSet DS = CommonDB.ExecuteSelectQueryToDataSet(dbcb);

        int DataTableIndex = 3;

        int GoodQtyTableIndex = 4;

        if (DS.Tables.Count < 5)
        {
            DataTableIndex = 2;

            GoodQtyTableIndex = 3;
        }

        DataTable DT = DS.Tables[DataTableIndex];

        DataTable SubDT = DS.Tables[GoodQtyTableIndex];

        if (DT.Rows.Count < 1)
        {
            Util.RegisterStartupScriptJqueryAlert(Page, (string)GetGlobalResourceObject("GlobalRes", "Str_ReportNoDataRow"));

            return;
        }

        if (SubDT.Rows.Count > 0)
        {
            foreach (DataRow Row in SubDT.Rows)
            {
                DataRow NewRow = DT.NewRow();
                if (DT.Columns.Contains("WorkShiftID"))
                    NewRow["WorkShiftID"] = Row["WorkShiftID"].ToString().Trim();
                if (DT.Columns.Contains("WorkShiftName"))
                    NewRow["WorkShiftName"] = Row["WorkShiftName"].ToString().Trim();
                if (DT.Columns.Contains("WorkShiftSortID"))
                    NewRow["WorkShiftSortID"] = (short)Row["WorkShiftSortID"];

                NewRow["DeviceID"] = Row["DeviceID"].ToString().Trim();
                NewRow["MachineName"] = Row["MachineName"].ToString().Trim();
                NewRow["DeviceSortID"] = (double)Row["DeviceSortID"];
                NewRow["IssueID"] = string.Empty;
                NewRow["IssueName"] = (string)GetLocalResourceObject("Str_WorkShiftDeviceMaintainMinute");
                NewRow["IssueSortID"] = -1;
                NewRow["UsageMinutes"] = (int)Row["MaintainMinute"];
                DT.Rows.InsertAt(NewRow, 0);

                NewRow = DT.NewRow();
                if (DT.Columns.Contains("WorkShiftID"))
                    NewRow["WorkShiftID"] = Row["WorkShiftID"].ToString().Trim();
                if (DT.Columns.Contains("WorkShiftName"))
                    NewRow["WorkShiftName"] = Row["WorkShiftName"].ToString().Trim();
                if (DT.Columns.Contains("WorkShiftSortID"))
                    NewRow["WorkShiftSortID"] = Row["WorkShiftSortID"].ToString().Trim();

                NewRow["DeviceID"] = Row["DeviceID"].ToString().Trim();
                NewRow["MachineName"] = Row["MachineName"].ToString().Trim();
                NewRow["DeviceSortID"] = (double)Row["DeviceSortID"];
                NewRow["IssueID"] = string.Empty;
                NewRow["IssueName"] = (string)GetLocalResourceObject("Str_WorkShiftDeviceGoodQty");
                NewRow["IssueSortID"] = -2;
                NewRow["UsageMinutes"] = (int)Row["GoodQty"];
                DT.Rows.InsertAt(NewRow, 0);
            }
        }
        else
        {
            DataRow NewRow = DT.NewRow();

            if (DT.Columns.Contains("WorkShiftID"))
                NewRow["WorkShiftID"] = "";
            if (DT.Columns.Contains("WorkShiftName"))
                NewRow["WorkShiftName"] = "";
            if (DT.Columns.Contains("WorkShiftSortID"))
                NewRow["WorkShiftSortID"] = 0;

            NewRow["DeviceID"] = string.Empty;
            NewRow["MachineName"] = string.Empty;
            NewRow["DeviceSortID"] = 0;
            NewRow["IssueID"] = string.Empty;
            NewRow["IssueName"] = (string)GetLocalResourceObject("Str_WorkShiftDeviceMaintainMinute");
            NewRow["IssueSortID"] = 0;
            NewRow["UsageMinutes"] = 0;
            DT.Rows.InsertAt(NewRow, 0);

            NewRow = DT.NewRow();
            if (DT.Columns.Contains("WorkShiftID"))
                NewRow["WorkShiftID"] = "";
            if (DT.Columns.Contains("WorkShiftName"))
                NewRow["WorkShiftName"] = "";
            if (DT.Columns.Contains("WorkShiftSortID"))
                NewRow["WorkShiftSortID"] = 0;

            NewRow["DeviceID"] = string.Empty;
            NewRow["MachineName"] = string.Empty;
            NewRow["DeviceSortID"] = 0;
            NewRow["IssueID"] = string.Empty;
            NewRow["IssueName"] = (string)GetLocalResourceObject("Str_WorkShiftDeviceGoodQty");
            NewRow["IssueSortID"] = 0;
            NewRow["UsageMinutes"] = 0;
            DT.Rows.InsertAt(NewRow, 0);
        }

        var Result = new
        {
            Rows = DT.AsEnumerable().Select(Row => new
            {
                WorkShiftID = Row.Table.Columns.Contains("WorkShiftID") ? Row["WorkShiftID"].ToString().Trim() : string.Empty,
                WorkShiftName = Row.Table.Columns.Contains("WorkShiftName") ? Row["WorkShiftName"].ToString().Trim() : string.Empty,
                WorkShiftSortID = Row.Table.Columns.Contains("WorkShiftSortID") ? (short)Row["WorkShiftSortID"] : 0,
                DeviceID = Row["DeviceID"].ToString().Trim(),
                MachineName = Row["MachineName"].ToString().Trim(),
                DeviceSortID = (double)Row["DeviceSortID"],
                IssueID = Row["IssueID"].ToString().Trim(),
                IssueName = Row["IssueName"].ToString().Trim(),
                IssueSortID = (double)Row["IssueSortID"],
                UsageMinutes = (int)Row["UsageMinutes"]
            }).OrderBy(item => item.IssueSortID).ThenBy(item => item.WorkShiftSortID).ThenBy(item => item.DeviceSortID)
        };

        Page.ClientScript.RegisterStartupScript(this.GetType(), "JGDataValue", "<script>var JGDataValue=" + Newtonsoft.Json.JsonConvert.SerializeObject(Result) + ";</script>");
    }
}