<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="Device_M.aspx.cs" Inherits="TimeSheet_Device_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DeviceID" runat="server" />
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_MachineID.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_MachineName.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MachineName%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MachineName" runat="server" CssClass="form-control" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_MachineAlias.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MachineAlias%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_MachineAlias" runat="server" CssClass="form-control" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group">
        <label for="<%= TB_Location.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Location%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_Location" runat="server" CssClass="form-control"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsMultipleGoIn.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsMultipleGoIn%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsMultipleGoIn" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsApprovalByDevice.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsApprovalByDevice%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsApprovalByDevice" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsBrand.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsBrand%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsBrand" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsFirstProcess.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsFirstProcess%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsFirstProcess" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsPrintPackage.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsPrintPackage%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsPrintPackage" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_OnWorkBeforeMinute.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_OnWorkBeforeMinute %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_OnWorkBeforeMinute" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_OffWorkBeforeMinute.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_OffWorkBeforeMinute %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_OffWorkBeforeMinute" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_Power.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Power %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_Power" runat="server" CssClass="form-control MumberType" required="required" Text="0" data-MumberTypeDecimals="2"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_PowerCoefficient.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_PowerCoefficient %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_PowerCoefficient" runat="server" CssClass="form-control MumberType" required="required" Text="0" data-MumberTypeDecimals="2"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_EstimateCurrent.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_EstimateCurrent %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_EstimateCurrent" runat="server" CssClass="form-control MumberType" required="required" Text="0" data-MumberTypeDecimals="2"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsCheckPreviousMOFinish.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsCheckPreviousMOFinish%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsCheckPreviousMOFinish" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsCheckProductionInspection.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsCheckProductionInspection%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsCheckProductionInspection" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsCheckSequenceDeclare.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsCheckSequenceDeclare%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsCheckSequenceDeclare" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_SectionID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_SectionName%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_SectionID" runat="server" CssClass="form-control" required="required">
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_SortID.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_SortID %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_SortID" runat="server" CssClass="form-control MumberType" required="required" Text="0" data-MumberTypeDecimals="1"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsSuspension%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsSuspension%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsSuspension" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 text-center">
        <asp:Button ID="BT_Add" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_SaveName%>" OnClick="BT_Add_Click" />
        <asp:Button ID="BT_Delete" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName%>" OnClick="BT_Delete_Click" />
    </div>
</asp:Content>


