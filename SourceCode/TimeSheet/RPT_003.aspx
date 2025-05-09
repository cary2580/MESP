<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_003.aspx.cs" Inherits="TimeSheet_RPT_003" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#BT_Search").click(function () {

                if (
                    // 必須至少有一組完整的日期範圍
                    !(
                        ($("#<%=TB_ReportDateStart.ClientID%>").val().trim() && $("#<%=TB_ReportDateEnd.ClientID%>").val().trim()) ||
                        ($("#<%=TB_ApprovalTimeStart.ClientID%>").val().trim() && $("#<%=TB_ApprovalTimeEnd.ClientID%>").val().trim())
                    )
                    // 必須選擇 SAP 報表類型
                    || $("#<%=DDL_IsSAPReportType.ClientID%>").val().trim() == ""
                ) {
                    // 顯示提示訊息
                    $.AlertMessage({
                        Message: (
                            !(
                                ($("#<%=TB_ReportDateStart.ClientID%>").val().trim() && $("#<%=TB_ReportDateEnd.ClientID%>").val().trim()) ||
                                ($("#<%=TB_ApprovalTimeStart.ClientID%>").val().trim() && $("#<%=TB_ApprovalTimeEnd.ClientID%>").val().trim())
                            )
                        )
                            ? "<%=(string)GetLocalResourceObject("Str_TimeRequiredAlertMessage")%>"
                            : "<%=(string)GetGlobalResourceObject("GlobalRes", "Str_RequiredAlertMessage")%>"
                    });

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_003.ashx")%>",
                    data: { ReportDateStart: $("#<%=TB_ReportDateStart.ClientID%>").val(), ReportDateEnd: $("#<%=TB_ReportDateEnd.ClientID%>").val(), ApprovalTimeStart: $("#<%=TB_ApprovalTimeStart.ClientID%>").val(), ApprovalTimeEnd: $("#<%=TB_ApprovalTimeEnd.ClientID%>").val(), IsSAPReportType: $("#<%=DDL_IsSAPReportType.ClientID%>").val(), AUFNR: $("#<%=TB_AUFNR.ClientID%>").val(), Brand: $("#<%=TB_Brand.ClientID%>").val() },
                    timeout: 1200 * 1000,
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
            <asp:Literal runat="server" Text="<%$ Resources:Str_Conditions%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_ReportDateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDateStart %>"></asp:Literal>
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
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_ReportDateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDateEnd %>"></asp:Literal>
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
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_ApprovalTimeStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ApprovalTimeStart %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_ApprovalTimeStart" runat="server" CssClass="form-control DateTimeDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_ApprovalTimeEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ApprovalTimeEnd %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_ApprovalTimeEnd" runat="server" CssClass="form-control DateTimeDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%= TB_AUFNR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNR%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_AUFNR" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%= TB_Brand.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_TS_Brand%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_Brand" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-6 form-group required">
                <label for="<%= DDL_IsSAPReportType.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IsSAPReportType%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_IsSAPReportType" runat="server" CssClass="form-control" required="required">
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0" Selected="True"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Search" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
            </div>
        </div>
    </div>
</asp:Content>
