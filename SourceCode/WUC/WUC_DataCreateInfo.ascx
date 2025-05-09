<%@ Control Language="C#" AutoEventWireup="true" CodeFile="WUC_DataCreateInfo.ascx.cs" Inherits="ED_WUC_WUC_DataCreateInfo" %>

<div class="col-xs-3 form-group">
    <label for="<%= TB_CreateAccountName.ClientID%>" class="control-label">
        <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDataAccountName %>"></asp:Literal>
    </label>
    <asp:TextBox ID="TB_CreateAccountName" runat="server" CssClass="form-control readonly"></asp:TextBox>
</div>
<div class="col-xs-3 form-group">
    <label for="<%= TB_CreateDate.ClientID%>" class="control-label">
        <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDataDate %>"></asp:Literal>
    </label>
    <asp:TextBox ID="TB_CreateDate" runat="server" CssClass="form-control readonly"></asp:TextBox>
</div>
<div class="col-xs-3 form-group">
    <label for="<%= TB_ModifyAccountName.ClientID%>" class="control-label">
        <asp:Literal runat="server" Text="<%$ Resources:Str_ModifyDataAccountName %>"></asp:Literal>
    </label>
    <asp:TextBox ID="TB_ModifyAccountName" runat="server" CssClass="form-control readonly"></asp:TextBox>
</div>
<div class="col-xs-3 form-group">
    <label for="<%= TB_ModifyDate.ClientID%>" class="control-label">
        <asp:Literal runat="server" Text="<%$ Resources:Str_ModifyDataDate %>"></asp:Literal>
    </label>
    <asp:TextBox ID="TB_ModifyDate" runat="server" CssClass="form-control readonly"></asp:TextBox>
</div>
