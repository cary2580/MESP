$.extend({
    Main: {
        Defaults: {
            AjaxAlertMessage: {
                ResponseText: "Web Server 連線逾時",
                TitleBarText: "平台訊息",
                TitleBarImg: "Image/Alert.png",
                DefaultMessage: "Server 未預期錯誤，請洽平台管理員"
            },
            VerificationDataDefaults: {
                Message: "帳號認證失敗，請重新登入 !!",
                TitleBarText: "系統訊息",
                TitleBarImg: "Image/UserLock.png",
                HomeAddress: "login.aspx"
            },
            ShowLoading: {
                loaderImg: "Image/loader.gif",
                loader2Img: "Image/loader2.gif"
            },
            ConfirmMessage: {
                TitleBarText: "提示訊息",
                TitleBarImg: "Image/Alert_Info.png",
                CancelButtonsText: "取消",
                ConfirmButtonsText: "確認",
                width: 600
            },
            AlertMessage: {
                TitleBarText: "提示訊息",
                TitleBarImg: "Image/Alert_Info.png",
                ButtonsText: "關閉",
                TitlebarClosetTitlt: "取消",
                width: 600
            },
            OpenOrganizationTreeView: {
                TitleBarText: "選取部門或人員",
                TitleBarImg: "Image/view_tree.png",
                ButtonsText: "確認",
                CancelButtonsText: "取消",
                WebPath: "OrganizationTreeView.aspx"
            },
            OpenPage: {
                TitlebarTitle: "關閉",
                NewWindowPageDivID: "NewWindowPageDivID",
                NewWindowPageFrameID: "NewWindowPageFrameID"
            },
            DownloadFile: {
                TitleBarText: "檔案下載",
                TitleBarImg: "Image/Alert_Info.png",
                FailMessageText: "檔案下載失敗 !!",
                WaitTitleText: "請稍後檔案產生中...."
            }
        }
    }
});


