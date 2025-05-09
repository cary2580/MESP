<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="BaseRouting_M_ProcessStandardDay.aspx.cs" Inherits="TimeSheet_BaseRouting_M_ProcessStandardDay" %>

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
                <div class="col-xs-6 form-group required">
                    <label for="<%= TB_ProcessStandardDay.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ProcessStandardDay%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ProcessStandardDay" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-6 form-group required">
                    <label for="<%= TB_ProcessReWorkStandardDay.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ProcessReWorkStandardDay%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ProcessReWorkStandardDay" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" required="required"></asp:TextBox>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
