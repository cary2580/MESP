<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="TicketReWork.aspx.cs" Inherits="TimeSheet_TicketReWork" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        var ProcessStartListID = "ProcessStartList";
        var ProcessStartTableID = "ProcessStartTable";

        var ProcessEndListID = "ProcessEndList";
        var ProcessEndTableID = "ProcessEndTable";

        var ProcessConfirmListID = "ProcessConfirmList";
        var ProcessConfirmTableID = "ProcessConfirmTable";

        var DefectListID = "DefectList";
        var DefectListTableID = "DefectTable";

        function JqEventBind()
        {
            $("#" + ProcessStartTableID).bind("jqGridDblClickRow", function (e, RowID)
            {
                var ProcessRowData = $(this).jqGrid("getRowData");

                var RowData = new Array();

                for (var i = RowID - 1; i < ProcessRowData.length; i++)
                {
                    RowData.push(ProcessRowData[i]);
                }

                ShowProcessEndList(RowData);
            });
        }

        function ShowProcessEndList(RowData)
        {
            var RoutingList = {
                ListID: ProcessEndListID,
                TableID: ProcessEndTableID,
                IsShowJQGridPager: false,
                IsShowJQRowNumbers: false,
                IsMultiSelect: true,
                JQGridDataValue: {
                    colModel: JQGridProcessColumn,
                    Rows: RowData
                }
            };

            LoadGridData(RoutingList);

            $("#ProcessStart").hide();

            $("#ProcessEnd").show();
        }

        $(function ()
        {
            $("#BT_PrintTicket").hide();

            var ProcessStartListData = {
                ListID: ProcessStartListID,
                TableID: ProcessStartTableID,
                IsShowJQGridPager: false,
                IsShowJQRowNumbers: false,
                JQGridDataValue: JQGridBeforeProcessData
            };

            LoadGridData(ProcessStartListData);

            $("#BT_RemoveProcess").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                var SelectCBKArrayID = new Array();

                var GridTable = $("#" + ProcessEndTableID);

                var rowKey = GridTable.jqGrid("getGridParam", "selrow");

                if (!rowKey)
                {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });
                    return false;
                }

                var ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

                $.each(GridTable.getGridParam("selarrrow"), function (i, item)
                {
                    var ProcessKeyValue = "";

                    if ($.grep(ColumnModel, function (Node) { return Node.name == ProcessKey; }).length > 0)
                        ProcessKeyValue = GridTable.jqGrid("getCell", item, ProcessKey);
                    if (ProcessKeyValue != "")
                        SelectCBKArrayID.push(ProcessKeyValue);
                });

                var EndRowData = GridTable.jqGrid("getRowData");

                var NeEndRowData = new Array();

                $.each(EndRowData, function (index, item)
                {
                    if ($.inArray(item[ProcessKey], SelectCBKArrayID) < 0)
                        NeEndRowData.push(item);
                });

                ShowProcessEndList(NeEndRowData);
            });

            $("#BT_ConfirmProcess").click(function ()
            {
                var GridTable = $("#" + ProcessEndTableID);

                var EndRowData = GridTable.jqGrid("getRowData");

                if (EndRowData.length < 1)
                {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_ReWorkNoProcess")%>" });

                    event.preventDefault();

                    return;
                }

                $.each(EndRowData.reverse(), function (index, item)
                {
                    JQGriAfterProcessData.Rows.unshift(item);
                });

                var ProcessConfirmListData = {
                    ListID: ProcessConfirmListID,
                    TableID: ProcessConfirmTableID,
                    IsShowJQGridPager: false,
                    IsShowJQRowNumbers: false,
                    IsMultiSelect: false,
                    JQGridDataValue: JQGriAfterProcessData
                };

                LoadGridData(ProcessConfirmListData);

                var DefectListData = {
                    ListID: DefectListID,
                    TableID: DefectListTableID,
                    IsShowJQGridPager: false,
                    IsShowJQRowNumbers: false,
                    IsMultiSelect: true,
                    JQGridDataValue: {
                        colModel: [
                            { name: "DefectID", index: "DefectID", label: "<%=(string)GetLocalResourceObject("Str_ColumnName_DefectID")%>", width: 60 },
                            { name: "DefectQty", index: "DefectQty", label: "<%=(string)GetLocalResourceObject("Str_ColumnName_Qty")%>", width: 40, align: "center" },
                            { name: "DefectName", index: "DefectName", label: "<%=(string)GetLocalResourceObject("Str_ColumnName_DefectName")%>" }
                        ],
                        Rows: [],
                    }
                };

                LoadGridData(DefectListData);

                $("#ProcessEnd").hide();

                $("#ProcessConfirm").show();
            });

            $("#BT_Create").click(function ()
            {
                var GridTable = $("#" + ProcessConfirmTableID);

                var ConfirmRowData = GridTable.jqGrid("getRowData");

                if (ConfirmRowData.length < 1)
                {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_ReWorkNoProcess")%>" });

                    event.preventDefault();

                    return;
                }

                var ProcessIDS = new Array();

                $.each(ConfirmRowData, function (index, item)
                {
                    ProcessIDS.push(item[ProcessKey]);
                });

                var Qty = parseInt($("#<%=TB_Qty.ClientID%>").val());

                var AllowQty = parseInt($("#<%=HF_AllowQty.ClientID%>").val());

                if ((Qty > AllowQty) || Qty == 0)
                {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_Qty")%>" });

                    event.preventDefault();

                    return;
                }

                var DefectIDs = new Array();

                GridTable = $("#" + DefectListTableID);

                var DefectIDRowData = GridTable.jqGrid("getRowData");

                var DefectQtyTotal = 0

                $.each(DefectIDRowData, function (index, item)
                {
                    DefectIDs.push({ DefectID: item["DefectID"], DefectQty: item["DefectQty"] });

                    DefectQtyTotal += parseInt(item["DefectQty"]);
                });

                if (DefectQtyTotal != parseInt($("#<%=TB_Qty.ClientID%>").val()))
                {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_DefectQtyNotTheSameQty")%>" });

                    event.preventDefault();

                    return;
                }

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_ConfirmMessage")%>", IsHtmlElement: true, CloseEvent: function (Result)
                    {
                        if (!Result)
                        {
                            event.preventDefault();
                            return;
                        }

                        $.Ajax({
                            url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketCreateByReWork.ashx")%>",
                            timeout: 300 * 1000,
                            data: {
                                TicketID: $("#<%=HF_TicketID.ClientID%>").val(),
                                Qty: $("#<%=TB_Qty.ClientID%>").val(),
                                ProcessIDS: JSON.stringify(ProcessIDS),
                                DefectIDs: JSON.stringify(DefectIDs)
                            },
                            CallBackFunction: function (data)
                            {
                                $("#BT_Create,#BT_DefectAdd,#BT_DefectDelete,.FromControl").hide();

                                $("#BT_PrintTicket").show();

                                $("#<%=HF_NewTicketID.ClientID%>").val(data.NewTicketID);

                                $("#<%=HF_NewAllowQty.ClientID%>").val(data.NewAllowQty);

                                PrintTicket();
                            }
                        });
                    }
                });
            });

            $("#BT_PrintTicket").click(function ()
            {
                PrintTicket();
            });

            $("#<%=TB_Qty.ClientID%>").TouchSpin({
                min: 0,
                max: parseInt($("#<%=HF_AllowQty.ClientID%>").val()),
                decimals: 0,
            });

            $("#BT_DefectAdd").click(function ()
            {
                if ($("#<%=TB_DefectID.ClientID%>").val() == "")
                {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_DefectIDEmpty")%>" });

                    return;
                }

                var DefectQty = parseInt($("#<%=TB_DefectQty.ClientID%>").val());

                if (DefectQty < 1)
                {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_DefectQty")%>" });

                    return;
                }

                var DefectID = $("#<%=TB_DefectID.ClientID%>").val();

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/DefectNameGet.ashx")%>",
                    data: { DefectID: $("#<%=TB_DefectID.ClientID%>").val() },
                    CallBackFunction: function (data)
                    {
                        var DefectName = data.DefectName;

                        if (DefectName == "")
                        {
                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_DefectIDNoName")%>" });

                            return;
                        }

                        var GridTable = $("#" + DefectListTableID);

                        var RowData = GridTable.jqGrid("getRowData");

                        if ($.grep(RowData, function (item, index) { return item.DefectID == DefectID; }).length > 0)
                        {
                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_DefectIDRepeat")%>" });

                            return;
                        }

                        RowData.push({ DefectQty: DefectQty, DefectID: DefectID, DefectName: DefectName });

                        GridTable.jqGrid("setGridParam", { data: RowData }).trigger("reloadGrid");

                        $("#<%=TB_DefectID.ClientID%>").val("");
                    }
                });

                GetDefectTotalQty(DefectQty);

                $("#<%=TB_DefectQty.ClientID%>").val("0");
            });

            $("#BT_DefectDelete").click(function ()
            {
                var GridTable = $("#" + DefectListTableID);

                var SelRcowId = GridTable.jqGrid("getGridParam", "selarrrow");

                if (SelRcowId.length < 1)
                {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });

                    return false;
                }

                /* 只能倒者刪除，不然每刪除一筆selarrrow會跟著邊化 */
                for (var row = SelRcowId.length - 1; row >= 0; row--)
                    GridTable.jqGrid("delRowData", SelRcowId[row]);

                GetDefectTotalQty(0);
            });
        });

        function GetDefectTotalQty(CurrQty)
        {
            var GridTable = $("#" + DefectListTableID);

            var RowData = GridTable.jqGrid("getRowData");

            var DefectTotalQty = CurrQty;

            $.each(RowData, function (i, item)
            {
                DefectTotalQty += parseInt(item["DefectQty"]);
            });

            $("#<%=TB_DefectTotalQty.ClientID%>").val(DefectTotalQty);

            $("#<%=TB_Qty.ClientID%>").val(DefectTotalQty);
        }

        function PrintTicket()
        {
            /* 下載流程卡 */
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_001.ashx")%>",
                data: { TicketID: JSON.stringify([$("#<%=HF_NewTicketID.ClientID%>").val()]) },
                timeout: 300 * 1000,
                CallBackFunction: function (data)
                {
                    if (data.Result && data.GUID != null)
                    {
                        if ($.ispAad())
                            window.open("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                        else
                            OpenWindowDownloadFile("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                    }
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_NewTicketID" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="HF_NewAllowQty" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="HF_TicketID" runat="server" />
    <asp:HiddenField ID="HF_ProcessID" runat="server" />
    <asp:HiddenField ID="HF_AUFNR" runat="server" />
    <asp:HiddenField ID="HF_PLNBEZ" runat="server" />
    <asp:HiddenField ID="HF_MainTicketID" runat="server" />
    <asp:HiddenField ID="HF_ParentTicketID" runat="server" />
    <asp:HiddenField ID="HF_ReWorkMainProcessID" runat="server" />
    <asp:HiddenField ID="HF_AUFPL" runat="server" />
    <asp:HiddenField ID="HF_APLZL" runat="server" />
    <asp:HiddenField ID="HF_VORNR" runat="server" />
    <asp:HiddenField ID="HF_LTXA1" runat="server" />
    <asp:HiddenField ID="HF_AllowQty" runat="server" Value="0" />
    <div class="col-xs-12" id="ProcessStart">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_ProcessStartListTitle%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="ProcessStartList"></div>
            </div>
        </div>
    </div>
    <div class="col-xs-12" id="ProcessEnd" style="display: none">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor8") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_ProcessEndListTitle%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <input type="button" class="btn btn-danger" id="BT_RemoveProcess" value="<%=(string)GetLocalResourceObject("Str_BT_RemoveProcess")%>" />
                <input type="button" class="btn btn-info" id="BT_ConfirmProcess" value="<%=(string)GetLocalResourceObject("Str_BT_ConfirmProcess")%>" />
                <p></p>
                <div id="ProcessEndList"></div>
            </div>
        </div>
    </div>
    <div class="col-xs-12" id="ProcessConfirm" style="display: none">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_ReworkDefectTitle%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="col-xs-12 form-group">
                    <input id="BT_Create" type="button" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_CreateName")%>" class="btn btn-warning" />
                </div>
                <div class="col-xs-4 form-group FromControl required">
                    <label for="<%= TB_Qty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_Qty%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_Qty" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <input id="BT_PrintTicket" type="button" value="<%= (string)GetLocalResourceObject("Str_BT_PrintTicket")%>" class="btn btn-success" />
                </div>
                <div class="col-xs-12 form-group">
                    <input id="BT_DefectAdd" type="button" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName") + (string)GetLocalResourceObject("Str_DefectID")%>" class="btn btn-success" />
                    <input id="BT_DefectDelete" type="button" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName") + (string)GetLocalResourceObject("Str_DefectID")%>" class="btn btn-danger" />
                </div>
                <div class="col-xs-4 form-group FromControl required">
                    <label for="<%= TB_DefectID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_DefectID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_DefectID" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group FromControl required">
                    <label for="<%= TB_DefectQty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_DefectQty%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_DefectQty" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group FromControl">
                    <label for="<%= TB_DefectTotalQty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_DefectTotalQty%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_DefectTotalQty" runat="server" CssClass="form-control" disabled="true" Text="0"></asp:TextBox>
                </div>
                <div class="col-xs-12 form-group">
                    <div id="DefectList"></div>
                </div>
            </div>
        </div>
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor8") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_ProcessConfirmListTitle%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="ProcessConfirmList"></div>
            </div>
        </div>
    </div>
</asp:Content>

