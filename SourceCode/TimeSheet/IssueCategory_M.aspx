<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="IssueCategory_M.aspx.cs" Inherits="TimeSheet_IssueCategory_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IssueCategoryInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_IssueCategoryID.ClientID%>" class="control-label ">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IssueCategoryID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_IssueCategoryID" runat="server" CssClass="form-control readonly readonlyColor"></asp:TextBox>
            </div>
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_SortID.ClientID%>" class="control-label ">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SortID %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_SortID" runat="server" CssClass="form-control MumberType" required="required" Text="0" data-MumberTypeDecimals="1"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group required">
                <label for="<%= TB_IssueCategoryName.ClientID%>" class="control-label ">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IssueCategoryName%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_IssueCategoryName" runat="server" CssClass="form-control" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <asp:Button ID="BT_Save" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName%>" CssClass="btn btn-warning" OnClick="BT_Save_Click" />
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName%>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
            </div>
        </div>
    </div>
</asp:Content>
