<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="ProcessDeviceGroup_M.aspx.cs" Inherits="TimeSheet_ProcessDeviceGroup_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_PLNNR" runat="server" />
    <asp:HiddenField ID="HF_PLNAL" runat="server" />
    <asp:HiddenField ID="HF_PLNKN" runat="server" />
    <asp:HiddenField ID="HF_VORNR" runat="server" />
    <asp:HiddenField ID="HF_ProcessID" runat="server" />
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_DeviceGroupID.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceGroupID%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_DeviceGroupID" runat="server" CssClass="form-control" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-12 form-group text-center">
        <asp:Button ID="BT_Submit" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:Str_Button_SubmitName%>" OnClick="BT_Submit_Click" />
    </div>
</asp:Content>
