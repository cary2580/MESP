<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="TicketCreate.aspx.cs" Inherits="TimeSheet_TicketCreate" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            /* 如果已經上崗就預設帶已上崗的工號 */
            $("#<%=TB_WorkCode.ClientID%>").val($.cookie("TS_WorkCode"));

            $("#<%=TB_ScanAUFNR.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                var AUFNR = $(this).val();

                if (AUFNR == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/MOWaitInfo.ashx")%>",
                    data: { AUFNR: AUFNR },
                    timeout: 300 * 1000,
                    CallBackFunction: function (data) {
                        $("#MOInfoDiv").show();

                        $("#<%=TB_ScanAUFNR.ClientID%>").val("");

                        $("#<%=TB_AUFNR.ClientID%>").val(data.MOInfo.AUFNR);

                        $("#<%=TB_AUART.ClientID%>").val(data.MOInfo.AUARTName);
                        $("#<%=TB_VERID.ClientID%>").val(data.MOInfo.VERID);
                        $("#<%=TB_PLNBEZ.ClientID%>").val(data.MOInfo.PLNBEZ);
                        $("#<%=TB_MAKTX.ClientID%>").val(data.MOInfo.MAKTX);
                        $("#<%=TB_CINFO.ClientID%>").val(data.MOInfo.CINFO);
                        $("#<%=TB_CHARG.ClientID%>").val(data.MOInfo.CHARG);
                        $("#<%=TB_ZEINR.ClientID%>").val(data.MOInfo.ZEINR);
                        $("#<%=TB_FERTH.ClientID%>").val(data.MOInfo.FERTH);
                        $("#<%=TB_PLNNR.ClientID%>").val(data.MOInfo.PLNNR);
                        $("#<%=TB_PLNAL.ClientID%>").val(data.MOInfo.PLNAL);
                        $("#<%=TB_KTEXT.ClientID%>").val(data.MOInfo.KTEXT);
                        $("#<%=TB_PSMNG.ClientID%>").val(data.MOInfo.PSMNG);
                        $("#<%=TB_FTRMI.ClientID%>").val(data.MOInfo.FTRMI);
                        $("#<%=TB_GSTRP.ClientID%>").val(data.MOInfo.GSTRP);
                        $("#<%=TB_GLTRP.ClientID%>").val(data.MOInfo.GLTRP);

                        $("#<%=TB_TicketBox.ClientID%>").val(data.MOInfo.MaxTicketBox).trigger("change");

                        $("#<%=TB_TicketBoxQty.ClientID%>").val(data.MOInfo.MaxTicketBoxQty).trigger("change");

                        $("#<%=TB_WorkCode.ClientID%>").focus();

                        LoadGridData({
                            IsShowJQRowNumbers: false,
                            JQGridDataValue: data.OperationList,
                            IsShowJQGridPager: data.OperationList.IsShowJQGridPager
                        });
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#MOInfoDiv").hide();
                        $("#<%=TB_AUFNR.ClientID%>").focus();
                    }
                });
            }).focus();

            $("#<%=TB_ScanMachineID.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                var MachineID = $(this).val();

                if (MachineID == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: MachineID },
                    CallBackFunction: function (data) {
                        if (data.A4 == null || data.A5 == null) {
                            $("#<%=TB_ScanMachineID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=GetLocalResourceObject("Str_Error_DeviceID")%>" });

                            return;
                        }

                        $("#<%=TB_ScanMachineID.ClientID%>").val(data.A5);
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_ScanMachineID.ClientID%>").val("");
                    }
                });
            });

            $("#<%=TB_LastTicketBoxQty.ClientID%>,#<%=TB_TicketBox.ClientID%>,#<%=TB_TicketBoxQty.ClientID%>").change(function () {

                if ($(this).prop("id") != "<%=TB_LastTicketBoxQty.ClientID%>") {

                    let MOQty = parseInt($("#<%=TB_PSMNG.ClientID%>").val());

                    let TempTicketBoxQty = parseInt($("#<%=TB_TicketBox.ClientID%>").val()) * parseInt($("#<%=TB_TicketBoxQty.ClientID%>").val());

                    if (isNaN(TempTicketBoxQty))
                        return;

                    let LastTicketBoxQty = 0;

                    if (TempTicketBoxQty > MOQty)
                        LastTicketBoxQty = TempTicketBoxQty - parseInt($("#<%=TB_TicketBoxQty.ClientID%>").val()) - MOQty;

                    $("#<%=TB_LastTicketBoxQty.ClientID%>").val(Math.abs(LastTicketBoxQty));
                }

                CalculateTotalQty();
            });

            $("#BT_TicketCreate").click(function () {
                if (!CheckRule()) {
                    event.preventDefault();
                    return;
                }

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_ConfirmMessage")%>", IsHtmlElement: true, CloseEvent: function (Result) {
                        if (!Result) {
                            event.preventDefault();
                            return;
                        }

                        $.Ajax({
                            url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketCreateByAUFNR.ashx")%>",
                            timeout: 600 * 1000,
                            data: {
                                AUFNR: $("#<%=TB_AUFNR.ClientID%>").val(),
                                MachineID: $("#<%=TB_ScanMachineID.ClientID%>").val(),
                                WorkCode: $("#<%=TB_WorkCode.ClientID%>").val(),
                                TicketBox: $("#<%=TB_TicketBox.ClientID%>").val(),
                                TicketBoxQty: $("#<%=TB_TicketBoxQty.ClientID%>").val(),
                                LastTicketBoxQty: $("#<%=TB_LastTicketBoxQty.ClientID%>").val()
                            },
                            CallBackFunction: function () {
                                $("#MOInfoDiv").hide();

                                $("#<%=TB_ScanAUFNR.ClientID%>").focus();

                                /* 下載流程卡 */
                                $.Ajax({
                                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_001.ashx")%>",
                                    data: { AUFNR: $("#<%=TB_AUFNR.ClientID%>").val() },
                                    timeout: 1200 * 1000,
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
                });
            });
        });

        function CheckRule() {
            var ErrorMessage = "";

            if (parseInt($("#<%=TB_TicketBox.ClientID%>").val()) < 1) {
                ErrorMessage = "<%=(string)GetLocalResourceObject("Str_Empty_BoxQty")%>";
                $("#<%=TB_TicketBox.ClientID%>").focus();
            }
            else if (parseInt($("#<%=TB_TicketBoxQty.ClientID%>").val()) < 1) {
                ErrorMessage = "<%=(string)GetLocalResourceObject("Str_Empty_TicketBoxQty")%>";
                $("#<%=TB_TicketBoxQty.ClientID%>").focus();
            }
            else if (parseInt($("#<%=TB_LastTicketBoxQty.ClientID%>").val()) < 0) {
                ErrorMessage = "<%=(string)GetLocalResourceObject("Str_Empty_LastTicketBoxQty")%>";
                $("#<%=TB_LastTicketBoxQty.ClientID%>").focus();
            }
            else if (parseInt($("#<%=TB_LastTicketBoxQty.ClientID%>").val()) > parseInt($("#<%=TB_TicketBoxQty.ClientID%>").val())) {
                ErrorMessage = "<%=(string)GetLocalResourceObject("Str_Error_LastTicketBoxQtyOverTicketBoxQty")%>";
                $("#<%=TB_LastTicketBoxQty.ClientID%>").focus();
            }
            else if ($("#<%=TB_ScanMachineID.ClientID%>").val() == "" && ($("#<%=TB_PLNNR.ClientID%>").val() != "" && $("#<%=TB_PLNAL.ClientID%>").val() != "")) {
                ErrorMessage = "<%=(string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_MachineID")%>";
                $("#<%=TB_ScanMachineID.ClientID%>").focus();
            }

            if (ErrorMessage != "") {
                $.AlertMessage({ Message: ErrorMessage });
                return false;
            }
            else
                return true;
        }

        function CalculateTotalQty() {

            let MOQty = parseInt($("#<%=TB_PSMNG.ClientID%>").val());

            let TempTicketBoxQty = parseInt($("#<%=TB_TicketBox.ClientID%>").val()) * parseInt($("#<%=TB_TicketBoxQty.ClientID%>").val());

            if (isNaN(TempTicketBoxQty))
                return;

            if (TempTicketBoxQty > MOQty)
                TempTicketBoxQty = TempTicketBoxQty - parseInt($("#<%=TB_TicketBoxQty.ClientID%>").val());

            let TotalQty = TempTicketBoxQty + parseInt($("#<%=TB_LastTicketBoxQty.ClientID%>").val());

            $("#<%=TB_TotalQty.ClientID%>").val(TotalQty);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_ScanAUFNR.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_AUFNR %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_ScanAUFNR" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanAUFNR %>"></asp:TextBox>
    </div>
    <div id="MOInfoDiv" style="display: none;">
        <div class="col-xs-12">
            <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                <div class="panel-heading text-center">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MoInfo %>"></asp:Literal>
                </div>
                <div class="panel-body">
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_AUFNR.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNR %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_AUFNR" runat="server" CssClass="form-control readonly readonlyColor"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_PSMNG.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_PSMNG %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PSMNG" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_AUART.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_AUART %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_AUART" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_VERID.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_VERID %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_VERID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_PLNBEZ.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_PLNBEZ %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PLNBEZ" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MAKTX %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_CHARG.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_CHARG%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_CHARG" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_CINFO.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_CINFO%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_CINFO" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_ZEINR.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_ZEINR %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_ZEINR" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_FERTH.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_FERTH %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_FERTH" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_PLNNR.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_PLNNR %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PLNNR" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_PLNAL.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_PLNAL %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PLNAL" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_KTEXT.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_KTEXT %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_KTEXT" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_FTRMI.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_FTRMI %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_FTRMI" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_GSTRP.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_GSTRP %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_GSTRP" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_GLTRP.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_GLTRP %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_GLTRP" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xs-6">
            <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor8") %>">
                <div class="panel-heading text-center">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo %>"></asp:Literal>
                </div>
                <div class="panel-body">
                    <div class="col-xs-6 form-group required">
                        <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_WorkCode %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
                    </div>
                    <div class="col-xs-6 form-group required">
                        <label for="<%= TB_ScanMachineID.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_MachineID %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_ScanMachineID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanMachineID %>"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_TicketBox.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketBox %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TicketBox" runat="server" CssClass="form-control MumberType" required="required"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_TicketBoxQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketBoxQty %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TicketBoxQty" runat="server" CssClass="form-control MumberType" required="required"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_LastTicketBoxQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_LastTicketBoxQty %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_LastTicketBoxQty" runat="server" CssClass="form-control MumberType" required="required"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group">
                        <label for="<%= TB_TotalQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TotalQty %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TotalQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-12 form-group text-center">
                        <input type="button" class="btn btn-primary" id="BT_TicketCreate" value="<%= (string)GetLocalResourceObject("Str_Button_TicketCreate") %>" />
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xs-6">
            <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
                <div class="panel-heading text-center">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_OperationList %>"></asp:Literal>
                </div>
                <div class="panel-body">
                    <div id="JQContainerList"></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
