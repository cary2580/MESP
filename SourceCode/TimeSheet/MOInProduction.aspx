<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="MOInProduction.aspx.cs" Inherits="TimeSheet_MOInProduction" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        let ShortHideFields = new Array();

        $(function () {

            let Rows = $("#" + JqGridParameterObject.TableID).jqGrid("getDataIDs");

            if ($.StringConvertBoolean($("#<%= HF_IsPMC.ClientID%>").val()) && !$.StringConvertBoolean($("#<%= DDL_IsInProduction.ClientID%>").val()) && Rows.length > 0)
                $("#BT_Activity").removeClass("disabled").show();
            else
                $("#BT_Activity").addClass("disabled").hide();

            if ($.StringConvertBoolean($("#<%= HF_IsPMC.ClientID%>").val()))
                $("#BT_Create,#BT_Delete").removeClass("disabled").show();
            else
                $("#BT_Create,#BT_Delete").addClass("disabled").hide();

            $("#BT_Activity").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                let GridTable = $("#" + JqGridParameterObject.TableID);

                let SelRcowId = GridTable.jqGrid("getGridParam", "selarrrow");

                if (SelRcowId.length < 1) {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });

                    return false;
                }

                let SelectCBKArrayID = new Array();

                let ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

                $.each(GridTable.getGridParam("selarrrow"), function (i, item) {
                    let AUFNR = "";

                    if ($.grep(ColumnModel, function (Node) { return Node.name == JQGridDataValue.AUFNRIDColumnName; }).length > 0)
                        AUFNR = GridTable.jqGrid("getCell", item, JQGridDataValue.AUFNRIDColumnName);

                    if (AUFNR != "")
                        SelectCBKArrayID.push(AUFNR);
                });

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_ActivityConfirmMessage") %>", IsHtmlElement: true, CloseEvent: function (result) {
                        if (result) {
                            $.Ajax({
                                url: "<%=ResolveClientUrl("~/TimeSheet/Service/MOActivity.ashx") %>", data: {
                                    AUFNRList: JSON.stringify(SelectCBKArrayID)
                                }, CallBackFunction: function (data) {
                                    window.location.reload();
                                }
                            });
                        }
                    }
                });
            });

            $("#BT_Create").click(function () {

                if ($(this).hasClass("disabled"))
                    return;

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/MOCreate.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_MOCreate_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 920,
                    height: 560,
                    NewWindowPageDivID: "MOCreate_DivID",
                    NewWindowPageFrameID: "MOCreate_FrameID",
                    CloseEvent: function () {
                        window.location.reload();
                    }
                });
            });

            $("#BT_Delete").click(function () {

                if ($(this).hasClass("disabled"))
                    return;

                let GridTable = $("#" + JqGridParameterObject.TableID);

                let SelRcowId = GridTable.jqGrid("getGridParam", "selarrrow");

                if (SelRcowId.length < 1) {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });

                    return false;
                }

                let SelectCBKArrayID = new Array();

                let ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

                $.each(GridTable.getGridParam("selarrrow"), function (i, item) {
                    let AUFNR = "";

                    if ($.grep(ColumnModel, function (Node) { return Node.name == JQGridDataValue.AUFNRIDColumnName; }).length > 0)
                        AUFNR = GridTable.jqGrid("getCell", item, JQGridDataValue.AUFNRIDColumnName);

                    if (AUFNR != "")
                        SelectCBKArrayID.push(AUFNR);
                });

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_DeleteConfirmMessage") %>", IsHtmlElement: true, CloseEvent: function (result) {
                        if (result) {
                            $.Ajax({
                                url: "<%=ResolveClientUrl("~/TimeSheet/Service/MODelete.ashx") %>", data: {
                                    AUFNRList: JSON.stringify(SelectCBKArrayID)
                                }, CallBackFunction: function (data) {
                                    window.location.reload();
                                }
                            });
                        }
                    }
                });
            });

            $("#BT_ListFieldChange").click(function () {

                let IsShort = $.StringConvertBoolean($(this).data("isshort"));

                let Action = !IsShort ? "hideCol" : "showCol";

                $("#" + JqGridParameterObject.TableID).jqGrid(Action, ShortHideFields).trigger("resize");

                if (!IsShort)
                    $(this).attr("value", "<%=(string)GetLocalResourceObject("Str_BT_LongField")%>");
                else
                    $(this).attr("value", "<%=(string)GetLocalResourceObject("Str_BT_ShortField")%>");

                $(this).data("isshort", !IsShort);
            })
        });

        function LoadGridDataCustomColModel(PO, colModel) {

            if (PO.TableID == JqGridParameterObject.TableID) {

                $.each(colModel, function (Index, Item) {

                    let LocalizedNumericColumnName = $.grep(JQGridDataValue.CustiomFormatterLocalizedNumericColumnNames, function (ColumnName) {
                        return ColumnName === Item.name;
                    });

                    if (LocalizedNumericColumnName.length > 0) {
                        colModel[Index].formatter = function (CellValue, Option, RowObject) {
                            return numeral(CellValue).format("0,0");
                        };

                        colModel[Index].unformat = function (CellValue, Option) {
                            return numeral(CellValue).value();
                        };
                    }
                });
            }

            return colModel;
        }

        function JqEventBind(PO) {
            if (PO.TableID == JqGridParameterObject.TableID) {

                ShortHideFields = JQGridDataValue.ShortHideFields;

                $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                    var cm = $(this).jqGrid("getGridParam", "colModel");

                    if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {
                        var columnNames = $(this).jqGrid("getGridParam", "colNames");

                        var AUFNR = "";

                        if ($.inArray(JQGridDataValue.AUFNRIDColumnName, columnNames) > 0)
                            AUFNR = $(this).jqGrid("getCell", RowID, JQGridDataValue.AUFNRIDColumnName);

                        if (AUFNR != "" && JQGridDataValue.AUFNRColumnName == cm[CellIndex].name)
                            $.WindowOpen("Post", "<%=ResolveClientUrl(@"~/TimeSheet/MOSearch.aspx?ViewInside=") + true.ToStringValue().ToBase64String(true)%>&AUFNR=" + AUFNR);
                        else if (AUFNR != "" && JQGridDataValue.AUARTNameColumnName == cm[CellIndex].name) {
                            $.OpenPage({
                                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/MOViewer.aspx") %>",
                                iFrameOpenParameters: { AUFNR: AUFNR },
                                TitleBarText: "<%=(string)GetLocalResourceObject("Str_MOViewer_TitleBarText") %>",
                                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                                width: 810,
                                height: 650,
                                NewWindowPageDivID: "MOViewer_DivID",
                                NewWindowPageFrameID: "MOViewer_Frame"
                            });
                        }
                    }
                });

                $("#" + JqGridParameterObject.TableID).bind("jqGridAfterGridComplete", function () {
                    var Rows = $(this).jqGrid("getDataIDs");

                    for (var i = 0; i < Rows.length; i++) {
                        var RowID = Rows[i];

                        var PSMNG = $(this).jqGrid("getCell", RowID, JQGridDataValue.PSMNGColumnName);

                        var TicketQty = $(this).jqGrid("getCell", RowID, JQGridDataValue.TicketQtyColumnName);

                        var LastProcessGoodQty = $(this).jqGrid("getCell", RowID, JQGridDataValue.LastProcessGoodQtyColumnName);

                        var WEMNG = $(this).jqGrid("getCell", RowID, JQGridDataValue.WEMNGColumnName);

                        var CompletionRate = $(this).jqGrid("getCell", RowID, JQGridDataValue.CompletionRateValueColumnName);

                        if (PSMNG != TicketQty)
                            $(this).jqGrid("setCell", RowID, JQGridDataValue.TicketQtyColumnName, "", { background: JQGridDataValue.TicketQtyColumnName, color: "red", "font-weight": "bold" });
                        if (LastProcessGoodQty - WEMNG < 1)
                            $(this).jqGrid("setCell", RowID, JQGridDataValue.WEMNGColumnName, "", { background: JQGridDataValue.WEMNGColumnName, color: "#484891", "font-weight": "bold" });
                        if (CompletionRate >= 0.998)
                            $(this).jqGrid("setCell", RowID, JQGridDataValue.CompletionRateColumnName, "", { background: JQGridDataValue.CompletionRateColumnName, color: "#484891", "font-weight": "bold" });
                    }
                });
            }
            else {

                $("#" + PO.TableID).bind("jqGridAfterGridComplete", function () {
                    var Rows = $(this).jqGrid("getDataIDs");

                    for (var i = 0; i < Rows.length; i++) {
                        var RowID = Rows[i];

                        var ColorCss = $(this).jqGrid("getCell", RowID, "ReportColor");

                        if (ColorCss != "")
                            $(this).jqGrid("setCell", RowID, "GoodQty", "", { background: ColorCss, color: "#FFFFFF" });
                    }
                });
            }
        }

        function JqHasSubGridRowFunction(RowID) {
            var IsHaveTicket = false;

            var TicketQty = $("#" + JqGridParameterObject.TableID).jqGrid("getCell", RowID, JQGridDataValue.TicketQtyColumnName);

            IsHaveTicket = (TicketQty > 0);

            return IsHaveTicket;
        }

        function JqSubGridRowExpandedEvent(ParentRowID, ParentRowKey) {
            var AUFNR = $("#" + JqGridParameterObject.TableID).jqGrid("getCell", ParentRowKey, JQGridDataValue.AUFNRIDColumnName);

            $("#" + JqGridParameterObject.TableID).jqGrid("setSelection", ParentRowKey);

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/MORoutingResultGet.ashx") %>", data: {
                    AUFNR: AUFNR,
                }, CallBackFunction: function (data) {
                    SetSubGridData(ParentRowID, ParentRowKey, data);
                }
            });
        }

        function SetSubGridData(ParentRowID, ParentRowKey, GridData) {
            var JqSubGridID = ParentRowID + "_Table";
            var JqSubGridPagerID = ParentRowID + "_Pager";

            LoadGridData({
                IsExtendJqGridParameterObject: false,
                ListID: ParentRowID,
                TableID: JqSubGridID,
                PagerID: JqSubGridPagerID,
                JQGridDataValue: GridData,
                IsShowSubGrid: false,
                IsShowJQGridFilterToolbar: false,
                IsShowJQGridPager: false,
            });

            $(".ui-jqgrid-htable", "#" + ParentRowID).find(".ui-th-column").addClass("SubGridThBackgroundColor");

            $($("#" + JqSubGridID)[0].grid.hDiv).find("th.ui-th-column").off("mouseenter mouseleave");
        }

    </script>
    <style>
        .SubGridThBackgroundColor {
            background-color: #cc9966;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsPMC" runat="server" />
    <div class="row">
        <div class="col-xs-3 form-group">
            <label for="<%= DDL_IsInProduction.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_IsInProduction %>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_IsInProduction" runat="server" CssClass="form-control selectpicker show-tick" required="required" OnSelectedIndexChanged="Page_Load" AutoPostBack="true">
                <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1" Selected="True"></asp:ListItem>
                <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="col-xs-12 form-group">
            <input type="button" class="btn btn-danger" id="BT_Delete" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName")%>" />
            <input type="button" class="btn btn-primary" id="BT_Create" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_CreateName")%>" />
            <input type="button" class="btn btn-grape" id="BT_Activity" value="<%=(string)GetLocalResourceObject("Str_BT_Activity")%>" />
            <asp:Button ID="BT_Recalculate" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:Str_BT_Recalculate %>" OnClick="BT_Recalculate_Click" />
            <input type="button" class="btn btn-gray" id="BT_ListFieldChange" value="<%=(string)GetLocalResourceObject("Str_BT_ShortField")%>" data-isshort="0" />
        </div>
        <div class="col-xs-12 form-group">
            <div id="ResultListDiv" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
                <div class="panel-heading text-center">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ListTitle %>"></asp:Literal>
                </div>
                <div class="panel-body">
                    <div id="JQContainerList"></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
