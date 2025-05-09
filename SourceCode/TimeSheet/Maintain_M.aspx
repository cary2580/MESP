<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="Maintain_M.aspx.cs" Inherits="TimeSheet_Maintain_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        var MaintainFaultByFirstListID = "MaintainFaultByFirstList";
        var MaintainFaultByFirstListTableID = "MaintainFaultByFirstListTable";
        var MaintainFaultByFirstListPagerID = "MaintainFaultByFirstListPager";

        var MaintainInfoOperatorListID = "MaintainInfoOperatorList";
        var MaintainInfoOperatorListTableID = "MaintainInfoOperatorListTable";
        var MaintainInfoOperatorListPagerID = "MaintainInfoOperatorListPager";

        $(function ()
        {
            LoadGridData({
                IsShowJQGridPager: false,
                JQGridDataValue: JQGridDataValueByFaultFitst,
                ListID: MaintainFaultByFirstListID,
                TableID: MaintainFaultByFirstListTableID,
                PagerID: MaintainFaultByFirstListPagerID,
            });

            LoadReportData();

            $("#BT_Fault").click(function ()
            {
                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/TicketMaintainFault.aspx") %>",
                    iFrameOpenParameters: { MaintainID: $("#<%=TB_MaintainID.ClientID%>").val(), PLNBEZ: $("#<%=HF_PLNBEZ.ClientID%>").val() },
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_BT_Fault") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 910,
                    height: 810,
                    NewWindowPageDivID: "Fault_DivID",
                    NewWindowPageFrameID: "Fault_Frame"
                });
            });

            $("#BT_Confirm").click(function ()
            {
                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainFinish.ashx")%>",
                    data: {
                        MaintainID: $("#<%=TB_MaintainID.ClientID%>").val(), ParentMaintainID: $("#<%=TB_ParentMaintainID.ClientID%>").val(), IsConfirm: $("#<%=DDL_IsConfirm.ClientID%>").val(), ConfirmWorkCode: $("#<%=HF_ConfirmWorkCode.ClientID%>").val(),
                        IsAlert: $("#<%=DDL_IsAlert.ClientID%>").val(), IsTrace: $("#<%=DDL_IsTrace.ClientID%>").val(), TraceQty: $("#<%=TB_TraceQty.ClientID%>").val(), TraceGoodQty: $("#<%=TB_TraceGoodQty.ClientID%>").val(), TraceNGQty: $("#<%=TB_TraceNGQty.ClientID%>").val(),
                        TestQty1: $("#<%=TB_TestQty1.ClientID%>").val(), TestQty2: $("#<%=TB_TestQty2.ClientID%>").val(), TestTicketID: $("#<%=TB_TestTicketID.ClientID%>").val(),
                        IsModify: true, ModifyWorkCode: $("#<%=TB_ModifyWorkCode.ClientID%>").val(),
                        Remark1: $("#<%=TB_Remark1.ClientID%>").val(), Remark2: $("#<%=TB_Remark2.ClientID%>").val(), Remark3: $("#<%=TB_Remark3.ClientID%>").val(),
                        IsCancel: $("#<%=DDL_IsCancel.ClientID%>").val()
                    },
                    CallBackFunction: function (data)
                    {
                        parent.$("#" + $("#<%=HF_Div.ClientID%>").val()).dialog("close");
                    }
                });
            });

