<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="BaseRouting_M_OutputResultMinute.aspx.cs" Inherits="TimeSheet_BaseRouting_M_OutputResultMinute" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_PLNNR" runat="server" />
    <asp:HiddenField ID="HF_PLNAL" runat="server" />
    <asp:HiddenField ID="HF_PLNKN" runat="server" />
    <asp:HiddenField ID="HF_ProcessID" runat="server" />
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
            <div class="panel-body">
                <div class="col-xs-12 form-group ">
                    <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click"/>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= DDL_IsOutputResultMinute.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_IsOutputResultMinute%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsOutputResultMinute" runat="server" CssClass="form-control" required="required">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= DDL_IsOutputResultMinuteForMan.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_IsOutputResultMinuteForMan%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsOutputResultMinuteForMan" runat="server" CssClass="form-control" required="required">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
