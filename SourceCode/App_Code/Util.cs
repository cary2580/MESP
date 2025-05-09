using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using System.Data;
using System.Reflection;
using System.Dynamic;
using DataAccess.Data;
using DataAccess.Data.Schema;
using System.Security.Cryptography;
using System.IO;
using Ionic.Zip;
using System.Text;
using System.Net.Mail;

/// <summary>
/// 常用函式庫
/// </summary>
public static partial class Util
{
    /// <summary>
    /// 指定控制項集合及結果類別陣列找出所有該類別控制項並加入集合中
    /// </summary>
    /// <typeparam name="T">控制項類別</typeparam>
    /// <param name="CC">控制項集合</param>
    /// <param name="ResultCollection">找出結果集合</param>
    public static void FindPageControlByType<T>(System.Web.UI.ControlCollection CC, List<T> ResultCollection) where T : System.Web.UI.Control
    {
        foreach (System.Web.UI.Control C in CC)
        {
            if (C is T)
                ResultCollection.Add((T)C);

            if (C.HasControls())
                FindPageControlByType(C.Controls, ResultCollection);
        }
    }

    public static IList<T> CloneList<T>(this IList<T> list) where T : ICloneable
    {
        return list.Select(item => (T)item.Clone()).ToList();
    }

    public static IList<Dictionary<string, string>> ToDictionary(this DataTable table, Dictionary<string, string> DataTimeFormats = null, Dictionary<string, string> NumberFormats = null)
    {
        IList<Dictionary<string, string>> result = new List<Dictionary<string, string>>();

        foreach (DataRow R in table.Rows)
        {
            Dictionary<string, string> Rl = new Dictionary<string, string>();
            foreach (DataColumn C in table.Columns)
            {
                if (R[C].GetType() == typeof(DateTime))
                {
                    if (DataTimeFormats != null && DataTimeFormats.Keys.Contains(C.ColumnName))
                        Rl.Add(C.ColumnName, ((DateTime)R[C]).ToString(DataTimeFormats[C.ColumnName]));
                    else
                    {
                        if ((C.ColumnName.ToLower().Contains("時間") || C.ColumnName.ToLower().Contains("time")))
                            Rl.Add(C.ColumnName, ((DateTime)R[C]).ToCurrentUICultureStringTime());
                        else if ((C.ColumnName.ToLower().Contains("日期") || C.ColumnName.ToLower().Contains("date")))
                            Rl.Add(C.ColumnName, ((DateTime)R[C]).ToCurrentUICultureString());
                        else
                            Rl.Add(C.ColumnName, R[C].ToString().Trim());
                    }
                }
                else if (R[C].GetType().IsNumericType() && NumberFormats != null)
                {
                    if (NumberFormats.Keys.Contains(C.ColumnName))
                    {
                        var Method = R[C].GetType().GetMethod("ToString", new Type[] { NumberFormats[C.ColumnName].GetType(), typeof(IFormatProvider) });
                        object[] args = new object[] { NumberFormats[C.ColumnName], System.Threading.Thread.CurrentThread.CurrentUICulture };
                        string Value = Method.Invoke(R[C], args).ToString();
                        Rl.Add(C.ColumnName, Value);
                    }
                    else
                        Rl.Add(C.ColumnName, R[C].ToString().Trim());
                }
                else
                    Rl.Add(C.ColumnName, R[C].ToString().Trim());
            }
            result.Add(Rl);
        }

        return result;
    }

    public static IList<List<string>> ToList(this DataTable table)
    {
        IList<List<string>> result = new List<List<string>>();

        foreach (DataRow R in table.Rows)
        {
            List<string> Rl = new List<string>();
            foreach (DataColumn C in table.Columns)
            {
                if ((C.ColumnName.ToLower().Contains("日期") || C.ColumnName.ToLower().Contains("日期") || C.ColumnName.ToLower().Contains("date")) && R[C].GetType() == typeof(DateTime))
                    Rl.Add(((DateTime)R[C]).ToCurrentUICultureString());
                else if ((C.ColumnName.ToLower().Contains("時間") || C.ColumnName.ToLower().Contains("时间") || C.ColumnName.ToLower().Contains("time")) && R[C].GetType() == typeof(DateTime))
                    Rl.Add(((DateTime)R[C]).ToCurrentUICultureStringTime());
                else
                    Rl.Add(R[C].ToString().Trim());
            }
            result.Add(Rl);
        }

        return result;
    }

    public static IList<T> ToList<T>(this DataTable table) where T : new()
    {
        IList<T> result = new List<T>();

        IList<PropertyInfo> properties = typeof(T).GetProperties().ToList();
        foreach (var row in table.Rows)
        {
            var item = CreateItemFromRow<T>((DataRow)row, properties);
            result.Add(item);
        }

        return result;
    }

    private static T CreateItemFromRow<T>(DataRow row, IList<PropertyInfo> properties) where T : new()
    {
        T item = new T();
        foreach (var property in properties)
        {
            property.SetValue(item, row[property.Name], null);
        }
        return item;
    }

    /// <summary>
    /// 指定開始及迄止日期得到可列舉表列日期
    /// </summary>
    /// <param name="StartDate">開始日期</param>
    /// <param name="EndDate">迄止日期</param>
    /// <returns>可列舉表列日期</returns>
    private static IEnumerable<DateTime> EachDay(DateTime StartDate, DateTime EndDate)
    {
        for (var day = StartDate.Date; day.Date <= EndDate.Date; day = day.AddDays(1))
            yield return day;
    }

    /// <summary>
    /// 指定開始及迄止日期得到可列舉表列日期(月份)
    /// </summary>
    /// <param name="StartDate">開始日期</param>
    /// <param name="EndDate">迄止日期</param>
    /// <returns>可列舉表列日期(月份)</returns>
    private static IEnumerable<DateTime> EachMonth(DateTime StartDate, DateTime EndDate)
    {
        for (var month = StartDate.Date; month.Date <= EndDate.Date || month.Month == EndDate.Month; month = month.AddMonths(1))
            yield return month;
    }

    /// <summary>
    /// 指定迄止日期得到可列舉表列日期
    /// </summary>
    /// <param name="DateFrom">開始日期</param>
    /// <param name="DateTo">迄止日期</param>
    /// <returns>可列舉表列日期</returns>
    public static IEnumerable<DateTime> EachDayTo(this DateTime DateFrom, DateTime DateTo)
    {
        return EachDay(DateFrom, DateTo);
    }

    /// <summary>
    /// 指定迄止日期得到可列舉表列日期(月份)
    /// </summary>
    /// <param name="DateFrom">開始日期</param>
    /// <param name="DateTo">迄止日期</param>
    /// <returns>可列舉表列日期(月份)</returns>
    public static IEnumerable<DateTime> EachMonthTo(this DateTime DateFrom, DateTime DateTo)
    {
        return EachMonth(DateFrom, DateTo);
    }

