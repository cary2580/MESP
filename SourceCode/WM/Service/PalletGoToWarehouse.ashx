<%@ WebHandler Language="C#" Class="PalletGoToWarehouse" %>

using System;
using System.Web;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using DataAccess.Data;
using DataAccess.Data.Schema;

public class PalletGoToWarehouse : BasePage
{
    protected string PalletNo = string.Empty;
    protected string Operator = string.Empty;
    protected string LGORT = string.Empty;
    protected string DeliveryLocation = string.Empty;

    public override void ProcessRequest(HttpContext context)
    {
        try
        {
            base.processRequest(context, false);

            if (_context.Request["PalletNo"] != null)
                PalletNo = _context.Request["PalletNo"].Trim();

            if (_context.Request["Operator"] != null)
                Operator = _context.Request["Operator"].Trim();

            if (_context.Request["LGORT"] != null)
                LGORT = _context.Request["LGORT"].Trim();

            if (_context.Request["DeliveryLocation"] != null)
                DeliveryLocation = _context.Request["DeliveryLocation"].Trim();

            if (string.IsNullOrEmpty(PalletNo))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Empty_PalletNo"));

            if (string.IsNullOrEmpty(Operator))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkCode"));

            if (string.IsNullOrEmpty(LGORT))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Empty_LGORT"));

            AccountID = BaseConfiguration.GetAccountID(Operator);

            if (AccountID < 1 || !BaseConfiguration.GetAccountIDIsActivity(AccountID))
                throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_AccountID"));

            CheckRule();

            string NewPalletNo = GoToAction();

            ResponseSuccessData(new { PalletNo = NewPalletNo });
        }
        catch (Exception ex)
        {
            ResponseErrorData(ex);
        }
    }

