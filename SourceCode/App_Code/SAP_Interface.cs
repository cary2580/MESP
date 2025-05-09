using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using RestSharp;
using RestSharp.Authenticators;
using System.Net;
using Newtonsoft.Json;
using System.Data;
using Sap.Data.Hana;

public class SAP
{
    /// <summary>
    ///  SAP呼叫統一回覆類別
    /// </summary>
    public class SAP_CallBackResult
    {
        public string OAFORMID { get; set; }
        public string OARID { get; set; }
        public string OAURL { get; set; }
        public string RESULT { get; set; }
        public string MESSAGE { get; set; }
        public string SAPID { get; set; }
    }

    /// <summary>
    ///  SAP 上傳的Json
    /// </summary>
    public class SAP_PostJson
    {
        public string IvInput = string.Empty;
    }

    /// <summary>
    ///  SAP 上傳的結構物件
    /// </summary>
    public class SAP_PostStructure
    {
        public string CODE = string.Empty;
        public List<SAP_PostJson> np_code2zcommon = new List<SAP_PostJson>();
    }

    /// <summary>
    /// 指定SAP服務位置、Code、上傳的Json資料(沒有就空)
    /// </summary>
    /// <param name="Url">SAP服務位置</param>
    /// <param name="Code">SAP 需要的 Code</param>
    /// <param name="IvInput">上傳的Json資料(沒有就空)</param>
    /// <returns>Post 結果的動態物件</returns>
    public static System.Dynamic.ExpandoObject ExcePost(string Code, string IvInput)
    {
        ServicePointManager.ServerCertificateValidationCallback += (sender, cert, chain, sslPolicyErrors) => true;
        ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12;

        var client = new RestClient(System.Configuration.ConfigurationManager.AppSettings["SAPUrl"].Trim());
        client.Authenticator = new HttpBasicAuthenticator(System.Configuration.ConfigurationManager.AppSettings["SAPLoginAccount"].Trim(), System.Configuration.ConfigurationManager.AppSettings["SAPLoginPWD"].Trim());
        client.Timeout = -1;

        var Request = new RestRequest(Method.POST);
        Request.AddHeader("Content-Type", "application/json");
        Request.AddHeader("X-Requested-With", "X");

        SAP_PostStructure SAPUploadData = new SAP_PostStructure();
        SAPUploadData.CODE = Code;
        SAPUploadData.np_code2zcommon.Add(new SAP_PostJson() { IvInput = IvInput });

        string DataStr = JsonConvert.SerializeObject(SAPUploadData);

        Request.AddParameter("application/json", JsonConvert.SerializeObject(SAPUploadData), ParameterType.RequestBody);
        IRestResponse IR = client.Execute(Request);

        return JsonConvert.DeserializeObject<System.Dynamic.ExpandoObject>(IR.Content);
    }

    /// <summary>
    /// 指定查詢SQL語法得到SAP查詢結果資料表
    /// </summary>
    /// <param name="SelectCommand">查詢SQL語法</param>
    /// <returns>SAP查詢結果資料表</returns>
    public static DataTable GetSelectSAPData(string SelectCommand)
    {
        HanaCommand Command = new HanaCommand();

        Command.CommandText = SelectCommand;

        return GetSelectSAPData(Command);
    }

    /// <summary>
    /// 指定SAPCommand執行得到第一個資料列第一行資料
    /// </summary>
    /// <param name="Command">SAP HanaCommand</param>
    /// <returns>第一個資料列第一行資料</returns>
    public static object GetSelectExecuteScalar(HanaCommand Command)
    {
        HanaConnection Connection = new HanaConnection(global::System.Configuration.ConfigurationManager.ConnectionStrings["HanaConnectionString"].ConnectionString.Trim());

        Command.Connection = Connection;

        object result = null;

        try
        {
            Connection.Open();

            result = Command.ExecuteScalar();
        }
        catch(Exception ex)
        {
            throw ex;
        }
        finally
        {
            Connection.Close();
        }

        return result;
    }

    /// <summary>
    /// 指定SAP HanaCommand 得到查詢資料表
    /// </summary>
    /// <param name="Command">SAP HanaCommand</param>
    /// <returns>查詢資料表</returns>
    public static DataTable GetSelectSAPData(HanaCommand Command)
    {
        HanaConnection Connection = new HanaConnection(global::System.Configuration.ConfigurationManager.ConnectionStrings["HanaConnectionString"].ConnectionString.Trim());

        DataTable ResultTable = new DataTable("ResultTable");

        try
        {
            Command.Connection = Connection;

            HanaDataAdapter DataAdapter = new HanaDataAdapter(Command);

            DataAdapter.Fill(ResultTable);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            Connection.Close();
        }

        return ResultTable;
    }

    /// <summary>
    /// 指定HanaCommand陣列，執行異動指令
    /// </summary>
    /// <param name="CommandList">HanaCommand List</param>
    public static void ExecuteMultiCommand(List<HanaCommand> CommandList)
    {
        HanaCommand HCR = null;

        try
        {
            ExecuteMultiCommand(CommandList, out HCR);

            if (HCR != null)
                HCR.Transaction.Commit();
        }
        catch (Exception ex)
        {
            if (HCR != null)
                HCR.Transaction.Rollback();

            throw ex;
        }
        finally
        {
            if (HCR != null)
                HCR.Connection.Close();
        }
    }

    /// <summary>
    /// 指定HanaCommand陣列、執行異動指令(要非常注意需自行Commit或Rollback並且要Connection.Close)，不然會將Connection用盡。
    /// </summary>
    /// <param name="CommandList">HanaCommandList</param>
    /// <param name="CommandResult">HanaCommand 結果指令，由呼叫端自行決定是否要Commit</param>
    public static void ExecuteMultiCommand(List<HanaCommand> CommandList, out HanaCommand CommandResult)
    {
        if (CommandList.Count == 0)
            CommandResult = null;

        HanaConnection Connection = new HanaConnection(global::System.Configuration.ConfigurationManager.ConnectionStrings["HanaConnectionString"].ConnectionString.Trim());

        Connection.Open();

        HanaTransaction Transaction = Connection.BeginTransaction(HanaIsolationLevel.ReadCommitted);

        CommandResult = Connection.CreateCommand();

        CommandResult.Transaction = Transaction;

        try
        {
            for (int i = 0; i < CommandList.Count; i++)
            {
                CommandResult.CommandText = CommandList[i].CommandText;
                CommandResult.Parameters.Clear();

                if (CommandList[i].Parameters.Count > 0)
                {
                    foreach (HanaParameter HP in CommandList[i].Parameters)
                    {
                        HanaParameter NewHP = new HanaParameter();
                        NewHP.ParameterName = HP.ParameterName;
                        NewHP.Value = HP.Value;
                        CommandResult.Parameters.Add(NewHP);
                    }
                }

                CommandResult.ExecuteNonQuery();
            }
        }
        catch (Exception e)
        {
            throw e;
        }
    }
}
