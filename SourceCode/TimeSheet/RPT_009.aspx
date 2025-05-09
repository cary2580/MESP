<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_009.aspx.cs" Inherits="TimeSheet_RPT_009" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {

            $("#BT_Export").click(function () {
                if ($("#<%=TB_ReportDateStart.ClientID%>").val() == "" || $("#<%=TB_ReportDateEnd.ClientID%>").val() == "") {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_009.ashx")%>",
                    timeout: 600 * 1000,
                    data: { IsChartDataType: false, ReportDateStart: $("#<%=TB_ReportDateStart.ClientID%>").val(), ReportDateEnd: $("#<%=TB_ReportDateEnd.ClientID%>").val(), MachineID: $("#<%=DDL_Machine.ClientID%>").selectpicker("val"), IsSumReportDate: $("#<%=DDL_IsSumReportDate.ClientID%>").val() },
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
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_ReportHeading %>"></asp:Literal>
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
            <div class="col-xs-3 form-group">
                <label for="<%= DDL_Machine.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_Machine" runat="server" CssClass="form-control selectpicker show-tick" data-live-search="true" required="required">
                </asp:DropDownList>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= DDL_IsSumReportDate.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IsSumReportDate%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_IsSumReportDate" runat="server" CssClass="form-control" required="required">
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
            </div>
        </div>
    </div>
</asp:Content>
