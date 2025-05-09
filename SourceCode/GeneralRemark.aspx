<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="GeneralRemark.aspx.cs" Inherits="GeneralRemark" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        $(function () {
            if ($.StringConvertBoolean($("#<%=HF_IsRequired.ClientID%>").val()))
                $("#<%=TB_Remark.ClientID%>").closest("div").addClass("required");

            $("#BT_Confirm").click(function () {

                if ($.StringConvertBoolean($("#<%=HF_IsRequired.ClientID%>").val()) && $("#<%=TB_Remark.ClientID%>").val() == "") {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage") %>" });

                    event.preventDefault();

                    return;
                }

                event.preventDefault();

                parent.$("#" + $("#<%=HF_DivID.ClientID%>").val()).dialog("close");
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DivID" runat="server" />
    <asp:HiddenField ID="HF_IsRequired" runat="server" Value="1" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-body">
            <div class="col-xs-12 form-group ">
                <input type="button" class="btn btn-primary" id="BT_Confirm" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ConfirmName") %>" />
            </div>
            <div class="col-xs-12 form-group">
                <label for="<%= TB_Remark.ClientID%>" class="control-label">
                    <asp:Literal ID="L_Remark" runat="server"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_Remark" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="20" ClientIDMode="Static"></asp:TextBox>
            </div>
        </div>
    </div>
</asp:Content>
