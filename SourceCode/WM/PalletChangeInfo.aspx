<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="PalletChangeInfo.aspx.cs" Inherits="WM_PalletChangeInfo" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_PalletNo" runat="server" />
    <div class="col-xs-6 form-group required">
        <label for="<%= DDL_LGORT.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_LGORT %>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_LGORT" runat="server" CssClass="form-control selectpicker" required="required" data-live-search="true">
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 text-center">
        <asp:Button ID="BT_Submit" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName%>" OnClick="BT_Submit_Click" />
    </div>
</asp:Content>
