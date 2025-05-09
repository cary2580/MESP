<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="DeviceArea.aspx.cs" Inherits="TimeSheet_DeviceArea" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        function CheckRequiredAdd()
        {
            if ($("#<%=DDL_AreaID.ClientID%>").val() == "")
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                return false;
            }
        }

        function CheckRequiredDelete()
        {
            var SelectCBKArrayID = new Array();

            var GridTable = $("#" + JqGridParameterObject.TableID + "");

            var rowKey = GridTable.jqGrid("getGridParam", "selrow");

            if (!rowKey)
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });

                return false;
            }

            var ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

            $.each(GridTable.getGridParam("selarrrow"), function (i, item)
            {
                var AreaID = "";

                if ($.grep(ColumnModel, function (Node) { return Node.name == JQGridDataValue.AreaIDColumnName; }).length > 0)
                    AreaID = GridTable.jqGrid("getCell", item, JQGridDataValue.AreaIDColumnName);

                if (AreaID != "")
                    SelectCBKArrayID.push(AreaID);
            });

            $("#<%=HF_DeleteAreaID.ClientID%>").val(SelectCBKArrayID.join("|"));
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DeleteAreaID" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-12">
                <asp:Button ID="BT_Add" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_BT_AddName%>" OnClick="BT_Add_Click" OnClientClick="return CheckRequiredAdd();" />
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%= DDL_AreaID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_AreaID%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_AreaID" runat="server" CssClass="form-control">
                </asp:DropDownList>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceAreaList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-12">
                <asp:Button ID="BT_Delete" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName%>" OnClick="BT_Delete_Click" OnClientClick="return CheckRequiredDelete();" />
            </div>
            <p>&nbsp;</p>
            <div class="col-xs-12 form-group">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
