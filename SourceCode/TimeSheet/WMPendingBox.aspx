<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="WMPendingBox.aspx.cs" Inherits="TimeSheet_WMPendingBox" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#BT_Create").click(function ()
            {
                OpenPage("");
            });

            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
            {
                $("#SearchResultListDiv").show();
            }
            else
                $("#SearchResultListDiv").hide();
        });


        function OpenPage(BoxNo)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/WMPendingBox_M.aspx") %>",
                iFrameOpenParameters: { BoxNo: BoxNo },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_ProductionPendingBox_Title") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 1220,
                height: 760,
                NewWindowPageDivID: "ProductionPendingBox_DivID",
                NewWindowPageFrameID: "ProductionPendingBox_FrameID"
            });
        }

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName)
                {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");

                    var BoxNo = "";

                    if ($.inArray(JQGridDataValue.BoxNoColumnName, columnNames) > 0)
                        BoxNo = $(this).jqGrid("getCell", RowID, JQGridDataValue.BoxNoValueColumnName);

                    if (BoxNo != "")
                        OpenPage(BoxNo);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsShowResultList" runat="server" Value="0" />
    <div class="col-xs-3 form-group">
        <label for="<%= TB_BoxNo.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_BoxNo%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_BoxNo" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_WM_ScanBoxNo %>"></asp:TextBox>
    </div>
    <div class="col-xs-3 form-group">
        <label for="<%= TB_CreateDateStart.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateStart %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_CreateDateStart" runat="server" CssClass="form-control DateTimeDatepicker readonly"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group">
        <label for="<%= TB_CreateDateEnd.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_CreateDateEnd %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_CreateDateEnd" runat="server" CssClass="form-control DateTimeDatepicker readonly"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group">
        <label for="<%= TB_CreateWorkCode.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_CreateWorkCode%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_CreateWorkCode" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
    </div>
    <div class="col-xs-12">
        <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
        <input id="BT_Create" type="button" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName") %>" class="btn btn-primary" />
    </div>
    <div class="col-xs-12">
        <p></p>
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
