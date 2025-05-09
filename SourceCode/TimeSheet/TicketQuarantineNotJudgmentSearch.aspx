<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="TicketQuarantineNotJudgmentSearch.aspx.cs" Inherits="TimeSheet_TicketQuarantineNotJudgmentSearch" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
                $("#SearchResultListDiv").show();
            else
                $("#SearchResultListDiv").hide();
        });

        function JqEventBind(PO) {
            if (PO.TableID != JqGridParameterObject.TableID)
                return;

            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {
                    let columnNames = $(this).jqGrid("getGridParam", "colNames");

                    let TicketIDValue = "";

                    if ($.inArray(JQGridDataValue.TicketIDColumnName, columnNames) > 0)
                        TicketIDValue = $(this).jqGrid("getCell", RowID, JQGridDataValue.TicketIDColumnName);


                    if (TicketIDValue != "" && cm[CellIndex].name == JQGridDataValue.RemarkColumnName) {

                        var FrameID = "TicketQuarantineRemark_FrameID";

                        $.OpenPage({
                            Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/TicketQuarantineRemark.aspx") %>",
                            iFrameOpenParameters: { TicketID: TicketIDValue},
                            TitleBarText: "<%=(string)GetLocalResourceObject("Str_ColumnName_Remark") %>",
                            TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                            width: 720,
                            height: 660,
                            NewWindowPageDivID: "TicketQuarantineRemark_DivID",
                            NewWindowPageFrameID: FrameID,
                            CloseEvent: function (result) {
                                var Remark = $(result).find("#" + FrameID).contents().find("#TB_Remark").val();

                                $("#" + JqGridParameterObject.TableID).jqGrid("setCell", RowID, JQGridDataValue.RemarkColumnName, Remark == "" ? null : Remark);
                            }
                        });
                    }
                    else if (TicketIDValue != "")
                        $.WindowOpen("Post", "<%=ResolveClientUrl(@"~/TimeSheet/TicketLifeCycle.aspx?A2=")%>" + TicketIDValue);
                }
            });

            $("#" + JqGridParameterObject.TableID).bind("jqGridAfterGridComplete", function () {
                var Rows = $(this).jqGrid("getDataIDs");

                for (var i = 0; i < Rows.length; i++) {
                    var RowID = Rows[i];

                    var ColorCss = $(this).jqGrid("getCell", RowID, "ReportColor");

                    if (ColorCss != "")
                        $(this).jqGrid("setCell", RowID, "Qty", "", { background: ColorCss, color: "#FFFFFF" });
                }
            });

            $("#" + JqGridParameterObject.TableID).bind("jqGridAfterGridComplete", function () {
                let Rows = $(this).jqGrid("getDataIDs");

                let Qty = 0;
                let ScrapQty = 0;

                for (var i = 0; i < Rows.length; i++) {
                    let RowID = Rows[i];

                    Qty += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.QtyColumnName)).value();
                    ScrapQty += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.ScrapQtyColumnName)).value();
                }

                $(this).jqGrid("footerData", "set", {
                    [JQGridDataValue.MachineNameColumnName]: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_SubTotal")%>",
                    [JQGridDataValue.QtyColumnName]: numeral(Qty).format("0,0"),
                    [JQGridDataValue.ScrapQtyColumnName]: numeral(ScrapQty).format("0,0")
                });

                $("#" + JqGridParameterObject.TableID).closest(".ui-jqgrid-bdiv").next(".ui-jqgrid-sdiv").find(".footrow").find(">td[aria-describedby=\"" + JqGridParameterObject.TableID + "_" + JQGridDataValue.MachineNameColumnName + "\"]").css("text-align", "right");
            });
        }

        function JqHasSubGridRowFunction(RowID) {
            var IsHaveResultItem = false;

            var columnNames = $("#" + JqGridParameterObject.TableID).jqGrid("getGridParam", "colNames");

            if ($.inArray(JQGridDataValue.IsHaveResultItemColumnName, columnNames) > 0)
                IsHaveResultItem = $.StringConvertBoolean($("#" + JqGridParameterObject.TableID).jqGrid("getCell", RowID, JQGridDataValue.IsHaveResultItemColumnName));

            return IsHaveResultItem;
        }

        function JqSubGridRowExpandedEvent(ParentRowID, ParentRowKey) {
            var TicketID = $("#" + JqGridParameterObject.TableID).jqGrid("getCell", ParentRowKey, JQGridDataValue.TicketIDColumnName);

            $("#" + JqGridParameterObject.TableID).jqGrid("setSelection", ParentRowKey);

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketQuarantineGet.ashx") %>", data: {
                    TicketID: TicketID,
                    IsOnlyGetItemData: true
                }, CallBackFunction: function (data) {
                    SetSubGridData(ParentRowID, ParentRowKey, data.ItemData);
                }
            });
        }

        function SetSubGridData(ParentRowID, ParentRowKey, GridData) {
            var JqSubGridID = ParentRowID + "_Table";
            var JqSubGridPagerID = ParentRowID + "_Pager";

            LoadGridData({
                IsExtendJqGridParameterObject: false,
                ListID: ParentRowID,
                TableID: JqSubGridID,
                PagerID: JqSubGridPagerID,
                JQGridDataValue: GridData,
                IsShowSubGrid: false,
                IsShowJQGridFilterToolbar: false,
                IsShowJQGridPager: false,
            });

            $(".ui-jqgrid-htable", "#" + ParentRowID).find(".ui-th-column").addClass("SubGridThBackgroundColor");

            $($("#" + JqSubGridID)[0].grid.hDiv).find("th.ui-th-column").off("mouseenter mouseleave");
        }
    </script>
    <style>
        .SubGridThBackgroundColor {
            background-color: #cc9966;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsShowResultList" runat="server" Value="0" />
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_CreateDateStart.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateStart %>"></asp:Literal>
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
        <label for="<%= DDL_IsViewOnlyNotJudgment.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsViewOnlyNotJudgment%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsViewOnlyNotJudgment" runat="server" CssClass="form-control" required="required">
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
        <div id="SearchResultListDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor11") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
