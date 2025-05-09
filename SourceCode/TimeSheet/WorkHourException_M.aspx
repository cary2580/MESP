<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="WorkHourException_M.aspx.cs" Inherits="TimeSheet_WorkHourException_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#<%=BT_Save.ClientID%>").click(function () {

                if (parseFloat($("#<%=TB_IIPHour.ClientID%>").val()) == 0 && parseFloat($("#<%=TB_SampleHour.ClientID%>").val()) == 0 && parseFloat($("#<%=TB_BorrowHour.ClientID%>").val()) == 0) {

                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return false;
                }
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsNewData" runat="server" />
    <asp:HiddenField ID="HF_SectionID" runat="server" />
    <div class="col-xs-6 form-group required">
        <label for="<%= TB_WorkDate.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_WorkDate%>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_WorkDate" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-6 form-group required">
        <label for="<%= DDL_SectionID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_SectionName%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_SectionID" runat="server" CssClass="form-control" required="required">
        </asp:DropDownList>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_IIPHour.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IIPHour %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_IIPHour" runat="server" CssClass="form-control MumberType" Text="0" data-MumberTypeDecimals="1"></asp:TextBox>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_SampleHour.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_SampleHour %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_SampleHour" runat="server" CssClass="form-control MumberType" Text="0" data-MumberTypeDecimals="1"></asp:TextBox>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_BorrowHour.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_BorrowHour %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_BorrowHour" runat="server" CssClass="form-control MumberType" Text="0" data-MumberTypeDecimals="1" data-MumberTypeLimitMinValue="-9999999"></asp:TextBox>
    </div>
    <div class="col-xs-12 form-group required">
        <label for="<%= TB_Remark.ClientID%>" class="control-label ">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Remark %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_Remark" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
    </div>
    <div class="col-xs-12 text-center">
        <asp:Button ID="BT_Save" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:Str_Button_SaveName%>" OnClick="BT_Save_Click" />
        <asp:Button ID="BT_Delete" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:Str_Button_DeleteName%>" OnClick="BT_Delete_Click" />
    </div>
</asp:Content>


