<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="TicketParameter_M.aspx.cs" Inherits="TimeSheet_TicketParameter_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_PLNNR.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_PLNNR%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_PLNNR" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_PLNAL.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_PLNAL%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_PLNAL" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_MATNR.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MATNR%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MATNR" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MAKTX%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_MaxTicketBox.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaxTicketBox%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MaxTicketBox" runat="server" CssClass="form-control MumberType" required="required" Text="0"></asp:TextBox>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_MaxTicketBoxQtyName.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaxTicketBoxQtyName%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MaxTicketBoxQtyName" runat="server" CssClass="form-control MumberType" required="required" Text="0"></asp:TextBox>
    </div>
    <div class="col-xs-3 form-group">
        <label for="<%= DLL_TicketPrintSizeName.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketPrintSizeName%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DLL_TicketPrintSizeName" runat="server" CssClass="form-control">
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 text-center">
        <asp:Button ID="BT_Submit" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName%>" OnClick="BT_Submit_Click" />
    </div>
</asp:Content>


