<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="DeliveryLocation.aspx.cs" Inherits="TimeSheet_DeliveryLocation" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" Runat="Server">
    <script type="text/javascript">
        function OpenPage_M(LocationID) {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/DeliveryLocation_M.aspx") %>",
                iFrameOpenParameters: { LocationID: LocationID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_DeliveryLocation_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 950,
                height: 360,
                NewWindowPageDivID: "DeliveryLocation_M_DivID",
                NewWindowPageFrameID: "DeliveryLocation_M_FrameID",
                CloseEvent: function () {
                    window.location.reload();
                }
            });
        }

        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var LocationID = "";

                    if ($.inArray(JQGridDataValue.LocationIDColumnName, columnNames) > 0)
                        LocationID = $(this).jqGrid("getCell", RowID, JQGridDataValue.LocationIDColumnName);

                    if (LocationID != "")
                        OpenPage_M(LocationID);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" Runat="Server">
     <div class="col-xs-12 form-group">
        <input id="BT_Add" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName") %>" class="btn btn-primary" onclick="OpenPage_M('');"/>
    </div>
    <div class="col-xs-12 form-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_DeliveryLocationList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>


