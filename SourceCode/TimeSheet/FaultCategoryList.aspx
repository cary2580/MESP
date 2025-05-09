<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="FaultCategoryList.aspx.cs" Inherits="TimeSheet_FaultCategoryList" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#BT_Add").click(function ()
            {
                OpenPage("");
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
                    var FaultCategoryID = "";

                    if ($.inArray(JQGridDataValue.FaultCategoryIDColumnName, columnNames) > 0)
                        FaultCategoryID = $(this).jqGrid("getCell", RowID, JQGridDataValue.FaultCategoryIDColumnName);

                    if (FaultCategoryID != "")
                        OpenPage(FaultCategoryID);
                }
            });
        }

        function OpenPage(FaultCategoryID)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/FaultCategory_M.aspx") %>",
                iFrameOpenParameters: { FaultCategoryID: FaultCategoryID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_FaultCategory_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 610,
                height: 560,
                NewWindowPageDivID: "FaultCategory_M_DivID",
                NewWindowPageFrameID: "FaultCategory_M_FrameID",
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
        <input id="BT_Add" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName") %>" class="btn btn-primary" />
    </div>
    <div class="col-xs-12 form-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_FaultCategoryList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
