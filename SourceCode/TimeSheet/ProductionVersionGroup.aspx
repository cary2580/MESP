<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ProductionVersionGroup.aspx.cs" Inherits="TimeSheet_ProductionVersionGroup" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#BT_Create").click(function ()
            {
                OpenPage_M("");
            });
        });

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName)
                {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var PVGroupID = "";

                    if ($.inArray(JQGridDataValue.PVGroupIDColumnName, columnNames) > 0)
                        PVGroupID = $(this).jqGrid("getCell", RowID, JQGridDataValue.PVGroupIDColumnName);

                    if (PVGroupID != "")
                        OpenPage_M(PVGroupID);
                }
            });
        }

        function OpenPage_M(ProductionVersionGroupID)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/ProductionVersionGroup_M.aspx") %>",
                iFrameOpenParameters: { ProductionVersionGroupID: ProductionVersionGroupID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_ProductionVersionGroup_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 920,
                height: 860,
                NewWindowPageDivID: "ProductionVersionGroup_M_DivID",
                NewWindowPageFrameID: "DProductionVersionGroup_M_FrameID",
                CloseEvent: function ()
                {
                    window.location.reload();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="col-xs-12 form-group">
        <input id="BT_Create" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_CreateName") %>" class="btn btn-primary" />
    </div>
    <div class="col-xs-12 form-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_ProductionVersionGroupList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
