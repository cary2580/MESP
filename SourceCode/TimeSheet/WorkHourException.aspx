<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="WorkHourException.aspx.cs" Inherits="TimeSheet_WorkHourException" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
                $("#SearchResultListDiv").show();
            else
                $("#SearchResultListDiv").hide();

            $("#BT_Create").click(function () {
                OpenPage("");
            });
        });

        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");

                    var WorkDate = "";
                    var SectionID = "";

                    if ($.inArray(JQGridDataValue.WorkDateColumnName, columnNames) > 0)
                        WorkDate = $(this).jqGrid("getCell", RowID, JQGridDataValue.WorkDateValueColumnName);
                    if ($.inArray(JQGridDataValue.SectionIDColumnName, columnNames) > 0)
                        SectionID = $(this).jqGrid("getCell", RowID, JQGridDataValue.SectionIDColumnName);

                    if (WorkDate != "" && SectionID != "")
                        OpenPage(WorkDate, SectionID);
                }
            });
        }

        function OpenPage(WorkDate, SectionID) {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/WorkHourException_M.aspx") %>",
                iFrameOpenParameters: { WorkDate: WorkDate, SectionID: SectionID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_WorkHourException_M_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 950,
                height: 560,
                NewWindowPageDivID: "WorkHourException_M_DivID",
                NewWindowPageFrameID: "WorkHourException_M_FrameID",
                CloseEvent: function () {
                    window.location.reload();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsShowResultList" runat="server" Value="0" />
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_WorkDateStart.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_WorkDateStart %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_WorkDateStart" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_WorkDateEnd.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_WorkDateEnd %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_WorkDateEnd" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-12">
        <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
        <input type="button" class="btn btn-primary" id="BT_Create" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName") %>" />
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

