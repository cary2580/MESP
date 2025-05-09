<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="LableScan_M.aspx.cs" Inherits="TimeSheet_LableScan_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=TB_NewLableID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;
                else
                    $("#<%=BT_Update.ClientID%>").trigger("click");
            });
        });

        function IsRepeat()
        {
            if ($.StringConvertBoolean($("#<%=HF_IsRepeat.ClientID%>").val()))
            {
                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/WorkCodeVerify.aspx") %>",
                     TitleBarText: "<%=(string)GetLocalResourceObject("Str_VerifySupervisorWorkCodeTitleBarText")%>",
                     TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                     width: 710,
                     height: 560,
                     NewWindowPageDivID: "VerifySupervisorWorkCode_DivID",
                     IsForciblyPage: true,
                     IsShowTitleBarCloseButton: false
                 });
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_ScanKey" runat="server" />
    <asp:HiddenField ID="HF_TicketID" runat="server" />
    <asp:HiddenField ID="HF_DeviceID" runat="server" />
    <asp:HiddenField ID="HF_WorkShiftID" runat="server" />
    <asp:HiddenField ID="HF_BoxNo" runat="server" />
    <asp:HiddenField ID="HF_IsRepeat" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_LableScan_M%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_OldLableID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_OldLableID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_OldLableID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_NewLableID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_NewLableID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_NewLableID" runat="server" CssClass="form-control" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group" style="text-align: center">
                <asp:Button ID="BT_Update" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SaveName %>" CssClass="btn btn-primary" OnClick="BT_Update_Click" />
            </div>
        </div>
    </div>
</asp:Content>


