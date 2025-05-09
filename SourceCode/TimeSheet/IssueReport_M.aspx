<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="IssueReport_M.aspx.cs" Inherits="TimeSheet_IssueReport_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsRefresh" runat="server" ClientIDMode="Static" Value="0" />
    <asp:HiddenField ID="HF_CreateDate" runat="server" />
    <asp:HiddenField ID="HF_DeviceID" runat="server" />
    <asp:HiddenField ID="HF_Operator" runat="server" />
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
            <div class="panel-body">
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_TS_Machine%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= DDL_WorkShift.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_TS_WorkShift%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_WorkShift" runat="server" CssClass="form-control" required="required" Enabled="false">
                    </asp:DropDownList>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_IssueDate.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_IssueDate %>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_IssueDate" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearDate" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= DDL_Category.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_Category%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_Category" runat="server" CssClass="form-control selectpicker" required="required" OnSelectedIndexChanged="DDL_Category_SelectedIndexChanged" AutoPostBack="true">
                    </asp:DropDownList>
                </div>
                <div class="col-xs-8 form-group required">
                    <label for="<%= DDL_Issue.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_Issue%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_Issue" runat="server" CssClass="form-control selectpicker" data-live-search="true" required="required">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_UsageMinutes.ClientID%>" class="control-label ">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_UsageMinutes%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_UsageMinutes" runat="server" CssClass="form-control MumberType" required="required" data-MumberTypeLimitMaxValue="15" data-MumberTypeLimitMinValue="1" data-toggle="tooltip" data-html="true" title="15(Max)，1(Min)"></asp:TextBox>
                </div>
                <div class="col-xs-12 form-group">
                    <label for="<%= TB_Remark.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_Remark %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_Remark" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="5"></asp:TextBox>
                </div>
                <div class="col-xs-12 form-group text-center">
                    <asp:Button ID="BT_Save" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName%>" CssClass="btn btn-warning" OnClick="BT_Save_Click" />
                    <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName%>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
