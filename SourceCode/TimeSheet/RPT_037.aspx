<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_037.aspx.cs" Inherits="TimeSheet_RPT_037" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#BT_Export").click(function () {
                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_037.ashx")%>",
                    timeout: 600 * 1000,
                    data: { DateStart: $("#<%=TB_DateStart.ClientID%>").val(), DateEnd: $("#<%=TB_DateEnd.ClientID%>").val(), CategoryID: $("#<%=DDL_Category.ClientID%>").selectpicker("val") },
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

            if (typeof (JGDataValue) != "undefined") {

                $("#" + JqGridParameterObject.TableID).bind("jqGridAfterGridComplete", function () {

                    let $grid = $(this);

                    let Rows = $grid.jqGrid("getDataIDs");

                    let colModel = $grid.jqGrid("getGridParam", "colModel");

                    let footerData = {};

                    let JQGridIssueName = JqGridParameterObject.TableID + "_IssueName";

                    colModel.forEach(function (col) {

                        let colName = col.name;

                        if (colName != "rn") {

                            let Total = 0;

                            Rows.forEach(function (id) {

                                if (id < 3 && ($grid.jqGrid("getCell", id, colName) == "<%=(string)GetLocalResourceObject("Str_WorkShiftDeviceMaintainMinute")%>" || $grid.jqGrid("getCell", id, colName) == "<%=(string)GetLocalResourceObject("Str_WorkShiftDeviceGoodQty")%>"))
                                    $(`#${id} td[aria-describedby="${JQGridIssueName}"]`).css("text-align", "right").css("font-weight", "bold");
                                else if (id > 2)
                                    Total += numeral($grid.jqGrid("getCell", id, colName)).value() || 0;
                            });

                            footerData[colName] = numeral(Total).format("0,0");
                        }
                    });

                    footerData["IssueName"] = "<%=(string)GetGlobalResourceObject("GlobalRes","Str_SubTotal")%>";

                    $grid.jqGrid("footerData", "set", footerData);

                    $grid.closest(".ui-jqgrid-bdiv").next(".ui-jqgrid-sdiv").find(".footrow").find(">td[aria-describedby=\"" + JQGridIssueName + "\"]").css("text-align", "right");

                    let $pager = $("#" + JqGridParameterObject.PagerID);

                    $pager.find("select.ui-pg-selbox option").each(function () {
                        if ($(this).val() === "100000000") {
                            $(this).text("ALL");
                        }
                    });
                });

                let DateStart = dayjs($("#<%=TB_DateStart.ClientID%>").val(), "L");

                let DateEnd = dayjs($("#<%=TB_DateEnd.ClientID%>").val(), "L");

                let yDimension = [];

                if (DateStart.isSame(DateEnd)) {
                    yDimension = [{ dataName: "WorkShiftName" }, { dataName: "MachineName" }];
                }
                else
                    yDimension = [{ dataName: "MachineName" }];

                $("#" + JqGridParameterObject.TableID).jqGrid("jqPivot", JGDataValue.Rows,
                    {
                        xDimension: [{
                            dataName: "IssueName", label: "<%=GetLocalResourceObject("Str_IssueName")%>", width: 100, index: "IssueSortID",
                        }],
                        aggregates: [{
                            member: "UsageMinutes", aggregator: "sum", summaryType: "sum", width: 30, align: "center", sortable: false, formatter: function (cellValue) {
                                if (cellValue != "undefined" && cellValue != null)
                                    return numeral(cellValue).format("0,0");
                                else
                                    return "";
                            }
                        }],
                        yDimension: yDimension,
                    },
                    {
                        rowNum: 100000000,
                        sortname: "IssueSortID",
                        pager: "#" + JqGridParameterObject.PagerID,
                        footerrow: true,
                        userDataOnFooter: true
                    }
                );
            }
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_ReportHeading %>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4 form-group required">
                <label for="<%=TB_DateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_DateStart %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_DateStart" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%=TB_DateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_DateEnd %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_DateEnd" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-4 form-group">
                <label for="<%= DDL_Category.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_Category%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_Category" runat="server" CssClass="form-control selectpicker">
                </asp:DropDownList>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
                <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_SearchName%>" OnClick="BT_Search_Click" />
            </div>
            <div class="col-xs-12">
                <table id="JQContainerListTable"></table>
                <div id="JQContainerListPager"></div>
            </div>
        </div>
    </div>
</asp:Content>
