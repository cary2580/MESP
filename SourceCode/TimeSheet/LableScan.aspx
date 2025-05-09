<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="LableScan.aspx.cs" Inherits="TimeSheet_LableScan" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        var JQContainerListForScanLableNormalTable = "JQContainerListForScanLableNormalTable";
        var ColumnClassesName = "";
        var LableIDColumnName = "";

        $(function ()
        {
            $("#<%=TB_TicketID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "" || $(this).hasClass("readonly"))
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        if (data.A2 == null)
                        {
                            $("#<%=TB_TicketID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("ProjectGlobalRes","Str_TS_Empty_TicketID") %>" });

                            return;
                        }

                        $("#<%=TB_TicketID.ClientID%>").val(data.A2);
                        $("#<%=HF_TicketID.ClientID%>").val(data.A2);

                        $("#<%=TB_ScanLable.ClientID%>").removeClass("readonlyColor readonly").prop("disabled", false);

                        $("#<%=TB_BoxNo.ClientID%>").val("").data("boxno", "");

                        $("#BT_LableScrap").prop("disabled", false);

                        $("#<%=TB_TicketID.ClientID%>").addClass("readonlyColor readonly").prop("disabled", true);

                        if ($("#<%=TB_MachineID.ClientID%>").val() != "")
                            $("#<%=TB_MachineID.ClientID%>").addClass("readonlyColor readonly").prop("disabled", true);

                        if (data.A2 != "" && $("#<%=TB_MachineID.ClientID%>").val() != "")
                            LoadTicketData();
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_TicketID.ClientID%>").val("");
                    }
                });
            });

            $("#<%=TB_MachineID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "" || $(this).hasClass("readonly"))
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        if (data.A4 == null || data.A5 == null)
                        {
                            $("#<%=TB_MachineID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("ProjectGlobalRes","Str_TS_Empty_DeviceID") %>" });

                            return;
                        }

                        $("#<%=TB_MachineID.ClientID%>").val(data.A5);

                        $("#<%=TB_TicketID.ClientID%>").focus();

                        $("#<%=TB_MachineID.ClientID%>").addClass("readonlyColor readonly").prop("disabled", true);

                        if ($("#<%=TB_TicketID.ClientID%>").val() != "")
                            $("#<%=TB_TicketID.ClientID%>").addClass("readonlyColor readonly").prop("disabled", true);

                        if (data.A5 != "" && $("#<%=TB_TicketID.ClientID%>").val() != "")
                            LoadTicketData();
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_MachineID.ClientID%>").val("");
                    }
                });

            });

            //标签条码扫入Server呼叫
            $("#<%=TB_ScanLable.ClientID%>,#<%=TB_ScanStandbyLable.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "" || $(this).hasClass("readonly"))
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/LableScanAdd.ashx")%>",
                    data: {
                        TicketID: $("#<%=HF_TicketID.ClientID%>").val(),
                        LableID: $.StringConvertBoolean($(this).data("isstandby")) ? $("#<%=TB_ScanStandbyLable.ClientID%>").val() : $("#<%=TB_ScanLable.ClientID%>").val(),
                        MachineID: $("#<%=TB_MachineID.ClientID%>").val(),
                        WorkShiftID: $("#<%=DDL_WorkShift.ClientID%>").val(),
                        PackageQty: $("#<%=TB_PackageQty.ClientID%>").val(),
                        IsStandBy: $.StringConvertBoolean($(this).data("isstandby")),
                        BoxNo: $("#<%=TB_BoxNo.ClientID%>").data("boxno")
                    },
                    CallBackFunction: function (data)
                    {
                        if (!$.StringConvertBoolean(data.Result))
                        {
                            if (data.ResponseResultMessage != "")
                            {
                                var IsWorkCodeVerify = $.StringConvertBoolean(data.IsWorkCodeVerify)

                                $.AlertMessage({
                                    Message: data.ResponseResultMessage, IsHtmlElement: true, CloseEvent: function ()
                                    {
                                        if (!IsWorkCodeVerify)
                                            return;

                                        $.OpenPage({
                                            Framesrc: "<%= ResolveClientUrl(@"~/WorkCodeVerify.aspx") %>",
                                            TitleBarText: "<%=(string)GetLocalResourceObject("Str_VerifySupervisorWorkCodeTitleBarText")%>",
                                            TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                                            width: 710,
                                            height: 560,
                                            NewWindowPageDivID: "VerifySupervisorWorkCode_DivID",
                                            IsForciblyPage: true
                                        });
                                    }
                                });
                            }

                            $("#<%=TB_ScanLable.ClientID%>,#<%=TB_ScanStandbyLable.ClientID%>").val("");
                        }
                        else
                        {
                            $("#<%=TB_ScanLable.ClientID%>,#<%=TB_ScanStandbyLable.ClientID%>").val("");

                            if (data.IsFullBox)
                            {
                                $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_BoxNoInfo_BoxNo")%>" + "(" + data.BoxNo + ")" });

                                $("#<%=TB_TicketID.ClientID%>,#<%=TB_MachineID.ClientID%>").removeClass("readonlyColor readonly").prop("disabled", false);

                                $("#<%=TB_TicketID.ClientID%>").val("");
                            }

                            LoadScanGetData();
                        }
                    }
                });
            });

            //删除报废,标签选择后呼叫Server
            $("#BT_LableScrap").click(function ()
            {

                if ($(this).hasClass("readonly"))
                    return;

                var SelectScanKeyArrayID = new Array();

                var GridTable = $("#" + JQContainerListForScanLableNormalTable);

                var rowKey = GridTable.jqGrid("getGridParam", "selrow");

                if (!rowKey)
                {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });
                    return false;
                }

                var ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

                $.each(GridTable.getGridParam("selarrrow"), function (i, item)
                {
                    var ScanKey = "";

                    if ($.grep(ColumnModel, function (Node) { return Node.name == ScanKeyColumnName; }).length > 0)
                        ScanKey = GridTable.jqGrid("getCell", item, ScanKeyColumnName);

                    if (ScanKey != "")
                        SelectScanKeyArrayID.push(ScanKey);
                });

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_DeleteConfirmMessage") %>", IsHtmlElement: true, CloseEvent: function (result)
                    {
                        if (result)
                        {
                            $.Ajax({
                                url: "<%=ResolveClientUrl("~/TimeSheet/Service/LableScanDelete.ashx") %>", data: {
                                    ScanKeyS: JSON.stringify(SelectScanKeyArrayID)
                                }, CallBackFunction: function (data)
                                {
                                    LoadScanGetData();
                                }
                            });
                        }
                    }
                });
            });

            //箱号查询
            $("#BT_Search").click(function ()
            {
                $("#BT_LableScrap").prop("disabled", true);

                $("#<%=TB_ScanLable.ClientID%>").prop("disabled", true);

                $("#<%=TB_TicketID.ClientID%>").val("");

                $("#<%=TB_TicketID.ClientID%>,#<%=TB_MachineID.ClientID%>").removeClass("readonlyColor readonly").prop("disabled", false);

                $("#<%=TB_BoxNo.ClientID%>").data("boxno", $("#<%=TB_BoxNo.ClientID%>").val());

                LoadScanGetData();
            });

            $("#BT_LableExcessive").click(function ()
            {               
                OpenPage($("#<%=DDL_WorkShift.ClientID%>").val(), $("#<%=TB_MachineID.ClientID%>").val());
            });
        });

        function LoadTicketData()
        {
            if ($("#<%=TB_TicketID.ClientID%>").val() == "" || $("#<%=TB_MachineID.ClientID%>").val() == "" || $("#<%=DDL_WorkShift.ClientID%>").val() == "")
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage") %>" });

                return;
            }

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/LableScanGoIn.ashx")%>",
                data: { TicketID: $("#<%=HF_TicketID.ClientID%>").val(), MachineID: $("#<%=TB_MachineID.ClientID%>").val() },
                CallBackFunction: function (data)
                {

                    $("#<%=TB_TEXT1.ClientID%>").val(data.TEXT1);

                    $("#<%=TB_PackageQty.ClientID%>").val(data.PackageQty);

                    //1先判断是不是试样工单，将包装数量变成可编辑，后面再判断列表是否有扫描进去数据，有了再变成不可编辑
                    $("#<%=TB_PackageQty.ClientID%>").prop("disabled", data.IsSample);//server传TRUE或者FALSE
                    LoadScanGetData();
                },
                ErrorCallBackFunction: function (data)
                {
                    $("#<%=TB_TicketID.ClientID%>,#<%=TB_MachineID.ClientID%>").val("").removeClass("readonlyColor readonly").prop("disabled", false);
                }
            });
        }

        function LoadScanGetData()
        {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/LableScanGetList.ashx")%>",
                data: {
                    TicketID: $("#<%=HF_TicketID.ClientID%>").val(),
                    MachineID: $("#<%=TB_MachineID.ClientID%>").val(),
                    BoxNo: $("#<%=TB_BoxNo.ClientID%>").data("boxno")
                },
                CallBackFunction: function (data)
                {

                    ScanKeyColumnName = data.ItemData.ScanKeyColumnName;
                    ColumnClassesName = data.ItemData.ColumnClassesName;
                    LableIDColumnName = data.ItemData.LableIDColumnName;

                    LoadGridData({
                        ListID: "JQContainerListForScanLableNormal",
                        TableID: JQContainerListForScanLableNormalTable,
                        PagerID: "JQContainerListForScanLableNormalPager",
                        IsShowJQGridFilterToolbar: true,
                        IsShowJQGridPager: true,
                        JQGridDataValue: data.ItemData,
                        IsMultiSelect: true,
                        IsShowJQRowNumbers: false
                    });

                    LoadGridData({
                        ListID: "JQContainerListForScanLableScrap",
                        TableID: "JQContainerListForScanLableScrapTable",
                        PagerID: "JQContainerListForScanLableScrapPager",
                        IsShowJQGridFilterToolbar: true,
                        IsShowJQGridPager: true,
                        JQGridDataValue: data.ItemScrapData,
                        IsMultiSelect: false
                    });

                    LoadGridData({
                        ListID: "JQContainerListForScanLableStandby",
                        TableID: "JQContainerListForScanLableStandbyTable",
                        PagerID: "JQContainerListForScanLableStandbyPager",
                        IsShowJQGridFilterToolbar: true,
                        IsShowJQGridPager: true,
                        JQGridDataValue: data.ItemStandByData,
                        IsMultiSelect: false
                    });
                }
            });
        }

        function JqEventBind()
        {
            $("#" + JQContainerListForScanLableNormalTable).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === ColumnClassesName)
                {
                    var rowData = $(this).jqGrid("getRowData", RowID);

                    if (cm[CellIndex].name === LableIDColumnName)
                    {
                        ScanKey = rowData[ScanKeyColumnName];

                        if (ScanKey != "")
                            OpenPage_M(ScanKey);
                    }
                }
            });
        }

        //打开条码替换页面
        function OpenPage_M(ScanKey)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/LableScan_M.aspx") %>",
                iFrameOpenParameters: { ScanKey: ScanKey },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_LableScan_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 1220,
                height: 860,
                NewWindowPageDivID: "LableScan_M_DivID",
                NewWindowPageFrameID: "LableScan_M_FrameID",
                CloseEvent: function ()
                {
                    LoadScanGetData();
                }
            });
        }

        //打开多余标签页面
        function OpenPage(WorkShiftID, MachineID)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/LableScrap.aspx") %>",
                iFrameOpenParameters: { WorkShiftID: WorkShiftID,MachineID: MachineID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_LableScrap_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 1220,
                height: 860,
                NewWindowPageDivID: "LableScrap_DivID",
                NewWindowPageFrameID: "LableScrap_FrameID",
                CloseEvent: function ()
                {
                    LoadScanGetData();
                }
            });
         }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_TicketID" runat="server" />
    <asp:HiddenField ID="HF_AUART" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-2 form-group required">
                <label for="<%= DDL_WorkShift.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_WorkShift%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_WorkShift" runat="server" CssClass="form-control" required="required">
                </asp:DropDownList>
            </div>
            <div class="col-xs-2 form-group required">
                <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanMachineID %>" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group required">
                <label for="<%= TB_TicketID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TicketID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group">
                <label for="<%= TB_TEXT1.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TEXT1%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_TEXT1" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_PackageQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_PackageQty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_PackageQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_BoxNo.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_BoxNo%>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_BoxNo" runat="server" CssClass="form-control"></asp:TextBox>
                    <span class="input-group-btn">
                        <input id="BT_Search" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_Search") %>" class="btn btn-warning" />
                    </span>
                </div>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ScanLableInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4">
                <div class="col-xs-12 form-group">
                    <label for="<%= TB_ScanLable.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ScanLable%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_ScanLable" runat="server" CssClass="form-control" data-isstandby="0"></asp:TextBox>
                        <span class="input-group-btn">
                            <input id="BT_LableScrap" type="button" value="<%=(string)GetLocalResourceObject("Str_BT_LableScrap") %>" class="btn btn-danger" />
                        </span>
                    </div>
                </div>
                <div class="col-xs-12">
                    <div id="JQContainerListForScanLableNormal"></div>
                </div>
            </div>
            <div class="col-xs-4">
                <div class="col-xs-12 form-group">
                    <label for="<%= TB_Empty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ScrapLable%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_Empty" runat="server" CssClass="form-control readonlyColor readonly" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-12">
                    <div id="JQContainerListForScanLableScrap"></div>
                </div>
            </div>
            <div class="col-xs-4">
                <div class="col-xs-12 form-group">
                    <label for="<%= TB_ScanStandbyLable.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ScanStandbyLable%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_ScanStandbyLable" runat="server" CssClass="form-control" data-isstandby="1"></asp:TextBox>
                        <span class="input-group-btn">
                            <input id="BT_LableExcessive" type="button" value="<%=(string)GetLocalResourceObject("Str_BT_LableExcessive") %>" class="btn btn-primary" />
                        </span>
                    </div>
                </div>
                <div class="col-xs-12">
                    <div id="JQContainerListForScanLableStandby"></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

