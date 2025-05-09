<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" meta:resourcekey="PageResource1" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("form").everyTime("1ms", "LoadPage", function () {
                $(this).stopTime("LoadPage");

                $.removeCookie("Guid", { path: "/" });

                $.cookie("Guid", $("#Guid").val(), { path: "/" });

                $("#Guid").remove();

                $.LocationHrefPost("<%= ResolveClientUrl(@"~/Index.aspx")%>");
            });
        });
    </script>
</asp:Content>

