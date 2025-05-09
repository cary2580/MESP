<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="IssueCategoryMappingDevice.aspx.cs" Inherits="TimeSheet_IssueCategoryMappingDevice" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        $(function () {

            $("#<%=TB_MachineName.ClientID%>").css("cursor", "pointer").click(function () {

                let FrameID = "DeviceSelect_FrameID";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/DeviceSelect.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_DeviceSelect_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 820,
                    height: 770,
                    NewWindowPageDivID: "DeviceSelect_DivID",
                    NewWindowPageFrameID: FrameID,
                    parentWindow: window.parent,
                    CloseEvent: function (result) {

                        let DeviceID = $(result).find("#" + FrameID).contents().find("#HF_SelectDeviceID").val();
                        let MachineName = $(result).find("#" + FrameID).contents().find("#HF_SelectMachineName").val();

                        $("#<%=HF_DeviceID.ClientID%>").val(DeviceID);
                        $("#<%=TB_MachineName.ClientID%>").val(MachineName);
                    }
                });

            });
        });

        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {

                $("#<%= TB_MachineName.ClientID%>").val($(this).jqGrid("getCell", RowID, JQGridDataValue.MachineNameColumnName));

                $("#<%= HF_DeviceID.ClientID%>").val($(this).jqGrid("getCell", RowID, JQGridDataValue.DeviceIDColumnName));
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_CategoryID" runat="server" />
    <asp:HiddenField ID="HF_DeviceID" runat="server" />
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-body">
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_CategoryName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_CategoryName %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_CategoryName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_MachineName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MachineName %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MachineName" runat="server" CssClass="form-control readonly" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-12 form-group" style="text-align: center">
                    <asp:Button ID="BT_Add" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click" />
                    <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
                </div>
            </div>
        </div>
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="col-xs-12 form-group">
                    <div id="JQContainerList"></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
