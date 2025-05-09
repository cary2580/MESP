<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="TicketReWorkNotEndSearch.aspx.cs" Inherits="TimeSheet_TicketReWorkNotEndSearch" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
                $("#SearchResultListDiv").show();
            else
                $("#SearchResultListDiv").hide();
        });

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName)
                {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var TicketIDValue = "";

                    if ($.inArray(JQGridDataValue.TicketIDColumnName, columnNames) > 0)
                        TicketIDValue = $(this).jqGrid("getCell", RowID, JQGridDataValue.TicketIDColumnName);

                    if (TicketIDValue != "")
                        $.WindowOpen("Post", "<%=ResolveClientUrl(@"~/TimeSheet/TicketLifeCycle.aspx?A2=")%>" + TicketIDValue);
                }
            });

            $("#" + JqGridParameterObject.TableID).bind("jqGridAfterGridComplete", function ()
            {
                var Rows = $(this).jqGrid("getDataIDs");

                for (var i = 0; i < Rows.length; i++)
                {
                    var RowID = Rows[i];

                    var ColorCss = $(this).jqGrid("getCell", RowID, "ReportColor");

                    if (ColorCss != "")
                        $(this).jqGrid("setCell", RowID, "Qty", "", { background: ColorCss, color: "#FFFFFF" });
                }
            });

            NavButton = new Array();

            NavButton.push({
                caption: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName")%>",
                buttonicon: "fa fa-file-excel-o",
                position: "last",
                onClickButton: function () {
                    $.Ajax({
                        url: "<%=ResolveClientUrl(@"~/Service/ExportJQGridData.ashx")%>",
                        data: { JQGridDataValue: JSON.stringify(JQGridDataValue) },
                        timeout: 1200 * 1000,
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
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsShowResultList" runat="server" Value="0" />
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_CreateDateStart.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateStartStart %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_CreateDateStart" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_CreateDateEnd.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateEnd %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_CreateDateEnd" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= DDL_IsViewOnlyEnd.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsViewOnlyEnd%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsViewOnlyEnd" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1" Selected="True"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-12">
        <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
    </div>
    <div class="col-xs-12">
        <p></p>
    </div>
    <div class="col-xs-12">
        <div id="SearchResultListDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_TicketQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_TicketQty%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TicketQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_GoodQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_GoodQty%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_GoodQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_ReWorkQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_ReWorkQty%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_ReWorkQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_ScrapQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_ScrapQty%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_ScrapQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                </div>
                <dl>
                    <dd style="color: red">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_Note1%>"></asp:Literal>
                    </dd>
                    <dt style="color: <%= YellowColor%>">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_Note2%>"></asp:Literal>
                    </dt>
                </dl>
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
