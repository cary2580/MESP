<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_015.aspx.cs" Inherits="TimeSheet_RPT_015" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
                $("#SearchResultListDiv").show();
            else
                $("#SearchResultListDiv").hide();

            $("#<%=BT_Search.ClientID%>").click(function () {

                if (IsAllEmpty() == false);
                return;
            });

            $("#BT_Export").click(function () {

                if (IsAllEmpty() == false)
                    return;
                else
                    $.Ajax({
                        url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_015.ashx")%>",
                        timeout: 600 * 1000,
                        data: { Brand: $("#<%=TB_Brand.ClientID%>").val(), CINFO: $("#<%=TB_CINFO.ClientID%>").val(), CreateDateStart: $("#<%=TB_CreateDateStart.ClientID%>").val(), CreateDateEnd: $("#<%=TB_CreateDateEnd.ClientID%>").val(), AUFNRCloseDateTimeStart: $("#<%=TB_AUFNRCloseDateTimeStart.ClientID%>").val(), AUFNRCloseDateTimeEnd: $("#<%=TB_AUFNRCloseDateTimeEnd.ClientID%>").val() },
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

        function IsAllEmpty() {
            if ($("#<%=TB_Brand.ClientID%>").val() == "" && $("#<%=TB_CINFO.ClientID%>").val() == "" && $("#<%=TB_CreateDateStart.ClientID%>").val() == "" && $("#<%=TB_CreateDateEnd.ClientID%>").val() == "" && $("#<%=TB_AUFNRCloseDateTimeStart.ClientID%>").val() == "" && $("#<%=TB_AUFNRCloseDateTimeEnd.ClientID%>").val() == "") {

                $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                return false;
            }
        }

        function JqEventBind() {

            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var AUFNRValue = "";

                    if ($.inArray(JQGridDataValue.AUFNRColumnName, columnNames) > 0)
                        AUFNRValue = $(this).jqGrid("getCell", RowID, CellIndex);

                    if (AUFNRValue != "")
                        $.WindowOpen("Post", "<%=ResolveClientUrl(@"~/TimeSheet/MOSearch.aspx?ViewInside=") + true.ToStringValue().ToBase64String(true)%>&AUFNR=" + AUFNRValue);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsShowResultList" runat="server" Value="0" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_ReportHeading %>"></asp:Literal>
        </div>
        <div class="panel-body">
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
                <label for="<%= TB_CreateDateStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateStart%>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_CreateDateStart" runat="server" CssClass="form-control DateDatepicker readonly"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_CreateDateEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateEnd%>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_CreateDateEnd" runat="server" CssClass="form-control DateDatepicker readonly"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_AUFNRCloseDateTimeStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNRCloseDateTimeStart%>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_AUFNRCloseDateTimeStart" runat="server" CssClass="form-control DateDatepicker readonly"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_AUFNRCloseDateTimeEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNRCloseDateTimeEnd%>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_AUFNRCloseDateTimeEnd" runat="server" CssClass="form-control DateDatepicker readonly"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-12">
                <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
                <input id="BT_Export" type="button" class="btn btn-warning" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
            </div>
            <div class="col-xs-12">
                <p></p>
            </div>
            <div class="col-xs-12">
                <div id="SearchResultListDiv" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                    <div class="panel-heading text-center">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultList%>"></asp:Literal>
                    </div>
                    <div class="panel-body">
                        <div id="JQContainerList"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

