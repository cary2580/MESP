<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="DeviceParametersByED_M.aspx.cs" Inherits="TimeSheet_DeviceParametersByED_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsNewData" runat="server" />
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_ReportDate.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDate%>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_ReportDate" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= DDL_DeviceID.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceID%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_DeviceID" runat="server" CssClass="form-control" required="required">
        </asp:DropDownList>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_ChangeWaterMinute.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ChangeWaterMinute %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_ChangeWaterMinute" runat="server" CssClass="form-control MumberType" Text="0" data-MumberTypeDecimals="1"></asp:TextBox>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_StandardMinute.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_StandardMinute %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_StandardMinute" runat="server" CssClass="form-control readonly readonlyColor" data-MumberTypeDecimals="1" Text="4.9"></asp:TextBox>
    </div>
    <div class="col-xs-12 form-group text-center">
        <asp:Button ID="BT_Save" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_SaveName %>" OnClick="BT_Save_Click" />
        <asp:Button ID="BT_Delete" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" OnClick="BT_Delete_Click" />
    </div>
</asp:Content>


