<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="UserManage.aspx.cs" Inherits="UserManage" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=BT_UpdateUser.ClientID%>,#<%=BT_CancelUser.ClientID%>").hide();

            $(".Clear").click(function ()
            {
                if ($(this).hasClass("SelectAccountDisabled"))
                    return;
                $(this).closest("div").find("textarea,input").val("");
            });
        });

        function CheckPageIsValid()
        {
            var Result = true;

            if ($("#<%=HF_UserAccountID.ClientID%>").val() == "" || $("#<%=TB_Password.ClientID%>").val() == "" || $("#<%=TB_Module.ClientID%>").val() == "")
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage") %>" });
                Result = false;
            }

            return Result;
        }

        function CheckDeleteIsValid()
        {
            var Result = true;

            var SelectCBKArrayID = new Array();

            var GridTable = $("#JQContainerListTable");

            var rowKey = GridTable.jqGrid("getGridParam", "selrow");

            if (!rowKey)
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });
                Result = false;
            }

            var ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

            $.each(GridTable.getGridParam("selarrrow"), function (i, item)
            {
                var UserID = "";

                if ($.grep(ColumnModel, function (Node) { return Node.name == JQGridDataValue.UserIDColumnName; }).length > 0)
                    UserID = GridTable.jqGrid("getCell", item, JQGridDataValue.UserIDColumnName);
                if (UserID != "")
                    SelectCBKArrayID.push(UserID);
            });

            $("#<%=HF_DeleteUser.ClientID%>").val(SelectCBKArrayID.join("|"));

            return Result;
        }

        function JqEventBind()
        {
            $("#JQContainerListTable").bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName)
                {
                    var UserIDValue = $(this).jqGrid('getCell', RowID, JQGridDataValue.UserIDColumnName);
                    var UserNameValue = $(this).jqGrid('getCell', RowID, JQGridDataValue.UserNnameColumnName);
                    var ModuleValue = $(this).jqGrid('getCell', RowID, JQGridDataValue.PermissionModuleColumnName);

                    if (UserIDValue == "" || UserNameValue == "")
                        return;

                    $("#<%=TB_UserAccount.ClientID%>").val(UserNameValue);

                    $("#<%=HF_UserAccountID.ClientID%>").val(UserIDValue);

                    $("#<%=TB_Module.ClientID%>").val(ModuleValue);

                    $("#<%=BT_UpdateUser.ClientID%>,#<%=BT_CancelUser.ClientID%>").show();

                    $("#<%=BT_CreateUser.ClientID%>,#<%=BT_DeleteUser.ClientID%>").hide();

                    $(".SelectAccount,.Clear").addClass("SelectAccountDisabled");
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DeleteUser" runat="server" />
    <div class="col-xs-12">
        <div class="panel-group">
            <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                <div class="text-center panel-heading">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ConditionhPanelTitleName %>"></asp:Literal>
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-6 form-group required">
                            <label for="<%= TB_UserAccount.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:Str_UserAccountName %>"></asp:Literal>
                            </label>
                            <div class="input-group">
                                <asp:TextBox ID="TB_UserAccount" runat="server" CssClass="form-control readonly SelectAccount ShowSearchArea" role="button"></asp:TextBox>
                                <input id="HF_UserAccountID" type="hidden" runat="server" class="AccountID" />
                                <span class="input-group-btn SelectAccount ShowSearchArea">
                                    <button class="btn btn-default" type="button">
                                        <i class="fa fa-sitemap"></i>
                                    </button>
                                </span>
                                <span class="input-group-btn" title="Clear">
                                    <button class="btn btn-default Clear" type="button">
                                        <i class="fa fa-times"></i>
                                    </button>
                                </span>
                            </div>
                        </div>
                        <div class="col-xs-6 form-group required">
                            <label for="<%= TB_Password.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:Str_PasswordName %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_Password" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 form-group required">
                            <label for="<%= TB_Module.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:Str_Module %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_Module" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-12 form-group text-center">
                            <asp:Button ID="BT_CreateUser" runat="server" Text="<%$ Resources:Str_BT_CreateUserName %>" CssClass="btn btn-primary" OnClick="BT_CreateUser_ServerClick" OnClientClick="return CheckPageIsValid();" />
                            <asp:Button ID="BT_DeleteUser" runat="server" Text="<%$ Resources:Str_BT_DeleteUserName %>" CssClass="btn btn-danger" OnClick="BT_DeleteUser_ServerClick" OnClientClick="return CheckDeleteIsValid();" />
                            <asp:Button ID="BT_UpdateUser" runat="server" Text="<%$ Resources:Str_BT_UpdateUserName %>" CssClass="btn btn-success" OnClick="BT_UpdateUser_ServerClick" />
                            <asp:Button ID="BT_CancelUser" runat="server" Text="<%$ Resources:Str_BT_CancelUserName %>" CssClass="btn btn-warning" OnClick="BT_CancelUser_Click" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_JqgridTitleColor") %>">
                <div class="panel-heading text-center">
                    <asp:Literal runat="server" Text=" <%$ Resources:Str_UserListTitleName %>"></asp:Literal>
                </div>
                <div class="panel-body">
                    <div id="JQContainerList"></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
