<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="IssueCategoryList.aspx.cs" Inherits="TimeSheet_IssueCategoryList" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#BT_Add").click(function () {
                OpenPage("");
            });
        });

        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                let cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {

                    let columnNames = $.map(cm, function (value, index) { return value.name; });

                    let CategoryID = "";

                    if ($.inArray(JQGridDataValue.CategoryIDColumnName, columnNames) > 0)
                        CategoryID = $(this).jqGrid("getCell", RowID, JQGridDataValue.CategoryIDColumnName);

                    if (CategoryID != "")
                        OpenPage(CategoryID);
                }
            });
        }

        function OpenPage(CategoryID) {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/IssueCategory_M.aspx") %>",
                iFrameOpenParameters: { CategoryID: CategoryID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_IssueCategory_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 710,
                height: 560,
                CloseEvent: function () {
                    window.location.reload();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="col-xs-12 form-group">
        <input id="BT_Add" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName") %>" class="btn btn-primary" />
    </div>
    <div class="col-xs-12 form-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_IssueCategoryList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
