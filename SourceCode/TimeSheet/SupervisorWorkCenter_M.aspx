<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="SupervisorWorkCenter_M.aspx.cs" Inherits="TimeSheet_SupervisorWorkCenter_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#<%=BT_Save.ClientID%>").click(function ()
            {
                var SelectedValue = $("#<%=DDL_WorkCenter.ClientID%>").val();
               
                $("#<%=HF_WorkCenterSelected.ClientID%>").val(SelectedValue);
            })
        });
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsNewData" runat="server" />
    <asp:HiddenField ID="HF_WorkCenterSelected" runat="server"/>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_ReportDate.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDate %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_ReportDate" runat="server" CssClass="form-control MonthsDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCode%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
    </div>
    <div class="col-xs-6 form-group required">
        <label for="<%= DDL_WorkCenter.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCenter%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_WorkCenter" runat="server" CssClass="form-control selectpicker" data-live-search="true" data-actions-box="true"  data-selected-text-format="count > 2" multiple="multiple" required="required">
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 form-group text-center">
        <asp:Button ID="BT_Save" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_AddName %>" OnClick="BT_Save_Click"/>
        <asp:Button ID="BT_Delete" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" OnClick="BT_Delete_Click"/>
    </div>
</asp:Content>

