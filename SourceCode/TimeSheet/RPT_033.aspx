<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_033.aspx.cs" Inherits="TimeSheet_RPT_033" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {

            $("#<%=TB_VERIDList.ClientID%>").css("cursor", "pointer").click(function () {
                var FrameID = "ProductionVersionSelect_FrameID";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/ProductionVersionSelect.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_ProductionVersionSelect_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 920,
                    height: 770,
                    NewWindowPageDivID: "ProductionVersionSelect_DivID",
                    NewWindowPageFrameID: FrameID,
                    CloseEvent: function (result) {
                        var ProductionVersionJson = $(result).find("#" + FrameID).contents().find("#HF_ProductionVersion").val();

                        var ProductionVersionList = $.parseJSON(ProductionVersionJson);

                        var AddNewProductionVersion = new Array();

                        $.each(ProductionVersionList, function (index, item) {
                            var RowData = {
                                MATNRVERID: item.MATNR + "-" + item.VERID,
                                TEXT1: item.TEXT1
                            };

                            if ((AddNewProductionVersion.filter(F => F.MATNRVERID === RowData.MATNRVERID).length) < 1)
                                AddNewProductionVersion.push(RowData);
                        });

                        var MATNRVERID = AddNewProductionVersion.map((list) => list.MATNRVERID).join("|");
                        var TEXT1 = AddNewProductionVersion.map((list) => list.TEXT1).join("\r\n");

                        $("#<%= HF_PVL.ClientID %>").val(MATNRVERID);
                        $("#<%= TB_VERIDList.ClientID %>").val(TEXT1);
                    }
                });
            });

            $(".ClearText").click(function () {
                if ($(this).closest(".input-group").find("[type=\"hidden\"]").length > 0)
                    $(this).closest(".input-group").find("[type=\"hidden\"]").val("");
            });

            $("#BT_Export").click(function () {
                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_033.ashx")%>",
                    timeout: 600 * 1000,
                    data: { TicketCreateDateStart: $("#<%=TB_TicketCreateDateStart.ClientID%>").val(), TicketCreateDateEnd: $("#<%=TB_TicketCreateDateEnd.ClientID%>").val(), MATNRVERID: $("#<%=HF_PVL.ClientID%>").val(), IsViewOnlyEndAUFNR: $("#<%=DDL_IsViewOnlyEndAUFNR.ClientID%>").val()},
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
            <div class="col-xs-4 form-group required">
                <label for="<%=TB_TicketCreateDateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketCreateDateStart %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_TicketCreateDateStart" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%=TB_TicketCreateDateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_TicketCreateDateEnd %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_TicketCreateDateEnd" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= DDL_IsViewOnlyEndAUFNR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IsViewOnlyEndAUFNR%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_IsViewOnlyEndAUFNR" runat="server" CssClass="form-control" required="required">
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="2"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="1"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-xs-12 form-group required">
                <label for="<%= TB_VERIDList.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_VERIDList%>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:HiddenField ID="HF_PVL" runat="server" />
                    <asp:TextBox ID="TB_VERIDList" runat="server" CssClass="form-control readonly" TextMode="MultiLine" Rows="10"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearText" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
            </div>
        </div>
        <div id="JQContainerList"></div>
    </div>
</asp:Content>


