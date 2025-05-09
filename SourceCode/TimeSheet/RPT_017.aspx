<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_017.aspx.cs" Inherits="TimeSheet_RPT_017" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#BT_Export").click(function ()
            {
                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_017.ashx")%>",
                    timeout: 600 * 1000,
                    data: { ProcessTypeID: $("#<%=DLL_ProcessType.ClientID%>").val(), IsApprovered: $("#<%=DDL_IsApprovered.ClientID%>").val(), ReportDateStart: $("#<%=ReportDateStart.ClientID%>").val(), ReportDateEnd: $("#<%=ReportDateEnd.ClientID%>").val() },
                    CallBackFunction: function (data)
                    {
                        if (data.Result && data.GUID != null)
                        {
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
                <label for="<%= DLL_ProcessType.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ProcessTypeID%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DLL_ProcessType" runat="server" CssClass="form-control">
                </asp:DropDownList>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= DDL_IsApprovered.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IsApprovered%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_IsApprovered" runat="server" CssClass="form-control" required="required">
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%=ReportDateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDateStart %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="ReportDateStart" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%=ReportDateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDateEnd %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="ReportDateEnd" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
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


