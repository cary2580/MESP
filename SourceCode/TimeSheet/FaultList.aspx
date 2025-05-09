<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="FaultList.aspx.cs" Inherits="TimeSheet_FaultList" %>

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
                    var FaultID = "";

                    if ($.inArray(JQGridDataValue.FaultIDColumnName, columnNames) > 0)
                        FaultID = $(this).jqGrid("getCell", RowID, JQGridDataValue.FaultIDColumnName);

                    if (FaultID != "")
                        OpenPage(FaultID);
                }
            });
        }

        function OpenPage(FaultID)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/Fault_M.aspx") %>",
                iFrameOpenParameters: { FaultID: FaultID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_Fault_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 610,
                height: 560,
                NewWindowPageDivID: "Fault_M_DivID",
                NewWindowPageFrameID: "Fault_M_FrameID",
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
                <asp:Literal runat="server" Text="<%$ Resources:Str_FaultList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>

