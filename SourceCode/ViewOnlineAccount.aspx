<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ViewOnlineAccount.aspx.cs" Inherits="ViewOnlineAccount" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_JqgridTitleColor") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text=" <%$ Resources:Str_ListContainerTitle %>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>
