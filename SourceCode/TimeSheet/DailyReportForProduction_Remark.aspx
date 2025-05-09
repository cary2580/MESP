<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="DailyReportForProduction_Remark.aspx.cs" Inherits="TimeSheet_DailyReportForProduction_Remark" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_TaskDateTime" runat="server" />
    <asp:HiddenField ID="HF_PVGroupID" runat="server" />
    <asp:HiddenField ID="HF_ProcessTypeID" runat="server" />

    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-body">
            <div class="col-xs-12 form-group ">
                <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click" />
            </div>
            <div class="col-xs-12 form-group">
                <label for="<%= TB_Remark.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_Remark %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_Remark" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="20" ClientIDMode="Static"></asp:TextBox>
            </div>
        </div>
    </div>
</asp:Content>
