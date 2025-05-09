<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="TicketLifeCycle.aspx.cs" Inherits="TimeSheet_TicketLifeCycle" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        let QuarantineResultTableID = "JQContainerListForResultInfoTable";

        let QuarantineFirstTimeItemTableID = "JQContainerListForQuarantineFirstTimeItemTable";

        $(function () {
            if ($("#<%=HF_PostTicketID.ClientID%>").val() != "")
                $("#<%=BT_Search.ClientID%>").trigger("click");

            if ($("#<%=HF_ViewInside.ClientID%>").val() == "")
                $("#SearchDiv").hide();

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

                            $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_TS_Empty_TicketID")%>" });

                            return;
                        }

                        $("#<%=TB_TicketID.ClientID%>").val(data.A2);

                        $("#<%=BT_Search.ClientID%>").trigger("click");
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_TicketID.ClientID%>").val("");
                    }
                });
            }).focus();

            if (typeof (DataValue) != "undefined") {
                $("#TicketInfoDiv,#TicketLifeCycleDiv").show();

                var DataRow = typeof DataValue != "object" ? $.parseJSON(DataValue) : DataValue;

                var Index = 0;

                $.each(DataRow, function (i, item) {
                    var ItemHtml = "";

                    var ItmeClass = "";

                    if ((Index % 2) === 0)
                        ItmeClass = "";
                    else
                        ItmeClass = "timeline-inverted";

                    if (Index == 0)
                        ItemHtml = "<li class=\"" + ItmeClass + "\"><div class=\"timeline-badge info\" ><i class=\"fa fa-gear\"></i></div><div class=\"timeline-panel\">";
                    else if (Index == DataRow.length - 1)
                        ItemHtml = "<li class=\"" + ItmeClass + "\"><div class=\"timeline-badge danger\" ><i class=\"fa fa-gears\"></i></div><div class=\"timeline-panel\">";
                    else
                        ItemHtml = "<li class=\"" + ItmeClass + "\"><div class=\"timeline-badge\" ><i class=\"fa fa-angle-double-down\"></i></div><div class=\"timeline-panel\">";

                    ItemHtml += "<div class=\"timeline-heading\"><h4 class=\"timeline-title\">" + item.ProcessName + "</h4></div>";
                    ItemHtml += "<div class=\"timeline-body\"><table class=\"table table-bordered\"><tbody>";
                    ItemHtml += "<tr><td class=\"col-xs-2 info text-right\"><%=(string)GetLocalResourceObject("Str_Item_OperatorName")%></td><td class=\"col-xs-4\">" + item.OperatorName + "</td>";
                    ItemHtml += "<td class=\"col-xs-3 info text-right\"><%=(string)GetLocalResourceObject("Str_Item_MachineName")%></td><td class=\"col-xs-4\">" + item.MachineName + "</td></tr>";
                    ItemHtml += "<tr><td class=\"info text-right\"><%=(string)GetLocalResourceObject("Str_Item_ReportTimeStart")%></td><td>" + item.ReportTimeStart + "</td>";
                    ItemHtml += "<td class=\"info text-right\"><%=(string)GetLocalResourceObject("Str_Item_GoodQty")%></td><td>" + item.GoodQty + "</td></tr>";
                    ItemHtml += "<tr><td class=\"info text-right\"><%=(string)GetLocalResourceObject("Str_Item_ReportTimeEnd")%></td><td>" + item.ReportTimeEnd + "</td>";
                    ItemHtml += "<td class=\"info text-right\"><%=(string)GetLocalResourceObject("Str_Item_ReWorkQty")%></td><td>" + item.ReWorkQty + "</td></tr>";
                    ItemHtml += "<tr><td class=\"info text-right\"><%=(string)GetLocalResourceObject("Str_Item_Brand")%></td><td>" + item.Brand + "</td>";
                    ItemHtml += "<td class=\"info text-right\"><%=(string)GetLocalResourceObject("Str_Item_ScrapQty")%></td><td>" + item.ScrapQty + "</td></tr>";
                    ItemHtml += "<tr><td class=\"info text-right\"><%=(string)GetLocalResourceObject("Str_Item_ApproverName")%></td><td>" + item.ApproverName + "</td>";
                    ItemHtml += "<td class=\"info text-right\"><%=(string)GetLocalResourceObject("Str_Item_ApprovalTime")%></td><td>" + item.ApprovalTime + "</td></tr>";
                    ItemHtml += "</tbody></table></div>";

                    if (item.ChildrenQuarantine != "" || item.ChildrenReWork != "")
                        ItemHtml += "<hr>";

                    if (item.ChildrenQuarantine != "") {
                        $.each(item.ChildrenQuarantine.split("|"), function (i, item) {
                            ItemHtml += "<p class=\"text-primary openticketlifecycle\" data-ticketid=\"" + item +"\" style=\"cursor: pointer\"><%=(string)GetLocalResourceObject("Str_Item_Quarantine")%> : " + item + "</p>";
                        });
                    }

                    if (item.ChildrenReWork != "") {
                        $.each(item.ChildrenReWork.split("|"), function (i, item) {
                            ItemHtml += "<p class=\"text-primary openticketlifecycle\" data-ticketid=\"" + item +"\" style=\"cursor: pointer\"><%=(string)GetLocalResourceObject("Str_Item_ReWork")%> : " + item + "</p>";
                        });
                    }

                     <% System.Reflection.PropertyInfo PI_Admin = Master.GetType().GetProperty("IsAdmin");
        System.Reflection.PropertyInfo PI_UserAdmin = Master.GetType().GetProperty("IsUserAdmin");
        if (HF_IsCanDeleteResultItem.Value.ToBoolean() && ViewInside.ToStringFromBase64(true).ToBoolean() && ((PI_Admin != null && (bool)PI_Admin.GetValue(Master)) || (PI_UserAdmin != null && (bool)PI_UserAdmin.GetValue(Master))))
        { %>
                    if (item.ReportTimeEnd != "" && parseInt(item.ScrapQty) < 1) {
                        ItemHtml += "<hr>";
                        ItemHtml += "<input type=\"button\" class=\"btn btn-danger DeleteResultItem\" data-ticketid=\"" + item.TicketID + "\" data-processid=\"" + item.ProcessID +"\" value=\"<%=(string)GetLocalResourceObject("Str_BT_DeleteResultItem")%>\"></input>";
                    }
                    <% } %>

                    ItemHtml += "</div ></div ></li>";

                    $(".timeline").append(ItemHtml);

                    Index++;
                });

                $(".openticketlifecycle").click(function () {
                    var TicketID = $(this).data("ticketid");

                    var ViewInside = $("#<%=HF_ViewInside.ClientID%>").val();

                    if (TicketID != "")
                        $.WindowOpen("Post", "<%=ResolveClientUrl(@"~/TimeSheet/TicketLifeCycle.aspx?A2=")%>" + TicketID);
                });

                if ($.StringConvertBoolean(IsQuarantineTicketType)) {
                    $.Ajax({
                        url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketQuarantineGet.ashx") %>", data: {
                            TicketID: $("#<%=TB_TicketID.ClientID%>").val(),
                            IsOnlyGetItemData: false,
                            IsCheckTicketQuarantineFinish: false,
                            IsGetFirstTimeItem: true
                        }, CallBackFunction: function (data) {
                            if (data.ItemData.Rows.length > 0) {
                                $("#TicketQuarantineResultListDiv").show();

                                $("#BT_ClearQuarantineResult").removeClass("disabled");

                                LoadGridData({
                                    ListID: "JQContainerListForResultInfo",
                                    TableID: QuarantineResultTableID,
                                    PagerID: "JQContainerListForResultInfoPager",
                                    IsShowJQGridFilterToolbar: false,
                                    IsShowJQGridPager: false,
                                    IsShowFooterRow: true,
                                    JQGridDataValue: data.ItemData
                                });
                            }

                            if (data.FirstTimeItemData.Rows.length > 0) {
                                $("#TicketQuarantineFirstTimeItemListDiv").show();

                                LoadGridData({
                                    ListID: "JQContainerListForQuarantineFirstTimeItem",
                                    TableID: QuarantineFirstTimeItemTableID,
                                    PagerID: "JQContainerListForQuarantineFirstTimeItemPager",
                                    IsShowJQGridFilterToolbar: false,
                                    IsShowJQGridPager: false,
                                    IsShowFooterRow: true,
                                    JQGridDataValue: data.FirstTimeItemData
                                });
                            }

                            $("#<%=HF_JudgmentAccountWorkCode.ClientID%>").val(data.JudgmentAccountWorkCode);
                        }
                    });
                }
            }
            else
                $("#TicketInfoDiv,#TicketQuarantineResultListDiv,#TicketLifeCycleDiv").hide();

            $("#BT_ClearQuarantineResult").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                var FrameID = "VerifyWorkCode_FrameID";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/WorkCodeInput.aspx") %>",
                    iFrameOpenParameters: { IsRequired: true },
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_VerifyWorkCodeTitleBarText")%>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 710,
                    height: 560,
                    NewWindowPageDivID: "VerifyWorkCode_DivID",
                    NewWindowPageFrameID: FrameID,
                    CloseEvent: function () {
                        var Frame = $("#" + FrameID + "").contents();

                        if (Frame != null) {
                            var WorkCode = Frame.find("#TB_WorkCode").val();

                            if (WorkCode.toUpperCase() != $("#<%=HF_JudgmentAccountWorkCode.ClientID%>").val().toUpperCase()) {
                                $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_VerifyWorkCodeFailMessage")%>" });

                                return;
                            }

                            $.ConfirmMessage({
                                Message: "<%=(string)GetLocalResourceObject("Str_ConfirmClearQuarantineResultMessage")%>", IsHtmlElement: true, CloseEvent: function (Result) {
                                    if (!Result) {
                                        event.preventDefault();
                                        return;
                                    }

                                    $.Ajax({
                                        url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketQuarantineReJudgment.ashx")%>",
                                        data: {
                                            TicketID: $("#<%=HF_SearchTicketID.ClientID%>").val()
                                        },
                                        CallBackFunction: function (data) {
                                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_ClearQuarantineResultMessage")%>", CloseEvent: function () { window.location.reload(); } });
                                        }
                                    });
                                }
                            });
                        }
                    }
                });
            });

            $(".DeleteResultItem").click(function () {
                var TicketID = $(this).data("ticketid");
                var ProcessID = $(this).data("processid");
                var Message = "<%=(string)GetLocalResourceObject("Str_DeleteResultItemConfirmMessage")%>" + "<br/> TicketID : " + TicketID + " <br/> ProcessID : " + ProcessID + "";

                $.ConfirmMessage({
                    Message: Message, IsHtmlElement: true, CloseEvent: function (Result) {
                        if (!Result)
                            event.preventDefault();
                        else {
                            $.Ajax({
                                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketResultDelete.ashx")%>",
                                data: {
                                    TicketID: TicketID,
                                    ProcessID: ProcessID
                                },
                                CallBackFunction: function (data) {
                                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_DeleteSuccessAlertMessage")%>", CloseEvent: function () { $("#<%=BT_Search.ClientID%>").trigger("click"); } });
                                }
                            });
                        }
                    }
                });

            });
        });

        function JqEventBind(PO) {

            if (PO.TableID == QuarantineFirstTimeItemTableID) {

                $("#" + QuarantineFirstTimeItemTableID).bind("jqGridAfterGridComplete", function () {

                    let Rows = $(this).jqGrid("getDataIDs");

                    let TotalQty = 0;

                    for (var i = 0; i < Rows.length; i++) {

                        let RowID = Rows[i];

                        TotalQty += numeral($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.QuarantineQtyColumnName)).value();
                    }

                    $(this).jqGrid("footerData", "set", {
                        [PO.JQGridDataValue.DefectNameColumnName]: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_SubTotal")%>",
                        [PO.JQGridDataValue.QuarantineQtyColumnName]: numeral(TotalQty).format("0,0")
                    });

                    $("#" + QuarantineFirstTimeItemTableID).closest(".ui-jqgrid-bdiv").next(".ui-jqgrid-sdiv").find(".footrow").find(">td[aria-describedby=\"" + QuarantineFirstTimeItemTableID + "_" + PO.JQGridDataValue.DefectNameColumnName + "\"]").css("text-align", "right");

                });
            }
            else if (PO.TableID == QuarantineResultTableID) {
                $("#" + QuarantineResultTableID).bind("jqGridAfterGridComplete", function () {

                    let Rows = $(this).jqGrid("getDataIDs");

                    let TotalQty = 0;

                    for (var i = 0; i < Rows.length; i++) {

                        let RowID = Rows[i];

                        TotalQty += numeral($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.ScrapQtyColumnName)).value();
                    }

                    $(this).jqGrid("footerData", "set", {
                        [PO.JQGridDataValue.DefectNameColumnName]: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_SubTotal")%>",
                        [PO.JQGridDataValue.ScrapQtyColumnName]: numeral(TotalQty).format("0,0")
                    });

                    $("#" + QuarantineResultTableID).closest(".ui-jqgrid-bdiv").next(".ui-jqgrid-sdiv").find(".footrow").find(">td[aria-describedby=\"" + QuarantineResultTableID + "_" + PO.JQGridDataValue.DefectNameColumnName + "\"]").css("text-align", "right");

                });
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_PostTicketID" runat="server" />
    <asp:HiddenField ID="HF_SearchTicketID" runat="server" />
    <asp:HiddenField ID="HF_JudgmentAccountWorkCode" runat="server" />
    <asp:HiddenField ID="HF_ViewInside" runat="server" />
    <asp:HiddenField ID="HF_IsCanDeleteResultItem" runat="server" />
    <div id="SearchDiv">
        <div class="col-xs-4 form-group required">
            <label for="<%= TB_TicketID.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_TicketID%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
        </div>
        <div class="col-xs-12">
            <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:Str_BT_Search %>" OnClick="BT_Search_Click" />
        </div>
    </div>
    <div class="col-xs-12">
        <p></p>
    </div>
    <div class="col-xs-12" id="TicketInfoDiv" style="display: none;">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center" role="button" aria-expanded="false" data-toggle="collapse" href="#TicketInfo">
                <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo%>"></asp:Literal>
            </div>
            <div id="TicketInfo" class="panel-collapse collapse in" aria-expanded="false">
                <div class="panel-body">
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_TicketType.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TicketType%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TicketType" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_TickeBoxQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TickeBoxQty%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TickeBoxQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_PSMNG.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_PSMNG%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PSMNG" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_WEMNG.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_WEMNG%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_WEMNG" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_TotalTicketQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TotalTicketQty%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TotalTicketQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_Qty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_Qty%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_Qty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_CreateDate.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_CreateDate%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_CreateDate" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_MainTicketID.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MainTicketID%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_MainTicketID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_ParentTicketID.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_ParentTicketID%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_ParentTicketID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_CreateProcess.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_CreateProcess%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_CreateProcess" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group" style="display: none;">
                        <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MAKTX%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_TEXT1.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TEXT1%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TEXT1" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_GroupCurr.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_GroupCurr%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_GroupCurr" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_CreateAccountName.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_CreateAccountName%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_CreateAccountName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_BATCH.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_BATCH%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_BATCH" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group" style="display: none;">
                        <label for="<%= TB_SEMIFINBATCH.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_SEMIFINBATCH%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_SEMIFINBATCH" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_CHARG.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_CHARG%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_CHARG" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_MOStatusName.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MOStatusName%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_MOStatusName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xs-12" id="TicketQuarantineFirstTimeItemListDiv" style="display: none;">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor8") %>">
            <div class="panel-heading text-center" role="button" aria-expanded="false" data-toggle="collapse" href="#TicketQuarantineFirstTimeItemInfo">
                <asp:Literal runat="server" Text="<%$ Resources:Str_TicketQuarantineFirstTimeItemInfo%>"></asp:Literal>
            </div>
            <div id="TicketQuarantineFirstTimeItemInfo" class="panel-collapse collapse in" aria-expanded="false">
                <div class="panel-body">
                    <div class="col-xs-12 form-group">
                        <div id="JQContainerListForQuarantineFirstTimeItem"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xs-12" id="TicketQuarantineResultListDiv" style="display: none;">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor7") %>">
            <div class="panel-heading text-center" role="button" aria-expanded="false" data-toggle="collapse" href="#TicketQuarantineResultInfo">
                <asp:Literal runat="server" Text="<%$ Resources:Str_TicketQuarantineResultInfo%>"></asp:Literal>
            </div>
            <div id="TicketQuarantineResultInfo" class="panel-collapse collapse in" aria-expanded="false">
                <div class="panel-body">
                    <div class="col-xs-12 form-group">
                        <input type="button" class="btn btn-pink disabled" id="BT_ClearQuarantineResult" value="<%=(string)GetLocalResourceObject("Str_BT_ClearQuarantineResult")%>" />
                    </div>
                    <div class="col-xs-12 form-group">
                        <div id="JQContainerListForResultInfo"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xs-12" id="TicketLifeCycleDiv" style="display: none;">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_TicketLifeCycleTitle%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <ul class="timeline">
                </ul>
            </div>
        </div>
    </div>
</asp:Content>
