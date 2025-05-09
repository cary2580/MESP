<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="MOViewer.aspx.cs" Inherits="TimeSheet_MOViewer" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_AUFNR" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-3 form-group">
                <label for="<%= TB_AUFNR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_AUFNR%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_AUFNR" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_AUARTName.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_AUARTName%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_AUARTName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_StatusName.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_StatusName%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_StatusName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_PLNBEZ.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_PLNBEZ%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_PLNBEZ" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_KTEXT.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_KTEXT%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_KTEXT" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_DISPO.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_DISPO%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_DISPO" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_ERDAT.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_ERDAT%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ERDAT" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_FTRMI.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_FTRMI%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_FTRMI" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_GSTRP.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_GSTRP%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_GSTRP" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_GLTRP.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_GLTRP%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_GLTRP" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_VERID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_VERID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_VERID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_PLNNR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_PLNNR%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_PLNNR" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_PLNAL.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_PLNAL%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_PLNAL" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_ZEINR.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_ZEINR%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ZEINR" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_FERTH.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_FERTH%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_FERTH" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_PSMNG.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_PSMNG%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_PSMNG" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_WEMNG.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_WEMNG%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_WEMNG" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_ScrapQty.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_ScrapQty%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ScrapQty" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_CompletionRate.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_CompletionRate%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_CompletionRate" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= TB_NotGoInWEMNG.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_NotGoInWEMNG%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_NotGoInWEMNG" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
            </div>
            <div class="col-xs-3 form-group">
                <label for="<%= DDL_IsPreClose.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MOInfo_IsPreClose%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_IsPreClose" runat="server" CssClass="form-control" required="required" Enabled="false">
                    <asp:ListItem Text="<%$ Resources:ProjectGlobalRes,Str_TS_IsPreClose_False%>" Value="0" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:ProjectGlobalRes,Str_TS_IsPreClose_True%>" Value="1"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-xs-12 text-center">
                <asp:Button ID="BT_Save" runat="server" CssClass="btn btn-success" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName%>" OnClick="BT_Save_Click" />
            </div>
        </div>
    </div>
</asp:Content>