    /// <summary>
    /// 取得DBCB屬性
    /// </summary>
    /// <param name="ColumnName">欄位名稱</param>
    /// <param name="DBTypeName">資料型別</param>
    /// <param name="Length">資料長度</param>
    /// <param name="Value">資料值</param>
    /// <returns>DBCB屬性</returns>
    public static DataAccess.Data.Schema.Attribute GetDataAccessAttribute(string ColumnName, string DBTypeName, int Length, object Value)
    {
        switch (DataAccess.Data.configuration.DBConnectionType)
        {
            case DataAccess.Data.configuration.ConnectionType.Sybase:
                SybaseColumn SybaseColumn = new SybaseColumn();
                SybaseColumn.AttributeName = ColumnName;
                SybaseColumn.ColumnType = (Sybase.Data.AseClient.AseDbType)(Enum.Parse(typeof(Sybase.Data.AseClient.AseDbType), DBTypeName, true));
                if (Length != 0)
                    SybaseColumn.ColumnLength = Length;
                SybaseColumn.ColumnValue = Value;
                return SybaseColumn;
            default:
                SQLColumn SQLColumn = new SQLColumn();
                SQLColumn.AttributeName = ColumnName;
                SQLColumn.ColumnType = (SqlDbType)(Enum.Parse(typeof(SqlDbType), DBTypeName, true));
                if (Length != 0)
                    SQLColumn.ColumnLength = Length;
                SQLColumn.ColumnValue = Value;
                return SQLColumn;
        }
    }

    /// <summary>
    /// 載入組織部門人員資料至參數檔
    /// </summary>
    public static void LoadOrganizationToBaseConfiguration()
    {
        DbCommandBuilder dbcb = new DbCommandBuilder("Select * From Base_Org.dbo.V_SubCompany Where Convert(bit,IsNull(canceled,0)) = 0 Order By showorder Asc");

        DataTable SubCompanyDT = CommonDB.ExecuteSelectQuery(dbcb);

        dbcb.CommandText = "Select * From Base_Org.dbo.V_Employee ";

        DataTable AccountDT = CommonDB.ExecuteSelectQuery(dbcb);

        List<BasePage.Organization> RootOnlyDepts = new List<BasePage.Organization>();

        List<BasePage.Organization> RootDepts = new List<BasePage.Organization>();

        BasePage.Organization RootOnlyDeptsOrganization = new BasePage.Organization()
        {
            IsRoot = true,
            IsDept = false,
            IsCompany = true,
            IsCanceled = false,
            FullName = (string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_OrganizationRootFullName"),
            icon = "../../../Image/users_folder.png",
            title = (string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_OrganizationRootTitle"),
            key = -1,
            CompanyID = -1,
            CompanyCode = string.Empty,
            CompanyName = string.Empty,
            Code = string.Empty,
            hideCheckbox = false,
            select = false,
            ParentKey = 0,
            ParentCode = string.Empty,
            ParentName = string.Empty,
            children = new List<BasePage.Organization>()
        };

        BasePage.Organization RootOrganization = new BasePage.Organization()
        {
            IsRoot = true,
            IsDept = false,
            IsCompany = true,
            IsCanceled = false,
            FullName = (string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_OrganizationRootFullName"),
            icon = "../../../Image/users_folder.png",
            title = (string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_OrganizationRootTitle"),
            key = -1,
            CompanyID = -1,
            CompanyCode = string.Empty,
            CompanyName = string.Empty,
            Code = string.Empty,
            hideCheckbox = false,
            select = false,
            ParentKey = 0,
            ParentCode = string.Empty,
            ParentName = string.Empty,
            children = new List<BasePage.Organization>()
        };

        RootOnlyDepts.Add(RootOnlyDeptsOrganization);

        RootDepts.Add(RootOrganization);

        foreach (DataRow R in SubCompanyDT.Rows)
        {
            BasePage.Organization SubCompanyOrganization = new BasePage.Organization()
            {
                IsRoot = false,
                IsDept = false,
                IsCompany = true,
                IsCanceled = false,
                FullName = RootOnlyDeptsOrganization.title + "/" + HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(R["subcompanyname"].ToString().Trim())),
                icon = "../../../Image/users_folder.png",
                title = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(R["subcompanyname"].ToString().Trim())),
                key = (int)R["id"],
                CompanyID = (int)R["id"],
                CompanyCode = R["subcompanycode"].ToString().Trim(),
                CompanyName = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(R["subcompanyname"].ToString().Trim())),
                Code = R["subcompanycode"].ToString().Trim(),
                hideCheckbox = false,
                select = false,
                ParentKey = RootOnlyDeptsOrganization.key,
                ParentCode = RootOnlyDeptsOrganization.Code,
                ParentName = RootOnlyDeptsOrganization.title,
                children = new List<BasePage.Organization>()
            };

            BasePage.Organization SubCompanyOrganization2 = new BasePage.Organization()
            {
                IsRoot = false,
                IsDept = false,
                IsCompany = true,
                IsCanceled = false,
                FullName = RootOnlyDeptsOrganization.title + "/" + HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(R["subcompanyname"].ToString().Trim())),
                icon = "../../../Image/users_folder.png",
                title = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(R["subcompanyname"].ToString().Trim())),
                key = (int)R["id"],
                CompanyID = (int)R["id"],
                CompanyCode = R["subcompanycode"].ToString().Trim(),
                CompanyName = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(R["subcompanyname"].ToString().Trim())),
                Code = R["subcompanycode"].ToString().Trim(),
                hideCheckbox = false,
                select = false,
                ParentKey = RootOnlyDeptsOrganization.key,
                ParentCode = RootOnlyDeptsOrganization.Code,
                ParentName = RootOnlyDeptsOrganization.title,
                children = new List<BasePage.Organization>()
            };

            RootOnlyDeptsOrganization.children.Add(SubCompanyOrganization);

            RootOrganization.children.Add(SubCompanyOrganization2);

            dbcb = new DbCommandBuilder("Select * From Base_Org.dbo.GetFullSubDeptByCompanyID(@CompanyID)");

            dbcb.appendParameter(GetDataAccessAttribute("CompanyID", "int", 0, R["id"]));

            DataTable DeptDT = CommonDB.ExecuteSelectQuery(dbcb);

            AddDeptData(DeptDT, SubCompanyOrganization);

