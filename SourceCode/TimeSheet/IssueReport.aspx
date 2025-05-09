<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="IssueReport.aspx.cs" Inherits="TimeSheet_IssueReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {

            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
                $("#SearchResultListDiv").show();
            else
                $("#SearchResultListDiv").hide();

            if (!$.StringConvertBoolean($("#<%=HF_IsShowCreate.ClientID%>").val()))
                $("#BT_Create").hide();
            else {
                $("#BT_Create").click(function () {
                    OpenPage();
                });
            }
        });

        function OpenPage(CreateDate, WorkShiftID, DeviceID, MachineID) {

            $.OpenPage({
                iFrameOpenParameters: {
                    CreateDate: CreateDate ?? "",
                    WorkShiftID: WorkShiftID ?? "",
                    MachineID: MachineID ?? "",
                    DeviceID: DeviceID ?? ""
                },
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/IssueReport_M.aspx") %>",
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_IssueReport_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 1160,
                height: 560,
                TitleBarCloseButtonTriggerCloseEvent: true,
                CloseEvent: function (result) {

                    if ($.StringConvertBoolean($(result).find("#" + $.Main.Defaults.OpenPage.NewWindowPageFrameID).contents().find("#HF_IsRefresh").val()))
                        $("#<%=BT_Search.ClientID%>").trigger("click");
                }
            });
        }

        function JqEventBind() {

            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {

                let cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {

                    let ColumnNames = $.map(cm, function (value, index) { return value.name; });

                    let CreateDate = "";

                    let WorkShiftID = "";

                    let DeviceID = "";

                    let MachineID = "";

                    if ($.inArray(JQGridDataValue.CreateDateColumnName, ColumnNames) > 0)
                        CreateDate = $(this).jqGrid("getCell", RowID, JQGridDataValue.CreateDateColumnName);
                    if ($.inArray(JQGridDataValue.WorkShiftIDColumnName, ColumnNames) > 0)
                        WorkShiftID = $(this).jqGrid("getCell", RowID, JQGridDataValue.WorkShiftIDColumnName);
                    if ($.inArray(JQGridDataValue.DeviceIDColumnName, ColumnNames) > 0)
                        DeviceID = $(this).jqGrid("getCell", RowID, JQGridDataValue.DeviceIDColumnName);
                    if ($.inArray(JQGridDataValue.MachineIDColumnName, ColumnNames) > 0)
                        MachineID = $(this).jqGrid("getCell", RowID, JQGridDataValue.MachineIDColumnName);

                    OpenPage(CreateDate, WorkShiftID, DeviceID, MachineID);
                }
            });

            $("#" + JqGridParameterObject.TableID).bind("jqGridAfterGridComplete", function () {
                let Rows = $(this).jqGrid("getDataIDs");

                for (var i = 0; i < Rows.length; i++) {

                    let RowID = Rows[i];

                    let DifferentQTYColor = $(this).jqGrid("getCell", RowID, "DifferentQTYColor");

                    if (DifferentQTYColor != "")
                        $(this).jqGrid("setCell", RowID, "ScrapQtyByTotal", "", {
                            background: "red", color: "#FFFFFF"
                        });
                }
            });
        }

        function CheckDelete() {
            let JqGrid = $("#" + JqGridParameterObject.TableID);

            let SelectedList = new Array();

            $.each(JqGrid.jqGrid("getGridParam", "selarrrow"), function (index, item) {
                let RowData = JqGrid.jqGrid("getRowData", item);

                let Task = {
                    CreateDate: RowData[JQGridDataValue.CreateDateColumnName],
                    WorkShiftID: RowData[JQGridDataValue.WorkShiftIDColumnName],
                    DeviceID: RowData[JQGridDataValue.DeviceIDColumnName]
                };

                SelectedList.push(Task);
            });

            if (SelectedList.length < 1) {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_GridSelectZeroAlertMessage")%>" });

                return false;
            }

            $("#<%= HF_DeleteIssueItems.ClientID%>").val(JSON.stringify(SelectedList));

            return true;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsShowResultList" runat="server" Value="0" />
    <asp:HiddenField ID="HF_DeleteIssueItems" runat="server" />
    <asp:HiddenField ID="HF_IsShowCreate" runat="server" />
    <div class="col-xs-3 form-group required">
        <label for="<%= DDL_Machine.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_TS_Machine%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_Machine" runat="server" CssClass="form-control selectpicker show-tick" data-live-search="true" required="required">
        </asp:DropDownList>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_CreateDateStart.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_DateStart %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_CreateDateStart" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_CreateDateEnd.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_DateEnd %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_CreateDateEnd" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group">
        <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_TS_WorkCode%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
    </div>
    <div class="col-xs-12">
        <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
        <input id="BT_Create" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName") %>" class="btn btn-primary" />
    </div>
    <div class="col-xs-12">
        <p></p>
    </div>
    <div class="col-xs-12 form-group">
        <div id="SearchResultListDiv" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_IssueList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClientClick="return CheckDelete();" OnClick="BT_Delete_Click" />
                <p></p>
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
