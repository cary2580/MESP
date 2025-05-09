<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="DeviceList.aspx.cs" Inherits="TimeSheet_DeviceList" %>

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
                    var DeviceID = "";

                    if ($.inArray(JQGridDataValue.DeviceIDColumnName, columnNames) > 0)
                        DeviceID = $(this).jqGrid("getCell", RowID, JQGridDataValue.DeviceIDColumnName);

                    if (DeviceID != "" && JQGridDataValue.LinkMachineName == cm[CellIndex].name)
                        //開啟維護設備畫面
                        OpenPage_M(DeviceID);
                    if (DeviceID != "" && JQGridDataValue.LinkAreaName == cm[CellIndex].name)
                        //開啟維護區域畫面
                        OpenPage_DeviceArea(DeviceID);
                    else if (DeviceID != "" && JQGridDataValue.LinkDeviceViewGroup == cm[CellIndex].name)
                        //開啟檢視群組畫面
                        OpenPage_DeviceViewGroup(DeviceID);

                }
            });
        }

        function OpenPage_M(DeviceID)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/Device_M.aspx") %>",
                iFrameOpenParameters: { DeviceID: DeviceID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Device_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 1000,
                height: 660,
                NewWindowPageDivID: "Device_M_DivID",
                NewWindowPageFrameID: "Device_M_FrameID",
                CloseEvent: function ()
                {
                    window.location.reload();
                }
            });
        }

        function OpenPage_DeviceArea(DeviceID)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/DeviceArea.aspx") %>",
                iFrameOpenParameters: { DeviceID: DeviceID },
                TitleBarText: "<%=(string)GetLocalResourceObject("DeviceArea_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                TitleBarCloseButtonTriggerCloseEvent: true,
                width: 810,
                height: 660,
                NewWindowPageDivID: "DeviceArea_M_DivID",
                NewWindowPageFrameID: "DeviceArea_M_FrameID",
                CloseEvent: function ()
                {
                    window.location.reload();
                }
            });
        }

        function OpenPage_DeviceViewGroup(DeviceID)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/DeviceViewGroup.aspx") %>",
                iFrameOpenParameters: { DeviceID: DeviceID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_DeviceViewGroup_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 810,
                height: 600,
                NewWindowPageDivID: "DeviceViewGroup_DivID",
                NewWindowPageFrameID: "DeviceViewGroup_FrameID",
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
                <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>

