<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="RPT_036.aspx.cs" Inherits="TimeSheet_RPT_036" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_SearchConditions %>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-3 form-group required">
                <label for="<%=TB_ReportDateMonth.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDateMonth %>"></asp:Literal>
                </label>
                <div class="input-group">
                    <asp:TextBox ID="TB_ReportDateMonth" runat="server" CssClass="form-control MonthsDatepicker readonly" required="required"></asp:TextBox>
                    <span class="input-group-btn" title="Clear">
                        <button class="btn btn-default ClearDate" type="button">
                            <i class="fa fa-times"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div class="col-xs-12 form-group text-center">
                <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_BT_SearchName %>" OnClick="BT_Search_Click" />
            </div>
        </div>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-body">
            <div class="col-xs-4 form-group">
                <label for="<%=TB_ResultValue1ByFiltered.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ResultValue1ByFiltered %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ResultValue1ByFiltered" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group">
                <label for="<%=TB_ResultValue1ByTotal.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ResultValue1ByTotal %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ResultValue1ByTotal" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group">
                <label for="<%=TB_ResultValue1.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ResultValue1 %>"></asp:Literal>
                </label>
                <div class="form-group input-group">
                    <asp:TextBox ID="TB_ResultValue1" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    <span class="input-group-addon">%</span>
                </div>
            </div>
            <div class="col-xs-4 form-group">
                <label for="<%=TB_ResultValue2ByFiltered.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ResultValue2ByFiltered %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ResultValue2ByFiltered" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group">
                <label for="<%=TB_ResultValue2ByTotal.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ResultValue2ByTotal %>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ResultValue2ByTotal" runat="server" CssClass="form-control readonly"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group">
                <label for="<%=TB_ResultValue2.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ResultValue2 %>"></asp:Literal>
                </label>
                <div class="form-group input-group">
                    <asp:TextBox ID="TB_ResultValue2" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    <span class="input-group-addon">%</span>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
