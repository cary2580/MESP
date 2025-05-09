<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="TickResultWithoutApprovedList.aspx.cs" Inherits="TimeSheet_TickResultWithoutApprovedList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        $(function () {

            $("#<%=BT_Approval.ClientID%>").hide();

            if ($.StringConvertBoolean($("#<%=HF_IsShowApproval.ClientID%>").val()))
                $(".Approval").show();
            else
                $(".Approval").hide();

            $("#BT_Approval_View").click(function () {

                let GridTable = $("#" + JqGridParameterObject.TableID);

                let SelRcowId = GridTable.jqGrid("getGridParam", "selarrrow");

                if (SelRcowId.length < 1) {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });

                    return false;
                }

                let SelectCBKArrayID = new Array();

                let ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

                $.each(GridTable.getGridParam("selarrrow"), function (i, item) {
                    let TicketID = "";
                    let ProcessID = "";
                    let SerialNo = "";

                    if ($.grep(ColumnModel, function (Node) { return Node.name == JQGridDataValue.TicketIDColumnName; }).length > 0) {
                        TicketID = GridTable.jqGrid("getCell", item, JQGridDataValue.TicketIDColumnName);
                        ProcessID = GridTable.jqGrid("getCell", item, JQGridDataValue.ProcessIDColumnName);
                        SerialNo = GridTable.jqGrid("getCell", item, JQGridDataValue.SerialNoColumnName);
                    }

                    if (TicketID != "" && ProcessID != "" && SerialNo != "") {
                        let AD = {
                            TicketID: TicketID,
                            ProcessID: ProcessID,
                            SerialNo: SerialNo
                        };

                        SelectCBKArrayID.push(AD);
                    }
                });

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_ApprovalConfirmMessage") %>", IsHtmlElement: true, CloseEvent: function (result) {
                        if (result) {

                            $("#<%=HF_ApprovalList.ClientID%>").val(JSON.stringify(SelectCBKArrayID));

                            $("#<%=BT_Approval.ClientID%>").trigger("click");
                        }
                    }
                });
            });
        });

        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName) {
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
    <asp:HiddenField ID="HF_IsShowApproval" runat="server" Value="0" />
    <asp:HiddenField ID="HF_ApprovalList" runat="server" Value="0" />
    <div class="col-xs-2 form-group Approval required">
        <label for="<%= DDL_PayrollType.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_PayrollType%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_PayrollType" runat="server" CssClass="form-control" required="required">
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 form-group Approval">
        <input type="button" class="btn btn-warning" id="BT_Approval_View" value="<%=(string)GetLocalResourceObject("Str_BT_Approval")%>" style="display: none;" />
        <asp:Button ID="BT_Approval" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:Str_BT_Approval %>" Style="display: none;" OnClick="BT_Approval_Click" />
    </div>
    <div class="col-xs-12 form-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_TicketResultList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="col-xs-12 form-group">
                    <div id="JQContainerList"></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
