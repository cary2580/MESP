<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="WorkCodeVerify.aspx.cs" Inherits="WorkCodeVerify" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            if ($.StringConvertBoolean($("#<%=HF_IsVerifySuccess.ClientID%>").val()))
                parent.$("#" + $("#<%=HF_Div.ClientID%>").val()).dialog("close");

            if ($("#<%=HF_AlertMessageWidth.ClientID%>").val() != "")
                $.Main.Defaults.AlertMessage.width = parseInt($("#<%=HF_AlertMessageWidth.ClientID%>").val());
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsVerifySuccess" runat="server" Value="0" ClientIDMode="Static" />
    <asp:HiddenField ID="HF_AlertMessageWidth" runat="server" />
    <asp:HiddenField ID="HF_Div" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Info%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_Info_WorkCode%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" required="required" ClientIDMode="Static" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
            </div>
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_Password.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_Password%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_Password" runat="server" CssClass="form-control" required="required" TextMode="Password"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <asp:Button ID="BT_Confirm" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_ConfirmName %>" OnClick="BT_Confirm_Click" />
            </div>
        </div>
    </div>
</asp:Content>
