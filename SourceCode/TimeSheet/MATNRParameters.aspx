<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="MATNRParameters.aspx.cs" Inherits="TimeSheet_MATNRParameters" %>

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

                    if ($.inArray(JQGridDataValue.MATNRColumnName, columnNames) > 0)
                    {
                        var MATNR = $(this).jqGrid("getCell", RowID, JQGridDataValue.MATNRColumnName);

                        if (MATNR != "")
                        {
                            $.OpenPage({
                                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/MATNRParameters_M.aspx") %>",
                                iFrameOpenParameters: { MATNR: MATNR},
                                TitleBarText: "<%=(string)GetLocalResourceObject("Str_MATNRParameters_M_Title") %>",
                                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                                width: 810,
                                height: 560,
                                NewWindowPageDivID: "MATNRParameters_M_DivID",
                                NewWindowPageFrameID: "MATNRParameters_M_FrameID",
                                CloseEvent: function () {
                                    window.location.reload();
                                }
                            });
                         }
                    }
                }
            })
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MATNRParametersList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>

