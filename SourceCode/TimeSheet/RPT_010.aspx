<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="RPT_010.aspx.cs" Inherits="TimeSheet_RPT_010" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/highcharts.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/data.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/exporting.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/export-data.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/Highcharts-12.1.2/modules/accessibility.js") %>"></script>

    <script type="text/javascript">
        var Chart = null;

        $(function () {
            $("#BT_Export").click(function () {
                if ($("#<%=DDL_Machine.ClientID%>").selectpicker("val") == "" || $("#<%=DDL_WorkShift.ClientID%>").val() == "") {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_010.ashx")%>",
                    timeout: 600 * 1000,
                    data: { MachineID: $("#<%=DDL_Machine.ClientID%>").selectpicker("val"), WorkShiftID: $("#<%=DDL_WorkShift.ClientID%>").val() },
                    CallBackFunction: function (data) {
                        $("#ChartContainer").closest(".panel").show();

                        CreateChart(data.ChartTilte, data.SeriesValue, data.xAxisValue);
                    }
                });
            });

            Highcharts.setOptions({
                chart: {
                    style: {
                        fontSize: "105%"
                    }
                }
            });
        });

        function CreateChart(ChartTilte, SeriesValue, xAxisValue) {
            Chart = Highcharts.chart("ChartContainer", {
                chart: {
                    type: "column"
                },
                title: {
                    text: ChartTilte
                },
                accessibility: {
                    announceNewData: {
                        enabled: true
                    }
                },
                xAxis: {
                    categories: xAxisValue,
                    crosshair: true
                },
                yAxis: {
                    min: 0,
                    title: {
                        useHTML: true,
                        text: "<%=(string)GetLocalResourceObject("Str_ChartyAxisText")%>"
                    }
                },
                plotOptions: {
                    column: {
                        dataLabels: {
                            enabled: true,
                            inside: true
                        }
                    }
                },
                tooltip: {
                    headerFormat: "<span style=\"font-size:14px\">{point.key}</span><table>",
                    pointFormat: "<tr><td style=\"color:{series.color};padding:0\">{series.name}&nbsp;:&nbsp;</td>" +
                        "<td style=\"padding:0\"><b>{point.y} pcs</b></td></tr>",
                    footerFormat: '</table>',
                    shared: true,
                    useHTML: true
                },
                series: SeriesValue
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
                <label for="<%= DDL_Machine.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_Machine" runat="server" CssClass="form-control selectpicker show-tick" data-live-search="true" required="required">
                </asp:DropDownList>
            </div>

            <div class="col-xs-3 form-group required">
                <label for="<%= DDL_WorkShift.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_WorkShift%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_WorkShift" runat="server" CssClass="form-control" required="required">
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
