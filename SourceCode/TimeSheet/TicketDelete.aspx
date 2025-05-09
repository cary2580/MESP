<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="TicketDelete.aspx.cs" Inherits="TimeSheet_TicketDelete" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=BT_Submit.ClientID%>").hide();

            $("#<%=TB_TickeID.ClientID%>").keydown(function (e)
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
                            $("#<%=TB_TickeID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_TicketID")%>" });

                            return;
                        }

                        $("#<%=HF_AUFNR.ClientID%>").val(data.A1);

                        $("#<%=TB_TickeID.ClientID%>").val(data.A2);

                        $("#<%=TB_MachineID.ClientID%>").focus();
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_TickeID.ClientID%>").val("");
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
                        if (data.A5 == null)
                        {
                            $("#<%=TB_MachineID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_TicketID")%>" });

                            return;
                        }

                        $("#<%=TB_MachineID.ClientID%>").val(data.A5);

                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_MachineID.ClientID%>").val("");
                    }
                });
            });

            $("#BT_Delete").click(function ()
            {
                if ($("#<%=TB_TickeID.ClientID%>").val() == "" || $("#<%=TB_MachineID.ClientID%>").val() == "")
                {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    event.preventDefault();

                    return;
                }

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_ConfirmMessage")%>", IsHtmlElement: true, CloseEvent: function (Result)
                    {
                        if (!Result)
                            event.preventDefault();
                        else
                            $("#<%=BT_Submit.ClientID%>").trigger("click");
                    }
                });
            });
        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_AUFNR" runat="server" />
    <div class="col-xs-12">
        <div class="col-xs-4 form-group required">
            <label for="<%= TB_TickeID.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_TicketID%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_TickeID" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
        </div>
        <div class="col-xs-4 form-group required">
            <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_MachineID%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanMachineID %>"></asp:TextBox>
        </div>
    </div>
    <div class="col-xs-12">
        <div class="col-xs-2 form-group">
            <input id="BT_Delete" type="button" value="<%= (string)GetLocalResourceObject("Str_Button_TicketDelete")%>" class="btn btn-primary" />
            <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:Str_Button_TicketDelete%>" OnClick="BT_Submit_Click" UseSubmitBehavior="false" />
        </div>
    </div>
</asp:Content>
