<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="ScrapReasonMappingDefect_M.aspx.cs" Inherits="TimeSheet_ScrapReasonMappingDefect_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        function JqEventBind() {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex) {
                $("#<%= TB_DefectID.ClientID%>").val($(this).jqGrid("getCell", RowID, JQGridDataValue.DefectIDColumnName));
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DivID" runat="server" />
    <asp:HiddenField ID="HF_ScrapReasonID" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DefectInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4 form-group">
                <label for="<%= TB_ScrapReasonName.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ScrapReasonName %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ScrapReasonName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_DefectID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_DefectID %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_DefectID" runat="server" CssClass="form-control" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group" style="text-align: center">
                <asp:Button ID="BT_AddDefect" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click" />
                <asp:Button ID="BT_DeleteDefect" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DefectIDList%>"></asp:Literal>
        </div>
        <div class="panel-body">

            <div class="col-xs-12 form-group">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>


