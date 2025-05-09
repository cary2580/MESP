<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="ProductionInspection.aspx.cs" Inherits="TimeSheet_ProductionInspection" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#BT_Create").click(function () {
                OpenInspectionPage("", "");
            });

            $("#BT_Search").click(function () {
                if ($("#<%=TB_TicketID.ClientID%>").val() == "" && $("#<%=TB_CreateDateStart.ClientID%>").val() == "" && $("#<%=TB_CreateDateEnd.ClientID%>").val() == "" && $("#<%=DDL_InspectionResult.ClientID%>").val() == "" && $("#<%=TB_TEXT1.ClientID%>").val() == "") {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredOneAlertMessage")%>" });

                    event.preventDefault();

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/ProductionInspectionGetList.ashx")%>",
                    timeout: 300 * 1000,
                    data: {
                        TicketID: $("#<%=TB_TicketID.ClientID%>").val(),
                        CreateDateStart: $("#<%=TB_CreateDateStart.ClientID%>").val(),
                        CreateDateEnd: $("#<%=TB_CreateDateEnd.ClientID%>").val(),
                        InspectionResult: $("#<%=DDL_InspectionResult.ClientID%>").val(),
                        TEXT1: $("#<%=TB_TEXT1.ClientID%>").val()
                    },
                    CallBackFunction: function (data) {
                        LoadGridData({ JQGridDataValue: data, IsShowJQGridFilterToolbar: true, IsExtendJqGridParameterObject: true });

                        $("#SearchResultListDiv").show();
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#SearchResultListDiv").hide();
                    }
                });
            });

            $("#<%=TB_TicketID.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data) {
                        if (data.A1 == null) {
                            $("#<%=TB_TicketID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_TS_Empty_TicketID")%>" });

                            return;
                        }

                        $("#<%=TB_TicketID.ClientID%>").val(data.A2);

                        //OpenInspectionPage("", data.A2);
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_TicketID.ClientID%>").val("");
                    }
                });

            }).focus();
        });

        function JqEventBind(PO) {

            if (PO.TableID != JqGridParameterObject.TableID)
                return;

            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {

                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === PO.JQGridDataValue.ColumnClassesName) {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");

                    var PIID = "";

                    if ($.inArray(PO.JQGridDataValue.PIIDColumnName, columnNames) > 0)
                        PIID = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.PIIDColumnName);

                    if (PIID != "")
                        OpenInspectionPage(PIID, "");
                }
            });
        }

        function OpenInspectionPage(PIID, TicketID) {
            var FrameID = "ProductionInspection_FrameID";

            if (PIID == "" && TicketID == "") {
                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/ProductionInspection_Create.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_ProductionInspection_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 720,
                    height: 660,
                    NewWindowPageDivID: "ProductionInspection_DivID",
                    NewWindowPageFrameID: FrameID
                });
            }
            else {
                var UploadParameters = {};

                if (PIID != "")
                    UploadParameters.PIID = PIID;
                if (TicketID != "")
                    UploadParameters.TicketID = TicketID;

                $.OpenPage({
                    iFrameOpenParameters: UploadParameters,
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/ProductionInspection_M.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_ProductionInspection_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 1080,
                    height: 860,
                    NewWindowPageDivID: "ProductionInspection_DivID",
                    NewWindowPageFrameID: FrameID,
                    TitleBarCloseButtonTriggerCloseEvent: true,
                    CloseEvent: function (result) {
                        if ($.StringConvertBoolean($(result).find("#" + FrameID).contents().find("#HF_IsRefresh").val()))
                            $("#BT_Search").trigger("click");
                    }
                });
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="col-xs-3 form-group">
        <label for="<%= TB_TicketID.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNR%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
    </div>
    <div class="col-xs-2 form-group">
        <label for="<%= TB_CreateDateStart.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateStart %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_CreateDateStart" runat="server" CssClass="form-control DateTimeDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-2 form-group">
        <label for="<%= TB_CreateDateEnd.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateEnd %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_CreateDateEnd" runat="server" CssClass="form-control DateTimeDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-2 form-group">
        <label for="<%= DDL_InspectionResult.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_InspectionResult%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_InspectionResult" runat="server" CssClass="form-control">
        </asp:DropDownList>
    </div>
    <div class="col-xs-3 form-group">
        <label for="<%= TB_TEXT1.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TEXT1%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_TEXT1" runat="server" CssClass="form-control"></asp:TextBox>
    </div>
    <div class="col-xs-12">
        <input id="BT_Search" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_Search") %>" class="btn btn-warning" />
        <input id="BT_Create" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName") %>" class="btn btn-primary" />
    </div>
    <div class="col-xs-12">
        <p></p>
        <div id="SearchResultListDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
