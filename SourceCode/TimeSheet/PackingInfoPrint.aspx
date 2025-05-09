<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="PackingInfoPrint.aspx.cs" Inherits="TimeSheet_PackingInfoPrint" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=BT_Print.ClientID%>").hide();

            $("#<%=BT_Print_DisPlay.ClientID%>").click(function ()
            {
                if ($("#<%=TB_TicketID.ClientID%>").val() == "" || $("#<%=TB_MachineID.ClientID%>").val() == "" || $("#<%=TB_WorkCode.ClientID%>").val() == "")
                {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage") %>" });

                    return;
                }

                $("#<%=BT_Print.ClientID%>").trigger("click");
            });

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

                        if ($("#<%=TB_MachineID.ClientID%>").val() != "" && $("#<%=TB_TicketID.ClientID%>").val() != "" && $("#<%=TB_WorkCode.ClientID%>").val() != "")
                            $("#<%=BT_Print_DisPlay.ClientID%>").trigger("click");
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_TicketID.ClientID%>").val("");
                    }
                });
            }).focus();

            //包装数量区块工单号栏位
            $("#<%=TB_AUFNR.ClientID%>").keydown(function (e)
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
                        if (data.A1 == null)
                        {
                            $("#<%=TB_AUFNR.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_TS_Empty_AUFNR")%>" });

                            return;
                        }

                        $("#<%=TB_AUFNR.ClientID%>").val(data.A1);

                        LoadPackageQtyData();
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_AUFNR.ClientID%>").val("");
                    }
                });
            }).focus();

            $("#<%=TB_MachineID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                var MachineID = $(this).val();

                if (MachineID == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: MachineID },
                    CallBackFunction: function (data)
                    {
                        if (data.A4 == null || data.A5 == null)
                        {
                            $("#<%=TB_MachineID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=GetLocalResourceObject("Str_Error_DeviceID")%>" });

                            return;
                        }

                        $("#<%=TB_MachineID.ClientID%>").val(data.A5);
                        $("#<%=TB_WorkCode.ClientID%>").focus();

                        if ($("#<%=TB_MachineID.ClientID%>").val() != "" && $("#<%=TB_TicketID.ClientID%>").val() != "" && $("#<%=TB_WorkCode.ClientID%>").val() != "")
                            $("#<%=BT_Print.ClientID%>").trigger("click");
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_MachineID.ClientID%>").val("");
                    }
                });
            });

            $("#<%=TB_WorkCode.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($("#<%=TB_MachineID.ClientID%>").val() != "" && $("#<%=TB_TicketID.ClientID%>").val() != "" && $("#<%=TB_WorkCode.ClientID%>").val() != "")
                    $("#<%=BT_Print_DisPlay.ClientID%>").trigger("click");
            });

            if ($("#<%=HF_ProcessID.ClientID%>").val() != "" && $("#<%=HF_DeviceID.ClientID%>").val() != "")
            {
                window.open("<%=ResolveClientUrl(@"~/TimeSheet/RPT_008.aspx?IsRePrint=1&TicketID=") + TB_TicketID.Text + "&ProcessID=" + HF_ProcessID.Value + "&DeviceID=" + HF_DeviceID.Value%>", "_blank", "toolbar=false,location=false,menubar=false,width=" + screen.availWidth + ",height=" + screen.availHeight + "");

                $("#<%=HF_ProcessID.ClientID%>").val("");
                $("#<%=HF_DeviceID.ClientID%>").val("");
            }

            //成品包装数量修改保存
            $("#<%=BT_Save.ClientID%>").click(function ()
            {
                if ($("#<%=TB_AUFNR.ClientID%>").val() == "" || $("#<%=TB_PackageQty.ClientID%>").val() == "")
                {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage") %>" });

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/PackageQtySet.ashx")%>",
                    data: { AUFNR: $("#<%=TB_AUFNR.ClientID%>").val(), PackageQty: $("#<%=TB_PackageQty.ClientID%>").val() },
                    CallBackFunction: function (data)
                    {
                        $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_ModifySuccessAlertMessage")%>" });
                    }
                });
            });
        });

        function LoadPackageQtyData()
        {
            if ($("#<%=TB_AUFNR.ClientID%>").val() == "")
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage") %>" });

                return;
            }

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/PackageQtyGet.ashx")%>",
                data: { AUFNR: $("#<%=TB_AUFNR.ClientID%>").val() },
                CallBackFunction: function (data)
                {
                    $("#<%=TB_PackageQty.ClientID%>").val(data.PackageQty);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_ProcessID" runat="server" />
    <asp:HiddenField ID="HF_DeviceID" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_PrintInfoHeading%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_TicketID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketID %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanMachineID %>"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCode%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input type="button" id="BT_Print_DisPlay" runat="server" class="btn btn-primary" value="<%$ Resources:GlobalRes,Str_BT_ConfirmName %>" />
                <asp:Button ID="BT_Print" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_ConfirmName %>" OnClick="BT_Print_Click" />
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor8") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_PackageQty%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_AUFNR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNR%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_AUFNR" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
            </div>
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_PackageQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_PackageQty %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_PackageQty" runat="server" CssClass="form-control MumberType"></asp:TextBox>
            </div>
            <div class="col-xs-12 text-center">
                 <input type="button" id="BT_Save" runat="server" class="btn btn-primary" value="<%$ Resources:GlobalRes,Str_BT_SaveName %>" />
            </div>
        </div>
    </div>
</asp:Content>
