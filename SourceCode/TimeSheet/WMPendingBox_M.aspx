<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="WMPendingBox_M.aspx.cs" Inherits="TimeSheet_WMPendingBox_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        var JQGridDataValue = null;

        $(function ()
        {
            if ($("#<%=TB_BoxNo.ClientID%>").val() != "")
            {
                $("#<%=TB_BoxNo.ClientID%>").prop("disabled", true);
                $("#<%=TB_WorkCode.ClientID%>").focus();
                $("#BT_PrintLable").removeClass("disabled");
            }

            $("#<%=TB_BoxNo.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() != "")
                    LoadList();

                $("#BT_PrintLable").removeClass("disabled");
            });

            $("#<%=TB_WorkCode.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                $("#<%=TB_AppendFromBoxNo.ClientID%>").focus();

            });

            $("#BT_Add,#BT_Save").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/WMPendingBoxAction.ashx")%>",
                    data: {
                        ActionID: $(this).data("actionid"),
                        BoxNo: $("#<%=TB_BoxNo.ClientID%>").val(),
                        Operator: $("#<%=TB_WorkCode.ClientID%>").val(),
                        AppendFromBoxNo: $("#<%=TB_AppendFromBoxNo.ClientID%>").val(),
                        Qty: $("#<%=TB_Qty.ClientID%>").val(),
                        TicketID: $("#<%=HF_Ticket.ClientID%>").val()
                    },
                    CallBackFunction: function (data)
                    {
                        LoadList();

                        $("#BT_Cancel").trigger("click");
                    }
                });

            });

            $("#BT_Cancel").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                $("#BT_Add,#BT_Delete").removeClass("disabled");
                $("#BT_Save,#BT_Cancel").addClass("disabled");

                $("#<%=HF_Ticket.ClientID%>").val("");

                $("#<%=TB_AppendFromBoxNo.ClientID%>").val("").prop("disabled", false);

                $("#<%=TB_Qty.ClientID%>").val("0").prop("disabled", false);;

                $("#" + JqGridParameterObject.TableID).trigger("reloadGrid");
            });

            $("#BT_Delete").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                var SelectCBKArrayID = new Array();

                var GridTable = $("#" + JqGridParameterObject.TableID);

                var rowKey = GridTable.jqGrid("getGridParam", "selrow");

                if (!rowKey)
                {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });
                    return false;
                }

                var ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

                $.each(GridTable.getGridParam("selarrrow"), function (i, item)
                {
                    var TicketID = "";

                    if ($.grep(ColumnModel, function (Node) { return Node.name == JQGridDataValue.TicketIDColumnName; }).length > 0)
                        TicketID = GridTable.jqGrid("getCell", item, JQGridDataValue.TicketIDColumnName);
                    if (TicketID != "")
                        SelectCBKArrayID.push(TicketID);
                });

                var actionid = $(this).data("actionid");

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_DeleteConfirmMessage") %>", IsHtmlElement: true, CloseEvent: function (result)
                    {
                        if (result)
                        {
                            $.Ajax({
                                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/WMPendingBoxAction.ashx")%>",
                                data: {
                                    ActionID: actionid,
                                    BoxNo: $("#<%=TB_BoxNo.ClientID%>").val(),
                                    Operator: $("#<%=TB_WorkCode.ClientID%>").val(),
                                    DeleteTicketIDs: JSON.stringify(SelectCBKArrayID)
                                },
                                CallBackFunction: function (data)
                                {
                                    LoadList();

                                    $("#BT_Cancel").trigger("click");
                                }
                            });
                        }
                    }
                });
            });

            $("#BT_PrintLable").click(function ()
            {
                if ($(this).hasClass("disabled"))
                    return;

                parent.window.open("<%=ResolveClientUrl(@"~/TimeSheet/RPT_008.aspx?IsRePrint=1&BoxNo=")%>" + $("#<%=TB_BoxNo.ClientID%>").val(), "_blank", "toolbar=false,location=false,menubar=false,width=" + screen.availWidth + ",height=" + screen.availHeight + "");
            });

            LoadList();
        });

        function LoadList()
        {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/WMPendingBoxGetInfoList.ashx")%>",
                data: { BoxNo: $("#<%=TB_BoxNo.ClientID%>").val() },
                CallBackFunction: function (data)
                {
                    LoadGridData({ JQGridDataValue: data, IsShowJQGridFilterToolbar: true, IsShowFooterRow: true, IsMultiSelect: true });

                    $("#<%=TB_AppendFromBoxNo.ClientID%>").val("");

                    $("#<%=TB_Qty.ClientID%>").val("0");

                    if (data.Rows.length < 1)
                    {
                        if ($("#<%=TB_BoxNo.ClientID%>").val() != "")
                        {
                            $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_NoDataMessage") %>" });

                            $("#<%=TB_BoxNo.ClientID%>").val("");
                        }
                        else
                            $("#<%=TB_BoxNo.ClientID%>").focus();
                    }
                    else
                    {
                        $("#<%=TB_BoxNo.ClientID%>").prop("disabled", true);

                        $("#<%=TB_AppendFromBoxNo.ClientID%>,#<%=TB_Qty.ClientID%>").prop("disabled", false);

                        $("#BT_Add,#BT_Delete").removeClass("disabled");

                        if ($("#<%=TB_WorkCode.ClientID%>").val() == "")
                            $("#<%=TB_WorkCode.ClientID%>").focus();
                        else
                            $("#<%=TB_AppendFromBoxNo.ClientID%>").focus();
                    }
                }
            });
        }

        function JqEventBind(PO)
        {
            JQGridDataValue = PO.JQGridDataValue;

            $("#" + PO.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === PO.JQGridDataValue.ColumnClassesName)
                {
                    var TicketID = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.TicketIDColumnName);

                    var Qty = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.QtyColumnName);

                    if (cm[CellIndex].name == PO.JQGridDataValue.TicketIDColumnName && TicketID != "")
                        $.WindowOpen("Post", "<%=ResolveClientUrl(@"~/TimeSheet/TicketLifeCycle.aspx?A2=")%>" + TicketID);
                    else if (cm[CellIndex].name == PO.JQGridDataValue.TEXT1ColumnName)
                    {
                        $("#BT_Add,#BT_Delete").addClass("disabled");
                        $("#BT_Save,#BT_Cancel").removeClass("disabled");

                        $("#<%=HF_Ticket.ClientID%>").val(TicketID);

                        $("#<%=TB_AppendFromBoxNo.ClientID%>").val("").prop("disabled", true);
                        $("#<%=TB_Qty.ClientID%>").val(Qty).prop("disabled", false);
                    }
                }
            });

            $("#" + PO.TableID).bind("jqGridAfterGridComplete", function ()
            {
                var Rows = $(this).jqGrid("getDataIDs");

                var TotalQty = 0;

                for (var i = 0; i < Rows.length; i++)
                {
                    var RowID = Rows[i];

                    TotalQty += numeral($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.QtyColumnName)).value();
                }

                $(this).jqGrid("footerData", "set", {
                    [PO.JQGridDataValue.QtyColumnName]: numeral(TotalQty).format("0,0")
                });
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_AllowQty" runat="server" Value="0" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
        <div class="panel-body">
            <div class="row">
                <div class="col-xs-12 form-group">
                    <input type="button" class="btn btn-brown disabled" id="BT_PrintLable" value="<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_WM_PrintLable")%>" />
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_BoxNo.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_BoxNo %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_BoxNo" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_WM_ScanBoxNo %>"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_WorkCode%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-12">
                    <p></p>
                    <div id="TicketListDiv" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
                        <div class="panel-heading text-center">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_ListTitle%>"></asp:Literal>
                        </div>
                        <div class="panel-body">
                            <div class="col-xs-12 form-group">
                                <input type="button" class="btn btn-primary disabled" id="BT_Add" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName")%>" data-actionid="0" />
                                <input type="button" class="btn btn-warning disabled" id="BT_Save" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_SaveName")%>" data-actionid="1" />
                                <input type="button" class="btn btn-info disabled" id="BT_Cancel" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_CancelName")%>" />
                                <input type="button" class="btn btn-danger disabled" id="BT_Delete" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName")%>" data-actionid="2" />
                            </div>
                            <div class="col-xs-4 form-group required">
                                <label for="<%= TB_AppendFromBoxNo.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:Str_AppendFromBoxNo%>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_AppendFromBoxNo" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_WM_ScanBoxNo %>" disabled="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-4 form-group required">
                                <label for="<%= TB_Qty.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:Str_Qty%>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Qty" runat="server" CssClass="form-control MumberType" Text="0" disabled="true"></asp:TextBox>
                            </div>
                            <asp:HiddenField ID="HF_Ticket" runat="server" />
                            <div class="col-xs-12 form-group">
                                <div id="JQContainerList"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
