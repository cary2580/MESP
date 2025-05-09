<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ScrapReasonMappingDefect.aspx.cs" Inherits="TimeSheet_ScrapReasonMappingDefect" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName)
                {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");

                    var UploadObj;

                    if ($.inArray(JQGridDataValue.ScrapReasonIDColumnName, columnNames) > 0)
                    {
                        UploadObj = {
                            ScrapReasonID: $(this).jqGrid("getCell", RowID, JQGridDataValue.ScrapReasonIDColumnName),
                            ScrapReasonName: $(this).jqGrid("getCell", RowID, JQGridDataValue.ScrapReasonNameColumnName)
                        }

                        if (UploadObj.ScrapReasonID != "")
                            OpenPage(UploadObj);
                    }
                }
            });
        }

        function OpenPage(UploadObj)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/ScrapReasonMappingDefect_M.aspx") %>",
                iFrameOpenParameters: UploadObj,
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_ScrapReasonMappingDefect_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 810,
                height: 850,
                NewWindowPageDivID: "ScrapReasonMappingDefect_M_DivID",
                NewWindowPageFrameID: "ScrapReasonMappingDefect_M_FrameID"
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ScrapReasonList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>


