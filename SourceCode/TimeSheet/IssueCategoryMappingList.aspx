<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="IssueCategoryMappingList.aspx.cs" Inherits="TimeSheet_IssueCategoryMappingList" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">

    <script type="text/javascript">

        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {

                let cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {

                    let columnNames = $.map(cm, function (value, index) { return value.name; });

                    let CategoryID = "";

                    if ($.inArray(JQGridDataValue.CategoryIDColumnName, columnNames) > 0)
                        CategoryID = $(this).jqGrid("getCell", RowID, JQGridDataValue.CategoryIDColumnName);

                    if (CategoryID != "" && JQGridDataValue.CategoryNameColumnName == cm[CellIndex].name)
                        OpenPage_M(CategoryID);
                    else if (CategoryID != "" && JQGridDataValue.CategoryIDColumnName == cm[CellIndex].name)
                        OpenPage_Issue(CategoryID);
                }
            });
        }

        function OpenPage_M(CategoryID) {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/IssueCategoryMappingDevice.aspx") %>",
                iFrameOpenParameters: { CategoryID: CategoryID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_MappingDevice_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 810,
                height: 760,
                CloseEvent: function () {
                    window.location.reload();
                }
            });
        }

        function OpenPage_Issue(CategoryID) {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/IssueCategoryMappingIssue.aspx") %>",
                iFrameOpenParameters: { CategoryID: CategoryID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_MappingIssue_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 810,
                height: 760,
                CloseEvent: function () {
                    window.location.reload();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
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
