<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="IT_ModifyWorkShift.aspx.cs" Inherits="TimeSheet_IT_ModifyWorkShift" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_ResultKeyData" runat="server" />
    <div class="col-xs-6 form-group required">
        <label for="<%= DDL_WorkShift.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_WorkShift %>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_WorkShift" runat="server" CssClass="form-control" required="required">
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 form-group text-center">
        <asp:Button ID="BT_Confirm" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_BT_ConfirmName %>" Onclick="BT_Confirm_Click"/>
    </div>
</asp:Content>


