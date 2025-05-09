<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="Defect_M.aspx.cs" Inherits="TimeSheet_Defect_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DefectID_OLD" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DefectInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_DefectID.ClientID%>" class="control-label ">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_DefectID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_DefectID" runat="server" CssClass="form-control" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group required">
            <label for="<%= DDL_IsEnable.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_IsEnable%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_IsEnable" runat="server" CssClass="form-control">
                <asp:ListItem Value="1" Text="<%$ Resources:GlobalRes,Str_Yes%>"></asp:ListItem>
                <asp:ListItem Value="0" Text="<%$ Resources:GlobalRes,Str_No%>"></asp:ListItem>
            </asp:DropDownList>
            </div>
            <div class="col-xs-12 form-group required">
                <label for="<%= TB_DefectName.ClientID%>" class="control-label ">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_DefectName%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_DefectName" runat="server" CssClass="form-control" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <asp:Button ID="BT_Create" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName%>" CssClass="btn btn-warning" OnClick="BT_Create_Click" />
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName%>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
            </div>
        </div>
    </div>
</asp:Content>
