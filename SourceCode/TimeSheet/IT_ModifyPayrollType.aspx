<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="IT_ModifyPayrollType.aspx.cs" Inherits="TimeSheet_IT_ModifyPayrollType" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" Runat="Server">
     <asp:HiddenField ID="HF_ResultKeyData" runat="server" />
    <div class="col-xs-6 form-group required">
        <label for="<%= DDL_PayrollType.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_PayrollType %>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_PayrollType" runat="server" CssClass="form-control" required="required">
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 form-group text-center">
        <asp:Button ID="BT_Confirm" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_BT_ConfirmName %>" OnClick ="BT_Confirm_Click1"/>
    </div>
</asp:Content>

