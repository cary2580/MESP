<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="TicketGoIn.aspx.cs" Inherits="TimeSheet_TicketGoIn" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=TB_TicketID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        if (data.A2 == null)
                        {
                            $("#<%=TB_TicketID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_TicketID")%>" });

                            return;
                        }

                        $("#<%=TB_TicketID.ClientID%>").val(data.A2);

                        $("#<%=TB_MachineID.ClientID%>").focus();

                        if ($("#<%=TB_MachineID.ClientID%>").val() != "" && $("#<%=TB_TicketID.ClientID%>").val() != "")
                            ExecTicketGoIn();
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_TicketID.ClientID%>").val("");
                    }
                });
            }).focus();

            $("#<%=TB_MachineID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        if (data.A4 == null || data.A5 == null)
                        {
                            $("#<%=TB_MachineID.ClientID%>,#<%=TB_MachineName.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=GetLocalResourceObject("Str_Error_DeviceID")%>" });

                            return;
                        }

                        $("#<%=TB_MachineID.ClientID%>").val(data.A5);

                        $("#<%=TB_MachineName.ClientID%>").val(data.A6);

                        $("#<%=TB_TicketID.ClientID%>").focus();

                        if ($("#<%=TB_MachineID.ClientID%>").val() != "" && $("#<%=TB_TicketID.ClientID%>").val() != "")
                            ExecTicketGoIn();
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_MachineID.ClientID%>,#<%=TB_MachineName.ClientID%>").val("");
                    }
                });

            });

            $("#<%=TB_TicketIDOut.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        if (data.A2 == null)
                        {
                            $("#<%=TB_TicketIDOut.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_TicketID")%>" });

                            return;
                        }
                        else if (data.A2 != $("#<%=TB_TicketID.ClientID%>").val())
                        {
                            $("#<%=TB_TicketIDOut.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_TicketIDDifferent")%>" });

                            return;
                        }

                        $("#<%=TB_TicketIDOut.ClientID%>").val("");

                        ExecTicketGoOut();
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_TicketIDOut.ClientID%>").val("");
                    }
                });
            });

            $("#BT_GoInCancel").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                ExecGoInCancel();
            });

            $("#BT_CreateReWorkTicket").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                var FrameID = "TicketReWork_Frame";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/TicketReWork.aspx") %>",
                    iFrameOpenParameters: { TicketID: $("#<%=TB_TicketID.ClientID%>").val() },
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_BT_CreateReWorkTicket") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    TitleBarCloseButtonTriggerCloseEvent: true,
                    width: 910,
                    height: 910,
                    NewWindowPageDivID: "TicketReWork_DivID",
                    NewWindowPageFrameID: FrameID,
                    CloseEvent: function ()
                    {
                        var Frame = $("#" + FrameID + "").contents();

                        if (Frame != null)
                        {
                            var NewTicketID = Frame.find("#HF_NewTicketID").val();
                            var NewAllowQty = Frame.find("#HF_NewAllowQty").val();

                            if (NewTicketID != "" && parseInt(NewAllowQty) < 1)
                                window.location.reload();
                            else if (NewTicketID != "")
                                ExecTicketGoIn();
                        }
                    }
                });
            });

            $("#BT_CreateQuarantineTicket").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                var FrameID = "TicketQuarantine_Frame";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/TicketQuarantine.aspx") %>",
                    iFrameOpenParameters: { TicketID: $("#<%=TB_TicketID.ClientID%>").val() },
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_BT_CreateQuarantineTicket") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    TitleBarCloseButtonTriggerCloseEvent: true,
                    width: 810,
                    height: 760,
                    NewWindowPageDivID: "TicketQuarantine_DivID",
                    NewWindowPageFrameID: FrameID,
                    CloseEvent: function ()
                    {
                        var Frame = $("#" + FrameID + "").contents();

                        if (Frame != null)
                        {
                            var NewTicketID = Frame.find("#HF_NewTicketID").val();
                            var NewAllowQty = Frame.find("#HF_NewAllowQty").val();

                            if (NewTicketID != "" && parseInt(NewAllowQty) < 1)
                                window.location.reload();
                            else if (NewTicketID != "")
                                ExecTicketGoIn();
                        }
                    }
                });
            });

            $("#BT_CreateTicketMaintain").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                var FrameID = "TicketMaintain_Frame";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/TicketMaintain.aspx") %>",
                    iFrameOpenParameters: { TicketID: $("#<%=TB_TicketID.ClientID%>").val() },
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_BT_CreateTicketMaintain") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    TitleBarCloseButtonTriggerCloseEvent: true,
                    width: 1110,
                    height: 940,
                    NewWindowPageDivID: "TicketMaintain_DivID",
                    NewWindowPageFrameID: FrameID,
                    CloseEvent: function ()
                    {
                        var Frame = $("#" + FrameID + "").contents();

                        if (Frame != null)
                        {
                            var MaintainIsComplete = Frame.find("#HF_IsComplete").val();
                            var MaintainIsOnMaintain = Frame.find("#HF_IsOnMaintain").val();
                            var IsHaveMaintain = Frame.find("#HF_IsHaveMaintain").val();

                            if ($.StringConvertBoolean(MaintainIsOnMaintain) && !$.StringConvertBoolean(MaintainIsComplete))
                                $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_TicketMaintainNeedComplete")%>", CloseEvent: function () { $("#BT_CreateTicketMaintain").trigger("click"); } });
                            else
                            {
                                $.Ajax({
                                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/WorkStationStatusSet.ashx")%>",
                                    data: { TicketID: $("#<%=TB_TicketID.ClientID%>").val(), WorkStationStatus:"<%= ((short)Util.TS.WorkStationStatus.InMake).ToString()%>" },
                                    CallBackFunction: function ()
                                    {
                                        if ($.StringConvertBoolean(IsHaveMaintain))
                                            $("#BT_GoInCancel").hide().addClass("disabled");
                                    }
                                });
                            }
                        }
                    }
                });
            });
        });

        function ExecTicketGoOut()
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/TicketReport.aspx") %>",
                iFrameOpenParameters: { TicketID: $("#<%=TB_TicketID.ClientID%>").val() },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_TicketReportTitleBarText") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 910,
                height: 560,
                NewWindowPageDivID: "TicketReport_DivID",
                NewWindowPageFrameID: "TicketReport_Frame",
                CloseEvent: function (result)
                {
                    window.location.reload();
                }
            });
        }

        function ExecTicketGoIn()
        {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketGoIn.ashx")%>",
                timeout: 300 * 1000,
                data: {
                    TicketID: $("#<%=TB_TicketID.ClientID%>").val(),
                    MachineID: $("#<%=TB_MachineID.ClientID%>").val(),
                    WorkCode: $("#<%=HF_WorkCode.ClientID%>").val(),
                    WorkShiftID: $("#<%=HF_WorkShift.ClientID%>").val(),
                },
                CallBackFunction: function (data)
                {
                    if ($.StringConvertBoolean(data.IsAlertChangeBrand))
                    {
                        $.AlertMessage({
                            IsHtmlElement: true,
                            Message: "<%=(string)GetLocalResourceObject("Str_Info_ChangeBrand")%>".format(data.PreviousGoInTEXT1, data.TEXT1),
                            CloseEvent: function ()
                            {
                                ExecGoInCancel(function ()
                                {
                                    window.location.href = "<%=ResolveClientUrl("~/TimeSheet/BrandSet.aspx")%>";
                                });
                            }
                        });
                    }

                    if ($.StringConvertBoolean(data.IsLastBox))
                    {
                        $.AlertMessage({
                            Message: "<%=(string)GetLocalResourceObject("Str_Info_LastBox")%>", CloseEvent: function ()
                            {
                                $("#<%=TB_TicketIDOut.ClientID%>").focus();
                            }
                        });
                    }

                    if ($.StringConvertBoolean(data.IsAlertChangeAUFNR))
                    {
                        var IsShowGoInCancel = (!$.StringConvertBoolean(data.IsHaveChildren) && !$.StringConvertBoolean(data.IsHaveMaintainTicket) && !$.StringConvertBoolean(data.IsHaveWaitReportMaintainTicket));

                        $.AlertMessage({
                            Message: "<%=(string)GetLocalResourceObject("Str_Info_ChangeAUFNR")%>".format(data.PreviousGoInAUFNR, data.PreviousGoInTEXT1, data.TEXT1, data.PreviousGoInCINFO, data.ProcessName), CloseEvent: function ()
                            {
                                var FrameID = "VerifySupervisorWorkCode_FrameID";

                                $.OpenPage({
                                    Framesrc: "<%= ResolveClientUrl(@"~/WorkCodeVerify.aspx") %>",
                                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_VerifySupervisorWorkCodeTitleBarText")%>",
                                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                                    width: 810,
                                    height: 560,
                                    NewWindowPageDivID: "VerifySupervisorWorkCode_DivID",
                                    NewWindowPageFrameID: FrameID,
                                    TitleBarCloseButtonTriggerCloseEvent: true,
                                    CloseEvent: function ()
                                    {
                                        var Frame = $("#" + FrameID + "").contents();

                                        if (Frame != null)
                                        {
                                            var IsVerifySuccess = $.StringConvertBoolean(Frame.find("#HF_IsVerifySuccess").val());

                                            if (IsVerifySuccess)
                                                LoadDataToPage(data);
                                            else if (IsShowGoInCancel)
                                            {
                                                $(".Alertmsg,.ConfirmMsg").dialog("close");
                                                ExecGoInCancel();
                                            }
                                            else
                                            {
                                                $(".Alertmsg,.ConfirmMsg").dialog("close");
                                                window.location.reload();
                                            }
                                        }
                                        else if (IsShowGoInCancel)
                                            ExecGoInCancel();
                                        else
                                        {
                                            $(".Alertmsg,.ConfirmMsg").dialog("close");
                                            window.location.reload();
                                        }
                                    }
                                });
                            }
                        });
                    }
                    else
                        LoadDataToPage(data);
                },
                ErrorCallBackFunction: function (data)
                {
                    $("#<%=TB_TicketID.ClientID%>,#<%=TB_MachineID.ClientID%>,#<%=TB_MachineName.ClientID%>").val("");

                    $("#<%=TB_MachineID.ClientID%>").val($("#<%=HF_MachineID.ClientID%>").val());
                }
            });
        }

        function LoadDataToPage(data)
        {
            $("#<%=TB_TicketID.ClientID%>").val(data.TicketID);
            $("#<%=HF_TicketTypeID.ClientID%>").val(data.TicketTypeID);
            $("#<%=TB_TicketType.ClientID%>").val(data.TicketTypeName);
            $("#<%=TB_TicketQty.ClientID%>").val(data.TicketQty);
            $("#<%=TB_MainTicketID.ClientID%>").val(data.MainTicketID);
            $("#<%=HF_ParentTicketID.ClientID%>").val(data.ParentTicketID);
            $("#<%=TB_ParentTicketPath.ClientID%>").val(data.ParentTicketPath);
            $("#<%=TB_CreateProcessName.ClientID%>").val(data.CreateProcessName);
            $("#<%=TB_EntryTime.ClientID%>").val(data.EntryTime);
            $("#<%=TB_Brand.ClientID%>").val(data.Brand);
            $("#<%=TB_MOBox.ClientID%>").val(data.MOBox);
            $("#<%=TB_MAKTX.ClientID%>").val(data.MAKTX);
            $("#<%=TB_BATCH.ClientID%>").val(data.Batch);
            $("#<%=TB_RoutingName.ClientID%>").val(data.RoutingName);
            $("#<%=TB_ProcessName.ClientID%>").val(data.ProcessName);
            $("#<%=TB_AllowQty.ClientID%>").val(data.AllowQty);
            $("#<%=TB_MachineName.ClientID%>").val(data.MachineName);

            $("#<%=TB_TicketID.ClientID%>,#<%=TB_MachineID.ClientID%>").prop("disabled", true);

            $("#<%=TB_TicketIDOut.ClientID%>").val("").prop("disabled", false).focus();

            if ($.StringConvertBoolean(data.IsCanCreateQuarantineTicket))
                $("#BT_CreateQuarantineTicket").removeClass("disabled");

            if ($.StringConvertBoolean(data.IsCanCreateReWorkTicket))
                $("#BT_CreateReWorkTicket").removeClass("disabled");

            if ($.StringConvertBoolean(data.IsHaveChildren) || $.StringConvertBoolean(data.IsHaveMaintainTicket) || $.StringConvertBoolean(data.IsHaveWaitReportMaintainTicket))
                $("#BT_GoInCancel").hide().addClass("disabled");
            else
                $("#BT_GoInCancel").show().removeClass("disabled");

            $("#BT_CreateTicketMaintain").removeClass("disabled");

            $("#TickeInfoPanel").removeClass("<%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1")%>").addClass("<%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9")%>");

            if ($.StringConvertBoolean(data.IsHaveWaitReportMaintainTicket))
                $("#BT_CreateTicketMaintain").trigger("click");
        }

        function ExecGoInCancel(CallBackFunction)
        {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketGoInCancel.ashx")%>",
                data: { TicketID: $("#<%=TB_TicketID.ClientID%>").val() },
                CallBackFunction: function ()
                {
                    if (CallBackFunction != null && $.isFunction(CallBackFunction))
                        CallBackFunction();
                    else
                        window.location.reload();
                },
                ErrorCallBackFunction: function (data)
                {
                    $("#<%=TB_TicketIDOut.ClientID%>").val("").focus();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="col-xs-12">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor6") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_WorkStationInfo%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <table class="table table-bordered">
                    <tbody>
                        <tr>
                            <td class="col-xs-1 info text-right">
                                <asp:Literal runat="server" Text="<%$ Resources:Str_WorkStationInfo_Operator%>"></asp:Literal></td>
                            <td class="col-xs-1">
                                <asp:Literal runat="server" ID="L_Operator"></asp:Literal>
                            </td>
                            <td class="col-xs-1 info text-right">
                                <asp:Literal runat="server" Text="<%$ Resources:Str_WorkStationInfo_WorkShift%>"></asp:Literal></td>
                            <td class="col-xs-1">
                                <asp:Literal runat="server" ID="L_WorkShift"></asp:Literal>
                            </td>
                            <td class="col-xs-1 info text-right">
                                <asp:Literal runat="server" Text="<%$ Resources:Str_WorkStationInfo_SecondOperator%>"></asp:Literal></td>
                            <td class="col-xs-2">
                                <asp:Literal runat="server" ID="L_SecondOperator"></asp:Literal>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="col-xs-12">
        <div id="TickeInfoPanel" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <asp:HiddenField ID="HF_WorkShift" runat="server" />
            <asp:HiddenField ID="HF_WorkCode" runat="server" />
            <asp:HiddenField ID="HF_TicketTypeID" runat="server" />
            <asp:HiddenField ID="HF_ParentTicketID" runat="server" />
            <asp:HiddenField ID="HF_MachineID" runat="server" />
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_TicketID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TicketID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MachineID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control readonly readonlyColor" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanMachineID %>"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_MachineName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MachineName%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MachineName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_TicketType.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TicketType%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TicketType" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_TicketQty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TicketQty%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TicketQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_MainTicketID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MainTicketID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MainTicketID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_ParentTicketPath.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_ParentTicketPath%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ParentTicketPath" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_CreateProcessName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_CreateProcessName%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_CreateProcessName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_EntryTime.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_EntryTime%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_EntryTime" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_Brand.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_Brand%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_Brand" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_MOBox.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MOBox%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MOBox" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MAKTX%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_BATCH.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_BATCH%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_BATCH" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_RoutingName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_RoutingName%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_RoutingName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_ProcessName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_ProcessName%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ProcessName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_AllowQty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_AllowQty%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_AllowQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_TicketIDOut.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TicketIDOut%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TicketIDOut" runat="server" CssClass="form-control" disabled="true" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
                </div>
                <div class="col-xs-12 form-group text-center">
                    <input type="button" class="btn btn-pink disabled" id="BT_CreateTicketMaintain" value="<%=(string)GetLocalResourceObject("Str_BT_CreateTicketMaintain")%>" />
                    <input type="button" class="btn btn-info disabled" id="BT_CreateQuarantineTicket" value="<%=(string)GetLocalResourceObject("Str_BT_CreateQuarantineTicket")%>" />
                    <input type="button" class="btn btn-warning disabled" id="BT_CreateReWorkTicket" value="<%=(string)GetLocalResourceObject("Str_BT_CreateReWorkTicket")%>" />
                    <input type="button" class="btn btn-danger disabled" id="BT_GoInCancel" value="<%=(string)GetLocalResourceObject("Str_BT_GoInCancel")%>" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
