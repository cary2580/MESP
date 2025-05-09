<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="DailyReport.aspx.cs" Inherits="TimeSheet_DailyReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            if (typeof (JQGridDataValue) != "undefined")
                $("#SearchResultInfoDiv,#SearchResultListDiv").show();
            else
                $("#SearchResultInfoDiv,#SearchResultListDiv").hide();

            $("#<%=BT_WorkShift.ClientID%>,#<%=BT_PayrollType.ClientID%>").click(function ()
            {

                var JqGrid = $("#" + JqGridParameterObject.TableID);

                var SelectedList = { Data: [], Url: "" };

                $.each(JqGrid.jqGrid("getGridParam", "selarrrow"), function (index, item)
                {
                    var RowData = JqGrid.jqGrid("getRowData", item);

                    var TicketResultKey = {
                        TicketID: RowData[JQGridDataValue.TicketIDColumnName],
                        ProcessID: RowData[JQGridDataValue.ProcessIDColumnName],
                        SerialNo: RowData[JQGridDataValue.SerialNoColumnName]
                    };

                    SelectedList.Data.push(TicketResultKey);
                });

                if ($(this).prop("id") == $("#<%=BT_WorkShift.ClientID%>").prop("id"))
                {
                    SelectedList.Url = "IT_ModifyWorkShift.aspx";
                    OpenPage(SelectedList);
                }
                else
                {
                    SelectedList.Url = "IT_ModifyPayrollType.aspx";
                    OpenPage(SelectedList);
                }
            })

            function OpenPage(SelectedList)
            {
                $.OpenPage({
                    Framesrc: "<%=ResolveClientUrl(@"~/TimeSheet/")%>" + SelectedList.Url.toString(),
                    iFrameOpenParameters: { SelectedList: JSON.stringify(SelectedList.Data) },
                    TitleBarText: "<%=(string)GetLocalResourceObject("AdminModify_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 660,
                    height: 560,
                    NewWindowPageDivID: "AdminModify_DivID",
                    NewWindowPageFrameID: "AdminModify_FrameID",
                    CloseEvent: function ()
                    {
                        window.location.reload();
                    }
                });
            }
        });

        function JqEventBind()
        {
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
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_SearchCondition%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCode%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_ReportTimeStart.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportTimeStart %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_ReportTimeStart" runat="server" CssClass="form-control DateTimeDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_ReportTimeEnd.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportTimeEnd %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_ReportTimeEnd" runat="server" CssClass="form-control DateTimeDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-12 form-group text-center">
                <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:Str_BT_Search %>" OnClick="BT_Search_Click" />
                <asp:Button ID="BT_WorkShift" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:Str_BT_WorkShift %>" Visible="false" OnClientClick="return false" />
                <asp:Button ID="BT_PayrollType" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:Str_BT_PayrollType %>" Visible="false" OnClientClick="return false" />
            </div>
        </div>
    </div>
    <div id="SearchResultInfoDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor6") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-2 form-group">
                <label for="<%= TB_GoodQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_Qty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_GoodQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_ScrapQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_ScrapQty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ScrapQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_ReWorkQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_ReWorkQty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ReWorkQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_ReportMinute.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_ReportMinute%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ReportMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_WaitMaintainMinute.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_WaitMaintainMinute%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_WaitMaintainMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_MaintainMinute.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_MaintainMinute%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MaintainMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_WaitMinute.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_WaitMinute%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_WaitMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_ResultMinute.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_ResultMinute%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ResultMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-2 form-group">
                <label for="<%= TB_ResultMinuteOperator.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultInfo_ResultMinuteOperator%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ResultMinuteOperator" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
        </div>
    </div>
    <div id="SearchResultListDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>
