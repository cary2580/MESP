<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="FaultMapping_M.aspx.cs" Inherits="TimeSheet_FaultMapping_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                $("#<%= TB_FaultID.ClientID%>").val($(this).jqGrid("getCell", RowID, JQGridDataValue.FaultIDColumnName));
                $("#<%= HF_FaultID_OLD.ClientID%>").val($(this).jqGrid("getCell", RowID, JQGridDataValue.FaultIDColumnName));
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_FaultID_OLD" runat="server" />
    <asp:HiddenField ID="HF_FaultCategoryID" runat="server" />
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_FaultMappingList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_FaultCategoryName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_FaultCategoryName %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_FaultCategoryName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_FaultID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_FaultID %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_FaultID" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-12 form-group" style="text-align:center">
                    <asp:Button ID="BT_AddFaultID" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click" />
                    <asp:Button ID="BT_DeleteFaultID" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
                </div>
            </div>
        </div>
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_FaultList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="col-xs-12 form-group">
                    <div id="JQContainerList"></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

