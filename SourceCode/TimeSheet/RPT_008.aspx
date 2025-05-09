<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="RPT_008.aspx.cs" Inherits="TimeSheet_RPT_008" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">

    <link rel="stylesheet" type="text/css" href="<%#ResolveClientUrl(@"~/vendor/print/print.min.css") %>">
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/print/print.min.js") %>"></script>

    <script type="text/javascript">
        $(function ()
        {
            printJS({
                printable: "<%=RPTBase64%>", type: "pdf", base64: true, onPrintDialogClose: function ()
                {
                    window.close();
                }
            });
        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
</asp:Content>