            AddDeptAndEmpData(DeptDT, AccountDT, SubCompanyOrganization2);
        }

        BaseConfiguration.OrganizationDeptList = RootOnlyDepts;

        BaseConfiguration.OrganizationDeptAndEmpList = RootDepts;
    }

    /// <summary>
    /// 指定部門資料和上層組織資料建構部門集合(只有部門而已)
    /// </summary>
    /// <param name="DeptDT">部門資料</param>
    /// <param name="Parent">上層組織資料</param>
    private static void AddDeptData(DataTable DeptDT, BasePage.Organization Parent = null)
    {
        int ParentDeptID = 0;

        if (Parent != null && Parent.key > -1 && !Parent.IsCompany)
            ParentDeptID = Parent.key;

        var RootDept = DeptDT.AsEnumerable().Where(Row => (int)Row["ParentDeptID"] == ParentDeptID);

        List<BasePage.Organization> Depts = new List<BasePage.Organization>();

        foreach (DataRow Row in RootDept)
        {
            BasePage.Organization O = new BasePage.Organization()
            {
                IsRoot = (Parent == null),
                IsDept = true,
                IsCompany = false,
                IsCanceled = Row["canceled"].ToString().ToBoolean(),
                FullName = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(Row["DeptFullName"].ToString().Replace(Row["CompanyName"].ToString().Trim() + "/", "").Trim())),
                icon = "../../../Image/users_folder.png",
                title = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(Row["DeptName"].ToString().Trim())),
                key = (int)Row["DeptID"],
                CompanyID = (int)Row["CompanyID"],
                CompanyCode = Row["CompanyCode"].ToString().Trim(),
                CompanyName = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(Row["CompanyName"].ToString().Trim())),
                Code = Row["DeptCode"].ToString().Trim(),
                hideCheckbox = false,
                select = false,
                ParentKey = (Parent == null) ? 0 : Parent.key,
                ParentCode = (Parent == null) ? string.Empty : Parent.Code,
                ParentName = (Parent == null) ? string.Empty : Parent.title,
                children = (Parent == null) ? null : new List<BasePage.Organization>()
            };

            if (O.IsCanceled)
                O.title += (string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_OrganizationDeptCanceledTitle");

            Depts.Add(O);

            if (DeptDT.AsEnumerable().Where(SRow => (int)SRow["ParentDeptID"] == O.key).Count() > 0)
                AddDeptData(DeptDT, O);

            if (Parent != null)
                Parent.children = Depts;
        }
    }

    /// <summary>
    /// 指定部門資料和上層組織資料及人員資料建構部門加人員集合(有部門也有人)
    /// </summary>
    /// <param name="DeptDT">部門資料</param>
    /// <param name="AccountDT">人員資料</param>
    /// <param name="Parent">上層資料</param>
    private static void AddDeptAndEmpData(DataTable DeptDT, DataTable AccountDT, BasePage.Organization Parent = null)
    {
        int ParentDeptID = 0;

        if (Parent != null && Parent.key > -1 && !Parent.IsCompany)
            ParentDeptID = Parent.key;

        var RootDept = DeptDT.AsEnumerable().Where(Row => (int)Row["ParentDeptID"] == ParentDeptID);

        List<BasePage.Organization> Depts = new List<BasePage.Organization>();

        foreach (DataRow Row in RootDept)
        {
            BasePage.Organization O = new BasePage.Organization()
            {
                IsRoot = (Parent == null),
                IsDept = true,
                IsCompany = false,
                IsCanceled = Row["canceled"].ToString().ToBoolean(),
                FullName = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(Row["DeptFullName"].ToString().Replace(Row["CompanyName"].ToString().Trim() + "/", "").Trim())),
                icon = "../../../Image/users_folder.png",
                title = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(Row["DeptName"].ToString().Trim())),
                key = (int)Row["DeptID"],
                hideCheckbox = false,
                select = false,
                CompanyID = (int)Row["CompanyID"],
                CompanyCode = Row["CompanyCode"].ToString().Trim(),
                CompanyName = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(Row["CompanyName"].ToString().Trim())),
                Code = Row["DeptCode"].ToString().Trim(),
                ParentKey = (Parent == null) ? 0 : Parent.key,
                ParentCode = (Parent == null) ? string.Empty : Parent.Code,
                ParentName = (Parent == null) ? string.Empty : Parent.title
            };

            if (O.IsCanceled)
                O.title += (string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_OrganizationDeptCanceledTitle");

            O.children = AddEmpData(AccountDT, O);

            Depts.Add(O);

            if (DeptDT.AsEnumerable().Where(SRow => (int)SRow["ParentDeptID"] == O.key).Count() > 0)
                AddDeptAndEmpData(DeptDT, AccountDT, O);

            if (Parent != null && Parent.children == null)
                Parent.children = Depts;
            else if (Parent != null && Parent.children != null)
                Parent.children.Add(O);
        }
    }
    /// <summary>
    /// 指定人員資料和上層資料建構人員物件
    /// </summary>
    /// <param name="AccountDT">人員資料</param>
    /// <param name="PO">上層資料</param>
    /// <returns>人員物件</returns>
    private static List<BasePage.Organization> AddEmpData(DataTable AccountDT, BasePage.Organization Parent)
    {
        if (!Parent.IsDept && !Parent.IsCompany)
            return new List<BasePage.Organization>();

        var RootAccount = AccountDT.AsEnumerable().Where(Row => (int)Row["departmentid"] == Parent.key);

        List<BasePage.Organization> Lists = new List<BasePage.Organization>();

        foreach (DataRow Row in RootAccount)
        {
            BasePage.Organization O = new BasePage.Organization()
            {
                IsRoot = false,
                IsDept = false,
                IsCompany = false,
                IsCanceled = false,
                FullName = Parent.FullName + "/" + HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(Row["lastname"].ToString().Trim())),
                icon = "../../../Image/user.png",
                title = HttpUtility.HtmlDecode(System.Text.RegularExpressions.Regex.Unescape(Row["lastname"].ToString().Trim())),
                key = (int)Row["id"],
                Code = Row["workcode"].ToString().Trim(),
                CompanyID = Parent.CompanyID,
                CompanyCode = Parent.CompanyCode,
                CompanyName = Parent.CompanyName,
                Status = Row["status"].ToString().Trim(),
                hideCheckbox = false,
                select = false,
                children = null,
                ParentKey = Parent.key,
                ParentCode = (Parent == null) ? string.Empty : Parent.Code,
                ParentName = (Parent == null) ? string.Empty : Parent.title,
                ManagerID = (int)Row["managerid"]
            };

            if (O.Status == "5")
                O.title += (string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_OrganizationLeaveAccountTitle");

            Lists.Add(O);
        }

        return Lists;
    }

    /// <summary>
    /// 指定CodeType得到T_Code的CodeID、CodeName資料表
    /// </summary>
    /// <param name="CodeType">CodeType</param>
    /// <returns>CodeID、CodeName資料表</returns>
    public static DataTable GetCodeTypeData(string CodeType)
    {
        string Query = @"Select CodeID,CodeName From T_Code Where CodeType = @CodeType And UICulture = @UICulture";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_Code"];

        dbcb.appendParameter(Schema.Attributes["UICulture"].copy(System.Threading.Thread.CurrentThread.CurrentUICulture.Name));

        dbcb.appendParameter(Schema.Attributes["CodeType"].copy(CodeType));

        return CommonDB.ExecuteSelectQuery(dbcb);
    }

    /// <summary>
    /// 指定控制項將指定CodeType資料載入
    /// </summary>
    /// <param name="DDL">DropDownList控制項</param>
    /// <param name="CodeType">CodeType</param>
    /// <param name="IsNeedFirstEmptyItem">是否要有第一個請選擇Item</param>
    public static void LoadDDLData(DropDownList DDL, string CodeType = "", bool IsNeedFirstEmptyItem = true)
    {
        DataTable DT = GetCodeTypeData(!string.IsNullOrEmpty(CodeType) ? CodeType : DDL.Attributes["DataCodeType"]);

        DDL.DataValueField = "CodeID";

        DDL.DataTextField = "CodeName";

        DDL.DataSource = DT;

        DDL.DataBind();

        if (IsNeedFirstEmptyItem)
            DDL.Items.Insert(0, new ListItem((string)HttpContext.GetGlobalResourceObject("GlobalRes", "Str_DropDownListDefaultText"), string.Empty));
    }

    /// <summary>
    /// 指定物件轉成可以擴充的物件
    /// </summary>
    /// <param name="obj">轉換物件</param>
    /// <returns></returns>
    public static dynamic ConvertToDynamic(object obj)
    {
        IDictionary<string, object> result = new ExpandoObject();

        foreach (PropertyDescriptor pro in TypeDescriptor.GetProperties(obj.GetType()))
        {
            result.Add(pro.Name, pro.GetValue(obj));
        }

        return result as ExpandoObject;

    }
    /// <summary>
    /// 將字串裝換行(\r\n)轉為Html換行符號字串
    /// </summary>
    /// <param name="ValueString">來源字串</param>
    /// <returns>Html換行符號字串</returns>
    public static string ToHtmlNewLine(this string ValueString)
    {
        return ValueString.Replace(@"\r\n", "<br>").Replace(Environment.NewLine, "<br>");
    }


    /// <summary>
    /// 轉換為預設文化特性簡短日期格式字串
    /// </summary>
    /// <param name="Now">日期物件</param>
    /// <returns>文化特性簡短日期格式字串</returns>
    public static string ToCurrentUICultureString(this DateTime Now)
    {
        if (Now.Year < 1911)
            return string.Empty;

        return Now.ToString("d", System.Threading.Thread.CurrentThread.CurrentUICulture);
    }

    /// <summary>
    /// 轉換為預設文化特性完整日期格式字串
    /// </summary>
    /// <param name="Now">日期物件</param>
    /// <returns>文化特性完整日期格式字串</returns>
    public static string ToCurrentUICultureStringTime(this DateTime Now)
    {
        if (Now.Year < 1911)
            return string.Empty;

        return Now.ToString("G", System.Threading.Thread.CurrentThread.CurrentUICulture);
    }

    /// <summary>
    /// 轉換為預設表示格式字串 (yyyy/MM/dd)
    /// </summary>
    /// <param name="Now">日期物件</param>
    /// <param name="FrmatString">格式字串表示式</param>
    /// <returns></returns>
    public static string ToDefaultString(this DateTime Now, string FrmatString = "")
    {
        if (Now.Year < 1911)
            return string.Empty;
        if (string.IsNullOrEmpty(FrmatString))
            return Now.ToString("yyyy/MM/dd");
        else
            return Now.ToString(FrmatString);
    }

    /// <summary>
    /// 轉換為預設表示日期時間字串 (yyyy/MM/dd HH:mm:ss)
    /// </summary>
    /// <param name="Now">日期物件</param>
    /// <returns>日期時間字串</returns>
    public static string ToDefaultStringTime(this DateTime Now)
    {
        if (Now.Year < 1911)
            return string.Empty;

        return Now.ToString("yyyy/MM/dd HH:mm:ss");
    }

    /// <summary>
    /// 轉換為中華民國日期字串
    /// </summary>
    /// <param name="dateTime"></param>
    /// <returns></returns>
    public static string ToStringTaiwanCalendar(this DateTime dateTime, string format = "")
    {
        if (string.IsNullOrEmpty(format))
            format = "yyyy/MM/dd";

        DateTime now = dateTime;
        System.Globalization.TaiwanCalendar tc = new System.Globalization.TaiwanCalendar();
        System.Text.RegularExpressions.Regex regex = new System.Text.RegularExpressions.Regex(@"[yY]+");
        format = regex.Replace(format, tc.GetYear(dateTime).ToString("000"));
        return dateTime.ToString(format);
    }

    /// <summary>
    /// 指定型別得到該物件是否為數值型物件
    /// </summary>
    /// <param name="type">型別</param>
    /// <returns>是否為數值型物件</returns>
    public static bool IsNumericType(this Type type)
    {
        switch (Type.GetTypeCode(type))
        {
            case TypeCode.UInt16:
            case TypeCode.UInt32:
            case TypeCode.UInt64:
            case TypeCode.Int16:
            case TypeCode.Int32:
            case TypeCode.Int64:
            case TypeCode.Decimal:
            case TypeCode.Double:
            case TypeCode.Single:
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 指定字串得到該字串是否為數值型別
    /// </summary>
    /// <param name="NumericString">數值字串</param>
    /// <returns>是否為數值型別字串</returns>
    public static bool IsNumericType(this string NumericString)
    {
        double Result;

        return double.TryParse(NumericString, out Result);
    }

    /// <summary>
    /// 將文字轉成JavaScript可Alert文字
    /// </summary>
    /// <param name="MessageString">欲轉換可Alert文字</param>
    /// <returns>可Alert文字</returns>
    public static string ToAlertMessageString(this string MessageString)
    {
        return MessageString.Replace("\"", "").Replace("@", "").Replace("\r\n", "\n").Replace("\n", "\\n").Replace("'", "");
    }
    /// <summary>
    /// 轉換為布林值的值(0或1)
    /// </summary>
    /// <param name="BL">域轉換的布林值</param>
    /// <returns>0或1</returns>
    public static string ToStringValue(this bool BL)
    {
        if (BL) return "1";
        else return "0";
    }

    /// <summary>
    /// 將邏輯值的指定字串表示轉換為它的相等的 System.Boolean。傳回值會指出轉換是成功或是失敗。
    /// </summary>
    /// <param name="value">包含要轉換的值。</param>
    /// <param name="result">如果轉換成功，則當 value 等於 System.Boolean.TrueString，這個方法會傳回 true；若 value 等於 System.Boolean.FalseString，則傳回 false。若轉換失敗，則包含 false。若 value 為 null，或不等於 System.Boolean.TrueString 或 System.Boolean.FalseString，則轉換失敗。這個參數以未初始化的狀態傳遞。</param>
    /// <returns>如果 value 轉換成功，則為 true，否則為 false。</returns>
    public static bool BoolTryParse(object value, out bool result)
    {
        value = (value ?? "").ToString().Trim().ToUpper();
        switch ((string)value)
        {
            case "TRUE":
            case "T":
            case "YES":
            case "Y":
                result = true;
                return true;
            case "FALSE":
            case "F":
            case "NO":
            case "N":
                result = false;
                return true;
            default:
                double number;
                if (double.TryParse((string)value, out number))
                {
                    result = (number != 0);
                    return true;
                }
                result = false;
                return false;
        }
    }

    /// <summary>
    /// 轉換為布林值
    /// </summary>
    /// <param name="BoolString"></param>
    /// <returns></returns>
    public static bool ToBoolean(this string BooleanString)
    {
        if (string.IsNullOrEmpty(BooleanString))
            return false;
        switch (BooleanString.ToLower())
        {
            case "1":
            case "true":
            case "yes":
            case "ok":
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// 轉換為Base64字串
    /// </summary>
    /// <param name="FromString">轉換字串</param>
    /// <returns>Base64字串</returns>
    public static string ToBase64String(this string FromString, bool IsUrlTokenEncode = false)
    {
        if (!string.IsNullOrEmpty(FromString))
        {
            if (IsUrlTokenEncode)
                return HttpServerUtility.UrlTokenEncode(System.Text.Encoding.UTF8.GetBytes(FromString));
            else
                return Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(FromString));
        }
        else
            return string.Empty;
    }

    /// <summary>
    /// 將Base64轉為字串
    /// </summary>
    /// <param name="FromBase64String">Base64字串</param>
    /// <returns>字串</returns>
    public static string ToStringFromBase64(this string FromBase64String, bool UrlTokenDecode = false)
    {
        if (!string.IsNullOrEmpty(FromBase64String))
        {
            byte[] Bytes;
            if (UrlTokenDecode)
                Bytes = HttpServerUtility.UrlTokenDecode(FromBase64String);
            else
                Bytes = Convert.FromBase64String(FromBase64String);

            return System.Text.Encoding.UTF8.GetString(Bytes);
        }
        else
            return string.Empty;
    }

    /// <summary>
    /// 轉為MD5字串
    /// </summary>
    /// <param name="FromString">轉換字串</param>
    /// <returns>MD5字串</returns>
    public static string ToMD5String(this string FromString)
    {
        using (MD5 md5 = MD5.Create())
        {
            byte[] inputBytes = System.Text.Encoding.UTF8.GetBytes(FromString);
            byte[] hashBytes = md5.ComputeHash(inputBytes);

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < hashBytes.Length; i++)
            {
                sb.Append(hashBytes[i].ToString("X2"));
            }
            return sb.ToString();
        }
    }
    /// <summary>
    /// 指定頁面及訊息字串和是否為html格式註冊該頁面RegisterStartupScript
    /// </summary>
    /// <param name="Page">頁面物件</param>
    /// <param name="MessageString">訊息字串</param>
    /// <param name="CloseEventString">關閉視窗後事件函式</param>
    /// <param name="IsHtmlElement">是否為html格式</param>
    /// <param name="TitleBarText">抬頭顯示文字</param>
    /// <param name="ButtonsText">按鈕文字</param>
    /// <param name="IsInParent">是否於父視窗中顯示</param>
    public static void RegisterStartupScriptJqueryAlert(System.Web.UI.Page Page, string MessageString, bool IsHtmlElement = true, bool IsInParent = false, string CloseEventString = "", string TitleBarText = "", string ButtonsText = "")
    {
        string strScript = "<script>";

        strScript += "$(function(){";

        if (IsInParent)
            strScript += "parent.";

        strScript += "$.AlertMessage({IsHtmlElement:" + IsHtmlElement.ToStringValue() + ",Message: \"" + MessageString.Replace(System.Environment.NewLine, string.Empty) + "\"";

        if (!string.IsNullOrEmpty(TitleBarText))
            strScript += ",TitleBarText:\"" + TitleBarText + "\"";

        if (!string.IsNullOrEmpty(ButtonsText))
            strScript += ",ButtonsText:\"" + ButtonsText + "\"";

        if (!string.IsNullOrEmpty(CloseEventString))
            strScript += ",CloseEvent: function () {" + CloseEventString + "}";

        strScript += "});})</script>";

        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "AlertMessage", strScript);
    }

    /// <summary>
    /// 指定欲壓縮檔案清單及壓縮後檔案位置或壓縮密碼和註解執行壓縮檔案
    /// </summary>
    /// <param name="ZipSourceFiles">欲壓縮檔案清單</param>
    /// <param name="ZipResultFullPath">壓縮後檔案位置</param>
    /// <param name="Password">壓縮密碼</param>
    /// <param name="Comment">註解</param>
    public static void ZipFiles(List<FileInfo> ZipSourceFiles, string ZipResultFullPath, string Password = "", string Comment = "")
    {
        ZipFile Zip = new ZipFile(Encoding.UTF8);

        if (!string.IsNullOrEmpty(Password))
            Zip.Password = Password;
        if (!string.IsNullOrEmpty(Comment))
            Zip.Comment = Comment;

        foreach (FileInfo File in ZipSourceFiles)
        {
            Zip.AddFile(File.FullName, string.Empty);//第二個參數設為空值表示壓縮檔案時不將檔案路徑加入
        }
        Zip.Save(ZipResultFullPath);
        Zip.Dispose();
    }

    /// <summary>
    /// 指定來源壓縮檔案及解壓縮後目錄或解壓縮密碼執行解壓縮檔案
    /// </summary>
    /// <param name="ZipSourceFile">來源壓縮檔案</param>
    /// <param name="UnZipFolder">解壓縮後目錄</param>
    /// <param name="Password">解壓縮密碼</param>
    public static void UnZipFiles(FileInfo ZipSourceFile, DirectoryInfo UnZipFolder, string Password = "")
    {
        ZipFile Zip = ZipFile.Read(ZipSourceFile.FullName);

        if (!string.IsNullOrEmpty(Password))
            Zip.Password = Password;

        foreach (ZipEntry ZE in Zip)
        {
            ZE.Extract(UnZipFolder.FullName, ExtractExistingFileAction.OverwriteSilently);
        }
        Zip.Dispose();
    }

    /// <summary>
    /// 指定目錄及檔案名稱得到儲存路徑(Full Path)
    /// </summary>
    /// <param name="di">目錄</param>
    /// <param name="FileName">檔案名稱(含副檔名)</param>
    /// <returns>儲存路徑(Full Path)</returns>
    public static string GetSaveFileName(DirectoryInfo di, string FileName)
    {
        string Result = di.FullName + @"\" + Path.GetFileNameWithoutExtension(Path.GetRandomFileName()) + Path.GetExtension(FileName);

        if (File.Exists(Result))
            return GetSaveFileName(di, FileName);
        else
            return Result;
    }

    /// <summary>
    /// 取得暫存資料夾資訊
    /// </summary>
    /// <returns>資料夾資訊</returns>
    public static DirectoryInfo GetTempDirectory()
    {
        string RootFolderPath = HttpContext.Current.Server.MapPath(@"~\" + BaseConfiguration.TempFolderPath);

        if (!string.IsNullOrEmpty(RootFolderPath) && !Directory.Exists(RootFolderPath))
            Directory.CreateDirectory(RootFolderPath);

        if (!Directory.Exists(RootFolderPath))
        {
            if (!Directory.Exists(HttpContext.Current.Server.MapPath(RootFolderPath)))
                Directory.CreateDirectory(HttpContext.Current.Server.MapPath(RootFolderPath));
            RootFolderPath = HttpContext.Current.Server.MapPath(@"~\" + BaseConfiguration.TempFolderPath + "");
        }

        if (!string.IsNullOrEmpty(RootFolderPath) && !RootFolderPath.EndsWith(@"\"))
            RootFolderPath += @"\";

        //宣告亂數
        Random R = new Random();
        //在同一個時間內去取得亂數可能會同一個，所以sleep一下
        System.Threading.Thread.Sleep(200);
        //暫存資料夾位置
        string Path = RootFolderPath += System.IO.Path.GetRandomFileName();
        if (!Path.EndsWith(@"\"))
            Path += @"\";
        //資料夾是否存在，存在的話需重新產生
        if (Directory.Exists(Path))
            return GetTempDirectory();
        else
            return Directory.CreateDirectory(Path);
    }

    /// <summary>
    /// 指定資料夾在暫存資料夾下新增子資料夾
    /// </summary>
    /// <param name="DI">資料夾物件</param>
    /// <param name="Path">建立資料夾名稱</param>
    /// <returns>資料夾資訊</returns>
    public static DirectoryInfo GetTempDirectory(DirectoryInfo DI, string PathName)
    {
        if (DI == null)
            DI = GetTempDirectory();

        string Path = DI.FullName;
        if (!string.IsNullOrEmpty(PathName))
        {
            Path = Path + PathName;
            if (Directory.Exists(Path))
                Directory.Delete(Path, true);
            return DI.CreateSubdirectory(Path);
        }
        else
            return DI;
    }

    /// <summary>
    /// 指定郵件收件者地址清單、郵件主旨、郵件內容發送郵件
    /// </summary>
    /// <param name="MailAddressList">郵件收件者地址清單</param>
    /// <param name="MailSubject">郵件主旨</param>
    /// <param name="htmlView">郵件內容</param>
    public static void SendMail(List<string> MailAddressList, string MailSubject, AlternateView htmlView)
    {
        MailMessage Message = new MailMessage();

        Message.BodyEncoding = Encoding.UTF8;

        Message.SubjectEncoding = Encoding.UTF8;

        Message.From = new MailAddress(BaseConfiguration.SmtpMailFrom.Trim(), "MESC");

        Message.Subject = MailSubject;

        Message.AlternateViews.Add(htmlView);

        Message.IsBodyHtml = true;

        foreach (string MA in MailAddressList)
        {
            if (!string.IsNullOrEmpty(MA))
                Message.To.Add(new MailAddress(MA.Trim()));
        }

        using (SmtpClient client = new SmtpClient(BaseConfiguration.SmtpServer.Trim(), 587))
        {
            System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;

            if (!string.IsNullOrEmpty(BaseConfiguration.SmtpAccount.Trim()) && !string.IsNullOrEmpty(BaseConfiguration.SmtpPWD.Trim()))
                client.Credentials = new System.Net.NetworkCredential(BaseConfiguration.SmtpAccount.Trim(), BaseConfiguration.SmtpPWD.Trim());

            client.TargetName = "STARTTLS/smtp.office365.com";

            client.EnableSsl = true;

            client.Send(Message);
        }
    }

    /// <summary>
    /// 指定郵件收件者地址清單、郵件主旨、郵件內容發送郵件
    /// </summary>
    /// <param name="MailAddressList">郵件收件者地址清單</param>
    /// <param name="MailSubject">郵件主旨</param>
    /// <param name="MailBody">郵件內容</param>
    public static void SendMail(List<string> MailAddressList, string MailSubject, string MailBody)
    {
        AlternateView htmlView = AlternateView.CreateAlternateViewFromString(MailBody, System.Text.UTF8Encoding.UTF8, "text/html");

        SendMail(MailAddressList, MailSubject, htmlView);
    }

    /// <summary>
    /// 路由類別
    /// </summary>
    public static class RouteUtils
    {
        /// <summary>
        /// 指定路由URL的到路由資料
        /// </summary>
        /// <param name="url"路由型式的URL</param>
        /// <returns>路由資料</returns>
        public static System.Web.Routing.RouteData GetRouteDataByUrl(string url)
        {
            return System.Web.Routing.RouteTable.Routes.GetRouteData(new RewritedHttpContextBase(url));
        }

        private class RewritedHttpContextBase : HttpContextBase
        {
            private readonly HttpRequestBase mockHttpRequestBase;

            public RewritedHttpContextBase(string appRelativeUrl)
            {
                this.mockHttpRequestBase = new MockHttpRequestBase(appRelativeUrl);
            }


            public override HttpRequestBase Request
            {
                get
                {
                    return mockHttpRequestBase;
                }
            }

            private class MockHttpRequestBase : HttpRequestBase
            {
                private readonly string appRelativeUrl;

                public MockHttpRequestBase(string appRelativeUrl)
                {
                    this.appRelativeUrl = appRelativeUrl;
                }

                public override string AppRelativeCurrentExecutionFilePath
                {
                    get { return appRelativeUrl; }
                }

                public override string PathInfo
                {
                    get { return ""; }
                }
            }
        }
    }


    #region 案號型別(Object_ID_Type)
    public static class SerialObject
    {
        /// <summary>
        /// 文號狀態列舉
        /// </summary>
        public enum FolderID_State : short
        {
            空號 = 0,
            使用中,
            銷號
        }

        /// <summary>
        /// 案號型別
        /// </summary>
        public class Object_ID_Type
        {
            internal short 案號型別代碼;        //ObjectID_TypeID
            internal string 案號型別名稱;       //ObjectID_TypeName
            internal short 案號型別非序號長度;
            internal string 案號型別表示式;     //ObjectID_Format
            internal bool 是否自動跳號;         //AutoJump
            internal string 案號型別非序號 = string.Empty;     //ObjectID_LikeStr

            internal Object_ID_Type(short ObjectID_TypeID, string ObjectID_TypeName, string ObjectID_Format, bool AutoJump)
            {
                案號型別代碼 = ObjectID_TypeID;
                案號型別名稱 = ObjectID_TypeName;

                #region 取得案號型別非序號長度

                string filter_ObjectID_Format = ObjectID_Format.Replace("'", string.Empty);
                int TotalLenth = filter_ObjectID_Format.Length;
                char[] ObjectIDCharArray = filter_ObjectID_Format.ToCharArray();

                for (int i = (ObjectIDCharArray.Length - 1); i >= 0; i--)
                {
                    if (ObjectIDCharArray[i].ToString().ToUpper() != "S")
                    {
                        案號型別非序號長度 = short.Parse((i + 1).ToString());
                        break;
                    }
                }

                #endregion

                案號型別表示式 = ObjectID_Format;
                是否自動跳號 = AutoJump;
            }

            internal Object_ID_Type()
            {
                案號型別代碼 = 0;
                案號型別名稱 = string.Empty;
                案號型別非序號長度 = 0;
                案號型別表示式 = string.Empty;
                是否自動跳號 = false;
            }

            private void formatting(ref string strformat, int length)
            {
                strformat = strformat.Trim();

                if (strformat.Length < length)
                {
                    int ZeroCount = length - strformat.Length;
                    for (int i = 0; i < ZeroCount; i++)
                    {
                        strformat = "0" + strformat;
                    }
                }
                else
                {
                    strformat = strformat.Substring((strformat.Length - length), length);
                }
            }

            private string SpecialStr(char Meaning, int length, DateTime paraDateTime)
            {
                string StrReturn;

                switch (Meaning)
                {
                    case 'Y':
                        int TempInt = (paraDateTime.Year - 1911);
                        StrReturn = TempInt.ToString().Trim();
                        break;
                    case 'y':
                        StrReturn = paraDateTime.Year.ToString().Trim();
                        break;
                    case 'M':
                    case 'm':
                        StrReturn = paraDateTime.Month.ToString().Trim();
                        break;
                    case 'D':
                    case 'd':
                        StrReturn = paraDateTime.Day.ToString().Trim();
                        break;
                    default:
                        StrReturn = string.Empty;
                        break;
                }

                this.formatting(ref StrReturn, length);

                return StrReturn;
            }

            private string 取得案號型別非序號(ref int SerialNoLength, DateTime paraDateTime)
            {
                return _取得案號型別非序號(ref SerialNoLength, paraDateTime);
            }

            private string 取得案號型別非序號(ref int SerialNoLength)
            {
                return _取得案號型別非序號(ref SerialNoLength, DateTime.Now);
            }

            private string _取得案號型別非序號(ref int SerialNoLength, DateTime paraDateTime)
            {
                string strReturn = string.Empty;

                char[] ArrObjectID_Format = 案號型別表示式.ToCharArray();

                bool IsPreserve = false;
                int CurrentCharLength = 1;

                for (int i = 0; i < ArrObjectID_Format.Length; i++)
                {
                    if (IsPreserve)
                    {
                        if (ArrObjectID_Format[i] == '\'')
                        {
                            IsPreserve = false;
                        }
                        else
                        {
                            strReturn += ArrObjectID_Format[i];
                        }
                    }
                    else
                    {
                        if (ArrObjectID_Format[i] == '\'')
                        {
                            IsPreserve = true;
                        }
                        else
                        {
                            if (ArrObjectID_Format[i] == 'S' || ArrObjectID_Format[i] == 's') SerialNoLength++;
                            else
                            {
                                if (ArrObjectID_Format[i] == ArrObjectID_Format[(i + 1)])
                                {
                                    CurrentCharLength++;
                                }
                                else
                                {
                                    strReturn = strReturn + this.SpecialStr(ArrObjectID_Format[i], CurrentCharLength, paraDateTime);
                                    CurrentCharLength = 1;
                                }
                            }
                        }
                    }
                }

                return strReturn;
            }

            internal string InsertSQL
            {
                get
                {
                    return "Insert into T_SYS_ObjectID_Type(ObjectID_TypeID,ObjectID_TypeName,ObjectID_Format,AutoJump) values (" + 案號型別代碼 + ",N'" + 案號型別名稱.Replace("'", "''") + "',N'" + 案號型別表示式.Replace("'", "''") + "','" + 是否自動跳號.ToStringValue() + "')";
                }
            }

            private static short GetObjectIDFromPreserveSubString(string PreserveSubString, int StartIndex, int Length)
            {
                string MinID = DataAccess.Data.CommonDB.ExecuteSelectQuery("SELECT MIN(ObjectID_TypeID) FROM T_SYS_ObjectID_Type WHERE (SUBSTRING(REPLACE(ObjectID_Format, '''', ''), " + (StartIndex + 1) + ", " + Length + ") = '" + PreserveSubString + "') AND (ObjectID_TypeID > - 1)").Rows[0][0].ToString().Trim();
                if (MinID.Length == 0) return -1;
                else return short.Parse(MinID);
            }

            internal static int GetNextObjectID_TypeID()
            {
                string MaxID = DataAccess.Data.CommonDB.ExecuteSelectQuery("SELECT MAX(ObjectID_TypeID) FROM T_SYS_ObjectID_Type WHERE (ObjectID_TypeID > - 1)").Rows[0][0].ToString().Trim();
                if (MaxID.Length == 0) return 0;
                else return (int.Parse(MaxID) + 1);
            }

            public string 取號()
            {
                return this.SQLClient_GETObject_ID();
            }

            public string 取號(DateTime paraDataTime)
            {
                return this.SQLClient_GETObject_ID(paraDataTime);
            }

            public void 用號(string SetObject_ID, FolderID_State ChangeState)
            {
                DataAccess.Data.CommonDB.ExecuteSingleCommand(UpadteStateSQL(SetObject_ID, ChangeState));
            }

            private string SQLClient_GETObject_ID(DateTime paraDataTime)
            {
                return _SQLClient_GETObject_ID(paraDataTime);
            }

            private string SQLClient_GETObject_ID()
            {
                return _SQLClient_GETObject_ID(DateTime.Now);
            }

            private string _SQLClient_GETObject_ID(DateTime paraDataTime)
            {
                string Object_ID = string.Empty;
                string SerialNumber = string.Empty;
                int SerialNumberLength = 0;

                Object_ID = this.取得案號型別非序號(ref SerialNumberLength, paraDataTime);

                DataAccess.Data.DbCommandBuilder DbCB = new DataAccess.Data.DbCommandBuilder();
                DbCB.DbCommandType = CommandType.StoredProcedure;

                if (是否自動跳號) DbCB.CommandText = "GetObject_ID_Jump";
                else DbCB.CommandText = "GetObject_ID_NotJump";

                DbCB.appendParameter(GetDataAccessAttribute("ObjectID_LikeStr", "NVarChar", 50, Object_ID));

                DbCB.appendParameter(GetDataAccessAttribute("ObjectID_TypeID", "SmallInt", 50, 案號型別代碼));

                SerialNumber = ((int)(DataAccess.Data.CommonDB.ExecuteScalar(DbCB))).ToString().Trim();

                this.formatting(ref SerialNumber, SerialNumberLength);

                return Object_ID + SerialNumber;
            }

            internal string UpadteStateSQL(string SetObject_ID, FolderID_State ChangeState)
            {
                string ObjectID_LikeStr = SetObject_ID.Substring(0, 案號型別非序號長度);
                int ObjectID_SerialNo = int.Parse(SetObject_ID.Substring(案號型別非序號長度, (SetObject_ID.Length - 案號型別非序號長度)));

                return "Update T_SYS_ObjectID_List SET ObjectID_State=" + (short)ChangeState + " where ObjectID_LikeStr='" + ObjectID_LikeStr + "' and ObjectID_SerialNo=" + ObjectID_SerialNo + " and ObjectID_TypeID=" + 案號型別代碼;
            }
        }

        /// <summary>
        /// 所有案號型別的集合
        /// </summary>
        public class Object_ID_TypeCollection : System.Collections.CollectionBase
        {
            /// <summary>
            /// 建構所有案號型別的集合
            /// </summary>
            public Object_ID_TypeCollection()
            {
                foreach (DataRow Object_ID_TypeRow in DataAccess.Data.CommonDB.ExecuteSelectQuery("SELECT ObjectID_TypeID,ObjectID_TypeName,ObjectID_Format,AutoJump FROM T_SYS_ObjectID_Type").Rows)
                {
                    Object_ID_Type NewObject_ID_Type = new Object_ID_Type(short.Parse(Object_ID_TypeRow["ObjectID_TypeID"].ToString()), Object_ID_TypeRow["ObjectID_TypeName"].ToString().Trim(), Object_ID_TypeRow["ObjectID_Format"].ToString().Trim(), Object_ID_TypeRow["AutoJump"].ToString().ToBoolean());
                    this.Add(NewObject_ID_Type);
                }
            }

            /// <summary>
            /// 在集合中新增案號型別
            /// </summary>
            /// <param name="item">案號型別(Object_ID_Type 物件)</param>
            /// <returns>在集合中的索引</returns>
            internal int Add(Object_ID_Type item)
            {
                return List.Add(item);
            }

            public short SynAdd(string ObjectID_TypeName, string ObjectID_Format, bool AutoJump)
            {
                int ObjectTypeID = Object_ID_Type.GetNextObjectID_TypeID();
                Object_ID_Type NewObject_ID_Type = new Object_ID_Type(short.Parse(ObjectTypeID.ToString()), ObjectID_TypeName, ObjectID_Format, AutoJump);
                if (DataAccess.Data.CommonDB.ExecuteSingleCommand(NewObject_ID_Type.InsertSQL))
                {
                    this.Add(NewObject_ID_Type);
                    return short.Parse(ObjectTypeID.ToString());
                }
                else return -1;
            }

            public short SynAdds(Object_ID_Type[] NewObject_ID_Types)
            {
                int ObjectTypeID = Object_ID_Type.GetNextObjectID_TypeID();
                string[] InsertQueries = new string[NewObject_ID_Types.Length];

                for (int i = 0; i < NewObject_ID_Types.Length; i++)
                {
                    if (NewObject_ID_Types[i].案號型別代碼 == -100) NewObject_ID_Types[i].案號型別代碼 = short.Parse((ObjectTypeID + i).ToString());
                    InsertQueries[i] = NewObject_ID_Types[i].InsertSQL;
                }

                if (DataAccess.Data.CommonDB.ExecuteMultiCommand(InsertQueries))
                {
                    for (int j = 0; j < NewObject_ID_Types.Length; j++)
                    {
                        this.Add(NewObject_ID_Types[j]);
                    }

                    if (NewObject_ID_Types.Length > 0) return short.Parse(ObjectTypeID.ToString());
                    else return -1;
                }
                else return -1;
            }

            /// <summary>
            /// 插入案號型別,必要實作的Method,但是用不到
            /// </summary>
            /// <param name="index">索引</param>
            /// <param name="item">案號型別(Object_ID_Type 物件)</param>
            private void Insert(int index, Object_ID_Type item)
            {
                List.Insert(index, item);
            }

            /// <summary>
            /// 從集合中移除案號型別
            /// </summary>
            /// <param name="item">案號型別(Object_ID_Type 物件)</param>
            internal void Remove(Object_ID_Type item)
            {
                List.Remove(item);
            }

            /// <summary>
            /// 是否包含該案號型別,必要實作的Method,但是用不到
            /// </summary>
            /// <param name="item">案號型別(Object_ID_Type 物件)</param>
            /// <returns>是否包含</returns>
            private bool Contains(Object_ID_Type item)
            {
                return List.Contains(item);
            }

            /// <summary>
            /// 是否包含該案號型別
            /// </summary>
            // <param name="ObjectID_TypeID">案號型別代碼</param>
            /// <returns>是否包含</returns>
            public bool Contains(short ObjectID_TypeID)
            {
                int SearchPatientComment_Class = this.IndexOf(ObjectID_TypeID);

                if (SearchPatientComment_Class == -1) return false;
                else return true;
            }

            /// <summary>
            /// 從集合中尋找指定的案號型別物件的索引,必要實作的Method,但是用不到
            /// </summary>
            /// <param name="item">案號型別(Object_ID_Type 物件)</param>
            /// <returns>索引</returns>
            private int IndexOf(Object_ID_Type item)
            {
                return List.IndexOf(item);
            }

            /// <summary>
            /// 從集合中尋找指定的案號型別代碼的索引
            /// </summary>
            /// <param name="ObjectID_TypeID">案號型別代碼</param>
            /// <returns>索引</returns>
            public int IndexOf(short ObjectID_TypeID)
            {
                for (int i = 0; i < this.Count; i++)
                {
                    if (this[i].案號型別代碼 == ObjectID_TypeID) return i;
                }
                return -1;
            }
            /// <summary>
            /// 從集合中尋找指定的案號型別名稱的索引
            /// </summary>
            /// <param name="ObjectID_TypeName">案號型別名稱</param>
            /// <returns>索引</returns>
            public int IndexOf(string ObjectID_TypeName)
            {
                for (int i = 0; i < this.Count; i++)
                {
                    if (this[i].案號型別名稱 == ObjectID_TypeName) return i;
                }
                return -1;
            }

            /// <summary>
            /// 複製成案號型別(Object_ID_Type類別)陣列
            /// </summary>
            /// <param name="array">被指定的案號型別陣列</param>
            /// <param name="index">起始索引</param>
            public void CopyTo(Object_ID_Type[] array, int index)
            {
                List.CopyTo(array, index);
            }
            /// <summary>
            /// 指定索引值得到案號型別
            /// </summary>
            /// <param name="index">索引值</param>
            /// <returns>案號型別物件</returns>
            public Object_ID_Type this[int index]
            {
                get
                {
                    return (Object_ID_Type)List[index];
                }
                set
                {
                    List[index] = value;
                }
            }

            /// <summary>
            /// 指定案號型別代碼得到案號型別
            /// </summary>
            /// <param name="ObjectID_TypeID">案號型別代碼</param>
            /// <returns>案號型別物件</returns>
            public Object_ID_Type this[short ObjectID_TypeID]
            {
                get
                {
                    int index = this.IndexOf(ObjectID_TypeID);
                    return (Object_ID_Type)List[index];
                }
            }
            /// <summary>
            /// 指定案號型別名稱得到案號型別
            /// </summary>
            /// <param name="ObjectID_TypeName">案號型別名稱</param>
            /// <returns>案號型別物件</returns>
            public Object_ID_Type this[string ObjectID_TypeName]
            {
                get
                {
                    int index = this.IndexOf(ObjectID_TypeName);
                    return (Object_ID_Type)List[index];
                }
            }
        }
    }
    #endregion

}

