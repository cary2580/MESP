<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_011.aspx.cs" Inherits="TimeSheet_RPT_011" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#BT_Export").click(function ()
            {
                if ($("#<%=DateStart.ClientID%>").val() == "" || $("#<%=DateEnd.ClientID%>").val() == "" || $("#<%=DLL_ProcessType.ClientID%>").val() == "")
                {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return;
                }
                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_011.ashx")%>",
                    timeout: 600 * 1000,
                    data: { DateStart: $("#<%=DateStart.ClientID%>").val(), DateEnd: $("#<%=DateEnd.ClientID%>").val(), ProcessTypeID: $("#<%=DLL_ProcessType.ClientID%>").val()},
                    CallBackFunction: function (data) {
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
            <div class="col-xs-6 form-group required">
                <label for="<%=DateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_DateStart %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="DateStart" runat="server" CssClass="form-control DateTimeDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-6 form-group required">
                <label for="<%=DateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_DateEnd %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="DateEnd" runat="server" CssClass="form-control DateTimeDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-6 form-group required">
                <label for="<%= DLL_ProcessType.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ProcessTypeID%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DLL_ProcessType" runat="server" CssClass="form-control">
                </asp:DropDownList>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
            </div>
        </div>
    </div>
</asp:Content>