$.extend({
    Ajax: function (AjaxOptions) {
        /// <summary>呼叫總部專案統一使用</summary>
        /// <param name="AjaxOptions" type="Object">url: 位置,data:傳遞參數,IsShowloading:是否要顯示loading(預設顯示),IsErrorShowAlert:如果Server引發錯誤,是否要顯示錯誤訊息(預設顯示),CallBackFunction:回呼函式,ErrorCallBackFunction:錯誤回呼函式</param>
        if (typeof AjaxOptions != "object")
            return;

        var Options = $.extend({
            url: "",
            type: "POST",
            dataType: "jsonp",
            async: true,
            cache: false,
            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
            data: new Object(),
            IsShowloading: true,
            IsErrorShowAlert: true,
            CallBackFunction: null,
            ErrorCallBackFunction: null,
            timeout: 60 * 1000,
            parentWindow: null,
            IsRecordLastActionTime: true
        }, AjaxOptions);

        Options.data.Guid = $.cookie("Guid");
        Options.data.AccountID = $.cookie("AccountID");
        Options.data.IsRecordLastActionTime = Options.IsRecordLastActionTime;

        $.ajax({
            beforeSend: function () {
                if (!Options.IsShowloading)
                    return;
                $.ShowLoading(Options.parentWindow);
            },
            complete: function () {
                $.CloseLoading(Options.parentWindow);
            },
            error: function (xhr, ajaxOptions, thrownError) {
                if (xhr.status == 0) {
                    /* 會到這裡代表 Client 無法連到 Server */
                    $.AlertMessage({ Message: xhr.responseText != null ? xhr.responseText : $.Main.Defaults.AjaxAlertMessage.ResponseText + "</br>Status Code:" + xhr.status, TitleBarText: $.Main.Defaults.AjaxAlertMessage.TitleBarText, TitleBarImg: $.Main.Defaults.AjaxAlertMessage.TitleBarImg, parentWindow: Options.parentWindow });
                }
                else if (xhr.status == 200) {
                    if ($.isFunction(Options.CallBackFunction)) {
                        $("body").everyTime("1ms", "SetTabsActive", function () {
                            $(this).stopTime("SetTabsActive");
                            Options.CallBackFunction(null);
                        });
                    }
                    return;
                }
                else if (xhr.status != 500) {
                    $.AlertMessage({ Message: ajaxOptions != "timeout" ? xhr.responseText + "</br>Status Code:" + xhr.status : $.Main.Defaults.AjaxAlertMessage.ResponseText, TitleBarText: $.Main.Defaults.AjaxAlertMessage.TitleBarText, TitleBarImg: $.Main.Defaults.AjaxAlertMessage.TitleBarImg, parentWindow: Options.parentWindow });
                }
                else
                    $.AlertMessage({ Message: $.Main.Defaults.AjaxAlertMessage.DefaultMessage, TitleBarText: $.Main.Defaults.AjaxAlertMessage.TitleBarText, TitleBarImg: $.Main.Defaults.AjaxAlertMessage.TitleBarImg, parentWindow: Options.parentWindow });

                if (Options.ErrorCallBackFunction != null && $.isFunction(Options.ErrorCallBackFunction)) {
                    Options.data.error = true;
                    Options.ErrorCallBackFunction(Options.data);
                }
            },
            contentType: Options.contentType,
            type: Options.type,
            timeout: Options.timeout,
            cache: Options.cache,
            url: Options.url,
            data: Options.data,
            dataType: Options.dataType,
            success: function (ResponseData) {
                $.removeCookie("Guid", { path: "/" });

                $.cookie("Guid", ResponseData.Guid, { path: "/" });

                var data = ResponseData.data;

                if (!$.VerificationData(data, Options.IsErrorShowAlert, Options.parentWindow)) {
                    if (Options.ErrorCallBackFunction == null)
                        return;
                    else if ($.isFunction(Options.ErrorCallBackFunction)) {
                        data.error = true;
                        $("body").everyTime("1ms", "SetTabsActive", function () {
                            $(this).stopTime("SetTabsActive");
                            Options.ErrorCallBackFunction(data);
                        });
                    }
                }
                else if ($.isFunction(Options.CallBackFunction)) {
                    $("body").everyTime("1ms", "SetTabsActive", function () {
                        $(this).stopTime("SetTabsActive");
                        Options.CallBackFunction(data);
                    });
                }
            }
        });
    },
    VerificationData: function (data, IsAlert, parentWindow) {
        /// <summary>指定Server回傳Data驗證是否Success</summary>
        /// <param name="data" type="Json">Server回傳Data</param>
        /// <param name="IsAlert" type="bool">如果錯誤是否要警示(預設true)</param>
        /// <param name="parentWindow" type="object">父視窗物件</param>
        /// <returns type="bool" />
        try {
            if (IsAlert == undefined)
                IsAlert = true;

            var obj;
            if (typeof data != "object")
                obj = $.parseJSON(data);
            else
                obj = data;

            $.CloseLoading();

            if ($.trim(obj.ErrorMsg) != "") {
                if (IsAlert) {
                    var MessageIsHtml = false;
                    if (obj.hasOwnProperty("MessageIsHtml"))
                        MessageIsHtml = this.StringConvertBoolean(obj.MessageIsHtml);
                    this.AlertMessage({ Message: $.trim(obj.ErrorMsg), IsHtmlElement: MessageIsHtml, TitleBarText: $.Main.Defaults.VerificationDataDefaults.TitleBarText, TitleBarImg: $.Main.Defaults.AlertMessage.TitleBarImg, "parentWindow": parentWindow });
                }
                return false;
            }
            else if ($.trim(obj.Logout) != "") {
                this.AlertMessage({
                    Message: $.Main.Defaults.VerificationDataDefaults.Message,
                    IsHtmlElement: false,
                    TitleBarText: $.Main.Defaults.VerificationDataDefaults.TitleBarText,
                    TitleBarImg: $.Main.Defaults.VerificationDataDefaults.TitleBarImg,
                    parentWindow: parentWindow,
                    TimeOut: 60000,
                    CloseEvent: function () {
                        if (parentWindow == null)
                            $(location).attr("href", $.Main.Defaults.VerificationDataDefaults.HomeAddress);
                        else
                            parentWindow.location.href = $.Main.Defaults.VerificationDataDefaults.HomeAddress;
                    }
                });
            }
            else
                return true;
        }
        catch (ex) {
            return false;
        }
    },
    include: function (file) {
        /// <summary>指定檔案名稱載入檔案</summary>
        /// <param name="file" type="String">檔案名稱</param>
        var files = typeof file == "string" ? [file] : file;
        for (var i = 0; i < files.length; i++) {
            var name = files[i].replace(/^\s|\s$/g, "");
            var att = name.split('.');
            var ext = att[att.length - 1].toLowerCase();
            var isCSS = ext == "css";
            var tag = isCSS ? "link" : "script";
            var link = (isCSS ? "href" : "src") + "='" + $.includePath + name + "'";

            var s = document.createElement(tag);
            if (isCSS) {
                s.setAttribute("type", "text/css");
                s.setAttribute("rel", "stylesheet");
                s.setAttribute("href", $.includePath + name);
            }
            else {
                s.setAttribute("type", "text/javascript");
                s.setAttribute("language", "javascript");
                s.setAttribute("src", $.includePath + name);
            }

            if ($(tag + "[" + link + "]").length == 0) {
                var head = document.getElementsByTagName("head")[0];
                if (head) head.appendChild(s)
                else document.body.appendChild(s);
            }
        }
    },
    ShowLoading: function (parentWindow) {
        /// <summary>顯示Loading視窗</summary>
        if (parentWindow == null) {
            $.CloseLoading();

            $("<div class=\"row loadingmsg\"><div class=\"col-sm-12 text-center\"><img src=\"" + $.Main.Defaults.ShowLoading.loaderImg + "\" /><p></p><img src=\"" + $.Main.Defaults.ShowLoading.loader2Img + "\" /></div></div>").dialog({
                autoOpen: true,
                modal: true,
                width: 200,
                resizable: false
            }).parents(".ui-dialog").css("background", "#ffffff").find(".ui-dialog-titlebar").remove();
        }
        else {
            parentWindow.$.CloseLoading();

            parentWindow.$("<div class=\"row loadingmsg\"><div class=\"col-sm-12 text-center\"><img src=\"" + $.Main.Defaults.ShowLoading.loaderImg + "\" /><p></p><img src=\"" + $.Main.Defaults.ShowLoading.loader2Img + "\" /></div></div>").dialog({
                autoOpen: true,
                modal: true,
                width: 200,
                resizable: false
            }).parents(".ui-dialog").css("background", "#ffffff").find(".ui-dialog-titlebar").remove();
        }
    },
    CloseLoading: function (parentWindow) {
        /// <summary>關閉Loading視窗</summary>
        if (parentWindow == null) {
            $(".loadingmsg").dialog("close");
            $(".loadingmsg").dialog("destroy");
        }
        else {
            parentWindow.$(".loadingmsg").dialog("close");
            parentWindow.$(".loadingmsg").dialog("destroy");
        }
    },
    ConfirmMessage: function (MessageOptions) {
        if (typeof MessageOptions != "object")
            return;
        var Options = $.extend({
            Message: "",
            IsHtmlElement: false,
            IsShowButtons: true,
            TitleBarText: $.Main.Defaults.ConfirmMessage.TitleBarText,
            TitleBarImg: $.Main.Defaults.ConfirmMessage.TitleBarImg,
            OpenEvent: null,
            CloseEvent: null,
            CancelButtonsText: $.Main.Defaults.ConfirmMessage.CancelButtonsText,
            ConfirmButtonsText: $.Main.Defaults.ConfirmMessage.ConfirmButtonsText,
            CancelCustomFunction: null,
            ConfirmCustomFunction: null,
            width: $.Main.Defaults.ConfirmMessage.width,
            height: -1,
            parentWindow: null
        }, MessageOptions);

        if (Options.parentWindow == null) {
            $(Options.IsHtmlElement ? "<div class=\"ConfirmMsg\">" + Options.Message + "</div>" : "<div class=\"ConfirmMsg\"><p>" + Options.Message + "</p></div>").dialog({
                open: function (event, ui) {
                    $(this).siblings(".ui-dialog-titlebar").html("");
                    $(this).siblings(".ui-dialog-titlebar-close").css("display", "none");
                    $(this).siblings(".ui-dialog-titlebar").append("<table><tr><td><img src=\"" + Options.TitleBarImg + "\" id=\"myNewImage\" /></td><td>&nbsp;&nbsp;&nbsp;</td><td>" + Options.TitleBarText + "</td></tr></table>");
                    if (Options.OpenEvent != null && $.isFunction(Options.OpenEvent))
                        Options.OpenEvent(this);
                },
                autoOpen: true,
                modal: true,
                resizable: false,
                width: Options.width,
                height: Options.height < 0 ? "auto" : Options.height,
                buttons: [
                    {
                        text: Options.ConfirmButtonsText,
                        "class": "btn btn-primary",
                        click: Options.ConfirmCustomFunction != null ? Options.ConfirmCustomFunction : function () {
                            $(this).dialog("close");
                            if (Options.CloseEvent != null && $.isFunction(Options.CloseEvent))
                                Options.CloseEvent(true);
                        }
                    },
                    {
                        text: Options.CancelButtonsText,
                        "class": "btn btn-primary",
                        click: Options.CancelCustomFunction != null ? Options.CancelCustomFunction : function () {
                            $(this).dialog("close");

                            if (Options.CloseEvent != null && $.isFunction(Options.CloseEvent))
                                Options.CloseEvent(false);
                        }
                    }],
                close: function (event, ui) {
                    $(this).dialog("destroy");
                }
            });
        }
        else {
            Options.parentWindow.$(Options.IsHtmlElement ? "<div class=\"ConfirmMsg\">" + Options.Message + "</div>" : "<div class=\"ConfirmMsg\"><p>" + Options.Message + "</p></div>").dialog({
                open: function (event, ui) {
                    $(this).siblings(".ui-dialog-titlebar").html("");
                    $(this).siblings(".ui-dialog-titlebar-close").css("display", "none");
                    $(this).siblings(".ui-dialog-titlebar").append("<table><tr><td><img src=\"" + Options.TitleBarImg + "\" id=\"myNewImage\" /></td><td>&nbsp;&nbsp;&nbsp;</td><td>" + Options.TitleBarText + "</td></tr></table>");
                    if (Options.OpenEvent != null && $.isFunction(Options.OpenEvent))
                        Options.OpenEvent(this);
                },
                autoOpen: true,
                modal: true,
                resizable: false,
                width: Options.width,
                height: Options.height < 0 ? "auto" : Options.height,
                buttons: [
                    {
                        text: Options.ConfirmButtonsText,
                        "class": "btn btn-primary",
                        click: Options.ConfirmCustomFunction != null ? Options.ConfirmCustomFunction : function () {
                            Options.parentWindow.$(this).dialog("close");
                            if (Options.CloseEvent != null && $.isFunction(Options.CloseEvent))
                                Options.CloseEvent(true);
                        }
                    },
                    {
                        text: Options.CancelButtonsText,
                        "class": "btn btn-primary",
                        click: Options.CancelCustomFunction != null ? Options.CancelCustomFunction : function () {
                            Options.parentWindow.$(this).dialog("close");

                            if (Options.CloseEvent != null && $.isFunction(Options.CloseEvent))
                                Options.CloseEvent(false);
                        }
                    }],
                close: function (event, ui) {
                    Options.parentWindow.$(this).dialog("destroy");
                }
            });
        }
    },
    AlertMessage: function (MessageOptions) {
        /// <summary>顯示訊息視窗</summary>
        /// <param name="MessageOptions" type="object">1.Message (訊息內容) 2.IsHtmlElement (訊息內容是否為HtmlElement 預設false) 3.TitleBarText (TitleBar 顯示文字 預設"提示訊息") 4.TitleBarImg (TitleBar 顯示圖示檔案位置) 5.CloseEvent (關閉訊息後回呼函式)</param>
        if (typeof MessageOptions != "object")
            return;
        var Options = $.extend({
            Message: "",
            IsHtmlElement: false,
            TitleBarText: $.Main.Defaults.AlertMessage.TitleBarText,
            TitleBarImg: $.Main.Defaults.AlertMessage.TitleBarImg,
            CloseEvent: null,
            OpenEvent: null,
            width: $.Main.Defaults.AlertMessage.width,
            height: -1,
            ButtonsText: $.Main.Defaults.AlertMessage.ButtonsText,
            parentWindow: null,
            TimeOut: 0,
            TitlebarClosetTitlt: $.Main.Defaults.AlertMessage.TitlebarClosetTitlt,
        }, MessageOptions);

        var DialogFrom;

        if (Options.parentWindow == null) {
            DialogFrom = $(Options.IsHtmlElement ? "<div class=\"Alertmsg\">" + Options.Message + "</div>" : "<div class=\"Alertmsg\"><p>" + Options.Message + "</p></div>").dialog({
                open: function (event, ui) {
                    if (Options.ButtonsText != "") {
                        $(this).siblings(".ui-dialog-titlebar").html("");
                        $(this).siblings(".ui-dialog-titlebar-close").css("display", "none");
                    }
                    else {
                        $(this).siblings(".ui-dialog-titlebar").find(".ui-dialog-title").remove();
                        $(this).siblings(".ui-dialog-titlebar").find(".ui-dialog-titlebar-close").attr("title", Options.TitlebarClosetTitlt);
                    }

                    $(this).siblings(".ui-dialog-titlebar").append("<table><tr><td><img src=\"" + Options.TitleBarImg + "\" id=\"myNewImage\" /></td><td>&nbsp;&nbsp;&nbsp;</td><td>" + Options.TitleBarText + "</td></tr></table>");

                    if (Options.OpenEvent != null && $.isFunction(Options.OpenEvent))
                        Options.OpenEvent(this);
                },
                autoOpen: true,
                modal: true,
                width: Options.width,
                height: Options.height < 0 ? "auto" : Options.height,
                resizable: false,
                buttons: Options.ButtonsText != "" ? [{
                    text: Options.ButtonsText,
                    "class": "btn btn-primary",
                    click: function () { $(this).dialog("close"); }
                }] : "",
                close: function (event, ui) {
                    try {
                        if (Options.CloseEvent != null && $.isFunction(Options.CloseEvent))
                            Options.CloseEvent(this);
                    }
                    catch (e) { }
                    $(this).dialog("destroy");
                }
            });
        }
        else {
            DialogFrom = Options.parentWindow.$(Options.IsHtmlElement ? "<div class=\"Alertmsg\">" + Options.Message + "</div>" : "<div class=\"Alertmsg\"><p>" + Options.Message + "</p></div>").dialog({
                open: function (event, ui) {
                    if (Options.ButtonsText != "") {
                        $(this).siblings(".ui-dialog-titlebar").html("");
                        $(this).siblings(".ui-dialog-titlebar-close").css("display", "none");
                    }
                    else {
                        $(this).siblings(".ui-dialog-titlebar").find(".ui-dialog-title").remove();
                        $(this).siblings(".ui-dialog-titlebar").find(".ui-dialog-titlebar-close").attr("title", Options.TitlebarClosetTitlt);
                    }
                    $(this).siblings(".ui-dialog-titlebar").append("<table><tr><td><img src=\"" + Options.TitleBarImg + "\" id=\"myNewImage\" /></td><td>&nbsp;&nbsp;&nbsp;</td><td>" + Options.TitleBarText + "</td></tr></table>");
                    if (Options.OpenEvent != null && $.isFunction(Options.OpenEvent))
                        Options.OpenEvent(this);
                },
                autoOpen: true,
                modal: true,
                width: Options.width,
                height: Options.height < 0 ? "auto" : Options.height,
                resizable: false,
                buttons: Options.ButtonsText != "" ? [{
                    text: Options.ButtonsText,
                    "class": "btn btn-primary",
                    click: function () { Options.parentWindow.$(this).dialog("close"); }
                }] : "",
                close: function (event, ui) {
                    try {
                        if (Options.CloseEvent != null && $.isFunction(Options.CloseEvent))
                            Options.CloseEvent(this);
                    }
                    catch (e) { }
                    Options.parentWindow.$(this).dialog("destroy");
                }
            });
        }

        if (Options.TimeOut > 0) {
            if (Options.parentWindow == null) {
                $("body").everyTime(Options.TimeOut + "ms", "AlertTimer", function () {
                    $(this).stopTime("AlertTimer");
                    try {
                        DialogFrom.dialog("close");
                    }
                    catch (err) {

                    }
                });
            }
            else {
                Options.parentWindow.$("body").everyTime(Options.TimeOut + "ms", "AlertTimer", function () {
                    $(this).stopTime("AlertTimer");
                    try {
                        DialogFrom.dialog("close");
                    }
                    catch (err) {

                    }

                });
            }
        }
    },
    DateCompare: function (StartDate, EndDate) {
        /// <summary>日期比較 (如果起始日期小於或等於會回傳True)</summary>
        /// <param name="StartDate" type="Date">起始日期</param>
        /// <param name="EndDate" type="Date">結束日期</param>
        /// <returns type="bool" />
        return (StartDate <= EndDate);
    },
    StringConvertBoolean: function (BooleanString) {
        if (typeof BooleanString == "boolean")
            return BooleanString;

        if (BooleanString == null)
            BooleanString = "false";

        if (typeof BooleanString == "number")
            BooleanString = BooleanString.toString();

        return !!BooleanString.match(/^(true|yes|y|1)$/i);
    },
    BooleanToIntValue: function (BooleanValue) {
        if (BooleanValue) return 1;
        else return 0;
    },
    paddingLeft: function (str, lenght) {
        if (str.length >= lenght)
            return str;
        else
            return this.paddingLeft("0" + str, lenght);
    },
    paddingRight: function (str, lenght) {
        if (str.length >= lenght)
            return str;
        else
            return this.paddingRight(str + "0", lenght);
    },
    OpenOrganizationTreeView: function (OpenOptions) {

        if (OpenOptions == null)
            OpenOptions = {};

        if (typeof OpenOptions != "object")
            return;

        var Options = $.extend({
            TitleBarText: $.Main.Defaults.OpenOrganizationTreeView.TitleBarText,
            TitleBarImg: $.Main.Defaults.OpenOrganizationTreeView.TitleBarImg,
            CloseEvent: null,
            OpenEvent: null,
            WebPath: $.Main.Defaults.OpenOrganizationTreeView.WebPath,
            width: 350,
            height: 550,
            ButtonsText: $.Main.Defaults.OpenOrganizationTreeView.ButtonsText,
            CancelButtonsText: $.Main.Defaults.OpenOrganizationTreeView.CancelButtonsText,
            iFrameOpenParameters: null,
            parentWindow: null
        }, OpenOptions);

        var OrgTreeDivID = "OrgTreeDiv";
        var OrgTreeFrameID = "OrgTreeFrame";

        var FrameSrc = Options.WebPath;
        if (Options.iFrameOpenParameters != null) {
            var Parameters = [];

            $.each(Options.iFrameOpenParameters, function (key, value) {
                var Parameter = key + "=" + value;
                Parameters.push(Parameter);
            });

            if (Parameters.length > 0)
                FrameSrc += "?" + Parameters.join("&");
        }

        if (Options.parentWindow == null) {
            $("#" + OrgTreeDivID + "").remove();
            $("form").append("<div id=\"" + OrgTreeDivID + "\"><iframe id=\"" + OrgTreeFrameID + "\" src=\"\"  scrolling=\"yes\" style=\"width: 100%;height: 99%;\" frameborder=\"0\" marginheight=\"0\" marginwidth=\"0\" framespacing=\"0\" border=\"0\"></iframe></div>");


            $("#" + OrgTreeDivID + "").dialog({
                open: function (event, ui) {
                    $("#" + OrgTreeFrameID + "").attr('src', FrameSrc).focus();
                    $(this).siblings(".ui-dialog-titlebar").html("");
                    //$(this).siblings(".ui-dialog-titlebar-close").css("display", "none");
                    $(this).siblings(".ui-dialog-titlebar").append("<button type=\"button\" class=\"close\" style=\"font-size:24px;\" data-toggle=\"tooltip\" data-placement=\"bottom\" title=\"close\"><span aria-hidden=\"true\">&times;</span><span class=\"sr-only\">close</span></button><i class=\"fa fa-sitemap\"></i>&nbsp;&nbsp;" + Options.TitleBarText + "");
                    $("button[class=\"close\"]").click(function (e) {
                        $("#" + OrgTreeDivID + "").dialog("close");
                    });
                    if (Options.OpenEvent != null && $.isFunction(Options.OpenEvent))
                        Options.OpenEvent();
                },
                autoOpen: true,
                resizable: false,
                modal: true,
                width: Options.width,
                height: Options.height,
                buttons: [{
                    text: Options.ButtonsText,
                    "class": "btn btn-primary",
                    click: function () {
                        if (Options.CloseEvent != null && $.isFunction(Options.CloseEvent)) {
                            var Frame = $("#" + OrgTreeFrameID + "").contents();
                            if (Frame != null) {
                                var SelectNodesDeptIDArray = new Array();
                                var SelectNodesDeptCodeArray = new Array();
                                var SelectNodesDeptNameeArray = new Array();
                                var SelectNodesCompanyIDArray = new Array();
                                var SelectNodesCompanyNameArray = new Array();
                                var SelectNodesDeptFullNameArray = new Array();
                                var SelectNodesAccountFullNameArray = new Array();
                                var SelectNodeAccountIDArray = new Array();
                                var SelectNodeAccountWorkCodeArray = new Array();
                                var SelectNodeAccountNameArray = new Array();

                                var DefaultSelectedSplitSymbol = Frame.find("#HF_DefaultSelectedSplitSymbol").val();

                                if (Frame.find("#SelectNodeDeptID").val() != "")
                                    SelectNodesDeptIDArray = Frame.find("#SelectNodeDeptID").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeDeptCode").val() != "")
                                    SelectNodesDeptCodeArray = Frame.find("#SelectNodeDeptCode").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeDeptName").val() != "")
                                    SelectNodesDeptNameeArray = Frame.find("#SelectNodeDeptName").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodesCompanyID").val() != "")
                                    SelectNodesCompanyIDArray = Frame.find("#SelectNodesCompanyID").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodesCompanyName").val() != "")
                                    SelectNodesCompanyNameArray = Frame.find("#SelectNodesCompanyName").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeDeptFullName").val() != "")
                                    SelectNodesDeptFullNameArray = Frame.find("#SelectNodeDeptFullName").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeAccountFullName").val() != "")
                                    SelectNodesAccountFullNameArray = Frame.find("#SelectNodeAccountFullName").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeAccountID").val() != "")
                                    SelectNodeAccountIDArray = Frame.find("#SelectNodeAccountID").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeAccountWorkCode").val() != "")
                                    SelectNodeAccountWorkCodeArray = Frame.find("#SelectNodeAccountWorkCode").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeAccountName").val() != "")
                                    SelectNodeAccountNameArray = Frame.find("#SelectNodeAccountName").val().split(DefaultSelectedSplitSymbol);

                                Options.CloseEvent({
                                    "SelectNodesDeptIDArray": SelectNodesDeptIDArray,
                                    "SelectNodesDeptCodeArray": SelectNodesDeptCodeArray,
                                    "SelectNodesDeptNameeArray": SelectNodesDeptNameeArray,
                                    "SelectNodesCompanyIDArray": SelectNodesCompanyIDArray,
                                    "SelectNodesCompanyNameArray": SelectNodesCompanyNameArray,
                                    "SelectNodesDeptFullNameArray": SelectNodesDeptFullNameArray,
                                    "SelectNodesAccountFullNameArray": SelectNodesAccountFullNameArray,
                                    "SelectNodeAccountIDArray": SelectNodeAccountIDArray,
                                    "SelectNodeAccountWorkCodeArray": SelectNodeAccountWorkCodeArray,
                                    "SelectNodeAccountNameArray": SelectNodeAccountNameArray
                                });
                            }
                        }

                        $(this).dialog("close");
                    }
                }, {
                    text: Options.CancelButtonsText,
                    "class": "btn btn-primary",
                    click: function () {
                        $(this).dialog("close");
                    }
                }],
                close: function (event, ui) {
                    $("#" + OrgTreeFrameID + "").attr("src", "");
                    $(this).dialog("destroy");
                    $("#" + OrgTreeDivID + "").remove();
                }
            });
        }
        else {
            Options.parentWindow.$("#" + OrgTreeDivID + "").remove();
            Options.parentWindow.$("form").append("<div id=\"" + OrgTreeDivID + "\"><iframe id=\"" + OrgTreeFrameID + "\" src=\"\"  scrolling=\"yes\" style=\"width: 100%;height: 99%;\" frameborder=\"0\" marginheight=\"0\" marginwidth=\"0\" framespacing=\"0\" border=\"0\"></iframe></div>");

            Options.parentWindow.$("#" + OrgTreeDivID + "").dialog({
                open: function (event, ui) {
                    Options.parentWindow.$("#" + OrgTreeFrameID + "").attr('src', FrameSrc).focus();
                    $(this).siblings(".ui-dialog-titlebar").html("");
                    //$(this).siblings(".ui-dialog-titlebar-close").css("display", "none");
                    $(this).siblings(".ui-dialog-titlebar").append("<button type=\"button\" class=\"close\" style=\"font-size:24px;\" data-toggle=\"tooltip\" data-placement=\"bottom\" title=\"close\"><span aria-hidden=\"true\">&times;</span><span class=\"sr-only\">close</span></button><i class=\"fa fa-sitemap\"></i>&nbsp;&nbsp;" + Options.TitleBarText + "");
                    $("button[class=\"close\"]").click(function (e) {
                        Options.parentWindow.$("#" + OrgTreeDivID + "").dialog("close");
                    });
                    if (Options.OpenEvent != null && $.isFunction(Options.OpenEvent))
                        Options.OpenEvent();
                },
                autoOpen: true,
                resizable: false,
                modal: true,
                width: Options.width,
                height: Options.height,
                buttons: [{
                    text: Options.ButtonsText,
                    "class": "btn btn-primary",
                    click: function () {
                        if (Options.CloseEvent != null && $.isFunction(Options.CloseEvent)) {
                            var Frame = Options.parentWindow.$("#" + OrgTreeFrameID + "").contents();
                            if (Frame != null) {
                                var SelectNodesDeptIDArray = new Array();
                                var SelectNodesDeptCodeArray = new Array();
                                var SelectNodesDeptNameeArray = new Array();
                                var SelectNodesCompanyIDArray = new Array();
                                var SelectNodesCompanyNameArray = new Array();
                                var SelectNodesDeptFullNameArray = new Array();
                                var SelectNodesAccountFullNameArray = new Array();
                                var SelectNodeAccountIDArray = new Array();
                                var SelectNodeAccountWorkCodeArray = new Array();
                                var SelectNodeAccountNameArray = new Array();

                                var DefaultSelectedSplitSymbol = Frame.find("#HF_DefaultSelectedSplitSymbol").val();

                                if (Frame.find("#SelectNodeDeptID").val() != "")
                                    SelectNodesDeptIDArray = Frame.find("#SelectNodeDeptID").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeDeptCode").val() != "")
                                    SelectNodesDeptCodeArray = Frame.find("#SelectNodeDeptCode").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeDeptName").val() != "")
                                    SelectNodesDeptNameeArray = Frame.find("#SelectNodeDeptName").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodesCompanyID").val() != "")
                                    SelectNodesCompanyIDArray = Frame.find("#SelectNodesCompanyID").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodesCompanyName").val() != "")
                                    SelectNodesCompanyNameArray = Frame.find("#SelectNodesCompanyName").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeDeptFullName").val() != "")
                                    SelectNodesDeptFullNameArray = Frame.find("#SelectNodeDeptFullName").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeAccountFullName").val() != "")
                                    SelectNodesAccountFullNameArray = Frame.find("#SelectNodeAccountFullName").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeAccountID").val() != "")
                                    SelectNodeAccountIDArray = Frame.find("#SelectNodeAccountID").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeAccountWorkCode").val() != "")
                                    SelectNodeAccountWorkCodeArray = Frame.find("#SelectNodeAccountWorkCode").val().split(DefaultSelectedSplitSymbol);
                                if (Frame.find("#SelectNodeAccountName").val() != "")
                                    SelectNodeAccountNameArray = Frame.find("#SelectNodeAccountName").val().split(DefaultSelectedSplitSymbol);

                                Options.CloseEvent({
                                    "SelectNodesDeptIDArray": SelectNodesDeptIDArray,
                                    "SelectNodesDeptCodeArray": SelectNodesDeptCodeArray,
                                    "SelectNodesDeptNameeArray": SelectNodesDeptNameeArray,
                                    "SelectNodesCompanyIDArray": SelectNodesCompanyIDArray,
                                    "SelectNodesCompanyNameArray": SelectNodesCompanyNameArray,
                                    "SelectNodesDeptFullNameArray": SelectNodesDeptFullNameArray,
                                    "SelectNodesAccountFullNameArray": SelectNodesAccountFullNameArray,
                                    "SelectNodeAccountIDArray": SelectNodeAccountIDArray,
                                    "SelectNodeAccountWorkCodeArray": SelectNodeAccountWorkCodeArray,
                                    "SelectNodeAccountNameArray": SelectNodeAccountNameArray
                                });
                            }
                        }

                        Options.parentWindow.$(this).dialog("close");
                    }
                }, {
                    text: Options.CancelButtonsText,
                    "class": "btn btn-primary",
                    click: function () {
                        Options.parentWindow.$(this).dialog("close");
                    }
                }],
                close: function (event, ui) {
                    Options.parentWindow.$("#" + OrgTreeFrameID + "").attr("src", "");
                    Options.parentWindow.$(this).dialog("destroy");
                    Options.parentWindow.$("#" + OrgTreeDivID + "").remove();
                }
            });
        }

        $("[data-toggle=tooltip]").tooltip();
    },
    OpenPage: function (OpenOptions) {
        if (OpenOptions == null)
            OpenOptions = {};

        if (typeof OpenOptions != "object")
            return;

        var Options = $.extend({
            Framesrc: "",
            IsShowTitleBarCloseButton: true,
            IsForciblyPage: false,
            TitleBarCloseButtonTriggerCloseEvent: false,
            TitleBarText: "",
            TitleBarImg: "",
            CloseEvent: null,
            OpenEvent: null,
            width: 800,
            height: $.client.browser == "Firefox" ? 600 : 550,
            ButtonsText: "",
            CancelButtonsText: "",
            iFrameOpenParameters: null,
            parentWindow: null,
            NewWindowPageDivID: $.Main.Defaults.OpenPage.NewWindowPageDivID,
            NewWindowPageFrameID: $.Main.Defaults.OpenPage.NewWindowPageFrameID,
            TitlebarTitle: $.Main.Defaults.OpenPage.TitlebarTitle
        }, OpenOptions);

        if (Options.Framesrc == "")
            return;

        var NewWindowPageDivID = Options.NewWindowPageDivID;
        var NewWindowPageFrameID = Options.NewWindowPageFrameID;
        var NewWindowPageFrameID = Options.NewWindowPageFrameID;

        var Pararmeters = [];

        if (OpenOptions.iFrameOpenParameters != null) {
            $.each(OpenOptions.iFrameOpenParameters, function (key, value) {
                var Parameter = key + "=" + value;
                Pararmeters.push(Parameter);
            });
        }

        if (Pararmeters.indexOf("DivID") < 0)
            Pararmeters.push("DivID=" + NewWindowPageDivID);

        if (Pararmeters.indexOf("FrameID") < 0)
            Pararmeters.push("FrameID=" + NewWindowPageFrameID);

        if (Pararmeters.length > 0)
            Options.Framesrc += "?" + Pararmeters.join("&");

        var IsCancelButtonClick = false;

        if (Options.parentWindow == null) {
            $("#" + NewWindowPageDivID + "").remove();
            $("form").append("<div id=\"" + NewWindowPageDivID + "\"><iframe id=\"" + NewWindowPageFrameID + "\" src=\"\" scrolling=\"yes\" style=\"width: 100%;height: 99%;\" frameborder=\"0\" marginheight=\"0\" marginwidth=\"0\" framespacing=\"0\" border=\"0\"></iframe></div>");

            $("#" + NewWindowPageDivID + "").dialog({
                open: function (event, ui) {
                    $("#" + NewWindowPageFrameID + "").attr('src', Options.Framesrc);

                    $(this).siblings(".ui-dialog-titlebar").html("");
                    $(this).siblings(".ui-dialog-titlebar-close").css("dispaly", "none");

                    if (!Options.IsForciblyPage && ((Options.ButtonsText == "" && Options.CancelButtonsText == "") || Options.IsShowTitleBarCloseButton)) {
                        $(this).siblings(".ui-dialog-titlebar").append("<button type=\"button\" class=\"close\" style=\"font-size:24px;\" data-toggle=\"tooltip\" data-placement=\"bottom\" title=\"" + Options.TitlebarTitle + "\"><span aria-hidden=\"true\">&times;</span><span class=\"sr-only\">" + Options.TitlebarTitle + "</span></button>");

                        $("button[class=\"close\"]").click(function (e) {
                            if (!Options.TitleBarCloseButtonTriggerCloseEvent)
                                IsCancelButtonClick = true;
                            $("#" + NewWindowPageDivID + "").dialog("close");
                        });
                    }
                    else
                        $(this).siblings(".ui-dialog-titlebar").append("<span class=\"sr-only\">" + Options.TitlebarTitle + "</span>");

                    var TitleTable = "<table><tr>";

                    if ($.trim(Options.TitleBarImg) != "")
                        TitleTable += "<td><img src=\"" + Options.TitleBarImg + "\" id=\"myNewImageFor" + NewWindowPageDivID + "\" />&nbsp;&nbsp;</td>";


                    if ($.trim(Options.TitleBarText) != "") {
                        if ($.trim(Options.TitleBarImg) != "")
                            TitleTable += "<td id=\"" + NewWindowPageDivID + "_Title\">" + Options.TitleBarText + "</td>";
                        else
                            TitleTable += "<td style=\"height:24px;\" id=\"" + NewWindowPageDivID + "_Title\">&nbsp;" + Options.TitleBarText + "</td>";
                    }

                    TitleTable += "</tr></table>";

                    $(this).siblings(".ui-dialog-titlebar").append(TitleTable);

                    if (Options.ButtonsText != "" || Options.CancelButtonsText != "") {
                        var Buttons = [];
                        if (Options.ButtonsText != "") {
                            Buttons.push({
                                text: Options.ButtonsText,
                                "class": "btn btn-primary",
                                click: function () {
                                    $(this).dialog("close");
                                }
                            });
                        }
                        if (Options.CancelButtonsText != "") {
                            Buttons.push({
                                text: Options.CancelButtonsText,
                                "class": "btn btn-primary",
                                click: function () {
                                    $(this).dialog("close");
                                }
                            });
                        }
                        $("#" + NewWindowPageDivID + "").dialog("option", "buttons", Buttons);
                    }

                    if (Options.OpenEvent != null && $.isFunction(Options.OpenEvent))
                        Options.OpenEvent();
                },
                autoOpen: true,
                resizable: false,
                modal: true,
                width: Options.width,
                height: Options.height,
                beforeClose: function (event, ui) {
                    if (!IsCancelButtonClick && Options.CloseEvent != null && $.isFunction(Options.CloseEvent))
                        Options.CloseEvent(event.target);
                },
                close: function (event, ui) {
                    $("#" + NewWindowPageFrameID + "").attr("src", "");
                    $(this).dialog("destroy");
                    $("#" + NewWindowPageDivID + "").remove();
                }
            });
        }
        else {
            Options.parentWindow.$("#" + NewWindowPageDivID + "").remove();
            Options.parentWindow.$("form").append("<div id=\"" + NewWindowPageDivID + "\"><iframe id=\"" + NewWindowPageFrameID + "\" src=\"\" scrolling=\"yes\" style=\"width: 100%;height: 99%;\" frameborder=\"0\" marginheight=\"0\" marginwidth=\"0\" framespacing=\"0\" border=\"0\"></iframe></div>");

            Options.parentWindow.$("#" + NewWindowPageDivID + "").dialog({
                open: function (event, ui) {
                    Options.parentWindow.$("#" + NewWindowPageFrameID + "").attr('src', Options.Framesrc);

                    $(this).siblings(".ui-dialog-titlebar").html("");
                    $(this).siblings(".ui-dialog-titlebar-close").css("dispaly", "none");

                    if (!Options.IsForciblyPage && ((Options.ButtonsText == "" && Options.CancelButtonsText == "") || Options.IsShowTitleBarCloseButton)) {
                        $(this).siblings(".ui-dialog-titlebar").append("<button type=\"button\" class=\"close\" style=\"font-size:24px;\" data-toggle=\"tooltip\" data-placement=\"bottom\" title=\"" + Options.TitlebarTitle + "\"><span aria-hidden=\"true\">&times;</span><span class=\"sr-only\">" + Options.TitlebarTitle + "</span></button>");

                        Options.parentWindow.$("button[class=\"close\"]").click(function (e) {
                            if (!Options.TitleBarCloseButtonTriggerCloseEvent)
                                IsCancelButtonClick = true;
                            Options.parentWindow.$("#" + NewWindowPageDivID + "").dialog("close");
                        });
                    }
                    else
                        $(this).siblings(".ui-dialog-titlebar").append("<span class=\"sr-only\">" + Options.TitlebarTitle + "</span>");

                    var TitleTable = "<table><tr>";

                    if ($.trim(Options.TitleBarImg) != "")
                        TitleTable += "<td><img src=\"" + Options.TitleBarImg + "\" id=\"myNewImageFor" + NewWindowPageDivID + "\" />&nbsp;&nbsp;</td>";


                    if ($.trim(Options.TitleBarText) != "") {
                        if ($.trim(Options.TitleBarImg) != "")
                            TitleTable += "<td id=\"" + NewWindowPageDivID + "_Title\">" + Options.TitleBarText + "</td>";
                        else
                            TitleTable += "<td style=\"height:24px;\" id=\"" + NewWindowPageDivID + "_Title\">" + Options.TitleBarText + "</td>";
                    }

                    TitleTable += "</tr></table>";

                    $(this).siblings(".ui-dialog-titlebar").append(TitleTable);

                    if (Options.ButtonsText != "" || Options.CancelButtonsText != "") {
                        var Buttons = [];
                        if (Options.ButtonsText != "") {
                            Buttons.push({
                                text: Options.ButtonsText,
                                "class": "btn btn-primary",
                                click: function () {
                                    $(this).dialog("close");
                                }
                            });
                        }
                        if (Options.CancelButtonsText != "") {
                            Buttons.push({
                                text: Options.CancelButtonsText,
                                "class": "btn btn-primary",
                                click: function () {
                                    $(this).dialog("close");
                                }
                            });
                        }
                        $("#" + NewWindowPageDivID + "").dialog("option", "buttons", Buttons);
                    }

                    if (Options.OpenEvent != null && $.isFunction(Options.OpenEvent))
                        Options.OpenEvent();
                },
                autoOpen: true,
                resizable: false,
                modal: true,
                width: Options.width,
                height: Options.height,
                beforeClose: function (event, ui) {
                    if (!IsCancelButtonClick && Options.CloseEvent != null && $.isFunction(Options.CloseEvent))
                        Options.CloseEvent(event.target);
                },
                close: function (event, ui) {
                    Options.parentWindow.$("#" + NewWindowPageFrameID + "").attr("src", "");
                    Options.parentWindow.$(this).dialog("destroy");
                    Options.parentWindow.$("#" + NewWindowPageDivID + "").remove();
                }
            });
        }

        $("[data-toggle=tooltip]").tooltip();
    },
    WindowOpen: function (verb, url, data, target) {
        /// <summary>開啟新視窗</summary>
        /// <param name="verb" type="string">method(post or get)</param>
        /// <param name="url" type="string">網址</param>
        /// <param name="data" type="object">傳值參數</param>
        /// <param name="target" type="string">開啟方式</param>
        var form = document.createElement("form");
        form.id = "NewWindowOpen"
        form.action = url;
        form.method = verb;
        form.target = target || "_blank";
        if (data) {
            for (var key in data) {
                var input = document.createElement("textarea");
                input.name = key;
                input.value = typeof data[key] === "object" ? JSON.stringify(data[key]) : data[key];
                form.appendChild(input);
            }
        }
        form.style.display = 'none';
        document.body.appendChild(form);
        form.submit();

        $("#NewWindowOpen").remove();
    },
    LocationHrefPost: function (url, parameters) {
        /// <summary>LocationHref By Post</summary>
        /// <param name="url" type="string">網址</param>
        /// <param name="parameters" type="object">傳值參數</param>
        var $form = $(document.createElement("form")).css({ display: "none" }).attr("method", "Post").attr("action", url);

        if (parameters != null) {
            if (parameters != null) {
                $.each(parameters, function (i, item) {
                    var $input = $(document.createElement("input")).attr("name", item.key).val(item.value);
                    $form.append($input);
                });
            }
        }

        $("body").append($form);

        $form.submit();
    },
    ispAad: function () {
        return (
            (navigator.platform.indexOf("iPhone") != -1) ||
            (navigator.platform.indexOf("iPod") != -1) ||
            (navigator.platform.indexOf("iPad") != -1) ||
            (navigator.platform.indexOf("android") != -1) ||
            (navigator.platform.indexOf("Android") != -1) ||
            (navigator.platform.indexOf("linux") != -1) ||
            (navigator.platform.indexOf("Linux") != -1)
        );
    },
    FloatAdd: function (arg1, arg2) {
        /// <summary>浮點數相加</summary>
        /// <param name="arg1" type="string">浮點數1</param>
        /// <param name="arg2" type="object">浮點數2</param>
        var r1, r2, m;
        try { r1 = arg1.toString().split(".")[1].length; } catch (e) { r1 = 0; }
        try { r2 = arg2.toString().split(".")[1].length; } catch (e) { r2 = 0; }
        m = Math.pow(10, Math.max(r1, r2));
        return ($.FloatMul(arg1, m) + $.FloatMul(arg2, m)) / m;
    },
    FloatSubtraction: function (arg1, arg2) {
        /// <summary>浮點數相減</summary>
        /// <param name="arg1" type="string">浮點數1</param>
        /// <param name="arg2" type="object">浮點數2</param>
        var r1, r2, m, n;
        try { r1 = arg1.toString().split(".")[1].length } catch (e) { r1 = 0 }
        try { r2 = arg2.toString().split(".")[1].length } catch (e) { r2 = 0 }
        m = Math.pow(10, Math.max(r1, r2));
        n = (r1 >= r2) ? r1 : r2;
        return ((arg1 * m - arg2 * m) / m).toFixed(n);
    },
    FloatMul: function (arg1, arg2) {
        /// <summary>浮點數相乘</summary>
        /// <param name="arg1" type="string">浮點數1</param>
        /// <param name="arg2" type="object">浮點數2</param>
        var m = 0, s1 = arg1.toString(), s2 = arg2.toString();
        try { m += s1.split(".")[1].length; } catch (e) { }
        try { m += s2.split(".")[1].length; } catch (e) { }
        return Number(s1.replace(".", "")) * Number(s2.replace(".", "")) / Math.pow(10, m);
    },
    FloatDiv: function (arg1, arg2) {
        /// <summary>浮點數相除</summary>
        /// <param name="arg1" type="string">浮點數1</param>
        /// <param name="arg2" type="object">浮點數2</param>
        var t1 = 0, t2 = 0, r1, r2;
        try { t1 = arg1.toString().split(".")[1].length } catch (e) { }
        try { t2 = arg2.toString().split(".")[1].length } catch (e) { }
        with (Math) {
            r1 = Number(arg1.toString().replace(".", ""))
            r2 = Number(arg2.toString().replace(".", ""))
            return (r1 / r2) * pow(10, t2 - t1);
        }
    },
    CopyToClipboard: function (ClipboardValue) {
        var textToClipboard = ClipboardValue;

        var success = true;
        if (window.clipboardData) { // Internet Explorer
            window.clipboardData.setData("Text", textToClipboard);
        }
        else {
            // create a temporary element for the execCommand method
            var forExecElement = CreateElementForExecCommand(textToClipboard);

            /* Select the contents of the element 
                (the execCommand for 'copy' method works on the selection) */
            SelectContent(forExecElement);

            var supported = true;

            // UniversalXPConnect privilege is required for clipboard access in Firefox
            try {
                if (window.netscape && netscape.security) {
                    netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
                }

                // Copy the selected content to the clipboard
                // Works in Firefox and in Safari before version 5
                success = document.execCommand("copy", false, null);
            }
            catch (e) {
                success = false;
            }

            // remove the temporary element
            document.body.removeChild(forExecElement);
        }

        return success;
    }
});

