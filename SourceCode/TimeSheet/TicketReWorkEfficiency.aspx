<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="TicketReWorkEfficiency.aspx.cs" Inherits="TimeSheet_TicketReWorkEfficiency" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
                $("#MOInftDiv,#SearchResultListDiv").show();
            else
                $("#MOInftDiv,#SearchResultListDiv").hide();
        });

        function JqEventBind(PO)
        {
            if (PO.TableID != JqGridParameterObject.TableID)
                return;

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
        }

        function JqSubGridRowExpandedEvent(ParentRowID, ParentRowKey)
        {
            var TicketID = $("#" + JqGridParameterObject.TableID).jqGrid("getCell", ParentRowKey, JQGridDataValue.TicketIDColumnName);

            $("#" + JqGridParameterObject.TableID).jqGrid("setSelection", ParentRowKey);

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketReWorkEfficiency.ashx") %>", data: {
                    TicketID: TicketID,
                }, CallBackFunction: function (data)
                {
                    SetSubGridData(ParentRowID, ParentRowKey, data);
                }
            });
        }

        function SetSubGridData(ParentRowID, ParentRowKey, GridData)
        {
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
            <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateStartEnd %>"></asp:Literal>
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
        <label for="<%= DDL_IsOnlyViewExpiredData.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsOnlyViewExpiredData%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsOnlyViewExpiredData" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1" Selected="True"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= DDL_IsOnlyViewNotEnd.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsOnlyViewNotEnd%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsOnlyViewNotEnd" runat="server" CssClass="form-control" required="required">
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
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
