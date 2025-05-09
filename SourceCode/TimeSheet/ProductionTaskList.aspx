<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ProductionTaskList.aspx.cs" Inherits="TimeSheet_ProductionTaskList" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
                $("#SearchResultListDiv").show();
            else
                $("#SearchResultListDiv").hide();

            $("#BT_Create").click(function () {
                OpenPage_M("", "", false);
            });

            $("#BT_BatchImport").click(function () {
                OpenPage_M("", "", true);
            });

        });

        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var TaskDateTime = "";
                    var PVGroupID = "";

                    if ($.inArray(JQGridDataValue.TaskDateTimeColumnName, columnNames) > 0)
                        TaskDateTime = $(this).jqGrid("getCell", RowID, JQGridDataValue.TaskDateTimeColumnName);
                    if ($.inArray(JQGridDataValue.PVGroupIDColumnName, columnNames) > 0)
                        PVGroupID = $(this).jqGrid("getCell", RowID, JQGridDataValue.PVGroupIDColumnName);

                    if (TaskDateTime != "" && PVGroupID != "")
                        OpenPage_M(TaskDateTime, PVGroupID, false);
                }
            });
        }

        function OpenPage_M(TaskDateTime, PVGroupID, IsInport) {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/ProductionTask_M.aspx") %>",
                iFrameOpenParameters: { TaskDateTime: TaskDateTime, PVGroupID: PVGroupID, IsInport: IsInport },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_ProductionTask_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 920,
                height: 860,
                NewWindowPageDivID: "ProductionTask_M_DivID",
                NewWindowPageFrameID: "ProductionTask_M_FrameID",
                CloseEvent: function () {

                    $("#<%=HF_DeleteProductionTasks.ClientID%>").val("");

                    $("#<%=BT_Search.ClientID%>").trigger("click");
                }
            });
        }

        function CheckDelete() {
            var JqGrid = $("#" + JqGridParameterObject.TableID);

            var SelectedList = new Array();

            $.each(JqGrid.jqGrid("getGridParam", "selarrrow"), function (index, item) {
                var RowData = JqGrid.jqGrid("getRowData", item);

                var Task = {
                    TaskDateTime: RowData[JQGridDataValue.TaskDateTimeColumnName],
                    PVGroupID: RowData[JQGridDataValue.PVGroupIDColumnName]
                };

                SelectedList.push(Task);
            });

            if (SelectedList.length < 1) {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_GridSelectZeroAlertMessage")%>" });

                return false;
            }

            $("#<%= HF_DeleteProductionTasks.ClientID%>").val(JSON.stringify(SelectedList));

            return true;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsShowResultList" runat="server" Value="0" />
    <asp:HiddenField ID="HF_DeleteProductionTasks" runat="server" />

    <div class="col-xs-3 form-group required">
        <label for="<%= TB_TaskDateStart.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TaskDateStart %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_TaskDateStart" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_TaskDateEnd.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TaskDateEnd %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_TaskDateEnd" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group">
        <label for="<%= TB_PVGroupID.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_PVGroupID %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_PVGroupID" runat="server" CssClass="form-control"></asp:TextBox>
    </div>
    <div class="col-xs-12">
        <input id="BT_Create" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName") %>" class="btn btn-primary" />
        <input id="BT_BatchImport" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ImportName") %>" class="btn btn-success" />
        <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
    </div>
    <div class="col-xs-12">
        <p></p>
    </div>
    <div class="col-xs-12 form-group">
        <div id="SearchResultListDiv" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor11") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_ProductionTaskList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClientClick="return CheckDelete();" OnClick="BT_Delete_Click" />
                <p></p>
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
