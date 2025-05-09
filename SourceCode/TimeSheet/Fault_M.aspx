<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="Fault_M.aspx.cs" Inherits="TimeSheet_Fault_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_FaultID_OLD" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_FaultInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_FaultID.ClientID%>" class="control-label ">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_FaultID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_FaultID" runat="server" CssClass="form-control" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-8 form-group required">
                <label for="<%= TB_FaultName.ClientID%>" class="control-label ">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_FaultName%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_FaultName" runat="server" CssClass="form-control" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <asp:Button ID="BT_Save" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName%>" CssClass="btn btn-warning" OnClick="BT_Save_Click" />
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName%>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
            </div>
        </div>
    </div>
</asp:Content>

