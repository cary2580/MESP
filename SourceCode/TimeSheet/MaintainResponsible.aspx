<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="MaintainResponsible.aspx.cs" Inherits="TimeSheet_MaintainResponsible" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        function OpenPage_M(ResponsibleID)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/MaintainResponsible_M.aspx") %>",
                iFrameOpenParameters: { ResponsibleID: ResponsibleID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_MaintainResponsible_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 950,
                height: 560,
                NewWindowPageDivID: "MaintainResponsible_M_DivID",
                NewWindowPageFrameID: "MaintainResponsible_M_FrameID",
                CloseEvent: function () {
                    window.location.reload();
                }
            });
        }

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                var cm = $(this).jqGrid("getGridParam", "colModel");
                
                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var ResponsibleID = "";

                    if ($.inArray(JQGridDataValue.ResponsibleIDColumnName, columnNames) > 0)
                        ResponsibleID = $(this).jqGrid("getCell", RowID, JQGridDataValue.ResponsibleIDColumnName);

                    if (ResponsibleID != "")
                        OpenPage_M(ResponsibleID);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="col-xs-12 form-group">
        <input id="BT_Create" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName") %>" class="btn btn-primary" onclick="OpenPage_M('');" />
    </div>
    <div class="col-xs-12 form-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainResponsibleList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>

