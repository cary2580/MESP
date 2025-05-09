<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="DeviceViewGroup.aspx.cs" Inherits="TimeSheet_DeviceViewGroup" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DeviceInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4 form-group">
                <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group">
                <label for="<%= TB_MachineName.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MachineName %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MachineName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_GroupList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-12 form-group">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>


