<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="DeviceGroup_M.aspx.cs" Inherits="TimeSheet_DeviceGroup_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        $(function ()
        {
            if ($("#<%= TB_DeviceGroupID.ClientID%>").val().length < 1)
                $("#<%=BT_Delete.ClientID%>").hide();

            $("#BT_AddDeviceID").click(function ()
            {
                var FrameID = "DeviceSelect_FrameID";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/DeviceSelect.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_DeviceSelect_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 820,
                    height: 770,
                    NewWindowPageDivID: "DeviceSelect_DivID",
                    NewWindowPageFrameID: FrameID,
                    parentWindow: window.parent,
                    CloseEvent: function (result)
                    {
                        var DeviceID = $(result).find("#" + FrameID).contents().find("#HF_SelectDeviceID").val();
                        var MachineID = $(result).find("#" + FrameID).contents().find("#HF_SelectMachineID").val();
                        var MachineName = $(result).find("#" + FrameID).contents().find("#HF_SelectMachineName").val();

                        var JqGrid = $("#" + JqGridParameterObject.TableID);

                        var RowId = JqGrid.getGridParam("reccount") + 1;

                        var RowData = {
                            DeviceID: DeviceID,
                            MachineID: MachineID,
                            MachineName: MachineName
                        };

                        var jqdata = JqGrid.jqGrid("getRowData");

                        if ((jqdata.filter(F => F.DeviceID === DeviceID).length) < 1)
                            JqGrid.jqGrid("addRowData", RowId, RowData, "last");
                    }
                });
            });

            $("#BT_DeleteDeviceID").click(function ()
            {
                var JqGrid = $("#" + JqGridParameterObject.TableID);

                var SelRcowId = JqGrid.jqGrid("getGridParam", "selarrrow");

                /* 只能倒者刪除，不然每刪除一筆selarrrow會跟著邊化 */
                for (var row = SelRcowId.length - 1; row >= 0; row--)
                    JqGrid.jqGrid('delRowData', SelRcowId[row]);
            });
        });

        function CheckSubmit(IsDeleteAction)
        {
            var JqGrid = $("#" + JqGridParameterObject.TableID);

            var DeviceIDs = new Array();

            $.each(JqGrid.jqGrid("getRowData"), function (index, item)
            {
                DeviceIDs.push(item.DeviceID);
            });

            if (DeviceIDs.length < 1 && !$.StringConvertBoolean(IsDeleteAction))
            {
                $.AlertMessage({ Message: "<%= (string)GetLocalResourceObject("Str_Error_NoMachineRow")%>" });

                return false;
            }

            $("#<%= HF_GridDeviceID.ClientID%>").val(DeviceIDs.join("|"));

            return true;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DivID" runat="server" />
    <asp:HiddenField ID="HF_GridDeviceID" runat="server" />

    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceGroupList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <p></p>
                <div class="row">
                    <div class="col-xs-12 form-group ">
                        <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SaveName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click" OnClientClick="return CheckSubmit(0);" />
                        <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" OnClientClick="return CheckDelete(1);" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-4 form-group">
                        <label for="<%= TB_DeviceGroupID.ClientID%>" class="control-label ">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceGroupID %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_DeviceGroupID" runat="server" CssClass="form-control readonly readonlyColor"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_DeviceGroupName.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceGroupName %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_DeviceGroupName" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                    </div>
                </div>
                <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                    <div class="panel-heading text-center">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceGroupList%>"></asp:Literal>
                    </div>
                    <div class="panel-body">
                        <div>
                            <input type="button" class="btn btn-warning" id="BT_AddDeviceID" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName")%>" />
                            <input type="button" class="btn btn-danger" id="BT_DeleteDeviceID" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName")%>" />
                        </div>
                        <p></p>
                        <div id="JQContainerList"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

