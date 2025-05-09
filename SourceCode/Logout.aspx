<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Logout.aspx.cs" Inherits="Logout" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {

            $.removeCookie("IsAdmin", { path: "/" });
            $.removeCookie("Guid", { path: "/" });
            $.removeCookie("AccountID", { path: "/" });
            $.removeCookie("AccountName", { path: "/" });

            window.location.href = $("#HomeAddress").val();;
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" Runat="Server">
</asp:Content>

