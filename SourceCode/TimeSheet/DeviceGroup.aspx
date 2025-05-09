<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="DeviceGroup.aspx.cs" Inherits="TimeSheet_DeviceGroup" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#BT_Add").click(function ()
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
                    var DeviceGroupID = "";

                    if ($.inArray(JQGridDataValue.DeviceGroupIDColumnName, columnNames) > 0)
                        DeviceGroupID = $(this).jqGrid("getCell", RowID, JQGridDataValue.DeviceGroupIDColumnName);

                    if (DeviceGroupID != "")
                        OpenPage_M(DeviceGroupID);
                }
            });
        }

        function OpenPage_M(DeviceGroupID)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/DeviceGroup_M.aspx") %>",
                iFrameOpenParameters: { DeviceGroupID: DeviceGroupID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_DeviceGroup_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 810,
                height: 760,
                NewWindowPageDivID: "DeviceGroup_M_DivID",
                NewWindowPageFrameID: "DeviceGroup_M_FrameID",
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
                <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceGroupList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>


