<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="PalletConfirm.aspx.cs" Inherits="WM_PalletConfirm" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $.Main.Defaults.AlertMessage.width = 300;
            $.Main.Defaults.ConfirmMessage.width = 300;

            $("#<%=TB_PalletNo.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        if (data.A7 == null)
                        {
                            $("#<%=TB_PalletNo.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=GetGlobalResourceObject("ProjectGlobalRes","Str_WM_Empty_PalletNo")%>" });

                            return;
                        }

                        $("#<%=TB_PalletNo.ClientID%>").val(data.A7);

                        if ($("#<%=TB_PalletNo.ClientID%>").val() != "" && $("#<%=TB_BoxNo.ClientID%>").val() != "")
                            $("#<%=BT_Confirm.ClientID%>").trigger("click");
                        else
                            $("#<%=TB_BoxNo.ClientID%>").focus();
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_PalletNo.ClientID%>").val("");
                    }
                });

            }).focus();

            $("#<%=TB_BoxNo.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() != "" && $("#<%=TB_PalletNo.ClientID%>").val() != "")
                    $("#<%=BT_Confirm.ClientID%>").trigger("click");
                else
                    $("#<%=TB_PalletNo.ClientID%>").focus();
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
        <div class="panel-body">
            <div class="row">
                <div class="col-xs-12 form-group">
                    <asp:Button ID="BT_Confirm" runat="server" CssClass="btn btn-primary btn-sm" Text="<%$ Resources:GlobalRes,Str_BT_ConfirmName%>" UseSubmitBehavior="false" OnClick="BT_Confirm_Click" />
                </div>
                <div class="col-xs-12 form-group required">
                    <label for="<%= TB_PalletNo.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PalletNo%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_PalletNo" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_WM_ScanPalletNo %>" required="required"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearText" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-xs-12 form-group required">
                    <label for="<%= TB_BoxNo.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_BoxNo %>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_BoxNo" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_WM_ScanBoxNo %>" required="required"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearText" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>


