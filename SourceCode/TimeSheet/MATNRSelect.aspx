<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="MATNRSelect.aspx.cs" Inherits="TimeSheet_MATNRSelect" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        function ConfirmSubmit()
        {
            var JqGrid = $("#" + JqGridParameterObject.TableID);

            var SelectedList = new Array();

            $.each(JqGrid.jqGrid("getGridParam", "selarrrow"), function (index, item)
            {
                var RowData = JqGrid.jqGrid("getRowData", item);

                SelectedList.push({
                    MATNR: RowData[JQGridDataValue.MATNRColumnName],
                    MAKTX: RowData[JQGridDataValue.MAKTXColumnName],
                });
            });

            $("#<%= HF_MATNR.ClientID%>").val(JSON.stringify(SelectedList));

            parent.$("#" + $("#<%=HF_DivID.ClientID%>").val()).dialog("close");

            return false;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DivID" runat="server" />
    <asp:HiddenField ID="HF_MATNR" runat="server" ClientIDMode="Static" />

    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MATNRList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="row">
                <div class="col-xs-12 form-group ">
                    <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_ConfirmName %>" CssClass="btn btn-warning" OnClientClick="return ConfirmSubmit();" />
                </div>
            </div>
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>
