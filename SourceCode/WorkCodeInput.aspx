<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="WorkCodeInput.aspx.cs" Inherits="WorkCodeInput" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            if ($.StringConvertBoolean($("#<%=HF_IsRequired.ClientID%>").val()))
                $("#<%=TB_WorkCode.ClientID%>").closest("div").addClass("required");

            $("#BT_Confirm").click(function ()
            {
                if ($.StringConvertBoolean($("#<%=HF_IsRequired.ClientID%>").val()) && $("#<%=TB_WorkCode.ClientID%>").val() == "")
                {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage") %>" });

                    event.preventDefault();

                    return;
                }

                event.preventDefault();

                parent.$("#" + $("#<%=HF_Div.ClientID%>").val()).dialog("close");

            });

            $("#<%=TB_WorkCode.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;
                else
                    $("#BT_Confirm").trigger("click");
            }).focus();
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsRequired" runat="server" Value="1" />
    <asp:HiddenField ID="HF_Div" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_Info%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-12 form-group">
                <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_Info_WorkCode%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" ClientIDMode="Static" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
            </div>
            <div class="col-xs-12 form-group text-center">
                <input type="button" class="btn btn-primary" id="BT_Confirm" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ConfirmName") %>" />
            </div>
        </div>
    </div>
</asp:Content>
