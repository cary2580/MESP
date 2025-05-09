<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Login" meta:resourcekey="PageResource" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="<%#ResolveClientUrl(@"~/Image/logo.png") %>" rel="shortcut icon" type="image/x-icon" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <meta http-equiv="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <meta http-equiv="Cache-Control" content="no-cache" />
    <title>
        <asp:Literal ID="Literal1" runat="server" Text="<%$ Resources:GlobalRes,Str_SystemName %>"></asp:Literal></title>
    <link href="<%#ResolveClientUrl(@"~/Content/bootstrap.min.css") %>" rel="stylesheet" />
    <link href="<%#ResolveClientUrl(@"~/vendor/metisMenu/metisMenu.min.css") %>" rel="stylesheet" />
    <link href="<%#ResolveClientUrl(@"~/Content/sb-admin-2.min.css") %>" rel="stylesheet" />
    <link href="<%#ResolveClientUrl(@"~/vendor/font-awesome/css/font-awesome.min.css") %>" rel="stylesheet" />
    <link href="<%#ResolveClientUrl(@"~/Content/themes/base/jquery-ui.min.css") %>" rel="stylesheet" />
    <link href="<%#ResolveClientUrl(@"~/Content/Main.css") %>" rel="stylesheet" />

    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/Scripts/jquery-3.6.3.min.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/Scripts/jquery-ui-1.13.2.min.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/Scripts/bootstrap.min.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/vendor/metisMenu/metisMenu.min.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/Scripts/sb-admin-2.min.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/Scripts/jquery.client.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/Scripts/jquery.cookie.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/Scripts/jquery.timers.js") %>"></script>
    <script type="text/javascript" src="<%#ResolveClientUrl(@"~/Scripts/Main.js") %>"></script>

    <!--[if lt IE 9]>
         <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
     <![endif]-->

    <script type="text/javascript">
        $(function () {
            if (($.client.browser == "Safari" && parseFloat($.client.version) < 5.1) || ($.client.browser == "Explorer" && parseFloat($.client.version) < 11) || ($.client.browser == "Mozilla" && parseFloat($.client.version) < 11) || ($.client.browser == "Chrome" && parseFloat($.client.version) < 37) || ($.client.browser == "Firefox" && parseFloat($.client.version) < 12)) {
                $("form").children().remove();
                $.AlertMessage({
                    TimeOut: 60000, Message: "<%= (string)GetLocalResourceObject("Str_Browser") %>", CloseEvent: function () {
                        window.close();
                    }
                });
            }

            if ($.cookie("Login_AccountID") != null && $.trim($.cookie("Login_AccountID")) != "") {
                $("#TB_Account").val($.cookie("Login_AccountID"));
                $("#remember").prop("checked", true)
            }

            $("#TB_Account").keyup(function () {
                $(this).val($(this).val().toUpperCase());
            }).focus();

            if ($("#DocumentID").val() != "")
                sessionStorage["DocumentID"] = $("#DocumentID").val();

            if ($("#ViewDocumentReject").val() != "" && $("#ViewDocumentReject").val() == "1")
                sessionStorage["ViewDocumentReject"] = $("#ViewDocumentReject").val();

            $("#form1").submit(function () {
                var Account = $("#TB_Account").val().trim();
                var PassWord = $("#TB_PassWord").val().trim();

                $.removeCookie("Guid", null, { path: "/" });
                $.removeCookie("AccountID", null, { path: "/" });

                var ExpiresDate = new Date();

                ExpiresDate.setDate(ExpiresDate.getDate() + 7);

                if ($("#remember").prop("checked"))
                    $.cookie("Login_AccountID", Account, { expires: ExpiresDate, path: "/" });
                else
                    $.removeCookie("Login_AccountID", { path: "/" });
            });

            if ($.StringConvertBoolean($("#TB_IsSingleSignOn").val())) {
                $("body").everyTime("1ms", "SetSingleSignOn", function () {
                    $(this).stopTime("SetSingleSignOn");
                    $("#form1").trigger("submit");
                });
            }
        });
    </script>
    <style>
        .login-panel {
            margin-top: 5%;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" method="post" action="Default.aspx">
        <div class="container">
            <div class="row">
                <div class="col-md-4 col-md-offset-4">
                    <div style="margin-top: 20%; text-align: center; letter-spacing: 2px;">
                        <img class="navbar-brand-logoimg" src="Image/logo.png" style="width: 358px; height: 95px;" />
                        <h1 class="display-1 text-center">
                            <asp:Literal ID="Literal2" runat="server" Text="<%$ Resources:GlobalRes,Str_SystemName %>"></asp:Literal>
                            <% if (BaseConfiguration.IsTestEnvironment)
                                { %>
                            <br />
                                Test Environment
                            <% } %>
                        </h1>
                    </div>
                    <div class="login-panel panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title">Please Sign In</h3>
                        </div>
                        <div class="panel-body">
                            <fieldset>
                                <div class="form-group">
                                    <asp:TextBox ID="TB_Account" runat="server" CssClass="form-control" placeholder="<%$ Resources:TB_Account.Placeholder %>" name="TB_Account" autofocus="true" required="required"></asp:TextBox>
                                </div>
                                <div class="form-group">
                                    <asp:TextBox ID="TB_PassWord" runat="server" CssClass="form-control" placeholder="<%$ Resources:TB_PassWord.Placeholder %>" TextMode="Password" name="TB_PassWord"></asp:TextBox>
                                </div>
                                <div class="checkbox">
                                    <label>
                                        <input id="remember" name="remember" type="checkbox" value="Remember Me" />Remember Me
                                    </label>
                                    <label>
                                        Language
                                          <asp:DropDownList ID="SL_Language" runat="server">
                                              <asp:ListItem Text="English" Value="en-US"></asp:ListItem>
                                              <asp:ListItem Text="Polish" Value="pl"></asp:ListItem>
                                              <asp:ListItem Text="繁體中文" Value="zh-TW"></asp:ListItem>
                                              <asp:ListItem Text="簡體中文" Value="zh-CN"></asp:ListItem>
                                          </asp:DropDownList>
                                    </label>
                                </div>
                                <div class="select">
                                </div>
                                <!-- Change this to a button or input when using this as a form -->
                                <input type="submit" value="Login" class="btn btn-lg btn-primary btn-block" />
                            </fieldset>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <input type="hidden" value="False" runat="server" id="TB_IsSingleSignOn" />
    </form>
</body>
</html>
