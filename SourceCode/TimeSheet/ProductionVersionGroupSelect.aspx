<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="ProductionVersionGroupSelect.aspx.cs" Inherits="TimeSheet_ProductionVersionGroupSelect" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridDblClickRow", function (e, RowID)
            {
                var rowData = $(this).jqGrid("getRowData", RowID);

                $("#<%=HF_PVGroupID.ClientID%>").val(rowData[JQGridDataValue.PVGroupIDColumnName]);
                $("#<%=HF_PVGroupName.ClientID%>").val(rowData[JQGridDataValue.PVGroupNameColumnName]);

                parent.$("#" + $("#<%=HF_DivID.ClientID%>").val()).dialog("close");
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DivID" runat="server" />
    <asp:HiddenField ID="HF_PVGroupID" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="HF_PVGroupName" runat="server" ClientIDMode="Static" />

    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ProductionVersionGroupList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <p></p>
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>
