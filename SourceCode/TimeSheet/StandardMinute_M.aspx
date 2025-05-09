<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="StandardMinute_M.aspx.cs" Inherits="TimeSheet_StandardMinute_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=TB_ARBPL.ClientID%>").blur(function ()
            {
                if ($(this).val() == "")
                {
                    $("#<%=TB_KTEXT.ClientID%>").val("");

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/GetWorkCenterText.ashx")%>",
                    data: { ARBPL: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        $("#<%=TB_KTEXT.ClientID%>").val(data.KTEXT);
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_ARBPL.ClientID%>,#<%=TB_KTEXT.ClientID%>").val("");
                    }
                });
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_ARBPL" runat="server" />
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_ARBPL.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ARBPL%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_ARBPL" runat="server" CssClass="form-control" required="required"></asp:TextBox>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsResultMinute.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsResultMinute%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsResultMinute" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-4 form-group required">
        <label for="<%= DDL_IsResultMinuteForPersonnel.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsResultMinuteForPersonnel%>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsResultMinuteForPersonnel" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-12 form-group">
        <label for="<%= TB_KTEXT.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_KTEXT%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_KTEXT" runat="server" CssClass="form-control readonly readonlyColor" TextMode="MultiLine" Rows="3"></asp:TextBox>
    </div>
    <div class="col-xs-12 text-center">
        <asp:Button ID="BT_Submit" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName%>" OnClick="BT_Submit_Click" />
        <asp:Button ID="BT_Delete" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName%>" OnClick="BT_Delete_Click" />
    </div>
</asp:Content>
