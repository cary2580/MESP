<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="SalesOrderSelect.aspx.cs" Inherits="WM_SalesOrderSelect" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridDblClickRow", function (e, RowID)
            {
                var RowData = $(this).jqGrid("getRowData", RowID);

                $("#<%=HF_SelectedValue.ClientID%>").val(JSON.stringify({
                    KUNNR: RowData[JQGridDataValue.KUNNRColumnName],
                    KUNNR_NAME: RowData[JQGridDataValue.KUNNR_NAMEColumnName],
                    VBELN: RowData[JQGridDataValue.VBELNColumnName],
                    POSNR: RowData[JQGridDataValue.POSNRColumnName],
                    MATNR: RowData[JQGridDataValue.MATNRColumnName],
                    MAKTX: RowData[JQGridDataValue.MAKTXColumnName],
                    KDMAT: RowData[JQGridDataValue.KDMATColumnName],
                    KWMENG: RowData[JQGridDataValue.KWMENGColumnName],
                    LFIMG: RowData[JQGridDataValue.LFIMGColumnName],
                    BSTKD: RowData[JQGridDataValue.BSTKDColumnName],
                    DeliveryDate: RowData[JQGridDataValue.CMTD_DELIV_DATEColumnName],
                    AllowQty: RowData[JQGridDataValue.ALLOWQTYColumnName]
                }));

                parent.$("#" + $("#<%=HF_DivID.ClientID%>").val()).dialog("close");
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DivID" runat="server" />
    <asp:HiddenField ID="HF_SelectedValue" runat="server" ClientIDMode="Static" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_SalesOrderList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>