    /// <summary>
    /// 檢查規則
    /// </summary>
    protected void CheckRule()
    {
        string Query = @"Select * From T_WMProductPalletTemp Where PalletNo = @PalletNo And CreateAccountID = @CreateAccountID";

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPalletTemp"];

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo));

        dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));

        DataTable DT = CommonDB.ExecuteSelectQuery(dbcb);

        EnumerableRowCollection<DataRow> DataRows = DT.AsEnumerable();

        if (DataRows.Count() < 1)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_ScanBoxNo"));

        var MATNRList = DT.AsEnumerable().GroupBy(Row => Row["MATNR"].ToString().Trim()).Select(item => item.Key).ToList();

        if (MATNRList.Count() > 1)
            throw new CustomException((string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_Error_PalletDifferentMATNR"));
    }

    /// <summary>
    /// 確認入庫
    /// </summary>
    /// <returns>入庫後棧板號</returns>
    protected string GoToAction()
    {
        DateTime CreateDateTime = DateTime.Now;

        string NewPalletNo = BaseConfiguration.SerialObject[(short)28].取號();

        ObjectSchema Schema = DBSchema.currentDB.Tables["T_WMProductPallet"];

        DBAction DBA = new DBAction();

        string Query = @"Insert Into T_WMProductPallet 
                         Select Distinct
                            @NewPalletNo As PalletNo,
                            MATNR,
                            Case
                                When Exists((Select Top 1 MAKTX From T_TSSAPMAPL Where T_TSSAPMAPL.MATNR = T_WMProductPalletTemp.MATNR)) Then (Select Top 1 MAKTX From T_TSSAPMAPL Where T_TSSAPMAPL.MATNR = T_WMProductPalletTemp.MATNR)
                                Else T_WMProductPalletTemp.MATNR
                            End As MAKTX,
                            @LGORT,
	                        (Select Sum(Qty) From T_WMProductPalletTemp As PPT Where PPT.PalletNo = T_WMProductPalletTemp.PalletNo) As Qty,
                            @DeliveryLocationID As DeliveryLocationID,
	                        Convert(bit,0) As IsConfirm,
	                        @CreateAccountID As CreateAccountID,
	                        @CreateDateTime As CreateDate
                        From T_WMProductPalletTemp
                        Where PalletNo = @OldPalletNo";

        DbCommandBuilder dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(NewPalletNo, "NewPalletNo"));

        dbcb.appendParameter(Schema.Attributes["LGORT"].copy(LGORT));

        dbcb.appendParameter(Schema.Attributes["DeliveryLocationID"].copy(DeliveryLocation));

        dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(CreateDateTime, "CreateDateTime"));

        dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo, "OldPalletNo"));

        DBA.AddCommandBuilder(dbcb);

        Query = @"Insert Into T_WMProductBox 
                    Select 
	                    BoxNo,
	                    @NewPalletNo As PalletNo,
	                    Qty,
	                    PackageQty,
                        '' As PackingID,
	                    @CreateAccountID,
	                    @CreateDateTime As CreateDate
                    From T_WMProductPalletTemp
                    Where PalletNo = @OldPalletNo";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(NewPalletNo, "NewPalletNo"));

        dbcb.appendParameter(Schema.Attributes["CreateAccountID"].copy(AccountID));

        dbcb.appendParameter(Schema.Attributes["CreateDate"].copy(CreateDateTime, "CreateDateTime"));

        dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo, "OldPalletNo"));

        DBA.AddCommandBuilder(dbcb);

        Query = @"Select 
	                BoxNo,
	                Row_Number() Over (Partition By BoxNo Order By Brand) As RowNumber,
	                (Select item From Base_Org.dbo.Split(Brand,'|') Where IndexKey = 1) As TicketID,
	                (Select item From Base_Org.dbo.Split(Brand,'|') Where IndexKey = 2) As Brand,
                    (Select item From Base_Org.dbo.Split(Brand,'|') Where IndexKey = 3) As VERID,
	                (Select item From Base_Org.dbo.Split(Brand,'|') Where IndexKey = 4) As TEXT1,
                    (Select item From Base_Org.dbo.Split(Brand,'|') Where IndexKey = 5) As CINFO,
	                Sum(Qty) As Qty
                Into #TempResult
                From (
		                Select
			                T_WMProductBoxByTicket.BoxNo,
			                --有刻字號就找刻字號，如果沒有就帶SAP批次號
			                Case
				                When IsNull((Select Top 1 Brand From V_TSTicketResult Where V_TSTicketResult.TicketID = T_WMProductBoxByTicket.TicketID And IsNull(Brand,'') <> ''),'') <> '' Then
					                (Select Top 1 TicketID + '|' + Brand + '|' + VERID + '|' + TEXT1 + '|' + CINFO From V_TSTicketResult Where V_TSTicketResult.TicketID = T_WMProductBoxByTicket.TicketID And Brand <> '' Order By CreateDate Desc)
                                Else 
									-- 没刻字号，但是有半成品批号的，取半成品批号
									(Select Top 1 TicketID + '|' + 
										Case 
											When IsNull(SEMIFINBATCH,'') = '' Then CHARG 
											Else SEMIFINBATCH
										End + '|' + VERID + '|' + TEXT1 + '|' + CINFO 
									From V_TSTicketResult Where V_TSTicketResult.TicketID = T_WMProductBoxByTicket.TicketID  Order By CreateDate Desc)
			                End As Brand,
			                T_WMProductBoxByTicket.Qty
		                From T_WMProductPalletTemp Inner Join T_WMProductBoxByTicket On T_WMProductPalletTemp.BoxNo = T_WMProductBoxByTicket.BoxNo
		                Where PalletNo = @OldPalletNo
	                ) As TempResult
                    Where IsNull(TempResult.Brand,'') <> ''
                Group By BoxNo,Brand;

                Select Brand,CHARG,VERID,CreateDate Into #TicketResult From V_TSTicketResult Where V_TSTicketResult.Brand In (Select Brand From #TempResult);

                Select * 
                ,SubString(Result.VERID,2,LEN(Result.VERID) - 1) As VERID_S,
                (Select Min(CreateDate) From #TicketResult Where Brand = Result.Brand And #TicketResult.VERID <> ''
                And SubString(#TicketResult.VERID,2,LEN(#TicketResult.VERID) - 1) = SubString(Result.VERID,2,LEN(Result.VERID) - 1)) As CreateDate
                Into #Brand
                From (
	                Select #TicketResult.Brand, VERID 
	                From #TicketResult Where #TicketResult.Brand In (Select Brand From #TempResult)
	                Group By #TicketResult.Brand, VERID
                ) As Result;
                    
                Select 
						BoxNo,
						RowNumber,
						TicketID,
						Brand,
                        '' As CHARG,
						VERID,
						VERID_S,
						TEXT1,
                        CINFO,
						CreateDate,
						Qty,
                        0 CHARGQty,
                        '' As CHARGLGORT
				Into #Result
				From (
					 Select 
						#TempResult.*,
						Case
							When IsNull((Select Count(*) From #Brand),0) > 0 Then
								#Brand.VERID_S
                            When IsNull(#TempResult.VERID,'') <> '' Then
                                SubString(#TempResult.VERID,2,LEN(#TempResult.VERID) - 1)
							Else
								''
						End As VERID_S,
						Case
							When IsNull((Select Count(*) From #Brand),0) > 0 Then
								#Brand.CreateDate
							Else
								GetDate()
						End As CreateDate
					From #TempResult	
					Left Join #Brand On #TempResult.Brand = #Brand.Brand And #TempResult.VERID = #Brand.VERID
				) As Result;

                Update #Result Set CreateDate = (Select Min(CreateDate) From #Result As R Where R.BoxNo = #Result.BoxNo);

                Insert Into T_WMProductBoxBrand Select * From #Result;";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo, "OldPalletNo"));

        DBA.AddCommandBuilder(dbcb);

        Query = @"Update T_WMPendingBox Set T_WMPendingBox.IsGoToWarehouse = 1
                  From T_WMProductPalletTemp Inner Join T_WMPendingBox On T_WMProductPalletTemp.BoxNo = T_WMPendingBox.BoxNo
                  Where T_WMProductPalletTemp.PalletNo = @OldPalletNo";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo, "OldPalletNo"));

        DBA.AddCommandBuilder(dbcb);

        Query = @"Delete T_WMProductPalletTemp Where PalletNo = @OldPalletNo";

        dbcb = new DbCommandBuilder(Query);

        dbcb.appendParameter(Schema.Attributes["PalletNo"].copy(PalletNo, "OldPalletNo"));

        DBA.AddCommandBuilder(dbcb);

        DBA.Execute();

        return NewPalletNo;
    }

    public new bool IsReusable
    {
        get
        {
            return false;
        }
    }

}