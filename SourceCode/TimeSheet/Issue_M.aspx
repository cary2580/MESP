<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="Issue_M.aspx.cs" Inherits="TimeSheet_Issue_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IssueInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_IssueID.ClientID%>" class="control-label ">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IssueID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_IssueID" runat="server" CssClass="form-control readonly readonlyColor"></asp:TextBox>
            </div>
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_SortID.ClientID%>" class="control-label ">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SortID %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_SortID" runat="server" CssClass="form-control MumberType" required="required" Text="0" data-MumberTypeDecimals="1"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group required">
                <label for="<%= TB_IssueName.ClientID%>" class="control-label ">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IssueName%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_IssueName" runat="server" CssClass="form-control" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <asp:Button ID="BT_Save" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName%>" CssClass="btn btn-warning" OnClick="BT_Save_Click" />
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName%>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
            </div>
        </div>
    </div>
</asp:Content>
