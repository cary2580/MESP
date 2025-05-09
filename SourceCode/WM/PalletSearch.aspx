<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="PalletSearch.aspx.cs" Inherits="WM_PalletSearch" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=BT_SynchronizeSAPData.ClientID%>").hide();

            $("#<%=HF_PalletNoSelected.ClientID%>").val("");

            if (typeof (JQGridDataValue) != "undefined")
                $("#SearchResultListDiv").show();
            else
                $("#SearchResultListDiv").hide();
        });

        function JqSubGridRowExpandedEvent(ParentRowID, ParentRowKey)
        {
            var PalletNo = $("#" + JqGridParameterObject.TableID).jqGrid("getCell", ParentRowKey, JQGridDataValue.PalletNoValueColumnName);

            $("#" + JqGridParameterObject.TableID).jqGrid("setSelection", ParentRowKey);

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/WM/Service/PalletBoxGetList.ashx") %>", data: {
                    PalletNo: PalletNo
                },
                CallBackFunction: function (data)
                {
                    SetSubGridData(ParentRowID, ParentRowKey, data);
                }
            });
        }

        function SetSubGridData(ParentRowID, ParentRowKey, GridData)
        {
            var JqSubGridID = ParentRowID + "_Table";
            var JqSubGridPagerID = ParentRowID + "_Pager";

            LoadGridData({
                IsExtendJqGridParameterObject: false,
                ListID: ParentRowID,
                TableID: JqSubGridID,
                PagerID: JqSubGridPagerID,
                JQGridDataValue: GridData,
                IsShowSubGrid: false,
                IsShowFooterRow: true,
                IsShowJQGridFilterToolbar: true,
                RowNum: 100000000
            });

            $(".ui-jqgrid-htable", "#" + ParentRowID).find(".ui-th-column").addClass("SubGridThBackgroundColor");

            $($("#" + JqSubGridID)[0].grid.hDiv).find("th.ui-th-column").off("mouseenter mouseleave");
        }

        function JqEventBind(PO)
        {
            if (PO.TableID == JqGridParameterObject.TableID)
            {
                $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
                {
                    var cm = $(this).jqGrid("getGridParam", "colModel");

                    if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName)
                    {
                        var columnNames = $(this).jqGrid("getGridParam", "colNames");
                        var PalletNo = "";

                        if ($.inArray(JQGridDataValue.PalletNoColumnName, columnNames) > 0)
                            PalletNo = $(this).jqGrid("getCell", RowID, JQGridDataValue.PalletNoValueColumnName);

                        if (PalletNo != "")
                            window.open("<%=ResolveClientUrl(@"~/WM/RPT_001.aspx?PalletNo=")%>" + PalletNo, "_blank", "toolbar=false,location=false,menubar=false,width=" + screen.availWidth + ",height=" + screen.availHeight + "");
                    }
                });

                $("#" + JqGridParameterObject.TableID).bind("jqGridAfterGridComplete", function ()
                {
                    var Rows = $(this).jqGrid("getDataIDs");

                    var TotalBoxQty = 0;
                    var TotalPCS = 0;

                    for (var i = 0; i < Rows.length; i++)
                    {
                        var RowID = Rows[i];

                        TotalBoxQty += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.BoxQtyColumnName)).value();
                        TotalPCS += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.PCSColumnName)).value();
                    }

                    $(this).jqGrid("footerData", "set", {
                        [JQGridDataValue.BoxQtyColumnName]: numeral(TotalBoxQty).format("0,0"),
                        [JQGridDataValue.PCSColumnName]: numeral(TotalPCS).format("0,0"),
                    });
                });
            }
            else
            {
                $("#" + PO.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
                {
                    var cm = $(this).jqGrid("getGridParam", "colModel");

                    if (cm[CellIndex].classes === PO.JQGridDataValue.ColumnClassesName)
                    {
                        var columnNames = $(this).jqGrid("getGridParam", "colNames");
                        var TicketID = "";

                        if ($.inArray(PO.JQGridDataValue.TicketIDColumnName, columnNames) > 0)
                            TicketID = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.TicketIDValueColumnName);

                        if (TicketID != "")
                            $.WindowOpen("Post", "<%=ResolveClientUrl(@"~/TimeSheet/TicketLifeCycle.aspx?A2=")%>" + TicketID);
                    }
                });

                $("#" + PO.TableID).bind("jqGridAfterGridComplete", function ()
                {
                    var Rows = $(this).jqGrid("getDataIDs");

                    var TotalBoxQty = 0;

                    for (var i = 0; i < Rows.length; i++)
                    {
                        var RowID = Rows[i];

                        TotalBoxQty += numeral($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.BoxQtyColumnName)).value();
                    }

                    $(this).jqGrid("footerData", "set", {
                        [PO.JQGridDataValue.BoxQtyColumnName]: numeral(TotalBoxQty).format("0,0"),
                    });
                });
            }
        }

        function ChangeLGORT()
        {
            var JqGrid = $("#" + JqGridParameterObject.TableID);

            var SelectedList = new Array();

            $.each(JqGrid.jqGrid("getGridParam", "selarrrow"), function (index, item)
            {
                var RowData = JqGrid.jqGrid("getRowData", item);

                SelectedList.push(RowData[JQGridDataValue.PalletNoValueColumnName]);
            });

            if (SelectedList.length < 1)
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_GridSelectZeroAlertMessage")%>" });

                return;
            }

            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/WM/PalletChangeInfo.aspx") %>",
                iFrameOpenParameters: { PalletNo: JSON.stringify(SelectedList) },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_BT_ChangeLGORTName") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 620,
                height: 560,
                NewWindowPageDivID: "PalletChangeInfo_M_DivID",
                NewWindowPageFrameID: "PalletChangeInfo_M_FrameID",
                CloseEvent: function ()
                {
                    $("#<%=BT_Search.ClientID%>").trigger("click");
                }
            });
        }

        function SynchronizeSAPData()
        {
            var JqGrid = $("#" + JqGridParameterObject.TableID);

            var SelectedList = new Array();

            $.each(JqGrid.jqGrid("getGridParam", "selarrrow"), function (index, item)
            {
                var RowData = JqGrid.jqGrid("getRowData", item);

                SelectedList.push(RowData[JQGridDataValue.PalletNoValueColumnName]);
            });

            if (SelectedList.length < 1)
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_GridSelectZeroAlertMessage")%>" });

                return;
            }

            $("#<%=HF_PalletNoSelected.ClientID%>").val(JSON.stringify(SelectedList));

            $("#<%=BT_SynchronizeSAPData.ClientID%>").trigger("click");
        }
    </script>
    <style>
        .SubGridThBackgroundColor {
            background-color: #cc9966;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_PalletNoSelected" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_SearchCondition%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_PalletCreateDateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PalletCreateDateStart %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_PalletCreateDateStart" runat="server" CssClass="form-control DateTimeDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_PalletCreateDateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PalletCreateDateEnd %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_PalletCreateDateEnd" runat="server" CssClass="form-control DateTimeDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_WorkCode%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_MAKTX%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_BoxNo.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_BoxNo%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_BoxNo" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_WM_ScanBoxNo %>"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_BT_SearchName %>" OnClick="BT_Search_Click" />
            </div>
        </div>
    </div>
    <div id="SearchResultListDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_SearchResult%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="row">
                <div class="col-xs-12 form-group">
                    <%-- <input type="button" class="btn btn-danger" id="BT_ChangeLGORT" value="<%= (string)GetLocalResourceObject("Str_BT_ChangeLGORTName") %>" onclick="ChangeLGORT();" />--%>
                    <input type="button" class="btn btn-danger" id="BT_SynchronizeSAPData_Display" value="<%= (string)GetLocalResourceObject("Str_BT_SynchronizeSAPData") %>" onclick="SynchronizeSAPData();" />
                    <asp:Button ID="BT_SynchronizeSAPData" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:Str_BT_SynchronizeSAPData %>" OnClick="BT_SynchronizeSAPData_Click" />
                </div>
            </div>
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>
