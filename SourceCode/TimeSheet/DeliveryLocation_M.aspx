<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="DeliveryLocation_M.aspx.cs" Inherits="TimeSheet_DeliveryLocation_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_LocationID" runat="server" />
    <asp:HiddenField ID="HF_IsNewData" runat="server" />
    <div class="row">
        <div class="col-xs-8 form-group required">
            <label for="<%= TB_LocationName.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_DeliveryLocation%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_LocationName" runat="server" CssClass="form-control" required="required"></asp:TextBox>
        </div>
          <div class="col-xs-4 form-group required">
            <label for="<%= TB_SortID.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_SortID %>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_SortID" runat="server" CssClass="form-control MumberType" required="required" Text="0" data-MumberTypeDecimals="1"></asp:TextBox>
        </div>
        <div class="col-xs-12 text-center">
            <asp:Button ID="BT_Save" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_SaveName %>" OnClick="BT_Save_Click" />
            <asp:Button ID="BT_Delete" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" OnClick="BT_Delete_Click" />
        </div>
    </div>
</asp:Content>

