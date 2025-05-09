<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="TicketMaintainFault.aspx.cs" Inherits="TimeSheet_TicketMaintainFault" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        var FaultCategoryIDColumnName = "";
        var FaultIDColumnName = "";

        $(function ()
        {
            $("#<%=DDL_FaultCategory.ClientID%>").change(function ()
            {
                var FaultCategoryID = $(this).val();

                if (FaultCategoryID == "")
                {
                    $("#<%=DDL_Fault.ClientID%> option").remove();

                    $("#<%=DDL_Fault.ClientID%>").selectpicker("destroy");

                    $("#<%=DDL_Fault.ClientID%>").selectpicker("refresh");

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/FaultGet.ashx")%>",
                    data: { FaultCategoryID: FaultCategoryID },
                    CallBackFunction: function (data)
                    {
                        $("#<%=DDL_Fault.ClientID%> option").remove();

                        $("#<%=DDL_Fault.ClientID%>").selectpicker("destroy");

                        $.each(data, function (i, item)
                        {
                            $("#<%=DDL_Fault.ClientID%>").append($("<option></option>").attr("value", item["FaultID"]).text(item["FaultName"]));
                        });

                        $("#<%=DDL_Fault.ClientID%>").selectpicker();

                        $("#<%=DDL_Fault.ClientID%>").selectpicker("refresh");
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=DDL_Fault.ClientID%> option").remove();

                        $("#<%=DDL_Fault.ClientID%>").selectpicker('destroy');

                        $("#<%=DDL_Fault.ClientID%>").selectpicker('refresh');
                    }
                });
            });

            $("#BT_Add").click(function ()
            {
                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainFaultAdd.ashx")%>",
                    data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val(), FaultCategoryID: $("#<%=DDL_FaultCategory.ClientID%>").find(":selected").val(), FaultID: $("#<%=DDL_Fault.ClientID%>").find(":selected").val() },
                    CallBackFunction: function (data)
                    {
                        LoadFaultList();
                    }
                });
            });

            $("#BT_Delete").click(function ()
            {
                var SelectCBKArrayID = new Array();

                var GridTable = $("#" + JqGridParameterObject.TableID);

                var rowKey = GridTable.jqGrid("getGridParam", "selrow");

                if (!rowKey)
                {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });
                    return false;
                }

                var ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

                $.each(GridTable.getGridParam("selarrrow"), function (i, item)
                {
                    var FaultCategoryID = "";
                    var FaultID = "";

                    if ($.grep(ColumnModel, function (Node) { return Node.name == FaultCategoryIDColumnName; }).length > 0)
                        FaultCategoryID = GridTable.jqGrid("getCell", item, FaultCategoryIDColumnName);
                    if ($.grep(ColumnModel, function (Node) { return Node.name == FaultIDColumnName; }).length > 0)
                        FaultID = GridTable.jqGrid("getCell", item, FaultIDColumnName);

                    if (FaultCategoryID != "" && FaultID != "")
                        SelectCBKArrayID.push({ FaultCategoryID: FaultCategoryID, FaultID: FaultID });
                });

                $.Ajax({
                    url: "<%=ResolveClientUrl("~/TimeSheet/Service/TicketMaintainFaultDelete.ashx") %>", data: {
                        MaintainID: $("#<%=HF_MaintainID.ClientID%>").val(),
                        FaultList: JSON.stringify(SelectCBKArrayID)
                    }, CallBackFunction: function (data)
                    {
                        LoadFaultList();
                    }
                });
            });

            LoadFaultList();
        });

        function LoadFaultList()
        {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainFaultGet.ashx")%>",
                data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val() },
                CallBackFunction: function (data)
                {
                    FaultCategoryIDColumnName = data.FaultCategoryIDColumnName;
                    FaultIDColumnName = data.FaultIDColumnName;
                    LoadGridData({ IsShowJQGridPager: false, IsMultiSelect: true, JQGridDataValue: data });
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_MaintainID" runat="server" />
    <asp:HiddenField ID="HF_PLNBEZ" runat="server" />
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_FaultCategory.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_FaultCategory%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_FaultCategory" runat="server" CssClass="form-control" required="required">
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_Fault.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Fault%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_Fault" runat="server" CssClass="form-control" required="required" data-live-search="true">
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 form-group">
        <input type="button" class="btn btn-primary" id="BT_Add" value="<%=(string)GetLocalResourceObject("Str_BT_Add")%>" />
        <input type="button" class="btn btn-danger" id="BT_Delete" value="<%=(string)GetLocalResourceObject("Str_BT_Delete")%>" />
    </div>
    <div class="col-xs-12">
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
