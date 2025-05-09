<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="TicketReportByOtherProcess.aspx.cs" Inherits="TimeSheet_TicketReportByOtherProcess" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        var JQGridDataValue = null;
        $(function ()
        {
            $("#<%=TB_WorkCode.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() != "")
                    $("#<%=DDL_WorkShift.ClientID%>").focus();

            }).focus();

            $("#<%=TB_TicketID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        if (data.A2 == null)
                        {
                            $("#<%=TB_TicketID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_TicketID")%>" });

                            return;
                        }

                        $("#<%=TB_TicketID.ClientID%>").val(data.A2);

                        if ($("#<%=TB_TicketID.ClientID%>").val() != "")
                            ExecTicketGoIn();
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_TicketID.ClientID%>").val("");
                    }
                });
            });

            $("#BT_Save").click(function ()
            {
                if ($("#<%=TB_WorkCode.ClientID%>").val() == "" || $("#<%=DDL_ProcessID.ClientID%>").val() == "" || $("#<%=DDL_WorkShift.ClientID%>").val() == "" || $("#<%=TB_AllowQty.ClientID%>").val() == "")
                {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketReportByOtherProcess.ashx")%>",
                    timeout: 300 * 1000,
                    data: {
                        TicketID: $("#<%=TB_TicketID.ClientID%>").val(),
                        WorkCode: $("#<%=TB_WorkCode.ClientID%>").val(),
                        ProcessID: $("#<%=DDL_ProcessID.ClientID%>").val(),
                        WorkShiftID: $("#<%=DDL_WorkShift.ClientID%>").val(),
                        Qty: $("#<%=TB_Qty.ClientID%>").val(),
                        SerialNo: $("#<%=HF_SerialNo.ClientID%>").val()
                    },
                    CallBackFunction: function (data)
                    {
                        if ($("#JQContainerList").closest(".panel").is(":visible"))
                            $("#BT_Search").removeClass("disabled").trigger("click");

                        $("#<%=TB_AllowQty.ClientID%>").val("0");
                        $("#<%=TB_Brand.ClientID%>,#<%=TB_TEXT1.ClientID%>,#<%=TB_Qty.ClientID%>,#<%=HF_SerialNo.ClientID%>").val("");

                        $("#<%=TB_TicketID.ClientID%>").val("").prop("disabled", false).focus();
                    }
                });
            });

            $("#BT_Search").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                if ($("#<%=TB_WorkCode.ClientID%>").val() == "" || $("#<%=DDL_ProcessID.ClientID%>").val() == "")
                {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketReportByOtherProcessGetList.ashx")%>",
                    timeout: 300 * 1000,
                    data: {
                        WorkCode: $("#<%=TB_WorkCode.ClientID%>").val(),
                        ProcessID: $("#<%=DDL_ProcessID.ClientID%>").val()
                    },
                    CallBackFunction: function (data)
                    {
                        $("#BT_Cancel").trigger("click");

                        $("#JQContainerList").closest(".panel").show();

                        JQGridDataValue = data;

                        LoadGridData({
                            IsMultiSelect: true,
                            IsShowJQGridFilterToolbar: true,
                            JQGridDataValue: data
                        });
                    }
                });
            });

            $("#BT_Cancel").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                $("#<%=TB_WorkCode.ClientID%>").prop("disabled", false);
                $("#<%=DDL_ProcessID.ClientID%>").prop("disabled", false);
                $("#<%=DDL_WorkShift.ClientID%>").val("").prop("disabled", false);
                $("#<%=TB_Brand.ClientID%>").val("");
                $("#<%=TB_TEXT1.ClientID%>").val("");
                $("#<%=TB_TicketID.ClientID%>").val("").prop("disabled", false);
                $("#<%=TB_AllowQty.ClientID%>").val("");
                $("#<%=TB_Qty.ClientID%>").val("0");
                $("#<%=HF_SerialNo.ClientID%>").val("");

                $("#BT_Search").removeClass("disabled");
                $(this).addClass("disabled");
            });

            $("#BT_Delete").click(function ()
            {
                var SelectCBKArrayID = new Array();

                var GridTable = $("#" + JqGridParameterObject.TableID);

                var rowKey = GridTable.jqGrid("getGridParam", "selrow");

                if (!rowKey)
                {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });

                    return;
                }

                var ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

                $.each(GridTable.getGridParam("selarrrow"), function (i, item)
                {
                    var TicketID = "";
                    var ProcessID = "";
                    var SerialNo = "";

                    if ($.grep(ColumnModel, function (Node) { return Node.name == JQGridDataValue.TicketIDValueColumnName; }).length > 0)
                        TicketID = GridTable.jqGrid("getCell", item, JQGridDataValue.TicketIDValueColumnName);
                    if ($.grep(ColumnModel, function (Node) { return Node.name == JQGridDataValue.ProcessIDColumnName; }).length > 0)
                        ProcessID = GridTable.jqGrid("getCell", item, JQGridDataValue.ProcessIDColumnName);
                    if ($.grep(ColumnModel, function (Node) { return Node.name == JQGridDataValue.SerialNoColumnName; }).length > 0)
                        SerialNo = GridTable.jqGrid("getCell", item, JQGridDataValue.SerialNoColumnName);

                    if (TicketID != "" && ProcessID != "" && SerialNo != "")
                        SelectCBKArrayID.push({ TicketID: TicketID, ProcessID: ProcessID, SerialNo: SerialNo });
                });

                $.Ajax({
                    url: "<%=ResolveClientUrl("~/TimeSheet/Service/TicketReportDeleteByOtherProcess.ashx") %>", data: {
                        DeleteList: JSON.stringify(SelectCBKArrayID)
                    }, CallBackFunction: function (data)
                    {
                        $("#BT_Search").trigger("click");
                    }
                });

            });
        });

        function JqEventBind(PO)
        {
            $("#" + PO.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === PO.JQGridDataValue.ColumnClassesName)
                {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");

                    var TicketID = "";
                    var SerialNo = "";
                    var WorkCode = "";
                    var ProcessID = "";
                    var WorkShiftID = "";
                    var Brand = "";
                    var TEXT1 = "";
                    var Qty = "";

                    if ($.inArray(PO.JQGridDataValue.TicketIDColumnName, columnNames) > 0)
                        TicketID = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.TicketIDValueColumnName);
                    if ($.inArray(PO.JQGridDataValue.SerialNoColumnName, columnNames) > 0)
                        SerialNo = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.SerialNoColumnName);
                    if ($.inArray(PO.JQGridDataValue.WorkCodeColumnName, columnNames) > 0)
                        WorkCode = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.WorkCodeColumnName);
                    if ($.inArray(PO.JQGridDataValue.ProcessIDColumnName, columnNames) > 0)
                        ProcessID = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.ProcessIDColumnName);
                    if ($.inArray(PO.JQGridDataValue.WorkShiftIDColumnName, columnNames) > 0)
                        WorkShiftID = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.WorkShiftIDColumnName);

                    if ($.inArray(PO.JQGridDataValue.BrandColumnName, columnNames) > 0)
                        Brand = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.BrandValueColumnName);
                    if ($.inArray(PO.JQGridDataValue.TEXT1ColumnName, columnNames) > 0)
                        TEXT1 = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.TEXT1ValueColumnName);
                    if ($.inArray(PO.JQGridDataValue.QtyColumnName, columnNames) > 0)
                        Qty = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.QtyValueColumnName);

                    if (TicketID != "" && SerialNo != "")
                    {
                        $("#<%=TB_WorkCode.ClientID%>").val(WorkCode).prop("disabled", true);
                        $("#<%=DDL_ProcessID.ClientID%>").val(ProcessID).prop("disabled", true);
                        $("#<%=DDL_WorkShift.ClientID%>").val(WorkShiftID);
                        $("#<%=TB_Brand.ClientID%>").val(Brand);
                        $("#<%=TB_TEXT1.ClientID%>").val(TEXT1);
                        $("#<%=TB_TicketID.ClientID%>").val(TicketID).prop("disabled", true);
                        $("#<%=TB_AllowQty.ClientID%>").val(Qty);
                        $("#<%=HF_SerialNo.ClientID%>").val(SerialNo);

                        $("#<%=TB_Qty.ClientID%>").trigger("touchspin.updatesettings", { max: parseInt($("#<%=TB_AllowQty.ClientID%>").val()) }).val(Qty);

                        $("#BT_Cancel").removeClass("disabled");
                        $("#BT_Search").addClass("disabled");
                    }
                }
            });
        }

        function ExecTicketGoIn()
        {
            if ($("#<%=TB_WorkCode.ClientID%>").val() == "" || $("#<%=DDL_ProcessID.ClientID%>").val() == "" || $("#<%=DDL_WorkShift.ClientID%>").val() == "" || $("#<%=TB_TicketID.ClientID%>").val() == "")
            {
                $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                $("#<%=TB_TicketID.ClientID%>").val("");

                return;
            }

            $("#<%=TB_TicketID.ClientID%>").prop("disabled", true);

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketGoInByOtherProcess.ashx")%>",
                timeout: 300 * 1000,
                data: {
                    TicketID: $("#<%=TB_TicketID.ClientID%>").val(),
                    WorkCode: $("#<%=TB_WorkCode.ClientID%>").val(),
                    ProcessID: $("#<%=DDL_ProcessID.ClientID%>").val()
                },
                CallBackFunction: function (data)
                {
                    $("#<%=HF_SerialNo.ClientID%>").val("");
                    $("#<%=TB_AllowQty.ClientID%>").val(data.AllowQty);
                    $("#<%=TB_Brand.ClientID%>").val(data.Brand);
                    $("#<%=TB_TEXT1.ClientID%>").val(data.TEXT1);

                    $("#<%=TB_Qty.ClientID%>").trigger("touchspin.updatesettings", { max: parseInt($("#<%=TB_AllowQty.ClientID%>").val()) }).val(data.AllowQty);

                    $("#BT_Save").focus();
                },
                ErrorCallBackFunction: function (data)
                {
                    $("#<%=TB_TicketID.ClientID%>").val("").prop("disabled", false).focus();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_SerialNo" runat="server" />
    <div class="col-xs-12">
        <div id="TickeInfoPanel" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Title%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCode%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= DDL_ProcessID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ProcessID %>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_ProcessID" runat="server" CssClass="form-control" required="required">
                    </asp:DropDownList>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= DDL_WorkShift.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_WorkShift %>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_WorkShift" runat="server" CssClass="form-control" required="required">
                    </asp:DropDownList>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_AllowQty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_AllowQty %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_AllowQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_Brand.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_Brand %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_Brand" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_TEXT1.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TEXT1 %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TEXT1" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_TicketID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketID %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_Qty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_Qty %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_Qty" runat="server" CssClass="form-control MumberType" required="required" Text="0"></asp:TextBox>
                </div>
                <div class="col-xs-12 form-group text-center">
                    <input type="button" class="btn btn-warning" id="BT_Save" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_SaveName") %>" />
                    <input type="button" class="btn btn-success" id="BT_Search" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_Search") %>" />
                    <input type="button" class="btn btn-pink disabled" id="BT_Cancel" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_CancelName") %>" />
                </div>
            </div>
        </div>
    </div>
    <div class="col-xs-12">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>" style="display: none;">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_DataList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <input type="button" class="btn btn-danger" id="BT_Delete" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName")%>" />
                <p></p>
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
