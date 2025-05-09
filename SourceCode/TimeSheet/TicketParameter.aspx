<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="TicketParameter.aspx.cs" Inherits="TimeSheet_TicketParameter" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName)
                {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");

                    if ($.inArray(JQGridDataValue.TicketParameterColumnNameByMATNRValue, columnNames) > 0 && $.inArray(JQGridDataValue.TicketParameterColumnNameByPLNNRValue, columnNames) > 0 && $.inArray(JQGridDataValue.TicketParameterColumnNameByPLNALValue, columnNames) > 0)
                    {

                        var MATNR = $(this).jqGrid("getCell", RowID, JQGridDataValue.TicketParameterColumnNameByMATNRValue);
                        var PLNNR = $(this).jqGrid("getCell", RowID, JQGridDataValue.TicketParameterColumnNameByPLNNRValue);
                        var PLNAL = $(this).jqGrid("getCell", RowID, JQGridDataValue.TicketParameterColumnNameByPLNALValue);

                        if (MATNR != "" && PLNNR != "" && PLNAL != "")
                        {
                            $.OpenPage({
                                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/TicketParameter_M.aspx") %>",
                                iFrameOpenParameters: { MATNR: MATNR, PLNNR: PLNNR, PLNAL: PLNAL },
                                TitleBarText: "<%=(string)GetLocalResourceObject("Str_TicketParameter_M_Title") %>",
                                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                                width: 810,
                                height: 540,
                                NewWindowPageDivID: "TicketParameter_M_DivID",
                                NewWindowPageFrameID: "TicketParameter_M_FrameID",
                                CloseEvent: function ()
                                {
                                    window.location.reload();
                                }
                            });
                        }
                    }
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketParameterList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>

