<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="TicketPrint.aspx.cs" Inherits="TimeSheet_TicketPrint" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">

    <script type="text/javascript">
        $(function () {

            $("#<%=TB_TicketID.ClientID%>").focus();

            $("#BT_PrintAUFNR").click(function () {
                DownloadFileByMO({ AUFNR: $("#<%=TB_AUFNR.ClientID %>").val() });
            });

            $("#BT_PrintTicketID").click(function () {

                let UploadParameter;

                if ($("#<%=TB_AUFNRToTicket.ClientID%>").val() != "")
                    UploadParameter = { AUFNR: $("#<%=TB_AUFNRToTicket.ClientID %>").val() };
                else
                    UploadParameter = { TicketID: JSON.stringify([$("#<%= TB_TicketID.ClientID %>").val()]) };

                DownloadFile(UploadParameter);
            });

            $("#Tabs").tabs();
        });

        function DownloadFileByMO(UploadParameter) {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_035.ashx")%>",
                data: UploadParameter,
                timeout: 300 * 1000,
                CallBackFunction: function (data) {
                    if (data.Result && data.GUID != null) {
                        if ($.StringConvertBoolean(data.IsQuarantineTicketType))
                            DownloadFileByQuarantineInfo(data.GUID);
                        else {
                            if ($.ispAad())
                                window.open("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                            else
                                OpenWindowDownloadFile("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                        }
                    }
                }
            });
        }

        function DownloadFile(UploadParameter) {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_001.ashx")%>",
                data: UploadParameter,
                timeout: 300 * 1000,
                CallBackFunction: function (data) {
                    if (data.Result && data.GUID != null) {
                        if ($.StringConvertBoolean(data.IsQuarantineTicketType))
                            DownloadFileByQuarantineInfo(data.GUID);
                        else {
                            if ($.ispAad())
                                window.open("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                            else
                                OpenWindowDownloadFile("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                        }
                    }
                }
            });
        }

        function DownloadFileByQuarantineInfo(TicketGUID) {
            /* 列印隔離品單和下載 */
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_014.ashx")%>",
                data: {
                    TicketID: $("#<%= TB_TicketID.ClientID %>").val(),
                    TicketQuarantineGUID: TicketGUID
                },
                timeout: 300 * 1000,
                CallBackFunction: function (data) {
                    if (data.Result && data.GUID != null) {
                        if ($.ispAad())
                            window.open("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                        else
                            OpenWindowDownloadFile("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                    }
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div id="Tabs">
        <ul>
            <li><a href="#TabByTicket">
                <asp:Literal runat="server" Text="<%$ Resources:Str_TabTitle_Ticket %>"></asp:Literal></a></li>
            <li><a href="#TabByAUFNR">
                <asp:Literal runat="server" Text="<%$ Resources:Str_TabTitle_AUFNR %>"></asp:Literal></a></li>
        </ul>
        <div id="TabByTicket">
            <p></p>
            <div class="row">
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_TicketID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketID %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_AUFNRToTicket.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNR %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_AUFNRToTicket" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="col-xs-12">
                    <div class="col-xs-2 form-group">
                        <input type="button" class="btn btn-primary" id="BT_PrintTicketID" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_DownloadFileTitleBarText") %>" />
                    </div>
                </div>
            </div>
        </div>
        <div id="TabByAUFNR">
            <p></p>
            <div class="row">
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_AUFNR.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNR %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_AUFNR" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="col-xs-12">
                    <div class="col-xs-2 form-group">
                        <input type="button" class="btn btn-primary" id="BT_PrintAUFNR" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_DownloadFileTitleBarText") %>" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

