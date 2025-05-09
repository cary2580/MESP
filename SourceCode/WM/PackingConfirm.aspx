<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="PackingConfirm.aspx.cs" Inherits="WM_PackingConfirm" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $.Main.Defaults.AlertMessage.width = 300;
            $.Main.Defaults.ConfirmMessage.width = 300;

            $("#BT_Clear").click(function () {
                window.location.reload();
            });

            $("#<%=TB_WorkCode.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() != "" && $("#<%=TB_PackingID.ClientID%>").val() != "")
                    PreScanBarCdoe();
                else if ($(this).val() != "")
                    $("#<%=TB_PackingID.ClientID%>").focus();

            }).focus();

            $("#<%=TB_PackingID.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data) {
                        if (data.A8 == null) {

                            $("#<%=TB_PackingID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_WM_Empty_PackingID")%>" });

                            return;
                        }

                        $("#<%=TB_PackingID.ClientID%>").val(data.A8);
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_PackingID.ClientID%>").val("");
                    }
                });

                if ($("#<%=TB_WorkCode.ClientID%>").val() == "") {
                    $("#<%=TB_WorkCode.ClientID%>").focus();

                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkCode")%>" });

                    e.preventDefault();

                    return;
                }

                PreScanBarCdoe();
            });

            $("#<%=TB_PBNO.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($("#<%=TB_PBNO.ClientID%>").hasClass("readonly"))
                    return;

                if ($(this).val().length != BoxNoLength) {
                    $.Ajax({
                        url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                        data: { QRCode: $(this).val() },
                        CallBackFunction: function (data) {
                            if (data.A7 != null)
                                $("#<%=TB_PBNO.ClientID%>").val(data.A7);

                            LoadList();
                        },
                        ErrorCallBackFunction: function (data) {
                            $("#<%=TB_PBNO.ClientID%>").val("");
                        }
                    });
                }
                else
                    LoadList();
            });

            $("#BT_GoToConfirm").click(function () {

                if ($(this).hasClass("disabled"))
                    return;

                $.ConfirmMessage({
                    Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_WM_PackingConfirmMessage")%>", IsHtmlElement: true, CloseEvent: function (Result) {
                        if (!Result) {
                            event.preventDefault();

                            return;
                        }

                        let BoxNoList = new Array();

                        $("#PackingTable > tbody > tr").each(function () {
                            let BoxNo = $(this).find("td").eq(2).text();

                            // 長度不是11碼就不是箱號，因為第一個TR是總箱數
                            if (BoxNo.length == BoxNoLength)
                                BoxNoList.push(BoxNo);
                        });

                        $.Ajax({
                            url: "<%=ResolveClientUrl(@"~/WM/Service/PackingListConfirm.ashx")%>",
                            data: {
                                PackingID: $("#<%=TB_PackingID.ClientID%>").val(),
                                Operator: $("#<%=TB_WorkCode.ClientID%>").val(),
                                ScanBoxNo: JSON.stringify(BoxNoList)
                            },
                            CallBackFunction: function (data) {
                                $.AlertMessage({
                                    Message: "<%= (string)GetGlobalResourceObject("GlobalRes", "Str_BT_ConfirmName") + (string)GetGlobalResourceObject("GlobalRes", "Str_Finish") %>",
                                    CloseEvent: function () {
                                        window.location.reload();
                                    }
                                });
                            }
                        });
                    }
                });
            });
        });

        function PreScanBarCdoe() {

            $("#<%=TB_PBNO.ClientID%>").removeClass("readonly").val("").focus();

            $("#<%=TB_PackingID.ClientID%>").addClass("readonly").prop("disabled", true);
        }

        function LoadList() {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/WM/Service/GetPackingListByConfirm.ashx")%>",
                data: { PackingID: $("#<%=TB_PackingID.ClientID%>").val(), PBNO: $("#<%=TB_PBNO.ClientID%>").val() },
                CallBackFunction: function (data) {

                    if (data.Rows.length > 0)
                        $("#PackingDiv").show();
                    else
                        $("#PackingDiv").hide();

                    let IsRepeat = false;

                    $.each(data.Rows, function (Index, item) {

                        $("#PackingTable > tbody > tr").each(function () {
                            if ($(this).find("td").eq(2).text() == item.BoxNo) {

                                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("ProjectGlobalRes", "Str_WM_BoxNo") + (string)GetGlobalResourceObject("GlobalRes", "Str_Repeat")%>" + item.BoxNo + "" });

                                IsRepeat = true;

                                return false;
                            }
                        });

                        if (IsRepeat)
                            return false;
                    });

                    if (IsRepeat)
                        return;

                    if ($("#PackingListTitle").text() == "")
                        $("#PackingListTitle").text(data.MAKTX);

                    let ShowColumnObjectKey = new Array();

                    let TheadIndex = 0;

                    $.each(data.colModel, function (Index, item) {
                        if (!$.StringConvertBoolean(item.hidden)) {
                            $("#PackingTable > thead > tr th:eq(" + TheadIndex + ")").text(item.label);

                            ShowColumnObjectKey.push({ name: item.name, index: TheadIndex });

                            TheadIndex++;
                        }
                    });

                    let RowIDText = $("#PackingTable > tbody > tr:eq(1) > td:first-child").text();

                    let RowID = 1;

                    if (RowIDText != "" && $.isNumeric(RowIDText))
                        RowID = parseInt(RowIDText) + 1;

                    if ($("#PackingTable > tbody > tr:eq(0) > td:eq(0)").text() == data.TotalQtyText)
                        $("#PackingTable > tbody > tr:eq(0)").remove();

                    $.each(data.Rows, function (Index, item) {

                        let ValueTD = "";

                        $.each(ShowColumnObjectKey, function (key, ObjectKey) {

                            if (data.colModel[ObjectKey.index].align == "center") {
                                if (ObjectKey.name != "RowNumber")
                                    ValueTD += "<td class=\"text-center\">" + item[ObjectKey.name] + "</td>";
                                else
                                    ValueTD += "<td class=\"text-center\">" + RowID + "</td>";
                            }
                            else
                                ValueTD += "<td>" + item[ObjectKey.name] + "</td>";
                        });

                        $("#PackingTable > tbody").prepend("<tr>" + ValueTD + "</tr>");

                        RowID = RowID + 1;
                    });

                    let TotalPCS = 0;

                    $("#PackingTable > tbody > tr").each(function () {
                        let PCS = $(this).find("td").eq(4).text();

                        if (PCS != "" && $.isNumeric(PCS))
                            TotalPCS += parseInt(PCS);
                    });

                    let TotalQty = "<tr><td colspan=\"2\" class=\"text-right\">" + data.TotalQtyText + "</td><td class=\"text-center\">" + data.PackingIDTotalBoxNo + "</td><td></td><td class=\"text-center\">" + TotalPCS + "</td></tr>";

                    $("#PackingTable > tbody").prepend(TotalQty);

                    if (data.PackingIDTotalBoxNo == (RowID - 1)) {

                        $("#BT_GoToConfirm").removeClass("disabled");

                        $("#<%=TB_PBNO.ClientID%>").addClass("readonly").prop("disabled", true);
                    }
                    else
                        $("#BT_GoToConfirm").addClass("disabled");
                },
                ErrorCallBackFunction: function (data) {
                    if ($("#PackingTable > tbody > tr").length < 1)
                        $("#<%=TB_PackingID.ClientID%>").removeClass("readonly").prop("disabled", false).val("").focus();
                }
            });

            $("#<%=TB_PBNO.ClientID%>").val("");
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
        <div class="panel-body">
            <div class="row">
                <div class="col-xs-12 form-group">
                    <input type="button" class="btn btn-danger btn-sm" id="BT_Clear" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_Clear")%>" />
                    <input type="button" class="btn btn-primary btn-sm disabled" id="BT_GoToConfirm" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ConfirmName")%>" />
                </div>
                <div class="col-xs-6 form-group required">
                    <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_WorkCode%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearText" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-xs-6 form-group required">
                    <label for="<%= TB_PackingID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PackingID %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PackingID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_WM_ScanPackingID %>"></asp:TextBox>
                </div>
                <div class="col-xs-6 form-group required">
                    <label for="<%= TB_PBNO.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PBNO %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PBNO" runat="server" CssClass="form-control readonly" placeholder="<%$ Resources:GlobalRes,Str_ScanBarCode %>"></asp:TextBox>
                </div>
            </div>
        </div>
    </div>
    <div id="PackingDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
        <h3 id="PackingListTitle"></h3>
        <div class="panel-body">
            <div class="row">
                <table id="PackingTable" class="table table-striped table-bordered table-hover">
                    <thead>
                        <tr>
                            <th style="width: 10%;" class="text-center">#</th>
                            <th style="width: 20%;" class="text-center"></th>
                            <th style="width: 20%;" class="text-center"></th>
                            <th style="width: 40%;" class="text-center"></th>
                            <th style="width: 10%;" class="text-center"></th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>