$(function () {
    $.datepicker.regional["zh-TW"] = {
        clearText: "清除", clearStatus: "清除已選日期",
        closeText: "關閉", closeStatus: "取消選擇",
        prevText: "<上一月", prevStatus: "顯示上個月",
        nextText: "下一月>", nextStatus: "顯示下個月",
        currentText: "今天", currentStatus: "顯示本月",
        monthNames: ["一月", "二月", "三月", "四月", "五月", "六月",
            "七月", "八月", "九月", "十月", "十一月", "十二月"],
        monthNamesShort: ["一月", "二月", "三月", "四月", "五月", "六月",
            "七月", "八月", "九月", "十月", "十一月", "十二月"],
        monthStatus: "選擇月份", yearStatus: "選擇年份",
        weekHeader: "週", weekStatus: "",
        dayNames: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"],
        dayNamesShort: ["週日", "週一", "週二", "週三", "週四", "週五", "週六"],
        dayNamesMin: ["日", "一", "二", "三", "四", "五", "六"],
        dayStatus: "設定每週第一天", dateStatus: "選擇 m月 d日, DD",
        dateFormat: "yy/mm/dd", firstDay: 0,
        initStatus: "請選擇日期", isRTL: false,
        buttonText: "請選擇日期"
    };

    $.datepicker.regional["zh-CN"] = {
        clearText: "清除", clearStatus: "清除已选日期",
        closeText: "关闭", closeStatus: "取消选择",
        prevText: "<上一月", prevStatus: "显示上个月",
        nextText: "下一月>", nextStatus: "显示下个月",
        currentText: "今天", currentStatus: "显示本月",
        monthNames: ["一月", "二月", "三月", "四月", "五月", "六月",
            "七月", "八月", "九月", "十月", "十一月", "十二月"],
        monthNamesShort: ["一月", "二月", "三月", "四月", "五月", "六月",
            "七月", "八月", "九月", "十月", "十一月", "十二月"],
        monthStatus: "选择月份", yearStatus: "选择年份",
        weekHeader: "周", weekStatus: "",
        dayNames: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"],
        dayNamesShort: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"],
        dayNamesMin: ["日", "一", "二", "三", "四", "五", "六"],
        dayStatus: "设定每周第一天", dateStatus: "选择 m月 d日, DD",
        dateFormat: "yy/mm/dd", firstDay: 0,
        initStatus: "请选择日期", isRTL: false,
        buttonText: "请选择日期"
    };

    if ($.cookie("langCookie") != null && $.trim($.cookie("langCookie")) != "")
        $.datepicker.setDefaults($.datepicker.regional[$.cookie("langCookie")]);
    else
        $.datepicker.setDefaults($.datepicker.regional["zh-TW"]);

    window.onscroll = function () { BtnScroll() };
});

