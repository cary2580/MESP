<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="PackingToOutside.aspx.cs" Inherits="WM_PackingToOutside" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        let PackingListID = "JQContainerPackingList";
        let BoxGridTableID = "StockBoxList";
        let PalletNoColumnName = "";
        let BoxNoColumnName = "";

        $(function () {
            $("#<%= TB_VBELN.ClientID %>,#<%= TB_POSNR.ClientID%>").css("cursor", "pointer");

            $(".SalesOrderSelect").click(function () {
                var FrameID = "SalesOrderSelect_FrameID";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/WM/SalesOrderSelect.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_SalesOrderSelect_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 1480,
                    height: 870,
                    NewWindowPageDivID: "SalesOrderSelect_DivID",
                    NewWindowPageFrameID: FrameID,
                    parentWindow: window.parent,
                    CloseEvent: function (result) {
                        var SelectedValueJson = $(result).find("#" + FrameID).contents().find("#HF_SelectedValue").val();

                        var SelectedValue = $.parseJSON(SelectedValueJson);

                        $("#<%= TB_VBELN.ClientID%>").val(SelectedValue.VBELN);
                        $("#<%= TB_POSNR.ClientID%>").val(SelectedValue.POSNR);
                        $("#<%= TB_KUNNR.ClientID%>").val(SelectedValue.KUNNR);
                        $("#<%= TB_KUNNR_Name.ClientID%>").val(SelectedValue.KUNNR_NAME);
                        $("#<%= TB_MATNR.ClientID%>").val(SelectedValue.MATNR);
                        $("#<%= TB_MAKTX.ClientID%>").val(SelectedValue.MAKTX);
                        $("#<%= TB_DeliveryDate.ClientID%>").val(SelectedValue.DeliveryDate);
                        $("#<%= TB_BSTKD.ClientID%>").val(SelectedValue.BSTKD);
                        $("#<%= TB_KDMAT.ClientID%>").val(SelectedValue.KDMAT);
                        $("#<%= TB_KWMENG.ClientID%>").val(SelectedValue.KWMENG);
                        $("#<%= TB_LFIMG.ClientID%>").val(SelectedValue.LFIMG);
                        $("#<%= TB_AllowQty.ClientID%>").val(SelectedValue.AllowQty);

                        $("#<%= HF_PackingID.ClientID%>").val("");

                        LoadStockList();
                    }
                });
            });

            $("#BT_AddPackingByBox,#BT_AddPackingByPallet,#BT_Packing,#BT_RemovePacking").hide();

            $("#BT_AddPackingByPallet").click(function () {
                let StockJqGrid = $("#" + JqGridParameterObject.TableID);

                let SelRcowId = StockJqGrid.jqGrid("getGridParam", "selarrrow");

                let PalletNoList = new Array();

                for (var row = SelRcowId.length - 1; row >= 0; row--) {
                    let RowData = StockJqGrid.jqGrid("getRowData", SelRcowId[row]);

                    PalletNoList.push(RowData[PalletNoColumnName])
                }

                if (PalletNoList.length < 1) {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_GridSelectZeroAlertMessage")%>" });

                    return false;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/WM/Service/BoxGoToPackingList.ashx")%>",
                    data: { ActionID: 1, PackingID: $("#<%=HF_PackingID.ClientID%>").val(), PalletNoList: JSON.stringify(PalletNoList), AllowQty: $("#<%=TB_AllowQty.ClientID%>").val() },
                    CallBackFunction: function (data) {
                        $("#<%=HF_PackingID.ClientID%>").val(data.PackingID);

                        LoadStockList();
                    }
                });
            });

            $("#BT_AddPackingByBox").click(function () {

                let SubTable = $("#" + JqGridParameterObject.TableID).find("table[id*=\"" + BoxGridTableID + "\"]");

                let BoxNoList = new Array();

                $.each(SubTable, function (Index, Item) {
                    let StockJqGrid = $(Item);

                    let SelRcowId = StockJqGrid.jqGrid("getGridParam", "selarrrow");

                    for (var row = SelRcowId.length - 1; row >= 0; row--) {
                        let RowData = StockJqGrid.jqGrid("getRowData", SelRcowId[row]);

                        BoxNoList.push(RowData[BoxNoColumnName])
                    }
                });

                if (BoxNoList.length < 1) {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_GridSelectZeroAlertMessage")%>" });

                    return false;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/WM/Service/BoxGoToPackingList.ashx")%>",
                    data: { ActionID: 1, PackingID: $("#<%=HF_PackingID.ClientID%>").val(), BoxNoList: JSON.stringify(BoxNoList), AllowQty: $("#<%=TB_AllowQty.ClientID%>").val() },
                    CallBackFunction: function (data) {
                        $("#<%=HF_PackingID.ClientID%>").val(data.PackingID);

                        LoadStockList();
                    }
                });
            });

            $("#BT_RemovePacking").click(function () {
                let PackingListJqGrid = $("#" + PackingListID + "Table");

                let SelRcowId = PackingListJqGrid.jqGrid("getGridParam", "selarrrow");

                let BoxNoList = new Array();

                for (var row = SelRcowId.length - 1; row >= 0; row--) {
                    let RowData = PackingListJqGrid.jqGrid("getRowData", SelRcowId[row]);

                    BoxNoList.push(RowData[BoxNoColumnName])
                }

                if (BoxNoList.length < 1) {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_GridSelectZeroAlertMessage")%>" });

                    return false;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/WM/Service/BoxGoToPackingList.ashx")%>",
                    data: { ActionID: 2, PackingID: $("#<%=HF_PackingID.ClientID%>").val(), BoxNoList: JSON.stringify(BoxNoList) },
                    CallBackFunction: function (data) {
                        $("#<%=HF_PackingID.ClientID%>").val(data.PackingID);

                        LoadStockList();
                    }
                });

            });

            $("#BT_Packing").click(function () {

                let FrameID = "GeneralRemark_FrameID";

                let Remark = $("#<%=HF_PackingRemark.ClientID%>").val();

                $("#<%=HF_PackingRemark.ClientID%>").val("");

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/GeneralRemark.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_PackingRemark_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    iFrameOpenParameters: { IsRequired: false, DefaultValue: Remark },
                    width: 780,
                    height: 670,
                    NewWindowPageDivID: "GeneralRemark_DivID",
                    NewWindowPageFrameID: FrameID,
                    parentWindow: window.parent,
                    CloseEvent: function (result) {
                        let RemarkValue = $(result).find("#" + FrameID).contents().find("#TB_Remark").val();

                        $("#<%=HF_PackingRemark.ClientID%>").val(RemarkValue);

                        Packing();
                    }
                });
            });
        });

        function Packing(parentWindow) {

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/WM/Service/PackingToOutside.ashx")%>",
                IsErrorShowAlert: false,
                data: {
                    PackingID: $("#<%=HF_PackingID.ClientID%>").val(),
                    VBELN: $("#<%=TB_VBELN.ClientID%>").val(),
                    POSNR: $("#<%=TB_POSNR.ClientID%>").val(),
                    KUNNR: $("#<%=TB_KUNNR.ClientID%>").val(),
                    KUNNR_NAME: $("#<%=TB_KUNNR_Name.ClientID%>").val(),
                    MATNR: $("#<%=TB_MATNR.ClientID%>").val(),
                    MAKTX: $("#<%=TB_MAKTX.ClientID%>").val(),
                    KDMAT: $("#<%=TB_KDMAT.ClientID%>").val(),
                    DeliveryDate: $("#<%=TB_DeliveryDate.ClientID%>").val(),
                    BSTKD: $("#<%=TB_BSTKD.ClientID%>").val(),
                    KWMENG: $("#<%=TB_KWMENG.ClientID%>").val(),
                    LFIMG: $("#<%=TB_LFIMG.ClientID%>").val(),
                    AllowQty: $("#<%=TB_AllowQty.ClientID%>").val(),
                    Remark: $("#<%=HF_PackingRemark.ClientID%>").val()
                },
                CallBackFunction: function (data) {

                    /*打印领料单*/
                    window.open("<%=ResolveClientUrl(@"~/WM/RPT_003.aspx?PackingID=")%>" + data.PackingID, "_blank", "toolbar=false,location=false,menubar=false,width=" + screen.availWidth + ",height=" + screen.availHeight + "");

                    window.location.reload();
                },
                ErrorCallBackFunction: function (data) {
                    $.AlertMessage({
                        Message: $.trim(data.ErrorMsg), IsHtmlElement: true, TitleBarText: $.Main.Defaults.VerificationDataDefaults.TitleBarText, TitleBarImg: $.Main.Defaults.AlertMessage.TitleBarImg, "parentWindow": parentWindow, CloseEvent: function () {
                            $("#BT_Packing").trigger("click");
                        }
                    });
                }
            });
        }

        function LoadStockList() {
            if ($("#<%= TB_KUNNR.ClientID%>").val() == "" || $("#<%= TB_MATNR.ClientID%>").val() == "")
                return;

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/WM/Service/GetPalletStockListBySalesOrder.ashx")%>",
                data: { KUNNR: $("#<%=TB_KUNNR.ClientID%>").val(), MATNR: $("#<%=TB_MATNR.ClientID%>").val(), PackingID: $("#<%=HF_PackingID.ClientID%>").val() },
                CallBackFunction: function (data) {
                    if (!$("#StockListContent").hasClass("in"))
                        $("#StockListContent").collapse("toggle");

                    if (data.Rows.length > 0)
                        $("#BT_AddPackingByBox,#BT_AddPackingByPallet").show();
                    else
                        $("#BT_AddPackingByBox,#BT_AddPackingByPallet").hide();

                    PalletNoColumnName = data.PalletNoColumnName;


                    LoadGridData({
                        IsMultiSelect: true,
                        IsShowSubGrid: true,
                        IsShowJQGridFilterToolbar: true,
                        RowNum: 100,
                        JQGridDataValue: data
                    });

                    LoadPackingListTemp();
                }
            });
        }

        function JqSubGridRowExpandedEvent(ParentRowID, ParentRowKey) {
            let PalletNo = $("#" + JqGridParameterObject.TableID).jqGrid("getCell", ParentRowKey, PalletNoColumnName);

            $("#" + JqGridParameterObject.TableID).jqGrid("setSelection", ParentRowKey);

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/WM/Service/GetStockListBySalesOrder.ashx")%>", data: {
                    PalletNo: PalletNo,
                    KUNNR: $("#<%=TB_KUNNR.ClientID%>").val(),
                    MATNR: $("#<%=TB_MATNR.ClientID%>").val(),
                    PackingID: $("#<%=HF_PackingID.ClientID%>").val()
                },
                CallBackFunction: function (data) {

                    BoxNoColumnName = data.BoxNoColumnName;

                    SetSubGridData(ParentRowID, ParentRowKey, data);
                }
            });
        }

        function SetSubGridData(ParentRowID, ParentRowKey, GridData) {

            let JqSubGridID = ParentRowID + BoxGridTableID + "_Table";
            let JqSubGridPagerID = ParentRowID + BoxGridTableID + "_Pager";

            LoadGridData({
                IsExtendJqGridParameterObject: false,
                ListID: ParentRowID,
                TableID: JqSubGridID,
                PagerID: JqSubGridPagerID,
                JQGridDataValue: GridData,
                IsShowSubGrid: false,
                IsShowFooterRow: true,
                IsShowJQGridFilterToolbar: true,
                IsMultiSelect: true,
                RowNum: 100000000
            });

            $(".ui-jqgrid-htable", "#" + ParentRowID).find(".ui-th-column").addClass("SubGridThBackgroundColor");

            $($("#" + JqSubGridID)[0].grid.hDiv).find("th.ui-th-column").off("mouseenter mouseleave");
        }

        function JqEventBind(PO) {

            if (PO.TableID.includes(BoxGridTableID) || PO.TableID.includes(PackingListID)) {

                $("#" + PO.TableID).bind("jqGridAfterGridComplete", function () {
                    let Rows = $(this).jqGrid("getDataIDs");

                    let TotalBoxQty = 0;

                    for (var i = 0; i < Rows.length; i++) {
                        let RowID = Rows[i];

                        TotalBoxQty += numeral($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.BoxQtyColumnName)).value();
                    }

                    $(this).jqGrid("footerData", "set", {
                        [PO.JQGridDataValue.BoxQtyColumnName]: numeral(TotalBoxQty).format("0,0"),
                    });
                });
            }
        }

        function LoadPackingListTemp() {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/WM/Service/GetPackingListTemp.ashx")%>",
                data: { PackingID: $("#<%=HF_PackingID.ClientID%>").val(), IsHiddenMAKTX: 1 },
                CallBackFunction: function (data) {
                    if (!$("#PackingListContent").hasClass("in"))
                        $("#PackingListContent").collapse("toggle");

                    if (data.Rows.length > 0)
                        $("#BT_Packing,#BT_RemovePacking").show();
                    else
                        $("#BT_Packing,#BT_RemovePacking").hide();

                    BoxNoColumnName = data.BoxNoColumnName;

                    LoadGridData({
                        IsExtendJqGridParameterObject: true,
                        ListID: PackingListID,
                        TableID: PackingListID + "Table",
                        PagerID: PackingListID + "Pager",
                        IsMultiSelect: true,
                        IsShowJQGridFilterToolbar: true,
                        IsShowFooterRow: true,
                        RowNum: 100,
                        JQGridDataValue: data
                    });
                }
            });
        }
    </script>
    <style>
        .SubGridThBackgroundColor {
            background-color: #cc9966;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_PackingID" runat="server" />
    <asp:HiddenField ID="HF_PackingRemark" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_SearchCondition%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_VBELN.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_VBELN %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_VBELN" runat="server" CssClass="form-control readonly SalesOrderSelect" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Search">
                        <button class="btn btn-default SalesOrderSelect" type="button">
                            <i class="fa fa-search"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_POSNR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_POSNR %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_POSNR" runat="server" CssClass="form-control readonly SalesOrderSelect" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Search">
                        <button class="btn btn-default SalesOrderSelect" type="button">
                            <i class="fa fa-search"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_KUNNR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_KUNNR%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_KUNNR" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_KUNNR_Name.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_KUNNR_Name%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_KUNNR_Name" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_MATNR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_MATNR%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MATNR" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_MAKTX%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_BSTKD.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_BSTKD%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_BSTKD" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_KDMAT.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_KDMAT%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_KDMAT" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_DeliveryDate.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_DeliveryDate%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_DeliveryDate" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_KWMENG.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_KWMENG%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_KWMENG" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_LFIMG.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_LFIMG%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_LFIMG" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_AllowQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_AllowQty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_AllowQty" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#StockListContent">
            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_StockList%>"></asp:Literal>
        </div>
        <div id="StockListContent" class="panel-collapse collapse" aria-expanded="true">
            <div class="panel-body">
                <div class="row">
                    <div class="col-xs-12 form-group">
                        <input type="button" class="btn btn-gray" id="BT_AddPackingByPallet" value="<%= (string)GetLocalResourceObject("Str_BT_AddPackingByPallet") %>" />
                        <input type="button" class="btn btn-warning" id="BT_AddPackingByBox" value="<%= (string)GetLocalResourceObject("Str_BT_AddPackingByBox") %>" />
                    </div>
                </div>
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor8") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#PackingListContent">
            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PackingList%>"></asp:Literal>
        </div>
        <div id="PackingListContent" class="panel-collapse collapse" aria-expanded="true">
            <div class="panel-body">
                <div class="row">
                    <div class="col-xs-12 form-group">
                        <input type="button" class="btn btn-danger" id="BT_RemovePacking" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName") %>" />
                        <input type="button" class="btn btn-success" id="BT_Packing" value="<%= (string)GetLocalResourceObject("Str_BT_Packing") %>" />
                    </div>
                </div>
                <div id="JQContainerPackingList"></div>
            </div>
        </div>
    </div>
</asp:Content>
