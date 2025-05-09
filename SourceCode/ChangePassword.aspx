<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="ChangePassword.aspx.cs" Inherits="ChangePassword" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        function CheckConfirmPassword() {
            var Result = true;

            if ($("#<%=TB_Password.ClientID%>").val() != $("#<%=TB_PasswordConfirm.ClientID%>").val()) {
                $.AlertMessage({ Message: "<%= (string)GetLocalResourceObject("Str_PasswordIncorrectAlertMessage") %>" });
                Result = false;
            }
            return Result;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="row">
        <div class="col-md-4 col-md-offset-4">
            <div style="margin-top: 40%; text-align: center; letter-spacing: 2px;"></div>
            <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                <div class="text-center panel-heading">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_PanelTitleName %>"></asp:Literal>
                </div>
                <div class="panel-body">
                    <div class="col-xs-12 form-group required">
                        <label for="<%= TB_Password.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_PasswordName %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_Password" runat="server" CssClass="form-control" TextMode="Password" required="required"></asp:TextBox>
                    </div>
                    <div class="col-xs-12 form-group required">
                        <label for="<%= TB_PasswordConfirm.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_PasswordConfirmName %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PasswordConfirm" runat="server" CssClass="form-control" TextMode="Password" required="required"></asp:TextBox>
                    </div>
                    <div class="col-xs-12 form-group text-center">
                        <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:Str_BT_SubmitName %>" CssClass="btn btn-success" OnClick="BT_CreateUser_Click" OnClientClick="return CheckConfirmPassword();" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