function OpenWindowDownloadFile(url, OpenOptions) {

    var Options = $.extend({
        DownloadFilePath: "",
        FileName: "",
        ExportRows: null,
        ExclusionColumnName: new Array(),
        Guid: $.cookie("Guid"),
        AccountID: $.cookie("AccountID"),
        parentWindow: null
    }, OpenOptions);

    if (Options.ExportRows != null) {
        var Values = new Array();

        $.each(Options.ExportRows, function (i, item) {
            var keys = new Array();
            $.each(item, function (key, element) {
                if ($.inArray(key, Options.ExclusionColumnName) < 0)
                    keys.push(key);
            });
            if (i == 0) {
                Options.Columns = JSON.stringify(keys);
            }
            var Value = new Array();
            $.each(keys, function (j, key) {
                Value.push(item[key]);
            });
            Values.push(Value);
        });
        Options.Rows = JSON.stringify(Values);
    }
    else
        delete Options.ExclusionColumnName;

    delete Options.ExportRows;

    if (Options.parentWindow == null) {

        var div = "<div id=\"DownloadFile_Dialog\" class=\"row\"><div class=\"col-sm-12 text-center\"><div class=\"progress\"><div class=\"progress-bar progress-bar-striped active\" role=\"progressbar\" aria-valuenow=\"100\" aria-valuemin=\"0\" aria-valuemax=\"100\" style=\"width: 100%\"><span class=\"sr-only\">100% Complete</span></div></div></div><div class=\"col-sm-12 text-center\"><h5>" + $.Main.Defaults.DownloadFile.WaitTitleText + "</h5></div></div>";

        $(div)
            .dialog({
                open: function (event, ui) {
                    $(this).siblings(".ui-dialog-titlebar").html("");
                    $(this).siblings(".ui-dialog-titlebar-close").css("display", "none");
                    $(this).siblings(".ui-dialog-titlebar").append("<div class=\"row\"><div class=\"col-sm-12\"><img src=\"" + $.Main.Defaults.DownloadFile.TitleBarImg + "\" id=\"myNewImage\"/>" + $.Main.Defaults.DownloadFile.TitleBarText + "</div></div>");
                },
                modal: true,
                resizable: false,
                width: 600,
                close: function (event, ui) {
                    $(this).dialog("destroy");
                }
            });
    }
    else {
        Options.parentWindow.$(div)
            .dialog({
                open: function (event, ui) {
                    $(this).siblings(".ui-dialog-titlebar").html("");
                    $(this).siblings(".ui-dialog-titlebar-close").css("display", "none");
                    $(this).siblings(".ui-dialog-titlebar").append("<div class=\"row\"><div class=\"col-sm-12\"><img src=\"" + $.Main.Defaults.DownloadFile.TitleBarImg + "\" id=\"myNewImage\"/>" + $.Main.Defaults.DownloadFile.TitleBarText + "</div></div>");
                },
                modal: true,
                resizable: false,
                width: 600,
                close: function (event, ui) {
                    $(this).dialog("destroy");
                }
            });
    }

    if (Options.parentWindow == null) {
        $.fileDownload(url, {
            httpMethod: "post", data: Options,
            successCallback: function (url) {
                $("#DownloadFile_Dialog").dialog("close");
                $("#DownloadFile_Dialog").remove();
            }, failCallback: function (responseHtml, url) {
                $("#DownloadFile_Dialog").dialog("close");
                $("#DownloadFile_Dialog").remove();
                $.AlertMessage({ Message: $.Main.Defaults.DownloadFile.FailMessageText });
            }
        });
    }
    else {
        Options.parentWindow.$.fileDownload(url, {
            httpMethod: "post", data: Options,
            successCallback: function (url) {
                $("#DownloadFile_Dialog").dialog("close");
                $("#DownloadFile_Dialog").remove();
            }, failCallback: function (responseHtml, url) {
                $("#DownloadFile_Dialog").dialog("close");
                $("#DownloadFile_Dialog").remove();
                $.AlertMessage({ Message: $.Main.Defaults.DownloadFile.FailMessageText });
            }
        });
    }
}

