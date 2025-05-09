<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="WorkStationGoOut.aspx.cs" Inherits="TimeSheet_WorkStationGoOut" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <style>
        .ui-jqgrid-hrtable {
            margin-bottom: 0px !important;
        }
    </style>
    <script type="text/javascript">
        $(function () {
            $("#<%=BT_Submit.ClientID%>,#<%=BT_Submit2.ClientID%>").hide();

            $("#BT_Confirm,#BT_Confirm2").click(function () {

                let ConfirmID = $(this).prop("id");

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_ConfirmMessage")%>", IsHtmlElement: true, CloseEvent: function (Result) {
                        if (!Result) {
                            event.preventDefault();

                            return;
                        }

                        if (ConfirmID == "BT_Confirm")
                            $("#<%=BT_Submit.ClientID%>").trigger("click");
                        else
                            $("#<%=BT_Submit2.ClientID%>").trigger("click");
                    }
                });
            });

            $("#BT_CreatePlanWorkMinute").click(function () {
                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/PlanWorkMinute_M.aspx") %>",
                    iFrameOpenParameters: { WorkCode: $("#<%=TB_SupervisorWorkCode.ClientID%>").val() },
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_PlanWorkMinute_M_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 860,
                    height: 560,
                    NewWindowPageDivID: "PlanWorkMinute_M_DivID",
                    NewWindowPageFrameID: "PlanWorkMinute_M_FrameID"
                });
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

            $("#" + JqGridParameterObject.TableID).bind("jqGridLoadComplete", function () {
                var Grid = $(this);

                var HeaderDataObject = {};

                $.each(HeaderDataColumns, function (index, item) {
                    HeaderDataObject[item] = Grid.jqGrid("getCol", item, false, "sum");
                });

                Grid.jqGrid("headerData", "set", HeaderDataObject);
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_AccountID" runat="server" />
    <asp:HiddenField ID="HF_ExtendResultMinute" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DailyReport%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-2 form-group required">
                <label for="<%= DDL_PayrollType.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_PayrollType%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_PayrollType" runat="server" CssClass="form-control" required="required">
                </asp:DropDownList>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCode%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control readonlyColor readonly" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group required">
                <label for="<%= TB_SupervisorWorkCode.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SupervisorWorkCode%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_SupervisorWorkCode" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
            </div>
            <div class="col-xs-5 form-group required">
                <label for="<%= TB_SupervisorPassword.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SupervisorPassword%>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_SupervisorPassword" runat="server" CssClass="form-control" required="required" TextMode="Password"></asp:TextBox>
                    <span class="input-group-btn">
                       <%-- <input id="BT_CreatePlanWorkMinute" type="button" class="btn btn-warning" value="<%= (string)GetLocalResourceObject("Str_Button_CreatePlanWorkMinute") %>" />--%>
                        <input id="BT_Confirm" type="button" class="btn btn-primary" value="<%= (string)GetLocalResourceObject("Str_Button_SubmitName") %>" />
                        <input id="BT_Confirm2" type="button" class="btn btn-warning" value="<%= (string)GetLocalResourceObject("Str_Button_SubmitName2") %>" />
                        <asp:Button ID="BT_Submit" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:Str_Button_SubmitName%>" OnClick="BT_Submit_Click" />
                        <asp:Button ID="BT_Submit2" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:Str_Button_SubmitName2%>" OnClick="BT_Submit_Click" />
                    </span>
                </div>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketResultList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>
