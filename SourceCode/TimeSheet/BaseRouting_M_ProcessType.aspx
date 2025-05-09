<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="BaseRouting_M_ProcessType.aspx.cs" Inherits="TimeSheet_BaseRouting_M_ProcessType" %>

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
                    <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click" />
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= DDL_ProcessType.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ProcessType%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_ProcessType" runat="server" CssClass="form-control" required="required">
                    </asp:DropDownList>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
