<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="ProductBoxToPallet.aspx.cs" Inherits="WM_ProductBoxToPallet" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $.Main.Defaults.AlertMessage.width = 300;
            $.Main.Defaults.ConfirmMessage.width = 300;

            $("#<%=TB_BoxNo.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($("#<%=TB_WorkCode.ClientID%>").val() == "")
                {
                    $("#<%=TB_WorkCode.ClientID%>").focus();

                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes", "Str_TS_Empty_WorkCode")%>" });

                    e.preventDefault();

                    return;
                }

                BoxGoToPallet();
            });

            $("#<%=TB_WorkCode.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() != "" && $("#<%=TB_BoxNo.ClientID%>").val() != "")
                    BoxGoToPallet();
                else if ($(this).val() != "")
                {
                    $("#<%=TB_BoxNo.ClientID%>").focus();

                    LoadList();
                }
            }).focus();

            $("#BT_GoToWarehouse").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                if ($.StringConvertBoolean($("#<%=HF_IsNeedSupervisorConfirm.ClientID%>").val()))
                {
                    var FrameID = "VerifySupervisorWorkCode_FrameID";

                    $.OpenPage({
                        Framesrc: "<%= ResolveClientUrl(@"~/WorkCodeVerify.aspx") %>",
                        iFrameOpenParameters: { AlertMessageWidth: 200 },
                        TitleBarText: "<%=(string)GetLocalResourceObject("Str_VerifySupervisorWorkCodeTitleBarText")%>",
                        TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                        width: 300,
                        height: 360,
                        NewWindowPageDivID: "VerifySupervisorWorkCode_DivID",
                        NewWindowPageFrameID: FrameID,
                        TitleBarCloseButtonTriggerCloseEvent: true,
                        CloseEvent: function ()
                        {
                            var Frame = $("#" + FrameID + "").contents();

                            if (Frame != null)
                            {
                                var IsVerifySuccess = $.StringConvertBoolean(Frame.find("#HF_IsVerifySuccess").val());

                                if (IsVerifySuccess)
                                    PalletGoToWarehouse();
                            }
                        }
                    });
                }
                else
                    PalletGoToWarehouse();
            });
        });

        ///進入棧板
        function BoxGoToPallet()
        {
            var BoxNo = $("#<%=TB_BoxNo.ClientID%>").val();

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/WM/Service/BoxGoToPallet.ashx")%>",
                data: {
                    PalletNo: $("#<%=HF_PalletNo.ClientID%>").val(),
                    Created: $("#<%=TB_WorkCode.ClientID%>").val(),
                    BoxNo: BoxNo
                },
                CallBackFunction: function (data)
                {
                    $("#<%=TB_BoxNo.ClientID%>").val("").focus();

                    LoadList();
                }
            });

            $("#<%=TB_BoxNo.ClientID%>").val("");
        }

        function LoadList()
        {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/WM/Service/PalletTempGetList.ashx")%>",
                data: { PalletNo: $("#<%=HF_PalletNo.ClientID%>").val(), Operator: $("#<%=TB_WorkCode.ClientID%>").val() },
                CallBackFunction: function (data)
                {
                    $("#PalletTable > tbody > tr").detach();

                    if (data.Rows.length > 0)
                    {
                        $("#BT_GoToWarehouse").removeClass("disabled");

                        $("#PalletDiv").show();
                    }
                    else
                    {
                        $("#BT_GoToWarehouse").addClass("disabled");

                        $("#PalletDiv").hide();
                    }

                    if (data.Rows.length < 1)
                        $("#<%=DDL_LGORT.ClientID%>").selectpicker("val", "");

                    if ($("#<%=DDL_LGORT.ClientID%>").selectpicker("val") == "")
                        $("#<%=DDL_LGORT.ClientID%>").selectpicker("val", data.LGORT);

                    $("#<%=HF_PalletNo.ClientID%>").val(data.PalletNo);

                    $("#PalletListTitle").text(data.MAKTX);

                    $("#<%=HF_IsNeedSupervisorConfirm.ClientID%>").val(data.IsNeedSupervisorConfirm);

                    var TheadIndex = 0;

                    var ShowColumnObjectKey = new Array();

                    $.each(data.colModel, function (Index, item)
                    {
                        if (!$.StringConvertBoolean(item.hidden))
                        {
                            $("#PalletTable > thead > tr th:eq(" + TheadIndex + ")").text(item.label);

                            ShowColumnObjectKey.push({ name: item.name, index: TheadIndex });

                            TheadIndex++;
                        }
                    });

                    var TotalQty = "<tr><td colspan=\"2\" class=\"text-right\">" + data.TotalQtyText + "</td><td class=\"text-center\">" + data.TotalQty + "</td><td></td></tr>";

                    $("#PalletTable > tbody").append(TotalQty);

                    $.each(data.Rows, function (Index, item)
                    {
                        var ValueTD = "";

                        $.each(ShowColumnObjectKey, function (key, ObjectKey)
                        {
                            if (data.colModel[ObjectKey.index].align == "center")
                                ValueTD += "<td class=\"text-center\">" + item[ObjectKey.name] + "</td>";
                            else
                                ValueTD += "<td>" + item[ObjectKey.name] + "</td>";
                        });

                        ValueTD += "<td class=\"text-center\"><button type =\"button\" class=\"btn btn-danger btn-xs DelButton\" data-boxno=\"" + item[data.BoxNoColumnName] +"\"><%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName")%></button></td >";

                        $("#PalletTable > tbody").append("<tr>" + ValueTD + "</tr>");
                    });

                    $(".DelButton").click(DeleteBox);
                }
            });
        }

        function DeleteBox()
        {
            var BoxNo = "";

            if (typeof $(this).data("boxno") != "undefined")
                BoxNo = $(this).data("boxno");

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/WM/Service/BoxDetachToPallet.ashx")%>",
                data: {
                    PalletNo: $("#<%=HF_PalletNo.ClientID%>").val(),
                    Operator: $("#<%=TB_WorkCode.ClientID%>").val(),
                    BoxNo: BoxNo
                },
                CallBackFunction: function (data)
                {
                    LoadList();
                }
            });
        }

        // 入庫
        function PalletGoToWarehouse()
        {
            $.ConfirmMessage({
                Message: "<%=(string)GetLocalResourceObject("Str_ConfirmMessage")%>", IsHtmlElement: true, CloseEvent: function (Result)
                {
                    if (!Result)
                    {
                        event.preventDefault();

                        return;
                    }

                    $.Ajax({
                        url: "<%=ResolveClientUrl(@"~/WM/Service/PalletGoToWarehouse.ashx")%>",
                        data: {
                            PalletNo: $("#<%=HF_PalletNo.ClientID%>").val(),
                            Operator: $("#<%=TB_WorkCode.ClientID%>").val(),
                            LGORT: $("#<%=DDL_LGORT.ClientID%>").val(),
                            DeliveryLocation: $("#<%=DDL_DeliveryLocation.ClientID%>").val()
                        },
                        CallBackFunction: function (data)
                        {
                            $("#<%=HF_IsNeedSupervisorConfirm.ClientID%>,#<%=HF_PalletNo.ClientID%>,#<%=TB_BoxNo.ClientID%>").val("");

                            $("#<%=TB_BoxNo.ClientID%>").val("").focus();

                            if (data.PalletNo != "")
                            {
                                $("#<%=HF_PalletNo.ClientID%>").val(data.PalletNo);
                                /*打印栈板页*/
                                window.open("<%=ResolveClientUrl(@"~/WM/RPT_001.aspx?PalletNo=")%>" + $("#<%=HF_PalletNo.ClientID%>").val(), "_blank", "toolbar=false,location=false,menubar=false,width=" + screen.availWidth + ",height=" + screen.availHeight + "");

                                LoadList();
                            }
                        }
                    });
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_PalletNo" runat="server" />
    <asp:HiddenField ID="HF_IsNeedSupervisorConfirm" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
        <div class="panel-body">
            <div class="row">
                <div class="col-xs-12 form-group">
                    <input type="button" class="btn btn-primary btn-sm disabled" id="BT_GoToWarehouse" value="<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_WM_GoToWarehouse")%>" />
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
                    <label for="<%= TB_BoxNo.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_BoxNo %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_BoxNo" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_WM_ScanBoxNo %>"></asp:TextBox>
                </div>
                <div class="col-xs-6 form-group required">
                    <label for="<%= DDL_LGORT.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_LGORT %>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_LGORT" runat="server" CssClass="form-control selectpicker" required="required" data-live-search="true">
                    </asp:DropDownList>
                </div>
                <div class="col-xs-6 form-group">
                    <label for="<%= DDL_DeliveryLocation.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_DeliveryLocation%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_DeliveryLocation" runat="server" CssClass="form-control selectpicker" data-live-search="true">
                    </asp:DropDownList>
                </div>
            </div>
        </div>
    </div>
    <div id="PalletDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
        <h3 id="PalletListTitle"></h3>
        <div class="panel-body">
            <div class="row">
                <table id="PalletTable" class="table table-striped table-bordered table-hover">
                    <thead>
                        <tr>
                            <th style="width: 10%;" class="text-center">#</th>
                            <th style="width: 65%;" class="text-center"></th>
                            <th style="width: 20%;" class="text-center"></th>
                            <th style="width: 5%;" class="text-center">
                                <button type="button" class="btn btn-danger btn-xs" onclick="DeleteBox();"><%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteAllName")%></button></th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>

