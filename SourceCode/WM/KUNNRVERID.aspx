<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="KUNNRVERID.aspx.cs" Inherits="WM_KUNNRVERID" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var KUNNR = "";
                    var KUNNR_Name = "";

                    if ($.inArray(JQGridDataValue.KUNNRColumnName, columnNames) > 0)
                        KUNNR = $(this).jqGrid("getCell", RowID, JQGridDataValue.KUNNRColumnName);

                    if ($.inArray(JQGridDataValue.KUNNR_NameColumnName, columnNames) > 0)
                        KUNNR_Name = $(this).jqGrid("getCell", RowID, JQGridDataValue.KUNNR_NameColumnName);

                    if (KUNNR != "")
                        OpenPage_M(KUNNR, KUNNR_Name);
                }
            });
        }

        function OpenPage_M(KUNNR, KUNNR_Name) {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/WM/KUNNRVERID_M.aspx") %>",
                iFrameOpenParameters: { KUNNR: KUNNR, KUNNR_Name: KUNNR_Name },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_KUNNRVERID_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 920,
                height: 860,
                NewWindowPageDivID: "KUNNRVERID_M_DivID",
                NewWindowPageFrameID: "KUNNRVERID_M_FrameID",
                CloseEvent: function () {
                    window.location.reload();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_KUNNRList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>

