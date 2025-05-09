<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_006.aspx.cs" Inherits="TimeSheet_RPT_006" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/highcharts.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/data.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/drilldown.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/exporting.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/drag-panes.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/accessibility.js") %>"></script>

    <script type="text/javascript">
        $(function () {

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


            $("#BT_Export").click(function () {
                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_006.ashx")%>",
                    timeout: 1200 * 1000,
                    data: { CreateDateStart: $("#<%=TB_CreateDateStart.ClientID%>").val(), CreateDateEnd: $("#<%=TB_CreateDateEnd.ClientID%>").val(), AUFNR: $("#<%=TB_AUFNR.ClientID%>").val() },
                    CallBackFunction: function (data) {
                        if (data.Result && data.GUID != null) {
                            if ($.ispAad())
                                window.open("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                            else
                                OpenWindowDownloadFile("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                        }
                    }
                });
            });


            if (typeof (BarChartData) != "undefined")
                CreateBarChart();
        });

        function CreateBarChart() {
            $("#ChartContainer1").closest(".panel").show();

            Highcharts.chart("ChartContainer1", {
                chart: {
                    type: "bar",
                    height: 800
                },
                title: {
                    text: "<%=(string)GetLocalResourceObject("Str_ChartTitle")%>"
                },
                xAxis: {
                    categories: BarChartData.map(item => item.name),
                },
                yAxis: {
                    title: { text: null },
                    min: 0
                },
                tooltip: {
                    useHTML: true,
                    formatter: function () {
                        const categoryIndex = this.point.index; // 獲取當前點的索引
                        const categoryName = BarChartData[categoryIndex].name; // 獲取對應的名稱

                        return `<span style=\"font-size: 14px;\"><b>${categoryName}</b></span><br/>
                    <span style=\"font-size: 14px;color:${this.series.chart.series[0].color}\">${this.series.chart.series[0].name}: </span><span style=\"font-size: 14px;"><b>${numeral(this.series.chart.series[0].data[this.point.index].y).format("0,0")}</b></span><br/>
                    <span style=\"font-size: 14px;color:${this.series.chart.series[1].color}\">${this.series.chart.series[1].name}: </span><span style=\"font-size: 14px;"><b>${numeral(this.series.chart.series[1].data[this.point.index].y).format("0,0")}</b></span><br/>
                    <span style=\"font-size: 14px;color:${this.series.chart.series[2].color}\">${this.series.chart.series[2].name}: </span><span style=\"font-size: 14px;"><b>${numeral(this.series.chart.series[2].data[this.point.index].y).format("0,0")}</b></span><br/>
                    <span style=\"font-size: 14px;\"><%=(string)GetLocalResourceObject("Str_MaintainCount")%>: <b>${numeral(BarChartData[this.point.index].MaintainCount).format("0,0")}</b></span><br/>`;
                    }
                },
                plotOptions: {
                    series: {
                        cursor: "pointer",
                        point: {
                            events: {
                                click: function () {
                                    const categoryIndex = this.point.index; // 獲取當前點的索引
                                    const categoryName = BarChartData[categoryIndex].name; // 獲取對應的名稱

                                    $("#ChartContainer2").closest(".panel").show();

                                    CreatePicChart("ChartContainer2", categoryName, $.grep(PicChartData, function (item) { return $.trim(item.MachineName) === categoryName; }), categoryName,
                                        $.grep(PicChartDetailData, function (item) { return $.trim(item.MachineName) === categoryName; }));
                                }
                            }
                        }
                    }
                },
                series: [{
                    name: "<%=(string)GetLocalResourceObject("Str_WaitMinuteName")%>",
                    data: BarChartData.map(item => item.WaitMinute),
                    dataLabels: {
                        enabled: true, // 啟用數據標籤
                        formatter: function () {
                            return numeral(this.y).format("0,0");
                        }
                    }
                }, {
                        name: "<%=(string)GetLocalResourceObject("Str_MaintainMinuteByMachine")%>",
                        data: BarChartData.map(item => item.MaintainMinuteByMachine),
                        dataLabels: {
                            enabled: true, // 啟用數據標籤
                            formatter: function () {
                                return numeral(this.y).format("0,0");
                            }
                        }
                    }, {
                        name: "<%=(string)GetLocalResourceObject("Str_MaintainMinute")%>",
                        data: BarChartData.map(item => item.MaintainMinute),
                        dataLabels: {
                            enabled: true, // 啟用數據標籤
                            formatter: function () {
                                return numeral(this.y).format("0,0");
                            }
                        }
                    }]
            });
        }

        function CreatePicChart(ChartID, SubTileText, DataSeries, DataSeriesName, DataDetailSeries) {

            let DataSeriesQty = DataSeries.reduce((sum, point) => sum + point.z, 0);

            var chart = Highcharts.chart(ChartID, {
                chart: {
                    type: "pie",
                    events: {
                        drilldown: function (e) {

                            let Qty = e.seriesOptions.data.reduce((sum, point) => sum + point.z, 0);

                            this.setTitle({ text: "<%=(string)GetLocalResourceObject("Str_FaultCodeName") + " " +  (string)GetLocalResourceObject("Str_Qty")%>" + " : " + numeral(Qty).format("0,0") });
                        },
                        drillup: function () {
                            this.setTitle({ text: "<%= (string)GetLocalResourceObject("Str_FaultCategoryName") + " " +  (string)GetLocalResourceObject("Str_Qty") %> : " + numeral(DataSeriesQty).format("0,0") });
                        }
                    }
                },

                title: {
                    text: "<%= (string)GetLocalResourceObject("Str_FaultCategoryName") + " " +  (string)GetLocalResourceObject("Str_Qty") %> : " + numeral(DataSeriesQty).format("0,0")
                },

                subtitle: {
                    text: SubTileText,
                    useHTML: true
                },

                tooltip: {
                    formatter: function (tooltip) {
                        return "<span><b>" + numeral(this.y).format("0,0.00%") + "</b><br><b><%=(string)GetGlobalResourceObject("GlobalRes","Str_SubTotal")%> : " + numeral(this.z).format("0,0") + "</b></span>";
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
                                return numeral(this.y).format("0,0.00%")
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
                        name: DataSeriesName,
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
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_ReportHeading %>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4 form-group">
                <label for="<%= TB_CreateDateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateStart %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_CreateDateStart" runat="server" CssClass="form-control DateDatepicker readonly"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-4 form-group">
                <label for="<%= TB_CreateDateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateEnd %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_CreateDateEnd" runat="server" CssClass="form-control DateDatepicker readonly"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-4 form-group">
                <label for="<%= TB_AUFNR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNR%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_AUFNR" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
                <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
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
</asp:Content>
