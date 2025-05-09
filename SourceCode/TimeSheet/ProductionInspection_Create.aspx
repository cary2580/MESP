<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="ProductionInspection_Create.aspx.cs" Inherits="TimeSheet_ProductionInspection_Create" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#<%=HF_AllowQty.ClientID%>").val("3");

            $("#<%=BT_Submit_NoCreateQuarantine.ClientID%>,#<%=BT_Submit_CreateQuarantine.ClientID%>").hide();

            $("#<%=TB_InspectionQty.ClientID%>").addClass("MumberType").val($("#<%=HF_AllowQty.ClientID%>").val());

            $(".MumberType").TouchSpin({
                min: 0,
                max: parseInt($("#<%=HF_AllowQty.ClientID%>").val()),
                decimals: 0
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
                        if (data.A2 == null) {
                            $("#<%=TB_TicketID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_TS_Empty_TicketID")%>" });

                            return;
                        }

                        $("#<%=TB_TicketID.ClientID%>").val(data.A2);

                        if ($("#<%=TB_TicketID.ClientID%>").val() != "" && $("#<%=TB_WorkCode.ClientID%>").val() != "")
                            ExceProductionInspectionGoIn();
                        else
                            $("#<%=TB_WorkCode.ClientID%>").focus();

                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_TicketID.ClientID%>").val("");
                    }
                });
            }).focus();

            $("#<%=TB_WorkCode.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($("#<%=TB_TicketID.ClientID%>").val() != "" && $("#<%=TB_WorkCode.ClientID%>").val() != "")
                    ExceProductionInspectionGoIn();
            });

            $("#BT_Create_NoCreateQuarantine_V").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                if ($("#<%=TB_TicketID.ClientID%>").val() == "" || $("#<%=TB_WorkCode.ClientID%>").val() == "" || parseInt($("#<%=TB_InspectionQty.ClientID%>").val()) < 1) {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    event.preventDefault();

                    return;
                }

                if (parseInt($("#<%=TB_InspectionQty.ClientID%>").val()) < 1) {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_InspectionQtyEmpty")%>" });

                    event.preventDefault();

                    return;
                }
                else if (parseInt($("#<%=TB_InspectionQty.ClientID%>").val()) > parseInt($("#<%=HF_AllowQty.ClientID%>").val())) {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_InspectionQtyOverAllowQty")%>" });

                    event.preventDefault();

                    return;
                }

                $("#<%=HF_IsCreateQuarantine.ClientID%>").val("0");

                $("#<%=BT_Submit_NoCreateQuarantine.ClientID%>").trigger("click");

            });

            $("#BT_Create_CreateQuarantine_V").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                if ($("#<%=TB_TicketID.ClientID%>").val() == "" || $("#<%=TB_WorkCode.ClientID%>").val() == "" || parseInt($("#<%=TB_InspectionQty.ClientID%>").val()) < 1) {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    event.preventDefault();

                    return;
                }

                if (parseInt($("#<%=TB_InspectionQty.ClientID%>").val()) < 1) {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_InspectionQtyEmpty")%>" });

                    event.preventDefault();

                    return;
                }
                else if (parseInt($("#<%=TB_InspectionQty.ClientID%>").val()) > parseInt($("#<%=HF_AllowQty.ClientID%>").val())) {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_InspectionQtyOverAllowQty")%>" });

                    event.preventDefault();

                    return;
                }

                $("#<%=HF_IsCreateQuarantine.ClientID%>").val("1");

                $("#<%=BT_Submit_CreateQuarantine.ClientID%>").trigger("click");

            });

            if ($.StringConvertBoolean($("#<%=HF_IsFinish.ClientID%>").val())) {

                $("#<%=BT_Submit_NoCreateQuarantine.ClientID%>,#<%=BT_Submit_CreateQuarantine.ClientID%>").hide();

                if ($.StringConvertBoolean($("#<%=HF_IsCreateQuarantine.ClientID%>").val()))
                    CreateCreateByQuarantine();
                else
                    PrintTicket("");
            }
        });

        function ExceProductionInspectionGoIn() {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/ProductionInspectionInfoGet.ashx")%>",
                data: {
                    TicketID: $("#<%=TB_TicketID.ClientID%>").val(),
                    CreateWorkCode: $("#<%=TB_WorkCode.ClientID%>").val()
                },
                CallBackFunction: function (data) {
                    $("#<%=TB_AUFNR.ClientID%>").val(data.AUFNR);
                    $("#<%=TB_PLNBEZ.ClientID%>").val(data.PLNBEZ);
                    $("#<%=TB_ZEINR.ClientID%>").val(data.ZEINR);
                    $("#<%=TB_FERTH.ClientID%>").val(data.FERTH);
                    $("#<%=TB_TEXT1.ClientID%>").val(data.TEXT1);
                    $("#<%=TB_CINFO.ClientID%>").val(data.CINFO);
                    $("#<%=TB_CHARG.ClientID%>").val(data.CHARG);
                    $("#<%=TB_Brand.ClientID%>").val(data.Brand);
                    $("#<%=HF_AllowQty.ClientID%>").val(data.TicketQty);

                    $(".MumberType").trigger("touchspin.updatesettings", { max: parseInt($("#<%=HF_AllowQty.ClientID%>").val()) });

                    $("#BT_Create_NoCreateQuarantine_V,#BT_Create_CreateQuarantine_V").removeClass("disabled");
                },
                ErrorCallBackFunction: function (data) {
                    $("#<%=TB_TicketID.ClientID%>").val("");
                }
            });
        }

        function CreateCreateByQuarantine() {

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketCreateByQuarantine.ashx")%>",
                timeout: 300 * 1000,
                data: {
                    TicketID: $("#<%=TB_TicketID.ClientID%>").val(),
                    Qty: $("#<%=HF_QuarantineQty.ClientID%>").val(),
                    QuarantineInfoList: JSON.stringify([{ DefectID: "005003", QuarantineQty: $("#<%=HF_QuarantineQty.ClientID%>").val() }])
                },
                CallBackFunction: function (data) {

                    let NewTicketID = data.NewTicketID;

                    /* 列印流程卡 */
                    $.Ajax({
                        url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_001.ashx")%>",
                        data: { TicketID: JSON.stringify([NewTicketID]) },
                        timeout: 300 * 1000,
                        CallBackFunction: function (data) {

                            if (data.Result && data.GUID != null) {

                                /* 列印隔離品單和下載 */
                                $.Ajax({
                                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_014.ashx")%>",
                                    data: {
                                        TicketID: NewTicketID,
                                        TicketQuarantineGUID: data.GUID
                                    },
                                    timeout: 300 * 1000,
                                    CallBackFunction: function (data) {
                                        PrintTicket(data.GUID);
                                    }
                                });

                            }
                        }
                    });
                },
                ErrorCallBackFunction: function () {
                    DeleteOrder();
                }
            });
        }

        function PrintTicket(TicketGUID) {
            $.AlertMessage({
                Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_CreateSuccessAlertMessage")%>", CloseEvent: function () {
                    $.Ajax({
                        url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_016.ashx")%>",
                        data: {
                            TicketID: $("#<%=TB_TicketID.ClientID%>").val(),
                            TicketQuarantineGUID: TicketGUID
                        },
                        timeout: 300 * 1000,
                        CallBackFunction: function (data) {
                            if (data.Result && data.GUID != null) {
                                if ($.ispAad())
                                    window.open("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                                else
                                    OpenWindowDownloadFile("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                            }
                        }
                    });
                }
            });
        }

        function DeleteOrder() {

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/ProductionInspectionDelete.ashx")%>",
                timeout: 300 * 1000,
                data: { PIID: $("#<%=HF_PIID.ClientID%>").val() }
            });

            $("#<%=TB_TicketID.ClientID%>").val("");
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsFinish" runat="server" Value="0" />
    <asp:HiddenField ID="HF_IsCreateQuarantine" runat="server" />
    <asp:HiddenField ID="HF_QuarantineQty" runat="server" />
    <asp:HiddenField ID="HF_AllowQty" runat="server" Value="3" />
    <asp:HiddenField ID="HF_IsRefresh" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="HF_PIID" runat="server" ClientIDMode="Static" />
    <div class="col-xs-12 form-group">
        <input id="BT_Create_NoCreateQuarantine_V" type="button" value="<%= (string)GetLocalResourceObject("Str_BT_CreateName_NoCreateQuarantine")%>" class="btn btn-warning disabled" />
        <asp:Button ID="BT_Submit_NoCreateQuarantine" runat="server" Text="<%$ Resources:Str_BT_CreateName_NoCreateQuarantine%>" UseSubmitBehavior="false" OnClick="BT_Submit_Click" />

        <input id="BT_Create_CreateQuarantine_V" type="button" value="<%= (string)GetLocalResourceObject("Str_BT_CreateName_CreateQuarantine")%>" class="btn btn-primary disabled" />
        <asp:Button ID="BT_Submit_CreateQuarantine" runat="server" Text="<%$ Resources:Str_BT_CreateName_CreateQuarantine%>" UseSubmitBehavior="false" OnClick="BT_Submit_Click" />
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_TicketID.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketID%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCode%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_InspectionQty.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_InspectionQty%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_InspectionQty" runat="server" CssClass="form-control" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_AUFNR.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNR%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_AUFNR" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_PLNBEZ.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_PLNBEZ%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_PLNBEZ" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_ZEINR.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ZEINR%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_ZEINR" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_CHARG.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_CHARG%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_CHARG" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_Brand.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Brand%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_Brand" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_FERTH.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_FERTH%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_FERTH" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_CINFO.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_CINFO%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_CINFO" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
    </div>
    <div class="col-xs-8 form-group">
        <label for="<%= TB_TEXT1.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TEXT1%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_TEXT1" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
    </div>
</asp:Content>
