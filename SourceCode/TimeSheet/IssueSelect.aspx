<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="IssueSelect.aspx.cs" Inherits="TimeSheet_IssueSelect" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridDblClickRow", function (e, RowID) {
                var rowData = $(this).jqGrid("getRowData", RowID);

                $("#<%=HF_IssueID.ClientID%>").val(rowData.IssueID);
                $("#<%=HF_IssueName.ClientID%>").val(rowData.IssueName);

                parent.$("#" + $("#<%=HF_DivID.ClientID%>").val()).dialog("close");
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DivID" runat="server" />
    <asp:HiddenField ID="HF_IssueID" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="HF_IssueName" runat="server" ClientIDMode="Static" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IssueList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <p></p>
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>
