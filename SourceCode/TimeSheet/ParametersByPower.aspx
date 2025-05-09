<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ParametersByPower.aspx.cs" Inherits="TimeSheet_ParametersByPower" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
                $("#SearchResultListDiv").show();
            else
                $("#SearchResultListDiv").hide();

            $("#BT_Create").click(function ()
            {
                OpenPage("");
            });
        });

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName)
                {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");

                    var ReportDate = "";

                    if ($.inArray(JQGridDataValue.ReportDateColumnName, columnNames) > 0)
                        ReportDate = $(this).jqGrid("getCell", RowID, JQGridDataValue.ReportDateValueColumnName);

                    if (ReportDate != "")
                        OpenPage(ReportDate);
                }
            });
        }

        function OpenPage(ReportDate)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/ParametersByPower_M.aspx") %>",
                iFrameOpenParameters: { ReportDate: ReportDate },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 950,
                height: 560,
                CloseEvent: function ()
                {
                    window.location.reload();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsShowResultList" runat="server" Value="0" />
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_ReportDateStart.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDateStart %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_ReportDateStart" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_ReportDateEnd.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDateEnd %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_ReportDateEnd" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-12">
        <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
        <input type="button" class="btn btn-primary" id="BT_Create" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName") %>" />
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
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
