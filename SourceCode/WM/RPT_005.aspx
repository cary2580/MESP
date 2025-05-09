<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_005.aspx.cs" Inherits="WM_RPT_005" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#BT_Export").click(function () {
                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/WM/Service/RPT_005.ashx")%>",
                    timeout: 600 * 1000,
                    data: { DeliveryDateStart: $("#<%=TB_DeliveryDateStart.ClientID%>").val(), DeliveryDateEnd: $("#<%=TB_DeliveryDateEnd.ClientID%>").val(), KUNNR: $("#<%=TB_KUNNR.ClientID%>").val(), Brand: $("#<%=TB_Brand.ClientID%>").val(), MAKTX: $("#<%=TB_MAKTX.ClientID%>").val() },
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
                <label for="<%= TB_DeliveryDateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_DeliveryDate %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_DeliveryDateStart" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_DeliveryDateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_DeliveryDate %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_DeliveryDateEnd" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_KUNNR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_KUNNR%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_KUNNR" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_Brand.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_Brand%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_Brand" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_MAKTX%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
            </div>
        </div>
    </div>
</asp:Content>
