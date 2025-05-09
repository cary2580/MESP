<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="DailyReportForShift.aspx.cs" Inherits="TimeSheet_DailyReportForShift" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {

            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
                $("#SearchResultListDiv").show();
            else
                $("#SearchResultListDiv").hide();
        });

        function JqEventBind() {

            $("#" + JqGridParameterObject.TableID).bind("jqGridAfterGridComplete", function () {
                let Rows = $(this).jqGrid("getDataIDs");

                let TotalWS1 = 0;
                let TotalWS2 = 0;
                let TotalWS3 = 0;
                let TotalWS4 = 0;
                let TotalWS5 = 0;
                let TotalQty = 0;

                for (var i = 0; i < Rows.length; i++) {
                    let RowID = Rows[i];

                    TotalWS1 += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.WS01ColumnName)).value();
                    TotalWS2 += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.WS02ColumnName)).value();
                    TotalWS3 += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.WS03ColumnName)).value();
                    TotalWS4 += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.WS04ColumnName)).value();
                    TotalWS5 += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.WS05ColumnName)).value();
                    TotalQty += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.TotalQtyColumnName)).value();
                }

                $(this).jqGrid("footerData", "set", {
                    [JQGridDataValue.ProcessNameColumnName]: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_SubTotal")%>",
                    [JQGridDataValue.WS01ColumnName]: numeral(TotalWS1).format("0,0"),
                    [JQGridDataValue.WS02ColumnName]: numeral(TotalWS2).format("0,0"),
                    [JQGridDataValue.WS03ColumnName]: numeral(TotalWS3).format("0,0"),
                    [JQGridDataValue.WS04ColumnName]: numeral(TotalWS4).format("0,0"),
                    [JQGridDataValue.WS05ColumnName]: numeral(TotalWS5).format("0,0"),
                    [JQGridDataValue.TotalQtyColumnName]: numeral(TotalQty).format("0,0"),
                });

                $("#" + JqGridParameterObject.TableID).closest(".ui-jqgrid-bdiv").next(".ui-jqgrid-sdiv").find(".footrow").find(">td[aria-describedby=\"" + JqGridParameterObject.TableID + "_" + JQGridDataValue.ProcessNameColumnName + "\"]").css("text-align", "right");
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
    <div class="col-xs-3 form-group">
        <label for="<%= DDL_IsApproved.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsApproved %>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsApproved" runat="server" CssClass="form-control selectpicker" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 form-group">
        <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
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
