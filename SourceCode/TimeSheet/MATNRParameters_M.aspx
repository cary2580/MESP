<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="MATNRParameters_M.aspx.cs" Inherits="TimeSheet_MATNRParameters_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="col-xs-6 form-group required">
        <label for="<%= TB_MATNR.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MATNR%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MATNR" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-6 form-group required">
        <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MAKTX%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_HangPointQty.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_HangPointQty%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_HangPointQty" runat="server" CssClass="form-control MumberType" required="required" Text="0"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_ProductLGORT.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ProductLGORT%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_ProductLGORT" runat="server" CssClass="form-control selectpicker" data-live-search="true" required="required">
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_AUFNRStdWorkDay.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNRStdWorkDay%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_AUFNRStdWorkDay" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="1" required="required" Text="0"></asp:TextBox>
    </div>
    <div class="col-xs-12 text-center">
        <asp:Button ID="BT_Submit" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName%>" OnClick="BT_Submit_Click" />
    </div>
</asp:Content>


