<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="WorkStationSelect.aspx.cs" Inherits="TimeSheet_WorkStationSelect" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#BT_GoDashboard").click(function () {
                var AreaID = $("#<%=DDL_Area.ClientID%>").find(":selected").val();

                var ResponsibleListID = $("#<%=DDL_Responsible.ClientID%>").selectpicker("val");

                if (AreaID == "") {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Empty_AreaID")%>" });

                    return;
                }

                $.WindowOpen("Post", "<%=ResolveClientUrl(@"~/TimeSheet/WorkStationStatus.aspx?AreaID=")%>" + AreaID + "&ResponsibleID=" + ResponsibleListID.join("|") + "&SortMethod=" + $("#<%=DDL_SortMethod.ClientID%>").selectpicker("val") + "&SortType=" + $("#<%=DDL_SortType.ClientID%>").selectpicker("val") + "&IsViewShortTemplet=" + $("#<%=DDK_IsViewShortTemplet.ClientID%>").selectpicker("val"));
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_AreaTitle%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-6 form-group required">
                <label for="<%= DDL_Area.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_Area %>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_Area" runat="server" CssClass="form-control selectpicker" required="required">
                </asp:DropDownList>
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%= DDL_Responsible.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_Responsible %>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_Responsible" runat="server" CssClass="form-control selectpicker show-tick" multiple>
                </asp:DropDownList>
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%= DDL_SortMethod.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SortMethod %>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_SortMethod" runat="server" CssClass="form-control selectpicker">
                    <asp:ListItem Text="<%$ Resources: Str_SortMethod0 %>" Value="0" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources: Str_SortMethod1 %>" Value="1"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%= DDL_SortType.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_SortType %>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_SortType" runat="server" CssClass="form-control selectpicker">
                    <asp:ListItem Text="<%$ Resources: Str_SortType0 %>" Value="0" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources: Str_SortType1 %>" Value="1"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%= DDK_IsViewShortTemplet.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_IsViewShortTemplet %>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDK_IsViewShortTemplet" runat="server" CssClass="form-control selectpicker">
                    <asp:ListItem Text="<%$ Resources: GlobalRes,Str_Yes %>" Value="1" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources: GlobalRes,Str_No %>" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-xs-12 form-group">
                <input id="BT_GoDashboard" type="button" class="btn btn-primary" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ConfirmName") %>" />
            </div>
        </div>
    </div>
</asp:Content>
