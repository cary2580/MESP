<%@ Control Language="C#" AutoEventWireup="true" CodeFile="WUC_ChartParameter.ascx.cs" Inherits="ED_WUC_WUC_ChartParameter" %>

<script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-Stock-12.1.2/highstock.js") %>"></script>
<script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-Stock-12.1.2/modules/data.js") %>"></script>
<script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-Stock-12.1.2/modules/exporting.js") %>"></script>
<script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-Stock-12.1.2/modules/drag-panes.js") %>"></script>
<script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-Stock-12.1.2/modules/accessibility.js") %>"></script>

<script type="text/javascript">
    var StockChart = null;

    $(function () {
        if (typeof (ChartValue) != "undefined") {
            $("#ChartContainer").closest(".panel").show();
            CreateChart();
        }
        else
            $("#ChartContainer").closest(".panel").hide();

        var plotLinesArray = [];

        var IsOneLine = false;

        if ((typeof (ChartStandardMaxValue) == "undefined") || (typeof (ChartStandardMinValue) == "undefined"))
            IsOneLine = true;

        if (typeof (ChartStandardMinValue) != "undefined") {
            plotLinesArray.push({
                value: ChartStandardMinValue,
                color: "green",
                dashStyle: "shortdash",
                width: 2,
                label: {
                    text: IsOneLine ? "standard(" + ChartStandardMinValue + ")" : "minimum(" + ChartStandardMinValue + ")"
                }
            });
        }

        if (typeof (ChartStandardMaxValue) != "undefined") {
            plotLinesArray.push({
                value: ChartStandardMaxValue,
                color: "red",
                dashStyle: "shortdash",
                width: 2,
                label: {
                    text: IsOneLine ? "standard(" + ChartStandardMaxValue + ")" : "maximum(" + ChartStandardMaxValue + ")"
                }
            });
        }

        if (plotLinesArray.length > 0) {
            StockChart.update({
                yAxis: {
                    plotLines: plotLinesArray,
                    max: (typeof (ChartYMaxValue) != "undefined") ? ChartYMaxValue : ChartStandardMaxValue + 0.01,
                    min: (typeof (ChartYMinValue) != "undefined") ? ChartYMinValue : ChartStandardMinValue - 0.01,
                }
            });
        }
    });

    function CreateChart() {

        StockChart = Highcharts.stockChart("ChartContainer", {
            chart: {
                style: {
                    fontSize: "105%"
                }
            },
            xAxis: {
                labels: {
                    formatter: function () {
                        var format = "hh:mm:ss";

                        if (dayjs(this.value, format).isBetween(dayjs("00:00:00", format), dayjs("11:59:59", format)) < 12)
                            return dayjs(this.value).format("YYMMDD") + "(D)";
                        else
                            return dayjs(this.value).format("YYMMDD") + "(N)";
                    }
                },
                visible: false
            },
            tooltip: {
                formatter: function () {
                    var Tooltip = "";

                    var IsNight = true;

                    if (dayjs(this.x).format("HH") == "08")
                        IsNight = false;

                    Tooltip = "<div><span style=\"font-size: 14px;\">" + dayjs(this.x).format("YYMMDD") + (IsNight ? "(N)" : "(D)") + "</span>";

                    for (var i = 0; i < this.points.length; i++) {
                        Tooltip += "<br><span style=\"color:" + this.points[i].series.color + "\"><b>" + this.points[i].series.name + "</b></span> : " + this.points[i].y;
                    }

                    Tooltip += "</div>";

                    return Tooltip;
                }
            },
            plotOptions: {
                line: {
                    dataLabels: {
                        enabled: true
                    }
                },
                series: {
                    showInNavigator: true
                }
            },
            legend: {
                enabled: true
            },
            rangeSelector: {
                selected: 0,
                inputEnabled: false
            },
            series: ChartValue
        });
    }
</script>
<p></p>
<div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
    <div class="panel-body">
        <div class="row">
            <div id="ChartContainer" style="height: 100%; width: 100%"></div>
        </div>
    </div>
</div>
