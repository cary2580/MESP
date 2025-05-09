<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="TicketReport.aspx.cs" Inherits="TimeSheet_TicketReport" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {

            if (!$.StringConvertBoolean($("#<%=HF_IsPrintPackage.ClientID%>").val()))
                $("#<%=DDL_IsPrintPackage.ClientID%>").selectpicker("val", "").closest(".form-group").hide();

            if ($.StringConvertBoolean($("#<%=HF_IsReportGoodQty.ClientID%>").val())) {
                $("#<%=TB_GoodQty.ClientID%>").addClass("MumberType");
                $("#<%=TB_ReWorkQty.ClientID%>").addClass("readonlyColor readonly");
            }
            else {
                $("#<%=TB_ReWorkQty.ClientID%>").addClass("MumberType");
                $("#<%=TB_GoodQty.ClientID%>").addClass("readonlyColor readonly");
            }

            $(".MumberType").TouchSpin({
                min: 0,
                max: parseInt($("#<%=HF_AllowQty.ClientID%>").val()),
                decimals: 0,
            });

            $("#BT_Save").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                $("#BT_Save").addClass("disabled");

                var GoodQty = parseInt($("#<%=TB_GoodQty.ClientID%>").val());

                var ReWorkQty = parseInt($("#<%=TB_ReWorkQty.ClientID%>").val());

                var AllowQty = parseInt($("#<%=HF_AllowQty.ClientID%>").val());

                var ReportQty = GoodQty + ReWorkQty;

                // 因為有機率會發生，進工後毫無生產，需要開立維修單。從此此張流程卡當班可能就完全沒生產。因此要讓它出工記下時間
<%--                if (ReportQty < 1)
                {
                    $("#BT_Save").removeClass("disabled");

                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_ReportQty")%>" });

                    event.preventDefault();

                    return;
                }--%>


                if (ReportQty > AllowQty) {
                    $("#BT_Save").removeClass("disabled");

                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_OverReportQty")%>" + "(" + AllowQty + ")" });

                    event.preventDefault();

                    return;
                }

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_ConfirmMessage")%>", IsHtmlElement: true, CloseEvent: function (Result) {
                        if (!Result) {
                            $("#BT_Save").removeClass("disabled");

                            event.preventDefault();
                        }
                        else {
                            $.Ajax({
                                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketReport.ashx")%>",
                                data: {
                                    TicketID: $("#<%=HF_TicketID.ClientID%>").val(),
                                    GoodQty: $("#<%=TB_GoodQty.ClientID%>").val(),
                                    ReWorkQty: $("#<%=TB_ReWorkQty.ClientID%>").val(),
                                    WaitMinute: $("#<%=TB_WaitMinute.ClientID%>").val()
                                },
                                CallBackFunction: function (data) {
                                    let Message = "<%=(string)GetGlobalResourceObject("GlobalRes", "Str_SaveSuccessAlertMessage")%>";

                                    if (AllowQty != ReportQty)
                                        Message += "<br><div><p class=\"blink\"><strong>" + "<%=(string)GetLocalResourceObject("Str_AlertMessageByDifferentReportQty")%>" + "</strong></p></div>";

                                    $.AlertMessage({
                                        IsHtmlElement: true,
                                        Message: Message,
                                        CloseEvent: function () {

                                            if ($.StringConvertBoolean($("#<%=HF_IsPrintPackage.ClientID%>").val()) && $.StringConvertBoolean($("#<%=DDL_IsPrintPackage.ClientID%>").selectpicker("val")))
                                                parent.window.open("<%=ResolveClientUrl(@"~/TimeSheet/RPT_008.aspx?TicketID=") + HF_TicketID.Value + "&ProcessID=" + HF_ProcessID.Value + "&DeviceID=" + HF_DeviceID.Value%>", "_blank", "toolbar=false,location=false,menubar=false,width=" + screen.availWidth + ",height=" + screen.availHeight + "");

                                            parent.$("#" + $("#<%=HF_DivID.ClientID%>").val()).dialog("close");
                                        }
                                    });
                                },
                                ErrorCallBackFunction: function (data) {
                                    $("#BT_Save").removeClass("disabled");
                                }
                            });

                            event.preventDefault();
                        }
                    }
                });
            }).focus();
        });
    </script>
    <style>
        #MaintainAlertDiv {
            /*display: none;*/
            position: fixed;
            z-index: 99;
            border: none;
            outline: none;
            background-color: rgba(255, 255, 102, 0.6);
            color: red;
            padding: 10px;
            border-radius: 4px;
            text-align: center;
        }

        .blink {
            font-size: 18px;
            color: red;
            animation-duration: 1s;
            animation-name: blink;
            animation-iteration-count: infinite;
            animation-direction: alternate;
            animation-timing-function: ease-in-out;
        }

        @keyframes blink {
            0% {
                opacity: 1;
            }

            80% {
                opacity: 1;
            }

            81% {
                opacity: 0;
            }

            100% {
                opacity: 0;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DivID" runat="server" />
    <asp:HiddenField ID="HF_AUFNR" runat="server" />
    <asp:HiddenField ID="HF_TicketID" runat="server" />
    <asp:HiddenField ID="HF_WorkShiftID" runat="server" />
    <asp:HiddenField ID="HF_Operator" runat="server" />
    <asp:HiddenField ID="HF_ProcessID" runat="server" />
    <asp:HiddenField ID="HF_AUFPL" runat="server" />
    <asp:HiddenField ID="HF_APLZL" runat="server" />
    <asp:HiddenField ID="HF_VORNR" runat="server" />
    <asp:HiddenField ID="HF_DeviceID" runat="server" />
    <asp:HiddenField ID="HF_TicketQty" runat="server" />
    <asp:HiddenField ID="HF_AllowQty" runat="server" />
    <asp:HiddenField ID="HF_IsReportGoodQty" runat="server" />
    <asp:HiddenField ID="HF_IsPrintPackage" runat="server" />
    <div class="col-xs-4 form-group">
        <label for="<%= TB_EntryTime.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_EntryTime%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_EntryTime" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_EndTime.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_EndTime%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_EndTime" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_ReportMinute.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ReportMinute%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_ReportMinute" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_WaitMaintainMinute.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_WaitMaintainMinute%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_WaitMaintainMinute" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_MaintainMinute.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainMinute%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MaintainMinute" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_MaintainQACheckMinute.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainQACheckMinute%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MaintainQACheckMinute" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_MaintainPDCheckMinute.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainPDCheckMinute%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MaintainPDCheckMinute" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_ResultMinute.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ResultMinute%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_ResultMinute" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_WaitMinute.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_WaitMinute%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_WaitMinute" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_GoodQty.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_GoodQty%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_GoodQty" runat="server" CssClass="form-control" Text="0" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_ReWorkQty.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ReWorkQty%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_ReWorkQty" runat="server" CssClass="form-control" Text="0" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_Brand.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Brand%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_Brand" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_WorkShift.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_WorkShift%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_WorkShift" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_OperatorName.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_OperatorName%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_OperatorName" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsPrintPackage.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsPrintPackage%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsPrintPackage" runat="server" CssClass="form-control selectpicker" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1" Selected="True"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 form-group">
        <label for="<%= TB_OperatorNameSecond.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_OperatorNameSecond%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_OperatorNameSecond" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
    </div>
    <div class="col-xs-12 form-group text-center">
        <input id="BT_Save" type="button" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_SubmitName")%>" class="btn btn-primary" />
    </div>
</asp:Content>