function BtnScroll() {
    if ($("#GoTopBtn").length < 1)
        $("body").append("<button onclick=\"GoToScrolTop()\" id=\"GoTopBtn\" title=\"Go To Top\"><i class=\"fa fa-arrow-up fa-2x\"></i></button>");

    if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20)
        document.getElementById("GoTopBtn").style.display = "block";
    else
        document.getElementById("GoTopBtn").style.display = "none";
}

function GoToScrolTop() {
    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;
}

function CreateElementForExecCommand(textToClipboard) {
    var forExecElement = document.createElement("div");
    // place outside the visible area
    forExecElement.style.position = "absolute";
    forExecElement.style.left = "-10000px";
    forExecElement.style.top = "-10000px";
    // write the necessary text into the element and append to the document
    forExecElement.textContent = textToClipboard;
    document.body.appendChild(forExecElement);
    // the contentEditable mode is necessary for the  execCommand method in Firefox
    forExecElement.contentEditable = true;

    return forExecElement;
}

function SelectContent(element) {
    // first create a range
    var rangeToSelect = document.createRange();
    rangeToSelect.selectNodeContents(element);

    // select the contents
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(rangeToSelect);
}


//可在Javascript中使用如同C#中的string.format
//使用方式 : var fullName = String.format('Hello. My name is {0} {1}.', 'FirstName', 'LastName');
String.format = function () {
    var s = arguments[0];
    if (s == null) return "";
    for (var i = 0; i < arguments.length - 1; i++) {
        var reg = getStringFormatPlaceHolderRegEx(i);
        s = s.replace(reg, (arguments[i + 1] == null ? "" : arguments[i + 1]));
    }
    return cleanStringFormatResult(s);
}
//可在Javascript中使用如同C#中的string.format (對jQuery String的擴充方法)
//使用方式 : var fullName = 'Hello. My name is {0} {1}.'.format('FirstName', 'LastName');
String.prototype.format = function () {
    var txt = this.toString();
    for (var i = 0; i < arguments.length; i++) {
        var exp = getStringFormatPlaceHolderRegEx(i);
        txt = txt.replace(exp, (arguments[i] == null ? "" : arguments[i]));
    }
    return cleanStringFormatResult(txt);
}
//讓輸入的字串可以包含{}
function getStringFormatPlaceHolderRegEx(placeHolderIndex) {
    return new RegExp('({)?\\{' + placeHolderIndex + '\\}(?!})', 'gm')
}
//當format格式有多餘的position時，就不會將多餘的position輸出
//ex:
// var fullName = 'Hello. My name is {0} {1} {2}.'.format('firstName', 'lastName');
// 輸出的 fullName 為 'firstName lastName', 而不會是 'firstName lastName {2}'
function cleanStringFormatResult(txt) {
    if (txt == null) return "";
    return txt.replace(getStringFormatPlaceHolderRegEx("\\d+"), "");
}