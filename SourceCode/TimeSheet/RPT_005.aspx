<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_005.aspx.cs" Inherits="TimeSheet_RPT_005" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#BT_Export").click(function ()
            {
                if ($("#<%=TB_DateStart.ClientID%>").val() == "" && $("#<%=TB_DateEnd.ClientID%>").val() == "" && $("#<%=TB_Brand.ClientID%>").val() == "" && $("#<%=TB_CINFO.ClientID%>").val() == "" && $("#<%=TB_AUFNR.ClientID%>").val() == "")
                {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_005.ashx")%>",
                    timeout: 600 * 1000,
                    data: { DateStart: $("#<%=TB_DateStart.ClientID%>").val(), DateEnd: $("#<%=TB_DateEnd.ClientID%>").val(), Brand: $("#<%=TB_Brand.ClientID%>").val(), CINFO: $("#<%=TB_CINFO.ClientID%>").val(), AUFNR: $("#<%=TB_AUFNR.ClientID%>").val() },
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
            <div class="col-xs-3 form-group">
                <label for="<%= TB_DateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_DateStart %>"></asp:Literal>
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
            <div class="col-xs-3 form-group">
                <label for="<%= TB_DateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_DateEnd %>"></asp:Literal>
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
            <div class="col-xs-2 form-group">
                <label for="<%= TB_Brand.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_Brand%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_Brand" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_CINFO.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_CINFO%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_CINFO" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_AUFNR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNR%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_AUFNR" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
            </div>
        </div>
    </div>
</asp:Content>
