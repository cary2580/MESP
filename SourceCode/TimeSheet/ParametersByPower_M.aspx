<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="ParametersByPower_M.aspx.cs" Inherits="TimeSheet_ParametersByPower_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsNewData" runat="server" />
    <div class="col-xs-4 form-group required">
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
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_Power.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Power %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_Power" runat="server" CssClass="form-control MumberType" Text="0" data-MumberTypeDecimals="2"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_ElectricCurrent.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ElectricCurrent %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_ElectricCurrent" runat="server" CssClass="form-control MumberType" Text="0" data-MumberTypeDecimals="2"></asp:TextBox>
    </div>
    <div class="col-xs-12 form-group text-center">
        <asp:Button ID="BT_Save" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_SaveName %>" OnClick="BT_Save_Click" />
        <asp:Button ID="BT_Delete" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" OnClick="BT_Delete_Click" />
    </div>
</asp:Content>
