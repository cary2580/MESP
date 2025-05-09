<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_022.aspx.cs" Inherits="TimeSheet_RPT_022" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/highcharts.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/data.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/drilldown.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/exporting.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/drag-panes.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/accessibility.js") %>"></script>

    <script type="text/javascript">
        var JQGridDataValue;
        $(function () {
            $("#BT_Export").click(function () {
                if ($("#<%=TB_ReportDateStart.ClientID%>").val() == "" || $("#<%=TB_ReportDateEnd.ClientID%>").val() == "" || $("#<%=DDL_Group.ClientID%>").val() == "" || $("#<%=TB_OverScrapRateSkip.ClientID%>").val() == "") {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_022.ashx")%>",
                    timeout: 600 * 1000,
                    data: {
                        IsGetChartData: true, ReportDateStart: $("#<%=TB_ReportDateStart.ClientID%>").val(), ReportDateEnd: $("#<%=TB_ReportDateEnd.ClientID%>").val(), GroupID: $("#<%=DDL_Group.ClientID%>").val(),
                        ScrapReasonID: $("#<%=DDL_ScrapReason.ClientID%>").val() ? $("#<%=DDL_ScrapReason.ClientID%>").val().join("|") : "",
                        OverScrapRateSkip: $("#<%=TB_OverScrapRateSkip.ClientID%>").val(), IsSkipMissing: $("#<%=DDL_IsSkipMissing.ClientID%>").val(), IsOnlyViewCloseMO: $("#<%=DDL_IsOnlyViewCloseMO.ClientID%>").val()
                    },
                    CallBackFunction: function (data) {
                        $("#ChartContainer3").closest(".panel").hide();

                        $("#ChartContainer1,#ChartContainer2,#JQContainerList").closest(".panel").show();

                        JQGridDataValue = data[0].JqGridData;

                        CreateChart1(data[0].yAxisTitle, data[0].MedianScrapRate, data[0].MedianScrapRateByUp50, data[0].MedianScrapRateByUp100, data[0].MedianScrapRateByDown50, data[0].ChartValue);

                        CreatePicChart("ChartContainer2", "", data[1].ChartValue, data[1].ChartDetailValue, data[1].DefectScrapQtyText);

                        LoadGridData({
                            IsShowSubGrid: true,
                            IsShowJQGridFilterToolbar: true,
                            IsShowFooterRow: true,
                            JQGridDataValue: JQGridDataValue
                        });
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#ChartContainer1,#ChartContainer2,#ChartContainer3,#JQContainerList").closest(".panel").hide();
                    }
                });
            });

            Highcharts.setOptions({
                lang: {
                    locale: "<%=System.Threading.Thread.CurrentThread.CurrentUICulture.Name%>"
                },
                chart: {
                    style: {
                        fontSize: "105%"
                    }
                }
            });
        });

        function JqSubGridRowExpandedEvent(ParentRowID, ParentRowKey) {

            let AUFNR = $("#" + JqGridParameterObject.TableID).jqGrid("getCell", ParentRowKey, JQGridDataValue.AUFNRValueColumnName);

            $("#" + JqGridParameterObject.TableID).jqGrid("setSelection", ParentRowKey);

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_022.ashx") %>", data: {
                    IsGetChartData: false,
                    AUFNR: AUFNR,
                    ScrapReasonID: $("#<%=DDL_ScrapReason.ClientID%>").val() ? $("#<%=DDL_ScrapReason.ClientID%>").val().join("|") : ""
                },
                CallBackFunction: function (data) {
                    SetSubGridData(ParentRowID, ParentRowKey, data);
                }
            });
        }

        function SetSubGridData(ParentRowID, ParentRowKey, GridData) {
            var JqSubGridID = ParentRowID + "_Table";
            var JqSubGridPagerID = ParentRowID + "_Pager";

            LoadGridData({
                IsExtendJqGridParameterObject: false,
                ListID: ParentRowID,
                TableID: JqSubGridID,
                PagerID: JqSubGridPagerID,
                JQGridDataValue: GridData,
                IsShowSubGrid: false,
                IsShowJQGridFilterToolbar: true,
                IsShowFooterRow: true,
                RowNum: 100000000
            });

            $(".ui-jqgrid-htable", "#" + ParentRowID).find(".ui-th-column").addClass("SubGridThBackgroundColor");

            $($("#" + JqSubGridID)[0].grid.hDiv).find("th.ui-th-column").off("mouseenter mouseleave");
        }

        function JqEventBind(PO) {
            if (PO.TableID == JqGridParameterObject.TableID) {
                $("#" + PO.TableID).bind("jqGridAfterGridComplete", function () {
                    let Rows = $(this).jqGrid("getDataIDs");

                    let TotalScrapRateValue = 0;

                    for (var i = 0; i < Rows.length; i++) {

                        let RowID = Rows[i];

                        let ColorCss = $(this).jqGrid("getCell", RowID, "ReportColor");

                        TotalScrapRateValue += numeral($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.ScrapRateValueColumnName)).value();

                        if (ColorCss != "")
                            $(this).jqGrid("setCell", RowID, PO.JQGridDataValue.ScrapRateColumnName, "", { background: ColorCss, color: "#FFFFFF" });
                    }

                    $(this).jqGrid("footerData", "set", {
                        [PO.JQGridDataValue.AvgColumnName]: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_Avg")%>",
                        [PO.JQGridDataValue.ScrapRateColumnName]: numeral(TotalScrapRateValue / Rows.length).format("0,0.000%")
                    });
                });

                $("#" + PO.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                    let cm = $(this).jqGrid("getGridParam", "colModel");

                    if (cm[CellIndex].classes === PO.JQGridDataValue.ColumnClassesName) {

                        let AUFNR = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.AUFNRValueColumnName);

                        let AUFNRLabel = PO.JQGridDataValue.colModel.find(Itme => Itme.name == "AUFNR").label;

                        let SubTitle = "";

                        if (AUFNRLabel != null)
                            SubTitle = AUFNRLabel + " : " + AUFNR;

                        $.Ajax({
                            url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_022.ashx")%>",
                            timeout: 600 * 1000,
                            data: { IsGetChartData: true, AUFNR: AUFNR, ReportDateStart: $("#<%=TB_ReportDateStart.ClientID%>").val(), ReportDateEnd: $("#<%=TB_ReportDateEnd.ClientID%>").val(), GroupID: $("#<%=DDL_Group.ClientID%>").val(), ScrapReasonID: $("#<%=DDL_ScrapReason.ClientID%>").val(), OverScrapRateSkip: $("#<%=TB_OverScrapRateSkip.ClientID%>").val(), IsSkipMissing: $("#<%=DDL_IsSkipMissing.ClientID%>").val(), IsOnlyViewCloseMO: $("#<%=DDL_IsOnlyViewCloseMO.ClientID%>").val() },
                            CallBackFunction: function (data) {
                                $("#ChartContainer3").closest(".panel").show();

                                CreatePicChart("ChartContainer3", SubTitle, data[1].ChartValue, data[1].ChartDetailValue, data[1].DefectScrapQtyText);
                            },
                            ErrorCallBackFunction: function (data) {
                                $("#ChartContainer3").closest(".panel").hide();
                            }
                        });
                    }
                });
            }
            else {
                $("#" + PO.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                    let cm = $(this).jqGrid("getGridParam", "colModel");

                    if (cm[CellIndex].classes === PO.JQGridDataValue.ColumnClassesName) {
                        let columnNames = $(this).jqGrid("getGridParam", "colNames");
                        let TicketIDValue = "";

                        if ($.inArray(PO.JQGridDataValue.TicketIDColumnName, columnNames) > 0)
                            TicketIDValue = $(this).jqGrid("getCell", RowID, PO.JQGridDataValue.TicketIDValueColumnName);

                        if (TicketIDValue != "")
                            $.WindowOpen("Post", "<%=ResolveClientUrl(@"~/TimeSheet/TicketLifeCycle.aspx?A2=")%>" + TicketIDValue);
                    }
                });

                $("#" + PO.TableID).bind("jqGridAfterGridComplete", function () {
                    let Rows = $(this).jqGrid("getDataIDs");

                    let TotalQty = 0;

                    for (var i = 0; i < Rows.length; i++) {
                        var RowID = Rows[i];

                        TotalQty += numeral($(this).jqGrid("getCell", RowID, PO.JQGridDataValue.QtyColumnName)).value();
                    }

                    $(this).jqGrid("footerData", "set", {
                        [PO.JQGridDataValue.SubTotalColumnName]: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_SubTotal")%>",
                        [PO.JQGridDataValue.QtyColumnName]: numeral(TotalQty).format("0,0")
                    });

                    $("#" + PO.TableID).closest(".ui-jqgrid-bdiv").next(".ui-jqgrid-sdiv").find(".footrow").find(">td[aria-describedby=\"" + PO.TableID + "_" + PO.JQGridDataValue.SubTotalColumnName + "\"]").css("text-align", "right");
                });
            }
        }

        function CreateChart1(yAxisTitle, MedianScrapRate, MedianScrapRateByUp50, MedianScrapRateByUp100, MedianScrapRateByDown50, ChartValue) {

            let ColorMedianScrapRateByDown50 = "#0000C6";
            let ColorMedianScrapRate = "#8E8E8E";
            let ColorMedianScrapRateByUp50 = "#C6A300";
            let ColorMedianScrapRateByUp100 = "red";

            StockChart = Highcharts.chart("ChartContainer1", {
                chart: {
                    type: "scatter",
                    zoomType: "xy",
                    events: {
                        load: function () {

                            let min = this.yAxis[0].min;
                            let max = this.yAxis[0].max;
                            let pLine = this.yAxis[0].chart.options.yAxis[0].plotLines[0].value;

                            min = Math.min(pLine, min, MedianScrapRate, MedianScrapRateByUp50, MedianScrapRateByUp100, MedianScrapRateByDown50);

                            max = Math.max(pLine, max, MedianScrapRate, MedianScrapRateByUp50, MedianScrapRateByUp100, MedianScrapRateByDown50);

                            this.yAxis[0].setExtremes(min, max);
                        }
                    }
                },
                title: {
                    text: $("#<%=DDL_Group.ClientID%> option:selected").text()
                },
                subtitle: {
                    text:
                        "<p style=\"color:" + ColorMedianScrapRateByDown50 + "\">Volatility-50% = " + numeral(MedianScrapRateByDown50).format("0,0.000%") + "</p>" +
                        "<p style=\"color:" + ColorMedianScrapRate + "\">" + "&nbsp;&nbsp;Median " + numeral(MedianScrapRate).format("0,0.000%") + "</p>" +
                        "<p style=\"color:" + ColorMedianScrapRateByUp50 + "\">&nbsp;&nbsp;Volatility50% = " + numeral(MedianScrapRateByUp50).format("0,0.000%") + "</p>" +
                        "<p style=\"color:" + ColorMedianScrapRateByUp100 + "\">&nbsp;&nbsp;Volatility100% = " + numeral(MedianScrapRateByUp100).format("0,0.000%") + "</p>",
                    align: "right"
                },
                tooltip: {
                    formatter: function () {
                        return "<span style=\"color:" + this.color + "\"><b>" + this.series.name + "</b></span> : " + numeral(this.y).format("0,0.000%");
                    },
                    shared: true
                },
                xAxis: {
                    visible: false,
                },
                plotOptions: {
                    line: {
                        dataLabels: {
                            enabled: true,
                            formatter: function () {
                                return numeral(this.y).format("0,0.000%");
                            }
                        }
                    }
                },
                yAxis: [{
                    title: {
                        text: yAxisTitle
                    },
                    labels: {
                        formatter: function () {
                            return numeral(this.value).format("0,0%");
                        }
                    },
                    plotLines: [{
                        color: ColorMedianScrapRate,
                        width: 2,
                        dashStyle: "shortdash",
                        value: MedianScrapRate,
                        label: {
                            text: "Median " + numeral(MedianScrapRate).format("0,0.000%"),
                            align: "right",
                            x: -5,
                            style: {
                                fontWeight: "bold"
                            }
                        }
                    },
                    {
                        color: ColorMedianScrapRateByUp50,
                        width: 2,
                        dashStyle: "shortdash",
                        value: MedianScrapRateByUp50,
                        label: {
                            text: "Volatility50% = " + numeral(MedianScrapRateByUp50).format("0,0.000%"),
                            align: "right",
                            x: -5,
                            style: {
                                fontWeight: "bold"
                            }
                        }
                    },
                    {
                        color: ColorMedianScrapRateByUp100,
                        width: 2,
                        dashStyle: "shortdash",
                        value: MedianScrapRateByUp100,
                        label: {
                            text: "Volatility100% = " + numeral(MedianScrapRateByUp100).format("0,0.000%"),
                            align: "right",
                            x: -5,
                            style: {
                                fontWeight: "bold"
                            }
                        }
                    },
                    {
                        color: ColorMedianScrapRateByDown50,
                        width: 2,
                        dashStyle: "shortdash",
                        value: MedianScrapRateByDown50,
                        label: {
                            text: "Volatility50% = " + numeral(MedianScrapRateByDown50).format("0,0.000%"),
                            align: "right",
                            x: -5,
                            style: {
                                fontWeight: "bold"
                            }
                        }
                    }]
                }],
                series: ChartValue
            });
        }

        function CreatePicChart(ChartID, SubTileText, DataSeries, DataDetailSeries, DefectScrapQtyText) {

            let ScrapReasonScrapQty = DataSeries.reduce((sum, point) => sum + point.z, 0);

            var chart = Highcharts.chart(ChartID, {
                chart: {
                    type: "pie",
                    events: {
                        drilldown: function (e) {

                            let DefectScrapQty = e.seriesOptions.data.reduce((sum, point) => sum + point.z, 0);

                            this.setTitle({ text: DefectScrapQtyText + " : " + numeral(DefectScrapQty).format("0,0") });
                        },
                        drillup: function () {
                            this.setTitle({ text: "<%= (string)GetLocalResourceObject("Str_ScrapReason") + " " + (string)GetLocalResourceObject("Str_Qty") %> : " + numeral(ScrapReasonScrapQty).format("0,0") });
                        }
                    }
                },

                title: {
                    text: "<%= (string)GetLocalResourceObject("Str_ScrapReason") + " " + (string)GetLocalResourceObject("Str_Qty") %> : " + numeral(ScrapReasonScrapQty).format("0,0")
                },

                subtitle: {
                    text: SubTileText,
                    useHTML: true
                },

                tooltip: {
                    formatter: function (tooltip) {
                        return "<span><b>" + numeral(this.y).format("0,0.000%") + "</b><br><b><%=(string)GetGlobalResourceObject("GlobalRes","Str_SubTotal")%> : " + numeral(this.z).format("0,0") + "</b></span>";
                    }
                },

                accessibility: {
                    announceNewData: {
                        enabled: true
                    },
                    point: {
                        valueSuffix: "%"
                    }
                },

                plotOptions: {
                    series: {
                        allowPointSelect: true,
                        cursor: "pointer",
                        borderRadius: 5,
                        showInLegend: true,
                        dataLabels: [{
                            enabled: true,
                            distance: 15,
                            format: "{point.name}"
                        }, {
                            enabled: true,
                            distance: "-50%",
                            filter: {
                                property: "percentage",
                                operator: ">",
                                value: 5
                            },
                            formatter: function () {
                                return numeral(this.y).format("0,0.000%")
                            },
                            style: {
                                fontSize: "0.9em",
                                textOutline: "none"
                            }
                        }]
                    }
                },

                yAxis: {
                    visible: false,
                },

                series: [
                    {
                        name: "<%= (string)GetLocalResourceObject("Str_ScrapReason") %>",
                        colorByPoint: true,
                        data: DataSeries
                    }
                ],

                drilldown: {
                    series: DataDetailSeries
                }
            });

            chart.setSubtitle({ style: chart.title.styles });

            if (DataSeries.length < 2) {

                let point = chart.series[0].data[0];

                point.firePointEvent("click");
            }
        }
    </script>
    <style>
        .SubGridThBackgroundColor {
            background-color: #cc9966;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Heading%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_ReportDateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDataStart %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_ReportDateStart" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_ReportDateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDataEnd %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_ReportDateEnd" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= DDL_Group.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_Group%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_Group" runat="server" CssClass="form-control selectpicker" data-live-search="true" required="required">
                </asp:DropDownList>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= DDL_ScrapReason.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ScrapReason%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_ScrapReason" runat="server" CssClass="form-control selectpicker" multiple data-live-search="true">
                </asp:DropDownList>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_OverScrapRateSkip.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_OverScrapRateSkip %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_OverScrapRateSkip" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="3" data-MumberTypeStep="0.001" data-Postfix="%" Text="0.000"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= DDL_IsSkipMissing.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IsSkipMissing %>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_IsSkipMissing" runat="server" CssClass="form-control" required="required">
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= DDL_IsOnlyViewCloseMO.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IsOnlyViewCloseMO %>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_IsOnlyViewCloseMO" runat="server" CssClass="form-control" required="required">
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ConfirmName") %>" />
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor3") %>" style="display: none;">
        <div class="panel-body">
            <div class="row">
                <div id="ChartContainer1"></div>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor3") %>" style="display: none;">
        <div class="panel-body">
            <div class="row">
                <div id="ChartContainer2"></div>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor3") %>" style="display: none;">
        <div class="panel-body">
            <div class="row">
                <div id="ChartContainer3"></div>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>" style="display: none;">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DataSourceList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>
