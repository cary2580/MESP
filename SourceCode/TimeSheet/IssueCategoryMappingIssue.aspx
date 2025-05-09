<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="IssueCategoryMappingIssue.aspx.cs" Inherits="TimeSheet_IssueCategoryMappingIssue" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        $(function () {

            $("#<%=TB_IssueName.ClientID%>").css("cursor", "pointer").click(function () {

                let FrameID = "IssueSelect_FrameID";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/IssueSelect.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_IssueSelect_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 820,
                    height: 770,
                    NewWindowPageDivID: "IssueSelect_DivID",
                    NewWindowPageFrameID: FrameID,
                    parentWindow: window.parent,
                    CloseEvent: function (result) {

                        let IssueID = $(result).find("#" + FrameID).contents().find("#HF_IssueID").val();
                        let IssueName = $(result).find("#" + FrameID).contents().find("#HF_IssueName").val();

                        $("#<%=HF_IssueID.ClientID%>").val(IssueID);
                        $("#<%=TB_IssueName.ClientID%>").val(IssueName);
                    }
                });

            });
        });

        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {

                $("#<%= TB_IssueName.ClientID%>").val($(this).jqGrid("getCell", RowID, JQGridDataValue.IssueNameColumnName));

                $("#<%= HF_IssueID.ClientID%>").val($(this).jqGrid("getCell", RowID, JQGridDataValue.IssueIDColumnName));
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_CategoryID" runat="server" />
    <asp:HiddenField ID="HF_IssueID" runat="server" />
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-body">
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_CategoryName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_CategoryName %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_CategoryName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_IssueName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_IssueName %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_IssueName" runat="server" CssClass="form-control readonly"></asp:TextBox>
                </div>
                <div class="col-xs-12 form-group" style="text-align: center">
                    <asp:Button ID="BT_Add" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click" />
                    <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
                </div>
            </div>
        </div>
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_IssueList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="col-xs-12 form-group">
                    <div id="JQContainerList"></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