<%--            $("#<%=TB_TraceGoodQty.ClientID%>,#<%=TB_TraceNGQty.ClientID%>").change(function ()
            {
                $("#<%=TB_TraceQty.ClientID%>").val(parseInt($("#<%=TB_TraceGoodQty.ClientID%>").val()) + parseInt($("#<%=TB_TraceNGQty.ClientID%>").val()));
            });--%>

            $("#<%=DDL_IsTrace.ClientID%>").change(function ()
            {
                if ($.StringConvertBoolean($(this).val()))
                    $("#<%=TB_TraceQty.ClientID%>,#<%=TB_TraceGoodQty.ClientID%>,#<%=TB_TraceNGQty.ClientID%>").prop("disabled", false).trigger("change");
                else
                    $("#<%=TB_TraceQty.ClientID%>,#<%=TB_TraceGoodQty.ClientID%>,#<%=TB_TraceNGQty.ClientID%>").prop("disabled", true).val("0").trigger("change");
            }).trigger("change");

            $("#<%=TB_TestTicketID.ClientID%>").keydown(function (e)
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
                            $("#<%=TB_TestTicketID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_TicketID")%>" });

                            return;
                        }

                        $("#<%=TB_TestTicketID.ClientID%>").val(data.A2);
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_TestTicketID.ClientID%>").val("");
                    }
                });
            });
        });

        function LoadReportData()
        {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainWaitReportData.ashx")%>",
                data: { MaintainID: $("#<%=TB_MaintainID.ClientID%>").val() },
                CallBackFunction: function (data)
                {
                    $("#<%=TB_MaintainMinute.ClientID%>").val(data.TotalMaintainMinute);

                    $("#<%=TB_MaintainMinuteByMachine.ClientID%>").val(data.TotalMaintainMinuteByMachine);

                    LoadGridData({
                        JQGridDataValue: data,
                        IsShowJQGridPager: false,
                        ListID: MaintainInfoOperatorListID,
                        TableID: MaintainInfoOperatorListTableID,
                        PagerID: MaintainInfoOperatorListPagerID
                    });

                    // 讓畫面垂直滾軸往到最下面
                    $("html,body").animate({ scrollTop: $(document).height() }, 1000);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_Div" runat="server" />
    <asp:HiddenField ID="HF_DeviceID" runat="server" />
    <asp:HiddenField ID="HF_ProcessID" runat="server" />
    <asp:HiddenField ID="HF_VORNR" runat="server" />
    <asp:HiddenField ID="HF_PLNBEZ" runat="server" />
    <asp:HiddenField ID="HF_ConfirmWorkCode" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#TicketInfo">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo%>"></asp:Literal>
        </div>
        <div id="TicketInfo" class="panel-collapse collapse in" aria-expanded="true">
            <div class="panel-body">
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_TicketID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TicketID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MachineID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_MachineName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MachineName%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MachineName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MAKTX%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
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
                    <label for="<%= TB_MaintainID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MaintainID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MaintainID" runat="server" CssClass="form-control" ClientIDMode="Static" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_ParentMaintainID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_ParentMaintainID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ParentMaintainID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_WaitMinute.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_WaitMinute%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_WaitMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_WaitTimeStart.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_WaitTimeStart%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_WaitTimeStart" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_WaitTimeEnd.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_WaitTimeEnd%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_WaitTimeEnd" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-12 form-group">
                    <div id="MaintainFaultByFirst" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor7") %>">
                        <div class="panel-heading text-center">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainFaultByFirstListTitle%>"></asp:Literal>
                        </div>
                        <div class="panel-body">
                            <div class="col-xs-12 form-group">
                                <label for="<%= TB_Responsible.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:Str_Responsible%>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Responsible" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-12 form-group">
                                <div id="MaintainFaultByFirstList"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#OperatorList">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfoOperator%>"></asp:Literal>
        </div>
        <div id="OperatorList" class="panel-collapse collapse in" aria-expanded="true">
            <div class="panel-body">
                <div id="MaintainInfoOperatorList"></div>
                <p></p>

            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor2") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#MaintainQACheck">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainQACheck%>"></asp:Literal>
        </div>
        <div id="MaintainQACheck" class="panel-collapse collapse" aria-expanded="true">
            <div class="panel-body">
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_QACheckTimeStart.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainQACheckInfo_QACheckTimeStart%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_QACheckTimeStart" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_QACheckTimeEnd.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainQACheckInfo_QACheckTimeEnd%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_QACheckTimeEnd" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_QACheckMinute.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainQACheckInfo_QACheckMinute%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_QACheckMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_QACheckAccountName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainQACheckInfo_QACheckAccountName%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_QACheckAccountName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor8") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#MaintainInfo">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo%>"></asp:Literal>
        </div>
        <div id="MaintainInfo" class="panel-collapse collapse in" aria-expanded="true">
            <div class="panel-body">
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_MaintainMinute.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_MaintainMinute%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_MaintainMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                        <span class="input-group-btn">
                            <input type="button" class="btn btn-primary" id="BT_Fault" value="<%=(string)GetLocalResourceObject("Str_BT_Fault")%>" />
                        </span>
                    </div>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_MaintainMinuteByMachine.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_MaintainMinuteByMachine%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MaintainMinuteByMachine" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= DDL_IsConfirm.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_IsConfirm%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsConfirm" runat="server" CssClass="form-control" disabled="true">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_ConfirmAccountName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_ConfirmAccountName%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ConfirmAccountName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= DDL_IsTrace.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_IsTrace%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsTrace" runat="server" CssClass="form-control">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TraceQty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TraceQty%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TraceQty" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TraceGoodQty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TraceGoodQty%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TraceGoodQty" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TraceNGQty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TraceNGQty%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TraceNGQty" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TestQty1.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TestQty1%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TestQty1" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TestTicketID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TestTicketID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TestTicketID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TestQty2.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TestQty2%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TestQty2" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= DDL_IsAlert.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_IsAlert%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsAlert" runat="server" CssClass="form-control">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= DDL_IsCancel.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_IsCancel%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsCancel" runat="server" CssClass="form-control">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_ModifyWorkCode.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_ModifyWorkCode%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ModifyWorkCode" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_ModifyDate.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_ModifyDate%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ModifyDate" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_ModifyDataAccountName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_ModifyDataAccountName%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ModifyDataAccountName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-12 form-group">
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_Remark1.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_Remark1%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_Remark1" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_Remark2.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_Remark2%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_Remark2" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_Remark3.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_Remark3%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_Remark3" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>
                </div>
                <div class="col-xs-12 form-group text-center">
                    <input type="button" class="btn btn-warning" id="BT_Confirm" value="<%=(string)GetLocalResourceObject("Str_BT_Confirm")%>" />
                </div>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor6") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#MaintainPDCheck">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainPDCheck%>"></asp:Literal>
        </div>
        <div id="MaintainPDCheck" class="panel-collapse collapse" aria-expanded="true">
            <div class="panel-body">
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_PDCheckTimeStart.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainPDCheckInfo_PDCheckTimeStart%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PDCheckTimeStart" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_PDCheckTimeEnd.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainPDCheckInfo_PDCheckTimeEnd%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PDCheckTimeEnd" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_PDCheckMinute.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainPDCheckInfo_PDCheckMinute%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PDCheckMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_PDCheckAccountName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainPDCheckInfo_PDCheckAccountName%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PDCheckAccountName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
