<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="IssueList.aspx.cs" Inherits="TimeSheet_IssueList" %>

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

                    let IssueID = "";

                    if ($.inArray(JQGridDataValue.IssueIDColumnName, columnNames) > 0)
                        IssueID = $(this).jqGrid("getCell", RowID, JQGridDataValue.IssueIDColumnName);

                    if (IssueID != "")
                        OpenPage(IssueID);
                }
            });
        }

        function OpenPage(IssueID) {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/Issue_M.aspx") %>",
                iFrameOpenParameters: { IssueID: IssueID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_Issue_M_Title") %>",
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
                <asp:Literal runat="server" Text="<%$ Resources:Str_IssueList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
