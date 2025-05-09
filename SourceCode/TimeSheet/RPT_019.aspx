<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_019.aspx.cs" Inherits="TimeSheet_RPT_019" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#BT_Export").click(function () {
                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_019.ashx")%>",
                    timeout: 600 * 1000,
                    data: { ReportDateStart: $("#<%=ReportDateStart.ClientID%>").val(), ReportDateEnd: $("#<%=ReportDateEnd.ClientID%>").val(), OperatorWorkCode: $("#<%=TB_OperatorWorkCode.ClientID%>").val(), MachineID: $("#<%=TB_MachineID.ClientID%>").val(), DeptID: $("#<%=HF_DeptID.ClientID%>").val() },
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

            $(".Clear").click(function () {
                $(this).closest("div").find("textarea,input").val("");
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
            <div class="col-xs-6 form-group">
                <label for="<%=ReportDateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDateStart %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="ReportDateStart" runat="server" CssClass="form-control DateDatepicker readonly"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%=ReportDateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDateEnd %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="ReportDateEnd" runat="server" CssClass="form-control DateDatepicker readonly"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%= TB_OperatorWorkCode.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_OperatorWorkCode%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_OperatorWorkCode" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group">
                <label for="<%=TB_DeptName.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_DeptName%>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_DeptName" runat="server" CssClass="form-control readonly SelectDept ShowSearchArea MultiSelect" role="button" TextMode="MultiLine" Rows="5"></asp:TextBox>
                    <input id="HF_DeptID" type="hidden" runat="server" class="DeptID" />
                    <span class="input-group-btn SelectDept ShowSearchArea">
                        <button class="btn btn-default" type="button">
                            <i class="fa fa-sitemap"></i>
                        </button>
                    </span>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default Clear" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
            </div>
        </div>
    </div>
</asp:Content>


