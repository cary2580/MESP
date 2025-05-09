<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="DeviceSelect.aspx.cs" Inherits="TimeSheet_DeviceSelect" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridDblClickRow", function (e, RowID)
            {
                var rowData = $(this).jqGrid("getRowData", RowID);

                $("#<%=HF_SelectDeviceID.ClientID%>").val(rowData.DeviceID);
                $("#<%=HF_SelectMachineID.ClientID%>").val(rowData.MachineID);
                $("#<%=HF_SelectMachineName.ClientID%>").val(rowData.MachineName);

                parent.$("#" + $("#<%=HF_DivID.ClientID%>").val()).dialog("close");
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DivID" runat="server" />
    <asp:HiddenField ID="HF_SelectDeviceID" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="HF_SelectMachineID" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="HF_SelectMachineName" runat="server" ClientIDMode="Static" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <p></p>
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>

