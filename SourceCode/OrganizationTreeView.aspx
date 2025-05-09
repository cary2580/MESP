<%@ Page Language="C#" AutoEventWireup="true" CodeFile="OrganizationTreeView.aspx.cs" Inherits="OrganizationTreeView" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <meta http-equiv="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <meta http-equiv="Cache-Control" content="no-cache" />

    <link href="<%=ResolveClientUrl(@"~/Content/bootstrap.min.css") %>" rel="stylesheet" />
    <link href="<%=ResolveClientUrl(@"~/Content/themes/base/jquery-ui.min.css") %>" rel="stylesheet" />
    <link href="<%=ResolveClientUrl(@"~/vendor/bootstrap-social/bootstrap-social.css") %>" rel="stylesheet" />
    <link href="<%=ResolveClientUrl(@"~/vendor/font-awesome/css/font-awesome.min.css") %>" rel="stylesheet" />
    <link href="<%=ResolveClientUrl(@"~/vendor/dynatree/skin-vista/ui.dynatree.css") %>" rel="stylesheet" />
    <link href="<%=ResolveClientUrl(@"~/Content/Main.css") %>" rel="stylesheet" />

    <script type="text/javascript" src="<%=ResolveClientUrl(@"~/Scripts/jquery-3.6.3.min.js") %>"></script>
    <script type="text/javascript" src="<%=ResolveClientUrl(@"~/Scripts/jquery-ui-1.13.2.min.js") %>"></script>
    <script type="text/javascript" src="<%=ResolveClientUrl(@"~/Scripts/bootstrap.min.js") %>"></script>
    <script type="text/javascript" src="<%=ResolveClientUrl(@"~/Scripts/jquery.cookie.js") %>"></script>
    <script type="text/javascript" src="<%=ResolveClientUrl(@"~/Scripts/jquery.timers.js") %>"></script>
    <script type="text/javascript" src="<%=ResolveClientUrl(@"~/vendor/dynatree/jquery.dynatree.js") %>"></script>
    <script type="text/javascript" src="<%=ResolveClientUrl(@"~/Scripts/Main.js") %>"></script>

    <title></title>
    <style>
        .ui-widget-overlay {
            background: none;
        }

        table {
            border: 1px solid #8e846b;
            border-collapse: collapse;
            border-spacing: 0px;
            border-color: #8e846b;
            width: 100%;
            word-wrap: break-word;
            word-break: break-all;
        }

            table td {
                border: 1px solid #8e846b;
                border-spacing: 0px;
                border-color: #8e846b;
                padding: 3px 3px;
                text-align: left;
            }
    </style>
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=BT_Post.ClientID%>").hide();

            $("#<%=RBL_Canceled.ClientID %> input").change(function ()
            {
                $("#<%=BT_Post.ClientID%>").trigger("click");
            });

            $("#OrganizationTree").dynatree({
                noLink: true,
                checkbox: true,
                classNames: SelectMode == 1 ? { checkbox: "dynatree-radio" } : {},
                selectMode: SelectMode,
                children: OrgJson,
                minExpandLevel: minExpandLevel,
                onCreate: function (event, data)
                {
                    if (!event.data.IsCompany && !event.data.IsDept)
                        $(data).attr("title", event.data.Code);
                },
                onPostInit: function (event, data)
                {
                    SetSelectedNodes(this.getSelectedNodes());

                    $.map(this.getSelectedNodes(), function (node)
                    {
                        node.makeVisible();
                    });
                },
                onSelect: function (event, data)
                {
                    if (!data.data.IsCompany && !data.data.IsDept && SelectMode > 1)
                    {
                        $.each(getNodesByKey(data.tree, data.data.IsCompany, data.data.IsDept, data.data.key), function (i, Node)
                        {
                            Node.select(event);
                        });
                    }
                    SetSelectedNodes(data.tree.getSelectedNodes());
                }
            });

            if ($.StringConvertBoolean(IsShowSelectText))
                $("#SelectResultArea,#SelectNodeDeptID,#SelectNodeDeptCode,#SelectNodeDeptName,#SelectNodesCompanyID,#SelectNodesCompanyName,#SelectNodeDeptFullName,#SelectNodeAccountFullName,#SelectNodeAccountID,#SelectNodeAccountWorkCode,#SelectNodeAccountName").show();

            if ($.StringConvertBoolean(IsShowSearchArea))
            {
                var Table = $("#SearchTable");

                Table.children("tbody").children("tr").children("td:first-child").css({ background: DefaultBackgroundColor, width: "25%", "text-align": "right" });

                Table.find("tfoot > tr > td ").css({ "text-align": "center" });

                Table.find("#BT_Search").unbind("click").click(function (e)
                {

                    var SearchAccountName = Table.find("#<%= TB_SearchAccountName.ClientID%>").val();
                    var SearchDeptName = Table.find("#<%= TB_SearchDeptName.ClientID%>").val();

                    var SearchAccountWorkCode = Table.find("#<%= TB_SearchAccountWorkCode.ClientID%>").val();
                    var SearchDeptCode = Table.find("#<%= TB_SearchDeptCode.ClientID%>").val();

                    if ($.trim(SearchAccountName) == "" && $.trim(SearchDeptName) == "" && $.trim(SearchAccountWorkCode) == "" && $.trim(SearchDeptCode) == "")
                        return;

                    var tree = $("#OrganizationTree").dynatree("getTree");

                    if ($.trim(SearchAccountWorkCode) != "")
                    {
                        $.each(getNodesByCode(tree, false, false, SearchAccountWorkCode), function (i, Node)
                        {
                            Node.makeVisible();
                            Node.select(true);
                        });
                    }

                    if ($.trim(SearchDeptCode) != "")
                    {
                        $.each(getNodesByKey(tree, false, true, SearchDeptCode), function (i, Node)
                        {
                            Node.makeVisible();
                            Node.select(true);
                        });
                    }

                    if ($.trim(SearchAccountName) != "")
                    {

                        var AccountNames = SearchAccountName.split("、");

                        $.each(AccountNames, function (i, AccountName)
                        {
                            $.each(getNodesByTitle(tree, AccountName, false), function (i, Node)
                            {
                                Node.makeVisible();
                                Node.select(true);
                            });
                        });
                    }

                    if ($.trim(SearchDeptName) != "")
                    {

                        var DeptNames = SearchDeptName.split("、");

                        $.each(DeptNames, function (i, DeptName)
                        {
                            $.each(getNodesByTitle(tree, DeptName, true), function (i, Node)
                            {
                                Node.makeVisible();
                                Node.select(true);
                            });
                        });
                    }
                });

                $("#SearchArea").show();
            }
            else
                $("#SearchArea").remove();

            if (!$.StringConvertBoolean(IsShowDeptCanceledArea))
                $("#DeptCanceledArea").remove();
            else
                $("#DeptCanceledArea").show();

            if (!$.StringConvertBoolean(IsShowSpecialdArea))
                $("#SpecialdArea").remove();
            else
            {
                $("#SpecialdArea").show();

                $("#BT_SelectAllBU").unbind("click").click(function (e)
                {
                    var tree = $("#OrganizationTree").dynatree("getTree");

                    $.each(ALLBUDeptID, function (i, BUDeptID)
                    {
                        $.each(getNodesByKey(tree, false, true, BUDeptID.toString()), function (i, Node)
                        {
                            Node.makeVisible();
                            Node.select(true);
                        });
                    });
                });
            }
        });

        function SetSelectedNodes(SelectedNodes)
        {
            SelectNodesDeptIDArray = new Array();
            SelectNodesDeptCodeArray = new Array();
            SelectNodesDeptNameeArray = new Array();
            SelectNodesCompanyIDArray = new Array();
            SelectNodesCompanyNameArray = new Array();
            SelectNodesDeptFullNameArray = new Array();
            SelectNodesAccountFullNameArray = new Array();
            SelectNodeAccountIDArray = new Array();
            SelectNodeAccountWorkCodeArray = new Array();
            SelectNodeAccountNameArray = new Array();

            $.each(SelectedNodes, function (i, Node)
            {

                var SelectNodeDeptID = "";
                var SelectNodeDeptCode = "";
                var SelectNodeDeptName = "";
                var SelectNodeDeptFullName = "";
                var SelectNodeAccountID = "";
                var SelectNodeAccountWorkCode = "";
                var SelectNodeAccountName = "";
                var SelectNodeAccountFullName = "";

                if (Node.data.IsDept)
                {
                    SelectNodeDeptID = Node.data.key.toString();
                    SelectNodeDeptCode = Node.data.Code;
                    SelectNodeDeptName = Node.data.title;
                    SelectNodeDeptFullName = Node.data.FullName;
                }
                else
                {
                    SelectNodeAccountID = Node.data.key.toString();
                    SelectNodeAccountWorkCode = Node.data.Code;
                    SelectNodeAccountName = Node.data.title;

                    if (Node.parent.isSelected())
                    {
                        SelectNodeDeptID = Node.data.ParentKey.toString();
                        SelectNodeDeptCode = Node.data.ParentCode;
                        SelectNodeDeptName = Node.data.ParentName;
                    }

                    SelectNodeAccountFullName = Node.data.FullName;
                }

                if ($.inArray(Node.data.CompanyID, SelectNodesCompanyIDArray) < 0)
                    SelectNodesCompanyIDArray.push(Node.data.CompanyID);

                if ($.inArray(Node.data.CompanyName, SelectNodesCompanyNameArray) < 0)
                    SelectNodesCompanyNameArray.push(Node.data.CompanyName);

                if (SelectNodeDeptID != "")
                {
                    if ($.inArray(SelectNodeDeptID, SelectNodesDeptIDArray) < 0)
                        SelectNodesDeptIDArray.push(SelectNodeDeptID);

                    if (SelectNodeDeptCode != "")
                        SelectNodesDeptCodeArray.push(SelectNodeDeptCode);

                    if (SelectNodeDeptName != "")
                        SelectNodesDeptNameeArray.push(SelectNodeDeptName);

                    if (SelectNodeDeptFullName != "")
                        SelectNodesDeptFullNameArray.push(SelectNodeDeptFullName);
                    else
                        SelectNodesAccountFullNameArray.push(SelectNodeAccountFullName);
                }

                if (SelectNodeAccountID != "")
                {

                    if ($.inArray(SelectNodeAccountID, SelectNodeAccountIDArray) < 0)
                        SelectNodeAccountIDArray.push(SelectNodeAccountID);

                    if (SelectNodeAccountWorkCode != "")
                        SelectNodeAccountWorkCodeArray.push(SelectNodeAccountWorkCode);

                    if (SelectNodeAccountName != "")
                        SelectNodeAccountNameArray.push(SelectNodeAccountName);
                }
            });

            var DefaultSelectedSplitSymbol = $("#<%= HF_DefaultSelectedSplitSymbol.ClientID%>").val();

            $("#SelectNodeDeptID").val(SelectNodesDeptIDArray.join(DefaultSelectedSplitSymbol));
            $("#SelectNodeDeptCode").val(SelectNodesDeptCodeArray.join(DefaultSelectedSplitSymbol));
            $("#SelectNodeDeptName").val(SelectNodesDeptNameeArray.join(DefaultSelectedSplitSymbol));
            $("#SelectNodesCompanyID").val(SelectNodesCompanyIDArray.join(DefaultSelectedSplitSymbol));
            $("#SelectNodesCompanyName").val(SelectNodesCompanyNameArray.join(DefaultSelectedSplitSymbol));
            $("#SelectNodeDeptFullName").val(SelectNodesDeptFullNameArray.join(DefaultSelectedSplitSymbol));
            $("#SelectNodeAccountFullName").val(SelectNodesAccountFullNameArray.join(DefaultSelectedSplitSymbol));
            $("#SelectNodeAccountID").val(SelectNodeAccountIDArray.join(DefaultSelectedSplitSymbol));
            $("#SelectNodeAccountWorkCode").val(SelectNodeAccountWorkCodeArray.join(DefaultSelectedSplitSymbol));
            $("#SelectNodeAccountName").val(SelectNodeAccountNameArray.join(DefaultSelectedSplitSymbol));
        }

        function getNodesByKey(tree, IsCompany, IsDept, key)
        {
            var match = new Array();

            tree.visit(function (node)
            {
                //找員工
                if (!node.data.hideCheckbox && node.data.key != null && (!IsCompany && !IsDept) && (!node.data.IsCompany && !node.data.IsDept && node.data.key.toLowerCase() == key.toLowerCase()))
                    match.push(node);
                //找部門
                else if (!node.data.hideCheckbox && node.data.key != null && (!IsCompany && IsDept) && (!node.data.IsCompany && node.data.IsDept && node.data.key.toLowerCase() == key.toLowerCase()))
                    match.push(node);
                //找公司
                else if (!node.data.hideCheckbox && node.data.key != null && (IsCompany && IsDept) && (node.data.IsCompany && node.data.IsDept && node.data.key.toLowerCase() == key.toLowerCase()))
                    match.push(node);
            }, true);
            return match;
        }

        function getNodesByCode(tree, IsCompany, IsDept, Code)
        {
            var match = new Array();

            tree.visit(function (node)
            {
                if (node.data.Code != null)
                {
                    //找員工
                    if (!node.data.hideCheckbox && node.data.key != null && (!IsCompany && !IsDept) && (!node.data.IsCompany && !node.data.IsDept && node.data.Code.toLowerCase() == Code.toLowerCase()))
                        match.push(node);
                    //找部門
                    else if (!node.data.hideCheckbox && node.data.key != null && (!IsCompany && IsDept) && (!node.data.IsCompany && node.data.IsDept && node.data.Code.toLowerCase() == Code.toLowerCase()))
                        match.push(node);
                    //找公司
                    else if (!node.data.hideCheckbox && node.data.key != null && (IsCompany && IsDept) && (node.data.IsCompany && node.data.IsDept && node.data.Code.toLowerCase() == Code.toLowerCase()))
                        match.push(node);
                }
            }, true);
            return match;
        }

        function getNodesByTitle(tree, Title, IsDept)
        {
            var match = new Array();

            tree.visit(function (node)
            {
                if (!node.data.hideCheckbox && node.data.IsDept == IsDept && node.data.title != null && node.data.title.toLowerCase().indexOf(Title.toLowerCase()) > -1)
                    match.push(node);
            }, true);
            return match;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="SearchArea" style="display: none;">
            <table id="SearchTable">
                <tbody>
                    <tr>
                        <td>
                            <asp:Literal runat="server" Text=" <%$ Resources:Str_SearchAccountName %>"></asp:Literal>
                        </td>
                        <td>
                            <asp:TextBox ID="TB_SearchAccountName" runat="server" Width="95%" CssClass="SearchValue" placeholder="<%$ Resources:Str_SearchPlaceholder %>"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Literal runat="server" Text=" <%$ Resources:Str_SearchDeptName %>"></asp:Literal>
                        </td>
                        <td>
                            <asp:TextBox ID="TB_SearchDeptName" runat="server" Width="95%" CssClass="SearchValue" placeholder="<%$ Resources:Str_SearchPlaceholder %>"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Literal runat="server" Text=" <%$ Resources:Str_SearchAccountWorkCode %>"></asp:Literal>
                        </td>
                        <td>
                            <asp:TextBox ID="TB_SearchAccountWorkCode" runat="server" Width="95%" CssClass="SearchValue"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Literal runat="server" Text=" <%$ Resources:Str_SearchDeptCode %>"></asp:Literal>
                        </td>
                        <td>
                            <asp:TextBox ID="TB_SearchDeptCode" runat="server" Width="95%" CssClass="SearchValue"></asp:TextBox>
                        </td>
                    </tr>
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="2">
                            <a id="BT_Search" class="btn btn-primary ">
                                <i class="fa fa-search fa-fw"></i>
                                <asp:Literal runat="server" Text=" <%$ Resources:Str_SearchButtonName %>"></asp:Literal></a>
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
        <div id="DeptCanceledArea" style="display: none;">
            <asp:Button ID="BT_Post" runat="server" OnClick="BT_Post_Click" />
            <asp:RadioButtonList ID="RBL_Canceled" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow">
                <asp:ListItem Text="<%$ Resources:Str_OnlyDisPlayEnableDept%>" Value="0" Selected="True"></asp:ListItem>
                <asp:ListItem Text="<%$ Resources:Str_DisPlayALLDept%>" Value="1"></asp:ListItem>
            </asp:RadioButtonList>
        </div>
        <div id="SpecialdArea" style="display: none;">
            <a id="BT_SelectAllBU" class="btn btn-success ">
                <i class="fa fa-search fa-fw"></i>
                <asp:Literal runat="server" Text=" <%$ Resources:Str_SelectAllBUButtonName %>"></asp:Literal></a>
        </div>
        <div id="OrganizationTree" style="width: 100%;">
        </div>
        <div id="SelectResultArea" style="width: 100%; display: none;">
            <input type="text" id="SelectNodeDeptID" style="display: none;" />
            <input type="text" id="SelectNodeDeptCode" style="display: none;" />
            <input type="text" id="SelectNodeDeptName" style="display: none;" />
            <input type="text" id="SelectNodesCompanyID" style="display: none;" />
            <input type="text" id="SelectNodesCompanyName" style="display: none;" />
            <input type="text" id="SelectNodeDeptFullName" style="display: none;" />
            <input type="text" id="SelectNodeAccountFullName" style="display: none;" />
            <input type="text" id="SelectNodeAccountID" style="display: none;" />
            <input type="text" id="SelectNodeAccountWorkCode" style="display: none;" />
            <input type="text" id="SelectNodeAccountName" style="display: none;" />
            <input type="hidden" id="HF_DefaultSelectedSplitSymbol" runat="server" />
        </div>
    </form>
</body>
</html>
