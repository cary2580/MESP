<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="ProductionInspection_M.aspx.cs" Inherits="TimeSheet_ProductionInspection_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        var SerialNoColumnName = "";

        $(function ()
        {
            $("#<%=BT_DeleteAllData.ClientID%>").hide();

            $("textarea,input[type='text']:not(#<%=TB_InspectionDate.ClientID%>)").val("");

            $(".MumberType").val("0");

            LoadNGList();
        });

        function LoadNGList()
        {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/ProductionInspectionNGItemGetList.ashx")%>",
                data: { PIID: $("#<%=HF_PIID.ClientID%>").val() },
                CallBackFunction: function (data)
                {
                    SerialNoColumnName = data.SerialNoColumnName;

                    LoadGridData({ JQGridDataValue: data, IsShowJQGridFilterToolbar: true, IsMultiSelect: true, IsExtendJqGridParameterObject: true  });

                    if (data.Rows.length < 1)
                        $("#<%=BT_Delete.ClientID%>").addClass("disabled");

                    $("#ResultListDiv").show();
                },
                ErrorCallBackFunction: function (data)
                {
                    $("#ResultListDiv").hide();
                }
            });
        }

        function JqEventBind(PO)
        {
            if (PO.TableID != JqGridParameterObject.TableID)
                return;

            $("#" + PO.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === PO.JQGridDataValue.ColumnClassesName)
                {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var SerialNo = "";                   

                    SerialNoColumnName = PO.JQGridDataValue.SerialNoColumnName;

                    if ($.inArray(SerialNoColumnName, columnNames) > 0)
                        SerialNo = $(this).jqGrid("getCell", RowID, SerialNoColumnName);

                    if (SerialNo != "")
                    {
                        $("#<%=HF_SerialNo.ClientID%>").val(SerialNo);

                        $("#<%=TB_NGQty.ClientID%>").val($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.NGQtyColumnName));
                        $("#<%=TB_InspectionDate.ClientID%>").val($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.InspectionDateColumnName));
                        $("#<%=TB_TraceQty.ClientID%>").val($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.TraceQtyColumnName));
                        $("#<%=TB_DefectQty.ClientID%>").val($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.DefectQtyColumnName));
                        $("#<%=TB_ReferenceNumber.ClientID%>").val($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.ReferenceNumberColumnName));
                        $("#<%=TB_HandlingMethods.ClientID%>").val($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.HandlingMethodsColumnName));
                        $("#<%=TB_Remark.ClientID%>").val($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.RemarkColumnName));
                    }
                }
            });
        }

        function CheckDelete(BTO)
        {
            if ($(BTO).hasClass("disabled"))
                return false;

            var SelectCBKArrayID = new Array();

            var GridTable = $("#" + JqGridParameterObject.TableID);

            var rowKey = GridTable.jqGrid("getGridParam", "selrow");

            if (!rowKey)
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });
                return false;
            }

            var ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

            $.each(GridTable.getGridParam("selarrrow"), function (i, item)
            {
                var SerialNo = "";

                if ($.grep(ColumnModel, function (Node) { return Node.name == SerialNoColumnName; }).length > 0)
                    SerialNo = GridTable.jqGrid("getCell", item, SerialNoColumnName);

                if (SerialNo != "")
                    SelectCBKArrayID.push(SerialNo);
            });

            $("#<%=HF_SerialNo.ClientID%>").val(SelectCBKArrayID.join("|"));

            return true;
        }

        function CheckRequired(BTO)
        {
            if ($("#<%=TB_WorkCode.ClientID%>").val() == "" || ("<%=BT_Save.ClientID%>" != BTO.id && parseInt($("#<%=TB_NGQty.ClientID%>").val()) < 1) || $("#<%=TB_InspectionDate.ClientID%>").val() == "")
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_RequiredAlertMessage") %>" });
                return false;
            }
            return true;
        }

        function Print()
        {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_016.ashx")%>",
                data: { TicketID: $("#<%=HF_TicketID.ClientID%>").val() },
                timeout: 300 * 1000,
                CallBackFunction: function (data)
                {
                    if (data.Result && data.GUID != null)
                    {
                        if ($.ispAad())
                            window.open("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                        else
                            OpenWindowDownloadFile("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                    }
                }
            });
        }

        function DeleteConfirmMessage()
        {
            $.ConfirmMessage({
                Message: "<%=(string)GetLocalResourceObject("Str_DeleteConfirmMessage")%>", IsHtmlElement: true, CloseEvent: function (Result)
                {
                    if (!Result)
                        event.preventDefault();
                    else
                        $("#<%=BT_DeleteAllData.ClientID%>").trigger("click");
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_PIID" runat="server" />
    <asp:HiddenField ID="HF_TicketID" runat="server" />
    <asp:HiddenField ID="HF_SerialNo" runat="server" />
    <asp:HiddenField ID="HF_IsRefresh" runat="server" ClientIDMode="Static" />
    <div class="col-xs-12 form-group">
        <asp:Button ID="BT_Save" runat="server" Text="<%$ Resources:Str_BT_Save%>" CssClass="btn btn-primary" OnClick="BT_Save_Click" OnClientClick="if(!CheckRequired(this)){return false;}" UseSubmitBehavior="false" />
        <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:Str_BT_CreateNG%>" CssClass="btn btn-success" OnClick="BT_Submit_Click" OnClientClick="if(!CheckRequired(this)){return false;}" UseSubmitBehavior="false" />
        <asp:Button ID="BT_Print" runat="server" Text="<%$ Resources:Str_BT_Print%>" CssClass="btn btn-info" OnClientClick="Print(); return false;" UseSubmitBehavior="false" />
        <input id="BT_DeleteData" type="button" runat="server" value="<%$ Resources:Str_BT_Delete%>" class="btn btn-danger" onclick="DeleteConfirmMessage();" />
        <asp:Button ID="BT_DeleteAllData" runat="server" Text="<%$ Resources:Str_BT_Delete%>" CssClass="btn btn-danger" OnClick="BT_DeleteAllData_Click" UseSubmitBehavior="false" />
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCode%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_NGQty.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_NGQty%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_NGQty" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_InspectionDate.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_InspectionDate %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_InspectionDate" runat="server" CssClass="form-control DateTimeDatepicker readonly"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_TraceQty.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TraceQty%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_TraceQty" runat="server" CssClass="form-control MumberType" required="required" Text="0"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_DefectQty.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DefectQty%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_DefectQty" runat="server" CssClass="form-control MumberType" required="required" Text="0"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_ReferenceNumber.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ReferenceNumber%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_ReferenceNumber" runat="server" CssClass="form-control"></asp:TextBox>
    </div>
    <div class="col-xs-6 form-group">
        <label for="<%= TB_HandlingMethods.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_HandlingMethods%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_HandlingMethods" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
    </div>
    <div class="col-xs-6 form-group">
        <label for="<%= TB_Remark.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Remark%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_Remark" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
    </div>
    <div class="col-xs-12">
        <p></p>
        <div id="ResultListDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor13") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_ResultList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName%>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" OnClientClick="if(!CheckDelete(this)){return false;}" UseSubmitBehavior="false" />
                <p></p>
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
