<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="MOCreate.aspx.cs" Inherits="TimeSheet_MOCreate" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#<%=TB_GSTRP.ClientID%>").change(function () {

                if ($(this).val() == "")
                    return;

                $("#<%=TB_GLTRP.ClientID%>").val(dayjs($(this).val(), "L").add(7, "day").format("L"));
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
        <div class="panel-body">
            <div class="row">
                <div class="col-xs-4 form-group required">
                    <label for="<%= DDL_ProductionVersion.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ProductionVersion %>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_ProductionVersion" runat="server" class="form-control selectpicker" required="required">
                    </asp:DropDownList>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= DDL_AUART.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_AUART %>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_AUART" runat="server" class="form-control selectpicker" required="required">
                        <asp:ListItem Text="Regular" Value="ZM20" Selected="True"></asp:ListItem>
                        <asp:ListItem Text="Sample" Value="ZP20"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_PSMNG.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_PSMNG%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PSMNG" runat="server" CssClass="form-control MumberType" required="required" Text="4774"></asp:TextBox>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-4 form-group required">
                    <label for="<%=TB_GSTRP.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_GSTRP %>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_GSTRP" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearDate" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%=TB_GLTRP.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_GLTRP %>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_GLTRP" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearDate" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-4 form-group required">
                    <label for="<%=TB_ERDAT.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ERDAT %>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_ERDAT" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearDate" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%=TB_FTRMI.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_FTRMI %>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_FTRMI" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearDate" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-12 form-group required">
                    <label for="<%=TB_BATCH.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_BATCH %>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_BATCH" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>
            </div>
            <div class="col-xs-12 text-center">
                <asp:Button ID="BT_Save" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:GlobalRes,Str_BT_CreateName %>" OnClick="BT_Save_Click" />
            </div>
        </div>
    </div>
</asp:Content>
