<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="TicketQuarantineReport.aspx.cs" Inherits="TimeSheet_TicketQuarantineReport" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        var JQContainerListForResultItemDIV = "JQContainerListForResultItem";
        var JQContainerListForResultItemTable = "JQContainerListForResultItemTable";
        var JQContainerListForResultItemPager = "JQContainerListForResultItemPager";

        var SerialNoColumnName = "";

        $(function () {
            $("#<%=DDL_ScrapReason.ClientID%>").change(function () {
                $("#<%=TB_DefectID.ClientID%>,#<%=TB_DefectName.ClientID%>").val("");
            });

            $("#<%=TB_DefectID.ClientID%>").blur(function () {
                var ScrapReasonID = $("#<%=DDL_ScrapReason.ClientID%>").find(":selected").val();
                var DefectID = $(this).val();

                if (DefectID == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/DefectNameGet.ashx")%>",
                    data: { ScrapReasonID: ScrapReasonID, DefectID: DefectID },
                    CallBackFunction: function (data) {
                        $("#<%=TB_DefectName.ClientID%>").val(data.DefectName);

                        if (data.DefectName == "")
                            $("#<%=TB_DefectID.ClientID%>").val("");
                        else {
                            if (ScrapReasonID == "" && data.ScrapReasonID != "")
                                $("#<%=DDL_ScrapReason.ClientID%>").val(data.ScrapReasonID);

                            $(".bootstrap-touchspin-down").focus();
                        }
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_DefectID.ClientID%>").val("");
                        $("#<%=TB_DefectName.ClientID%>").val("");
                    }
                });
            });

            $("#<%=TB_Report_JudgmentAccountID.ClientID%>,#<%=TB_JudgmentAccountID.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $(this).closest("div").find("input[type='button']").trigger("click");
            });

            $("#<%=TB_TicketID.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data) {
                        if (data.A2 == null) {
                            $("#<%=TB_TicketID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_TicketID")%>" });

                            return;
                        }

                        $("#<%=TB_TicketID.ClientID%>").val(data.A2);
                        $("#<%=HF_TicketID.ClientID%>").val(data.A2);

                        $("#<%=TB_TicketID.ClientID%>").addClass("readonlyColor readonly").prop("disabled", true);

                        if (data.A2 != "")
                            LoadQuarantineData();
                        else
                            window.location.reload();
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_TicketID.ClientID%>").val("");
                    }
                });
            }).focus();

            $("#BT_Scrapped").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_ConfirmMessage")%>", IsHtmlElement: true, CloseEvent: function (Result) {
                        if (!Result) {
                            event.preventDefault();
                            return;
                        }

                        $.Ajax({
                            url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketQuarantineSetItem.ashx")%>",
                            timeout: 300 * 1000,
                            data: {
                                IsFinish: false,
                                TicketID: $("#<%=HF_TicketID.ClientID%>").val(),
                                ScrapQty: $("#<%=TB_ScrapQty.ClientID%>").val(),
                                ScrapReason: $("#<%=DDL_ScrapReason.ClientID%>").find(":selected").val(),
                                DefectID: $("#<%=TB_DefectID.ClientID%>").val(),
                                Remark: $("#<%=TB_Remark.ClientID%>").val(),
                                JudgmentWorkCode: $("#<%=TB_Report_JudgmentAccountID.ClientID%>").val()
                            },
                            CallBackFunction: function (data) {
                                if (!$.StringConvertBoolean(data.IsJudgment)) {
                                    $("#<%=DDL_ScrapReason.ClientID%>").val("").trigger("change");

                                    $("#<%=TB_ScrapQty.ClientID%>").val("0").trigger("change");

                                    LoadQuarantineData();
                                }
                                else
                                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_FinishMessage")%>", CloseEvent: function () { window.location.reload(); } });
                            }
                        });
                    }
                });
            });

            $("#BT_Finish").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_ConfirmMessageByFinish")%>", IsHtmlElement: true, CloseEvent: function (Result) {
                        if (!Result) {
                            event.preventDefault();
                            return;
                        }

                        $.Ajax({
                            url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketQuarantineSetItem.ashx")%>",
                            timeout: 300 * 1000,
                            data: {
                                IsFinish: true,
                                TicketID: $("#<%=HF_TicketID.ClientID%>").val(),
                                JudgmentWorkCode: $("#<%=TB_JudgmentAccountID.ClientID%>").val()
                            },
                            CallBackFunction: function (data) {
                                if (!$.StringConvertBoolean(data.IsJudgment))
                                    LoadQuarantineData();
                                else
                                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_FinishMessage")%>", CloseEvent: function () { window.location.reload(); } });
                            }
                        });
                    }
                });

            });

            $("#BT_Delete").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                var SelectCBKArrayID = new Array();

                var GridTable = $("#" + JQContainerListForResultItemTable);

                var rowKey = GridTable.jqGrid("getGridParam", "selrow");

                if (!rowKey) {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });
                    return false;
                }

                var ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

                $.each(GridTable.getGridParam("selarrrow"), function (i, item) {
                    var SerialNo = "";

                    if ($.grep(ColumnModel, function (Node) { return Node.name == SerialNoColumnName; }).length > 0)
                        SerialNo = GridTable.jqGrid("getCell", item, SerialNoColumnName);
                    if (SerialNo != "")
                        SelectCBKArrayID.push(SerialNo);
                });

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_DeleteConfirmMessage") %>", IsHtmlElement: true, CloseEvent: function (result) {
                        if (result) {
                            $.Ajax({
                                url: "<%=ResolveClientUrl("~/TimeSheet/Service/TicketQuarantineDeleteItem.ashx") %>", data: {
                                    TicketID: $("#<%=HF_TicketID.ClientID%>").val(),
                                    SerialNoS: JSON.stringify(SelectCBKArrayID)
                                }, CallBackFunction: function (data) {
                                    LoadQuarantineData();
                                }
                            });
                        }
                    }
                });
            });
        });

        function LoadQuarantineData() {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketQuarantineGet.ashx")%>",
                data: { TicketID: $("#<%=HF_TicketID.ClientID%>").val(), IsGetFirstTimeItem: true },
                CallBackFunction: function (data) {
                    $("#<%=HF_TicketID.ClientID%>").val(data.TicketID);
                    $("#<%=TB_TicketQty.ClientID%>").val(data.Qty);
                    $("#<%=TB_MainTicketID.ClientID%>").val(data.MainTicketID);
                    $("#<%=TB_ParentTicketPath.ClientID%>").val(data.ParentTicketPath);
                    $("#<%=TB_RoutingName.ClientID%>").val(data.RoutingName);
                    $("#<%=TB_ProcessName.ClientID%>").val(data.ProcessName);
                    $("#<%=TB_MAKTX.ClientID%>").val(data.MAKTX);
                    $("#<%=TB_BATCH.ClientID%>").val(data.MOBatch);
                    $("#<%=TB_CreateDate.ClientID%>").val(data.CreateDate);
                    $("#<%=TB_CreateAccountName.ClientID%>").val(data.CreateAccountName);
                    $("#<%=TB_WaitReportQty.ClientID%>").val(data.WaitReportQty);
                    $("#<%=TB_TotalScrapQty.ClientID%>").val(data.ScrapQty);

                    SerialNoColumnName = data.ItemData.SerialNoColumnName;

                    if (data.FirstTimeItemData.Rows.length > 0) {
                        $("#QuarantineFirstTimeItemListDiv").show();

                        LoadGridData({
                            ListID: "JQContainerListForFirstTimeItem",
                            TableID: "JQContainerListForFirstTimeItemTable",
                            PagerID: "JQContainerListForFirstTimeItemPager",
                            IsShowJQGridFilterToolbar: true,
                            IsShowJQGridPager: false,
                            JQGridDataValue: data.FirstTimeItemData
                        });
                    }
                    else
                        $("#QuarantineFirstTimeItemListDiv").hide();

                    LoadGridData({
                        ListID: JQContainerListForResultItemDIV,
                        TableID: JQContainerListForResultItemTable,
                        PagerID: JQContainerListForResultItemPager,
                        IsShowJQGridFilterToolbar: true,
                        IsShowJQGridPager: false,
                        JQGridDataValue: data.ItemData,
                        IsMultiSelect: true
                    });

                    $("#ScrapListDiv").show();

                    var WaitReportQty = parseInt($("#<%=TB_WaitReportQty.ClientID%>").val());

                    $("#<%=TB_ScrapQty.ClientID%>").trigger("touchspin.updatesettings", { max: WaitReportQty });

                    $("#BT_Scrapped,#BT_Finish").addClass("disabled");

                    $("#<%=TB_JudgmentAccountID.ClientID%>,#<%=TB_Report_JudgmentAccountID.ClientID%>").addClass("readonlyColor readonly");

                    $("#BT_Scrapped,#BT_Finish").addClass("disabled");

                    var IsJudgment = $.StringConvertBoolean(data.IsJudgment);

                    if (IsJudgment) {
                        $("#<%=TB_JudgmentAccountID.ClientID%>").removeClass("readonlyColor readonly");

                        $("#BT_Finish").removeClass("disabled");

                        $("#BT_Delete").addClass("disabled");

                        return;
                    }

                    $("#<%=TB_JudgmentAccountID.ClientID%>,#<%=TB_Report_JudgmentAccountID.ClientID%>").removeClass("readonlyColor readonly");

                    $("#BT_Finish,#BT_Scrapped").removeClass("disabled");

                },
                ErrorCallBackFunction: function (data) {
                    $("#<%=TB_JudgmentAccountID.ClientID%>,#<%=TB_Report_JudgmentAccountID.ClientID%>").addClass("readonlyColor readonly");

                    $("#BT_Scrapped,#BT_Finish").addClass("disabled");

                    $("#<%=TB_JudgmentAccountID.ClientID%>,#<%=TB_Report_JudgmentAccountID.ClientID%>").val("");
                }
            });
        }

        function TicketID_Click() {

            $("#<%=HF_TicketID.ClientID%>").val($("#<%=TB_TicketID.ClientID%>").val());

            LoadQuarantineData();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_TicketID" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_TicketID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TicketID%>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
                    <span class="input-group-btn">
                        <input type="button" class="btn btn-info" id="BT_TicketConfirm" onclick="TicketID_Click();" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_SearchName")%>" />
                    </span>
                </div>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_TicketQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TicketQty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_TicketQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_MainTicketID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MainTicketID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MainTicketID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_ParentTicketPath.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_ParentTicketPath%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ParentTicketPath" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_RoutingName.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_RoutingName%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_RoutingName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_ProcessName.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_ProcessName%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ProcessName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MAKTX%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_BATCH.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_BATCH%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_BATCH" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_CreateDate.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_CreateDate%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_CreateDate" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_CreateAccountName.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_CreateAccountName%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_CreateAccountName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_WaitReportQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_WaitReportQty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_WaitReportQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_TotalScrapQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TotalScrapQty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_TotalScrapQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_JudgmentAccountID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_JudgmentAccountID%>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_JudgmentAccountID" runat="server" CssClass="form-control readonlyColor readonly" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
                    <span class="input-group-btn">
                        <input type="button" class="btn btn-primary disabled" id="BT_Finish" value="<%=(string)GetLocalResourceObject("Str_BT_Finish")%>" />
                    </span>
                </div>
            </div>
        </div>
    </div>
    <div id="ExecScrapDiv" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ReportInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-3 form-group required">
                <label for="<%= DDL_ScrapReason.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportInfo_ScrapReason%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_ScrapReason" runat="server" CssClass="form-control" required="required">
                </asp:DropDownList>
            </div>
            <div class="col-xs-2 form-group required">
                <label for="<%= TB_DefectID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportInfo_DefectID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_DefectID" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_DefectName.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportInfo_DefectName%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_DefectName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group required">
                <label for="<%= TB_ScrapQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportInfo_ScrapQty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ScrapQty" runat="server" CssClass="form-control MumberType" required="required" Text="0"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group required">
                <label for="<%= TB_Report_JudgmentAccountID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportInfo_JudgmentAccountID%>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_Report_JudgmentAccountID" runat="server" CssClass="form-control readonlyColor readonly" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
                    <span class="input-group-btn">
                        <input type="button" class="btn btn-warning disabled" id="BT_Scrapped" value="<%=(string)GetLocalResourceObject("Str_BT_Scrapped")%>" />
                    </span>
                </div>
            </div>
            <div class="col-xs-12 form-group">
                <label for="<%= TB_Remark.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportInfo_Remark%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_Remark" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
            </div>
        </div>
    </div>
    <div id="ScrapListDiv" style="display: none" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor7") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ScrapInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <input id="BT_Delete" type="button" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName")%>" class="btn btn-danger" />
            <p></p>
            <div id="JQContainerListForResultItem"></div>
        </div>
    </div>
    <div id="QuarantineFirstTimeItemListDiv" style="display: none" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor8") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="false" data-toggle="collapse" href="#TicketQuarantineFirstTimeItemInfo">
            <asp:Literal runat="server" Text="<%$ Resources:Str_FirstTimeItemInfo%>"></asp:Literal>
        </div>
        <div id="TicketQuarantineFirstTimeItemInfo" class="panel-collapse collapse in" aria-expanded="false">
            <div class="panel-body">
                <div id="JQContainerListForFirstTimeItem"></div>
            </div>
        </div>
    </div>
</asp:Content>
