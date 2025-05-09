<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="FaultMappingList.aspx.cs" Inherits="TimeSheet_FaultMappingList" %>

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
                    var FaultCategoryID = "";

                    if ($.inArray(JQGridDataValue.FaultCategoryIDColumnName, columnNames) > 0)
                        FaultCategoryID = $(this).jqGrid("getCell", RowID, JQGridDataValue.FaultCategoryIDColumnName);

                    if (FaultCategoryID != "" && JQGridDataValue.LinkFaultMapping == cm[CellIndex].name)
                        //開啟故障代碼資對應維護畫面
                        OpenPage_M(FaultCategoryID);
                    else if (FaultCategoryID != "" && JQGridDataValue.LinkFaultMappingPLNBEZColumnName == cm[CellIndex].name)
                        //開啟物料對應維護畫面
                        OpenPage_MPLNBEZ(FaultCategoryID);
                }
            });
        }

        function OpenPage_M(FaultCategoryID)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/FaultMapping_M.aspx") %>",
                iFrameOpenParameters: { FaultCategoryID: FaultCategoryID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_FaultMapping_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 810,
                height: 760,
                NewWindowPageDivID: "FaultMapping_M_DivID",
                NewWindowPageFrameID: "FaultMapping_M_FrameID",
                CloseEvent: function ()
                {
                    window.location.reload();
                }
            });
        }

        function OpenPage_MPLNBEZ(FaultCategoryID)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/FaultMappingPLNBEZ_M.aspx") %>",
                iFrameOpenParameters: { FaultCategoryID: FaultCategoryID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_FaultMappingPLNBEZ_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 810,
                height: 760,
                NewWindowPageDivID: "FaultMappingPLNBEZ_M_DivID",
                NewWindowPageFrameID: "FaultMappingPLNBEZ_M_FrameID",
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
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_FaultMappingList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>

