<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_009_Chart.aspx.cs" Inherits="TimeSheet_RPT_009_Chart" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-Stock-12.1.2/highstock.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-Stock-12.1.2/modules/data.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-Stock-12.1.2/modules/exporting.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-Stock-12.1.2/modules/drag-panes.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-Stock-12.1.2/modules/accessibility.js") %>"></script>

    <script type="text/javascript">
        var StockChart = null;

        $(function () {
            $("#BT_Export").click(function () {
                if ($("#<%=TB_ReportDateStart.ClientID%>").val() == "" || $("#<%=TB_ReportDateEnd.ClientID%>").val() == "" || $("#<%=DDL_Machine.ClientID%>").selectpicker("val") == "") {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_009.ashx")%>",
                    timeout: 600 * 1000,
                    data: { IsChartDataType: true, ReportDateStart: $("#<%=TB_ReportDateStart.ClientID%>").val(), ReportDateEnd: $("#<%=TB_ReportDateEnd.ClientID%>").val(), MachineID: $("#<%=DDL_Machine.ClientID%>").selectpicker("val") },
                    CallBackFunction: function (data) {
                        $("#ChartContainer").closest(".panel").show();

                        CreateChart(data.ChartTilte, data.ChartValue, data.AverageValueKey, data.DateFormatter);
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

        function CreateChart(ChartTilte, ChartValue, AverageValueKey, DateFormatter) {

            let SubTitleText = "<p><%=(string)GetGlobalResourceObject("GlobalRes","Str_Avg")%></p>&nbsp;&nbsp;";

            $.each(ChartValue, function (Index, Item) {

                if (!Item.hasOwnProperty(AverageValueKey))
                    return;

                SubTitleText += "<p style=\"color:" + Item.color + "\">" + Item.name + " = " + numeral(Item[AverageValueKey]).format("0,0%") + "</p>&nbsp;&nbsp;";
            });

            StockChart = Highcharts.stockChart("ChartContainer", {
                title: {
                    text: ChartTilte
                },
                subtitle: {
                    text: SubTitleText,
                    align: "right"
                },
                tooltip: {
                    formatter: function () {
                        var Tooltip = "<div><span style=\"font-size: 14px;\">" + dayjs(this.x).format(DateFormatter) + "&nbsp;&nbsp;" + dayjs(this.x).format("dddd") + "</span>";

                        for (var i = 0; i < this.points.length; i++) {
                            Tooltip += "<br><span style=\"color:" + this.points[i].series.color + "\"><b>" + this.points[i].series.name + "</b></span> : " + numeral(this.points[i].y).format("0,0%");
                        }

                        Tooltip += "</div>";

                        return Tooltip;
                    }
                },
                plotOptions: {
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
                xAxis: {
                    labels: {
                        formatter: function () {
                            return dayjs(this.value).format(DateFormatter);
                        }
                    }
                },
                yAxis: {
                    opposite: false,
                    labels: {
                        align: "left",
                        x: 0,
                        y: -2,
                        formatter: function () {
                            return numeral(this.value).format("0,0%");
                        }
                    },
                    tickInterval: 0.25
                },
                series: ChartValue
            });
        }
    </script>
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
                <label for="<%= DDL_Machine.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_Machine" runat="server" CssClass="form-control selectpicker show-tick" data-live-search="true" required="required">
                </asp:DropDownList>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ConfirmName") %>" />
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>" style="display: none;">
        <div class="panel-body">
            <div class="row">
                <div id="ChartContainer" style="height: 100%; width: 100%"></div>
            </div>
        </div>
    </div>
</asp:Content>
