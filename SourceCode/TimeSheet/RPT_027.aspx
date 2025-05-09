<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_027.aspx.cs" Inherits="TimeSheet_RPT_027" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#BT_Export").click(function ()
            {
                if ($("#<%=DDL_IsSynchronizeData.ClientID%>").val() == "")
                {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_027.ashx")%>",
                    timeout: 600 * 1000,
                    data: { IsSynchronizeData: $("#<%=DDL_IsSynchronizeData.ClientID%>").val() },
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
            <div class="col-xs-4 form-group required">
                <label for="<%= DDL_IsSynchronizeData.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IsSynchronizeData%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_IsSynchronizeData" runat="server" CssClass="form-control" required="required">
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
            </div>
        </div>
    </div>
</asp:Content>

