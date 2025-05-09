<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="MOSearch.aspx.cs" Inherits="TimeSheet_MOSearch" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {

            $("#<%=BT_SetEnd.ClientID%>").hide();

            if ($.StringConvertBoolean($("#<%=HF_IsShowSetEnd.ClientID%>").val()))
                $("#BT_SetEnd_View").show();
            else
                $("#BT_SetEnd_View").hide();

            $("#<%=TB_AUFNR.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data) {
                        if (data.A1 == null) {
                            $("#<%=TB_AUFNR.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_TS_Empty_AUFNR")%>" });

                            return;
                        }

                        $("#<%=TB_AUFNR.ClientID%>").val(data.A1);

                        $("#<%=BT_Search.ClientID%>").trigger("click");
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_AUFNR.ClientID%>").val("");
                    }
                });

            }).focus();

            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val())) {
                $("#MOInftDiv,#SearchResultListDiv").show();

                if ($("#<%=DDL_ViewModel.ClientID%>").val() == "0")
                    $(".ViewModel0TitleText").show();
                else
                    $(".ViewModel0TitleText").hide();
            }
            else
                $("#MOInftDiv,#SearchResultListDiv,.ViewModel0TitleText").hide();

            $("#BT_SetEnd_View").click(function () {
                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_SetEndConfirmMessage") %>", IsHtmlElement: true, CloseEvent: function (result) {
                        if (result)
                            $("#<%=BT_SetEnd.ClientID%>").trigger("click");
                    }
                });
            });
        });

        function LoadGridDataCustomColModel(PO, colModel) {

            if ($("#<%=DDL_ViewModel.ClientID%>").val() != "2")
                return colModel;

            PO.JQGridDataValue.groupingView.groupText = [function (CellValue, Option, RowObject) {

                let SumValue = 0;

                $.each(RowObject, function (Index, Item) {
                    if ($.inArray(Item.nm, PO.JQGridDataValue.CustiomFormatterLocalizedNumericColumnNames) > -1)
                        SumValue += Item.v;
                });

                return "<b>" + CellValue + " (" + numeral(SumValue).format("0,0") + ")</b>";
            }];

            $.each(colModel, function (Index, Item) {

                let LocalizedNumericColumnName = $.grep(PO.JQGridDataValue.CustiomFormatterLocalizedNumericColumnNames, function (ColumnName) {
                    return ColumnName === Item.name;
                });

                if (LocalizedNumericColumnName.length > 0) {
                    colModel[Index].formatter = function (CellValue, Option, RowObject) {
                        return numeral(CellValue).format("0,0");
                    };

                    colModel[Index].unformat = function (CellValue, Option) {
                        return numeral(CellValue).value();
                    };
                }

                if (PO.JQGridDataValue.ReportDateColumnName == Item.name) {
                    colModel[Index].summaryType = function (value, name, record) {
                        return "<%= (string)GetGlobalResourceObject("GlobalRes", "Str_SubTotal")%> : ";
                    };
                }
            });

            return colModel;
        }

        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var TicketIDValue = "";

                    if ($.inArray(JQGridDataValue.TicketIDColumnName, columnNames) > 0)
                        TicketIDValue = $(this).jqGrid("getCell", RowID, JQGridDataValue.TicketIDColumnName);

                    if (TicketIDValue != "")
                        $.WindowOpen("Post", "<%=ResolveClientUrl(@"~/TimeSheet/TicketLifeCycle.aspx?A2=")%>" + TicketIDValue);
                }
            });

            $("#" + JqGridParameterObject.TableID).bind("jqGridAfterGridComplete", function () {
                let Rows = $(this).jqGrid("getDataIDs");

                for (var i = 0; i < Rows.length; i++) {
                    let RowID = Rows[i];

                    let ColorCss = $(this).jqGrid("getCell", RowID, "ReportColor");

                    let DifferentQTYColor = $(this).jqGrid("getCell", RowID, "DifferentQTYColor");

                    if (ColorCss != "")
                        $(this).jqGrid("setCell", RowID, "Qty", "", { background: ColorCss, color: "#FFFFFF" });

                    if (DifferentQTYColor != "")
                        $(this).jqGrid("setCell", RowID, "ScrapQtyByTotal", "", { background: DifferentQTYColor, color: "#FFFFFF" });
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsShowSetEnd" runat="server" Value="0" />
    <asp:HiddenField ID="HF_IsShowResultList" runat="server" Value="0" />
    <div class="col-xs-4 form-group">
        <label for="<%= TB_AUFNR.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_AUFNR%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_AUFNR" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_Brand.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_TS_Brand%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_Brand" runat="server" CssClass="form-control"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_ViewModel.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ViewModel%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_ViewModel" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:ViewModel_1%>" Value="0"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:ViewModel_2%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:ViewModel_3%>" Value="2"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 form-group">
        <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
        <input type="button" class="btn btn-danger" id="BT_SetEnd_View" value="<%=(string)GetLocalResourceObject("Str_BT_SetEnd")%>" style="display: none;" />
        <asp:Button ID="BT_SetEnd" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:Str_BT_SetEnd %>" OnClick="BT_SetEnd_Click" Style="display: none;" />
    </div>
    <div class="col-xs-12 form-group">
        <div id="MOInftDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#MOInfoContent">
                <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo%>"></asp:Literal>
            </div>
            <div id="MOInfoContent" class="panel-collapse collapse" aria-expanded="true">
                <div class="panel-body">
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_PSMNG.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_PSMNG%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PSMNG" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_TicketTotalQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_TicketTotalQty%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TicketTotalQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_WEMNG.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_WEMNG%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_WEMNG" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_AUART.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_AUART%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_AUART" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_VERID.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_VERID%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_VERID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_PLNBEZ.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_PLNBEZ %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PLNBEZ" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_MAKTX %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_ZEINR.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_ZEINR%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_ZEINR" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_FERTH.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_FERTH%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_FERTH" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_PLNNR.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_PLNNR%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PLNNR" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_PLNAL.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_PLNAL%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PLNAL" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_KTEXT.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_KTEXT%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_KTEXT" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_ERDAT.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_ERDAT%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_ERDAT" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_FTRMI.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_FTRMI%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_FTRMI" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_GSTRP.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_GSTRP%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_GSTRP" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_GLTRP.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_GLTRP%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_GLTRP" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_GoodQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_GoodQty%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_GoodQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_ReWorkQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_ReWorkQty%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_ReWorkQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_ScrapQty.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_ScrapQty%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_ScrapQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_IsPreClose.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_IsPreClose%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_IsPreClose" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xs-12">
        <div id="SearchResultListDiv" runat="server" style="display: none;" class="panel ">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <dl class="ViewModel0TitleText">
                    <p style="color: red">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_Note1%>"></asp:Literal>
                    </p>
                    <p style="color: <%= YellowColor%>">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_Note2%>"></asp:Literal>
                    </p>
                    <p style="color: <%= PinkColor%>">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_Note3%>"></asp:Literal>
                    </p>
                </dl>
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
