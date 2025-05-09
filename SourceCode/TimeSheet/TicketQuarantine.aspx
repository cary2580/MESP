<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="TicketQuarantine.aspx.cs" Inherits="TimeSheet_TicketQuarantine" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            LoadGridData({
                IsShowJQGridPager: false,
                IsShowJQRowNumbers: false,
                IsMultiSelect: true,
                JQGridDataValue: {
                    colModel: [
                        { name: "DefectID", index: "DefectID", label: "<%=(string)GetLocalResourceObject("Str_DefectID")%>", width: 60 },
                        { name: "DefectName", index: "DefectName", label: "<%=(string)GetLocalResourceObject("Str_DefectName")%>" },
                        { name: "QuarantineQty", index: "QuarantineQty", label: "<%=(string)GetLocalResourceObject("Str_QuarantineQty")%>", width: 40, align: "center" },
                    ],
                    Rows: [],
                }
            });

            $("#BT_PrintTicket").hide();

            $("#<%=TB_DefectID.ClientID%>").blur(function () {
                var DefectID = $(this).val();

                if (DefectID == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/DefectNameGet.ashx")%>",
                    data: { DefectID: DefectID },
                    CallBackFunction: function (data) {
                        $("#<%=TB_DefectName.ClientID%>").val(data.DefectName);

                        if (data.DefectName == "")
                            $("#<%=TB_DefectID.ClientID%>").val("");
                        else {
                            $(".bootstrap-touchspin-down").focus();
                        }
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_DefectID.ClientID%>").val("");
                        $("#<%=TB_DefectName.ClientID%>").val("");
                    }
                });
            });

            $("#BT_QuarantineAdd").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                if ($("#<%=TB_DefectID.ClientID%>").val() == "") {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_DefectIDEmpty")%>" });

                    return;
                }

                if ($("#<%=TB_QuarantineQty.ClientID%>").val() == "") {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_QuarantineQty")%>" });

                    return;
                }

                var QuarantineQty = parseInt($("#<%=TB_QuarantineQty.ClientID%>").val());

                if (QuarantineQty < 1) {

                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_QuarantineQty")%>" });

                    return;
                }

                var QuarantineTotalQty = GetQuarantineTotalQty(QuarantineQty);

                if (QuarantineTotalQty > parseInt($("#<%=HF_AllowQty.ClientID%>").val())) {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_QtyThanAllowQty")%>" });

                    return;
                }

                var DefectID = $("#<%=TB_DefectID.ClientID%>").val();

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/DefectNameGet.ashx")%>",
                    data: { DefectID: $("#<%=TB_DefectID.ClientID%>").val() },
                    CallBackFunction: function (data) {
                        var DefectName = data.DefectName;

                        if (DefectName == "") {
                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_DefectIDNoName")%>" });

                            return;
                        }

                        var GridTable = $("#" + JqGridParameterObject.TableID);

                        var RowData = GridTable.jqGrid("getRowData");

                        if ($.grep(RowData, function (item, index) { return item.DefectID.trimStart() == DefectID.trimStart(); }).length > 0) {
                            QuarantineTotalQty = GetQuarantineTotalQty(0);

                            $("#<%=TB_Qty.ClientID%>").val(QuarantineTotalQty);

                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_DefectIDRepeat")%>" });

                            return;
                        }

                        RowData.push({ DefectID: DefectID.trimStart(), DefectName: DefectName, QuarantineQty: QuarantineQty, });

                        GridTable.jqGrid("setGridParam", { data: RowData }).trigger("reloadGrid");

                        $("#<%=TB_DefectID.ClientID%>").val("").focus();

                        $("#<%=TB_Qty.ClientID%>").val(QuarantineTotalQty);

                        $("#<%=TB_QuarantineQty.ClientID%>").val("");

                        $("#<%=TB_DefectID.ClientID%>,#<%=TB_DefectName.ClientID%>").val("");

                        if (QuarantineTotalQty > 0)
                            $("#BT_Create").removeClass("disabled");
                        else
                            $("#BT_Create").addClass("disabled");

                        if (RowData.length >= 13)
                            $("#BT_QuarantineAdd").addClass("disabled");
                    }
                });
            });

            $("#BT_QuarantineDelete").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                var GridTable = $("#" + JqGridParameterObject.TableID);

                var SelRcowId = GridTable.jqGrid("getGridParam", "selarrrow");

                if (SelRcowId.length < 1) {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });

                    return false;
                }

                /* 只能倒著刪除，不然每刪除一筆selarrrow會跟著邊化 */
                for (var row = SelRcowId.length - 1; row >= 0; row--)
                    GridTable.jqGrid("delRowData", SelRcowId[row]);

                var QuarantineTotalQty = GetQuarantineTotalQty(0);

                $("#<%=TB_Qty.ClientID%>").val(QuarantineTotalQty);

                if (QuarantineTotalQty > 0)
                    $("#BT_Create").removeClass("disabled");
                else
                    $("#BT_Create").addClass("disabled");

                var RowData = GridTable.jqGrid("getRowData");

                if (RowData.length < 13)
                    $("#BT_QuarantineAdd").removeClass("disabled");
            });

            $("#BT_Create").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                var Qty = parseInt($("#<%=TB_Qty.ClientID%>").val());
                var AllowQty = parseInt($("#<%=HF_AllowQty.ClientID%>").val());

                if (Qty < 1)
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_QtyLessThan1")%>" });
                else if (Qty > AllowQty)
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_QtyThanAllowQty")%>" });

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_ConfirmMessage")%>", IsHtmlElement: true, CloseEvent: function (Result) {
                        if (!Result) {
                            event.preventDefault();
                            return;
                        }

                        var QuarantineInfoList = new Array();

                        GridTable = $("#" + JqGridParameterObject.TableID);

                        var DefectIDRowData = GridTable.jqGrid("getRowData");

                        $.each(DefectIDRowData, function (index, item) {
                            QuarantineInfoList.push({ DefectID: item["DefectID"], QuarantineQty: item["QuarantineQty"] });
                        });

                        $.Ajax({
                            url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketCreateByQuarantine.ashx")%>",
                            timeout: 300 * 1000,
                            data: {
                                TicketID: $("#<%=HF_TicketID.ClientID%>").val(),
                                Qty: Qty,
                                QuarantineInfoList: JSON.stringify(QuarantineInfoList)
                            },
                            CallBackFunction: function (data) {
                                $("#BT_Create,#BT_QuarantineAdd,#BT_QuarantineDelete,.FromControl").hide();

                                $("#BT_PrintTicket").show();

                                $("#<%=HF_NewTicketID.ClientID%>").val(data.NewTicketID);

                                $("#<%=HF_NewAllowQty.ClientID%>").val(data.NewAllowQty);

                                PrintTicket();
                            }
                        });
                    }
                });
            });

            $("#BT_PrintTicket").click(function () {
                PrintTicket();
            });
        });

        function GetQuarantineTotalQty(CurrQty) {
            var GridTable = $("#" + JqGridParameterObject.TableID);

            var RowData = GridTable.jqGrid("getRowData");

            var QuarantineTotalQty = CurrQty;

            $.each(RowData, function (i, item) {
                QuarantineTotalQty += parseInt(item["QuarantineQty"]);
            });

            return QuarantineTotalQty;
        }

        function PrintTicket() {
            /* 列印流程卡 */
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_001.ashx")%>",
                data: { TicketID: JSON.stringify([$("#<%=HF_NewTicketID.ClientID%>").val()]) },
                timeout: 300 * 1000,
                CallBackFunction: function (data) {
                    if (data.Result && data.GUID != null)
                        PrintTicketAndQuarantineInfo(data.GUID);
                }
            });
        }

        function PrintTicketAndQuarantineInfo(TicketGUID) {
            /* 列印隔離品單和下載 */
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_014.ashx")%>",
                data: {
                    TicketID: $("#<%=HF_NewTicketID.ClientID%>").val(),
                    TicketQuarantineGUID: TicketGUID
                },
                timeout: 300 * 1000,
                CallBackFunction: function (data) {
                    if (data.Result && data.GUID != null) {
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
    <asp:HiddenField ID="HF_TicketID" runat="server" />
    <asp:HiddenField ID="HF_AllowQty" runat="server" Value="0" />
    <asp:HiddenField ID="HF_NewTicketID" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="HF_NewAllowQty" runat="server" ClientIDMode="Static" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketQuarantineTitle%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4 form-group FromControl required">
                <label for="<%= TB_Qty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_Qty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_Qty" runat="server" CssClass="form-control" Text="0" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Create" type="button" value="<%= (string)GetLocalResourceObject("Str_BT_CreateName")%>" class="btn btn-danger disabled" />
                <input id="BT_PrintTicket" type="button" value="<%= (string)GetLocalResourceObject("Str_BT_PrintTicket")%>" class="btn btn-success" />
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor2") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_FirstJudgmentTitle%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_DefectID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_DefectID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_DefectID" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_DefectName.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_DefectName%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_DefectName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_QuarantineQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_QuarantineQty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_QuarantineQty" runat="server" CssClass="form-control MumberType" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_QuarantineAdd" type="button" value="<%= (string)GetLocalResourceObject("Str_BT_AddName") %>" class="btn btn-success" />
                <input id="BT_QuarantineDelete" type="button" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName") %>" class="btn btn-danger" />
            </div>
            <div class="col-xs-12 form-group">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
