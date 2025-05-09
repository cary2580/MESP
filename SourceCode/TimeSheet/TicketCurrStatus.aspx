<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="TicketCurrStatus.aspx.cs" Inherits="TimeSheet_TicketCurrStatus" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        $(function () {

            $("#<%=BT_Delete.ClientID%>").hide();

            if (!$.StringConvertBoolean($("#<%= HF_IsAdmin.ClientID%>").val()))
                $("#BT_Delete_V").hide();

            $("#BT_Delete_V").click(function () {

                let GridTable = $("#" + JqGridParameterObject.TableID);

                let SelRcowId = GridTable.jqGrid("getGridParam", "selarrrow");

                if (SelRcowId.length < 1) {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });

                    return false;
                }

                let SelectCBKArrayID = new Array();

                let ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

                $.each(GridTable.getGridParam("selarrrow"), function (i, item) {
                    let TicketID = "";

                    if ($.grep(ColumnModel, function (Node) { return Node.name == JQGridDataValue.TicketIDColumnName; }).length > 0)
                        TicketID = GridTable.jqGrid("getCell", item, JQGridDataValue.TicketIDColumnName);

                    if (TicketID != "")
                        SelectCBKArrayID.push(TicketID);
                });

                $("#<%=HF_TicketIDList.ClientID%>").val(JSON.stringify(SelectCBKArrayID));

                $("#<%=BT_Delete.ClientID%>").trigger("click")
            });

        });

        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var TicketIDValue = "";

                    if ($.inArray(JQGridDataValue.TicketIDColumnName, columnNames) > 0)
                        TicketIDValue = $(this).jqGrid("getCell", RowID, JQGridDataValue.TicketIDColumnName);

                    if (TicketIDValue != "")
                        $.WindowOpen("Post", "<%=ResolveClientUrl(@"~/TimeSheet/TicketLifeCycle.aspx?A2=")%>" + TicketIDValue);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_TicketIDList" runat="server" />
    <asp:HiddenField ID="HF_IsAdmin" runat="server" />
    <div id="SearchResultListDiv" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ResultList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-12 form-group">
                <input type="button" class="btn btn-danger" id="BT_Delete_V" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName")%>" />
                <asp:Button ID="BT_Delete" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" OnClick="BT_Delete_Click" UseSubmitBehavior="false" />
            </div>
            <div class="col-xs-12 form-group">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
