<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="BaseRouting_M.aspx.cs" Inherits="TimeSheet_BaseRouting_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            if ($.StringConvertBoolean($("#<%= HF_IsModify.ClientID%>").val()))
                $("#DIV_IsInsertAfterProcessID").hide();

            $("#<%=DDL_IsInsertAfterProcessID.ClientID%>").change(function ()
            {
                if ($.StringConvertBoolean(this.value))
                    $("#<%=TB_ProcessID.ClientID%>").val(parseInt($("#<%=HF_ProcessID.ClientID%>").val() + 1));
                else
                    $("#<%=TB_ProcessID.ClientID%>").val($("#<%=HF_ProcessID.ClientID%>").val());
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
        <div class="panel-body">
            <asp:HiddenField ID="HF_CID" runat="server" />
            <asp:HiddenField ID="HF_PLNKN" runat="server" />
            <asp:HiddenField ID="HF_IsTSProcess" runat="server" />
            <asp:HiddenField ID="HF_IsModify" runat="server" />
            <asp:HiddenField ID="HF_ARBID" runat="server" />
            <asp:HiddenField ID="HF_ProcessID" runat="server" />
            <div class="row">
                <div class="col-xs-12 form-group ">
                    <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click" />
                    <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_PLNNR.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_PLNNR %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PLNNR" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_PLNAL.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_PLNAL %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PLNAL" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_VORNR.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_VORNR %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_VORNR" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_ProcessID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ProcessID %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ProcessID" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_ARBPL.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ARBPL %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ARBPL" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_ARBPL_KTEXT.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ARBPL_KTEXT %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ARBPL_KTEXT" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_VERAN.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_VERAN %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_VERAN" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_VERAN_KTEXT.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_VERAN_KTEXT %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_VERAN_KTEXT" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_KTEXT.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_KTEXT %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_KTEXT" runat="server" CssClass="form-control readonly readonlyColor" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_VGW01.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_VGW01 %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_VGW01" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_VGW02.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_VGW02 %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_VGW02" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_USR00.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_USR00 %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_USR00" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>
                <div id="DIV_IsInsertAfterProcessID" class="col-xs-3 form-group required">
                    <label for="<%= DDL_IsInsertAfterProcessID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_IsInsertAfterProcessID %>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsInsertAfterProcessID" runat="server" CssClass="form-control">
                        <asp:ListItem Value="1" Text="<%$  Resources:GlobalRes,Str_Yes%>" Selected="True"></asp:ListItem>
                        <asp:ListItem Value="0" Text="<%$  Resources:GlobalRes,Str_No%>"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_LTXA1.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_LTXA1 %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_LTXA1" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
