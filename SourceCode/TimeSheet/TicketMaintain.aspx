<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="TicketMaintain.aspx.cs" Inherits="TimeSheet_TicketMaintain" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        var MaintainFaultByFirstListID = "MaintainFaultByFirstList";
        var MaintainFaultByFirstListTableID = "MaintainFaultByFirstListTable";
        var MaintainFaultByFirstListPagerID = "MaintainFaultByFirstListPager";

        var MaintainInfoOperatorListID = "MaintainInfoOperatorList";
        var MaintainInfoOperatorListTableID = "MaintainInfoOperatorListTable";
        var MaintainInfoOperatorListPagerID = "MaintainInfoOperatorListPagerID";

        var OperatorWorkCodeColumnName = "";

        $(function () {
            LoadGridData({
                IsShowJQGridPager: false,
                IsMultiSelect: true,
                JQGridDataValue: JQGridDataValueByFaultFitst,
                ListID: MaintainFaultByFirstListID,
                TableID: MaintainFaultByFirstListTableID,
                PagerID: MaintainFaultByFirstListPagerID,
            });

            $("#<%=DDL_Responsible.ClientID%>").selectpicker("val", DefaultResponsibleID);

            /* 初判故障代碼，故障分類變更時候 */
            $("#<%=DDL_FaultCategory.ClientID%>").change(function () {
                var FaultCategoryID = $(this).val();

                if (FaultCategoryID == "") {
                    $("#<%=DDL_Fault.ClientID%> option").remove();

                    $("#<%=DDL_Fault.ClientID%>").selectpicker("destroy");

                    $("#<%=DDL_Fault.ClientID%>").selectpicker("refresh");

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/FaultGet.ashx")%>",
                    data: { FaultCategoryID: FaultCategoryID },
                    CallBackFunction: function (data) {
                        $("#<%=DDL_Fault.ClientID%> option").remove();

                        $("#<%=DDL_Fault.ClientID%>").selectpicker("destroy");

                        $.each(data, function (i, item) {
                            $("#<%=DDL_Fault.ClientID%>").append($("<option></option>").attr("value", item["FaultID"]).text(item["FaultName"]));
                        });

                        $("#<%=DDL_Fault.ClientID%>").selectpicker();

                        $("#<%=DDL_Fault.ClientID%>").selectpicker("refresh");
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=DDL_Fault.ClientID%> option").remove();

                        $("#<%=DDL_Fault.ClientID%>").selectpicker('destroy');

                        $("#<%=DDL_Fault.ClientID%>").selectpicker('refresh');
                    }
                });
            });

            $("#BT_AddMaintain").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                var GridTable = $("#" + MaintainFaultByFirstListTableID);

                var RowData = GridTable.jqGrid("getRowData");

                var FirstTimeMaintainFaultList = new Array();

                $.each(RowData, function (index, item) {
                    FirstTimeMaintainFaultList.push({ FaultCategoryID: item["FaultCategoryID"], FaultID: item["FaultID"] });
                });

                if (FirstTimeMaintainFaultList.length < 1) {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_MaintainFaultByFirstListRowLess1")%>" });

                    return;
                }

                var ResponsibleListID = $("#<%=DDL_Responsible.ClientID%>").selectpicker("val");

                if (ResponsibleListID.length < 1 || (ResponsibleListID.length == 1 && ResponsibleListID[0] == "")) {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_MaintainResponsible")%>" });

                    return;
                }

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainGoIn.ashx")%>",
                    data: {
                        TicketID: $("#<%=TB_TicketID.ClientID%>").val(),
                        OperatorWorkCode: $("#<%=TB_Operator.ClientID%>").val(),
                        WaitTimeStart: $("#<%=TB_WaitTimeStart.ClientID%>").val(),
                        ParentMaintainID: $("#<%=TB_ParentMaintainID.ClientID%>").val(),
                        FirstTimeMaintainFaultList: JSON.stringify(FirstTimeMaintainFaultList),
                        ResponsibleListID: JSON.stringify(ResponsibleListID)
                    },
                    CallBackFunction: function (data) {
                        $("#<%=TB_Operator.ClientID%>").val("");

                        $("#<%=HF_IsOnMaintain.ClientID%>").val("1");
                        $("#<%=HF_MaintainID.ClientID%>").val(data.MaintainID);
                        $("#<%=HF_ProcessID.ClientID%>").val(data.ProcessID);
                        $("#<%=HF_AUFPL.ClientID%>").val(data.AUFPL);
                        $("#<%=HF_APLZL.ClientID%>").val(data.APLZL);
                        $("#<%=HF_VORNR.ClientID%>").val(data.VORNR);
                        $("#<%=HF_DeviceID.ClientID%>").val(data.DeviceID);
                        $("#<%=TB_WaitTimeEnd.ClientID%>").val(data.WaitTimeEnd);

                        $("#BT_MaintainFaultByFirstAdd,#BT_MaintainFaultByFirstDelete").addClass("disabled").hide();

                        $("#<%=DDL_Responsible.ClientID%>").prop("disabled", true);

                        $("#<%=DDL_FaultCategory.ClientID%>").val("").prop("disabled", true).trigger("change");

                        LoadWaitReportData();
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_Operator.ClientID%>").val("");
                    }
                });

                event.preventDefault();
            });

            $("#<%=TB_Operator.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;
                else
                    $("#BT_AddMaintain").trigger("click");

            }).focus();

            if ($.StringConvertBoolean($("#<%=HF_IsOnMaintain.ClientID%>").val()))
                LoadWaitReportData();

            $("#<%=DDL_Responsible.ClientID%>").on("changed.bs.select", function (e, clickedIndex, isSelected, previousValue) {
                var ResponsibleListID = $("#<%=DDL_Responsible.ClientID%>").selectpicker("val");

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainChangeResponsibleID.ashx")%>",
                    IsShowloading: false,
                    IsErrorShowAlert: false,
                    data: {
                        TicketID: $("#<%=TB_TicketID.ClientID%>").val(),
                        ResponsibleListID: JSON.stringify(ResponsibleListID)
                    },
                    CallBackFunction: function (data) {

                    }
                });
            });

            $("#BT_Fault").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/TicketMaintainFault.aspx") %>",
                    iFrameOpenParameters: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val(), PLNBEZ: $("#<%=HF_PLNBEZ.ClientID%>").val() },
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_BT_Fault") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 910,
                    height: 810,
                    NewWindowPageDivID: "Fault_DivID",
                    NewWindowPageFrameID: "Fault_Frame"
                });
            });

            $("#BT_Delete").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                VerifyWorkCode([$.cookie("TS_WorkCode")], "<%= (string)GetLocalResourceObject("Str_VerifyPDWorkCode") %>","<%= (string)GetLocalResourceObject("Str_VerifyPDWorkCodeFail") %>", function () {
                    $.Ajax({
                        url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainDelete.ashx")%>",
                        data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val() },
                        CallBackFunction: function (data) {
                            $("#<%=HF_IsComplete.ClientID%>").val("1");
                            $("#<%=HF_IsOnMaintain.ClientID%>").val("0");
                            $("#<%=HF_IsHaveMaintain.ClientID%>").val("0");

                            parent.$("#" + $("#<%=HF_Div.ClientID%>").val()).dialog("close");
                        }
                    });
                });
            });

            $("#BT_Finish").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                if ($("#<%=TB_QACheckWorkCode.ClientID%>").val() == "" || $("#<%=TB_QACheckTimeEnd.ClientID%>").val() == "") {
                    $.AlertMessage({ Message:"<%= (string)GetLocalResourceObject("Str_Error_QACheckNull") %>" });

                    return;
                }

                let WorkCodeList = new Array();

                WorkCodeList.push($.cookie("TS_WorkCode"));

                if ($("#<%=HF_SecondOperatorWorkCode.ClientID%>").val() != "")
                    WorkCodeList = WorkCodeList.concat($("#<%=HF_SecondOperatorWorkCode.ClientID%>").val().split("|"));

                VerifyWorkCode(WorkCodeList, "<%= (string)GetLocalResourceObject("Str_VerifyPDWorkCode") %>", "<%= (string)GetLocalResourceObject("Str_VerifyPDWorkCodeFail") %>", function () {
                    $.Ajax({
                        url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainFinish.ashx")%>",
                        data: {
                            MaintainID: $("#<%=HF_MaintainID.ClientID%>").val(), ParentMaintainID: $("#<%=TB_ParentMaintainID.ClientID%>").val(), IsConfirm: $("#<%=DDL_IsConfirm.ClientID%>").val(), ConfirmWorkCode: $("#<%=TB_ConfirmWorkCode.ClientID%>").val(),
                            IsAlert: $("#<%=DDL_IsAlert.ClientID%>").val(), IsTrace: $("#<%=DDL_IsTrace.ClientID%>").val(), TraceGoodQty: $("#<%=TB_TraceGoodQty.ClientID%>").val(), TraceNGQty: $("#<%=TB_TraceNGQty.ClientID%>").val(),
                            TestQty1: $("#<%=TB_TestQty1.ClientID%>").val(), TestQty2: $("#<%=TB_TestQty2.ClientID%>").val(), TestTicketID: $("#<%=TB_TestTicketID.ClientID%>").val(),
                            Remark1: $("#<%=TB_Remark1.ClientID%>").val(), Remark2: $("#<%=TB_Remark2.ClientID%>").val(), Remark3: $("#<%=TB_Remark3.ClientID%>").val(), IsCancel: $("#<%=DDL_IsCancel.ClientID%>").val()
                        },
                        CallBackFunction: function (data) {
                            $("#<%=TB_ParentMaintainID.ClientID%>").prop("disabled", true);

                            $("#BT_Finish,#BT_Delete").addClass("disabled").hide();

                            if ($("#OperatorList").hasClass("in"))
                                $("#OperatorList").collapse("toggle");
                            if ($("#MaintainQACheck").hasClass("in"))
                                $("#OperatMaintainQACheckorList").collapse("toggle");
                            if ($("#MaintainInfo").hasClass("in"))
                                $("#MaintainInfo").collapse("toggle");

                            $("#MaintainPDCheckDiv").show();
                        }
                    });
                });
            });

            $("#<%=TB_TraceGoodQty.ClientID%>,#<%=TB_TraceNGQty.ClientID%>").change(function () {
                $("#<%=TB_TraceQty.ClientID%>").val(parseInt($("#<%=TB_TraceGoodQty.ClientID%>").val()) + parseInt($("#<%=TB_TraceNGQty.ClientID%>").val()));
            });

            $("#<%=DDL_IsTrace.ClientID%>").change(function () {
                if ($.StringConvertBoolean($(this).val()))
                    $("#<%=TB_TraceGoodQty.ClientID%>,#<%=TB_TraceNGQty.ClientID%>").prop("disabled", false).trigger("change");
                else
                    $("#<%=TB_TraceGoodQty.ClientID%>,#<%=TB_TraceNGQty.ClientID%>").prop("disabled", true).val("0").trigger("change");
            }).trigger("change");

            $("#<%=TB_TestTicketID.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data) {
                        if (data.A2 == null) {
                            $("#<%=TB_TestTicketID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_TicketID")%>" });

                            return;
                        }

                        $("#<%=TB_TestTicketID.ClientID%>").val(data.A2);
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_TestTicketID.ClientID%>").val("");
                    }
                });
            });

            $("#BT_QACheckGoin").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainQACheckGoin.ashx")%>",
                    data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val() },
                    CallBackFunction: function (data) {
                        LoadWaitReportData();
                    }
                });
            });

            $("#BT_QACheckGoOut").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainQACheckGoOut.ashx")%>",
                    data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val(), QACheckAccountWorkCode: $("#<%=TB_QACheckWorkCode.ClientID%>").val() },
                    CallBackFunction: function (data) {
                        LoadWaitReportData();
                    }
                });

            });

            $("#BT_PDCheckGoin").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainPDCheckGoin.ashx")%>",
                    data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val() },
                    CallBackFunction: function (data) {
                        LaodPDCheckData();
                    }
                });
            });

            $("#BT_PDCheckGoOut").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainPDCheckGoOut.ashx")%>",
                    data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val(), PDCheckAccountWorkCode: $("#<%=TB_PDCheckWorkCode.ClientID%>").val() },
                    CallBackFunction: function (data) {
                        $("#<%=HF_IsComplete.ClientID%>").val("1");

                        $("#<%=HF_IsOnMaintain.ClientID%>").val("0");

                        $.AlertMessage({
                            Message: "<%= (string)GetLocalResourceObject("Str_FinishSuccessAlertMessage") %> " + $("#<%=HF_MaintainID.ClientID%>").val() + "", CloseEvent: function () {
                                $("#<%=HF_IsHaveMaintain.ClientID%>").val("1");

                                parent.$("#" + $("#<%=HF_Div.ClientID%>").val()).dialog("close");
                            }
                        });
                    }
                });
            });

            $("#<%=TB_QACheckWorkCode.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;
                else
                    $("#BT_QACheckGoOut").trigger("click");

            });

            $("#<%=TB_PDCheckWorkCode.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;
                else
                    $("#BT_PDCheckGoOut").trigger("click");

            });

            $("#BT_MaintainFaultByFirstAdd").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                if ($("#<%=DDL_FaultCategory.ClientID%>").val() == "" || $("#<%=DDL_Fault.ClientID%>").val() == "") {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return;
                }

                var FaultCategoryID = $("#<%=DDL_FaultCategory.ClientID%>").val();
                var FaultCategoryName = $("#<%=DDL_FaultCategory.ClientID%> :selected").text();
                var FaultID = $("#<%=DDL_Fault.ClientID%>").val();
                var FaultName = $("#<%=DDL_Fault.ClientID%> :selected").text();

                var GridTable = $("#" + MaintainFaultByFirstListTableID);

                var RowData = GridTable.jqGrid("getRowData");

                if ($.grep(RowData, function (item, index) { return item.FaultCategoryID.trimStart() == FaultCategoryID.trimStart() && item.FaultID.trimStart() == FaultID.trimStart(); }).length > 0) {
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_Error_FirstFaultIDRpeat")%>" });

                    return;
                }

                RowData.push({ FaultCategoryID: FaultCategoryID.trimStart(), FaultCategoryName: FaultCategoryName.trimStart(), FaultID: FaultID.trimStart(), FaultName: FaultName.trimStart() });

                GridTable.jqGrid("setGridParam", { data: RowData }).trigger("reloadGrid");
            });

            $("#BT_MaintainFaultByFirstDelete").click(function () {
                if ($(this).hasClass("disabled"))
                    return;

                var GridTable = $("#" + MaintainFaultByFirstListTableID);

                var SelRcowId = GridTable.jqGrid("getGridParam", "selarrrow");

                if (SelRcowId.length < 1) {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });

                    return false;
                }

                /* 只能倒著刪除，不然每刪除一筆selarrrow會跟著邊化 */
                for (var row = SelRcowId.length - 1; row >= 0; row--)
                    GridTable.jqGrid("delRowData", SelRcowId[row]);
            });
        });

        function LaodQACheckData() {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainQACheckGet.ashx")%>",
                data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val() },
                CallBackFunction: function (data) {
                    $("#<%=TB_QACheckTimeStart.ClientID%>").val(data.QACheckTimeStart);
                    $("#<%=TB_QACheckTimeEnd.ClientID%>").val(data.QACheckTimeEnd);
                    $("#<%=TB_QACheckMinute.ClientID%>").val(data.QACheckMinute);
                    $("#<%=TB_QACheckWorkCode.ClientID%>").val(data.QACheckAccountWorkCode);

                    $("#MaintainQACheckDiv").show();

                    if (data.QACheckTimeStart != "")
                        $("#BT_QACheckGoin").addClass("disabled");

                    if (data.QACheckTimeStart != "" && data.QACheckAccountID < 0) {
                        $("#BT_QACheckGoOut").removeClass("disabled");

                        $("#<%=TB_QACheckWorkCode.ClientID%>").prop("disabled", false);

                        $("#BT_QACheckGoin").addClass("disabled");
                    }

                    $("#BT_AddMaintain").addClass("disabled");

                    $("#<%=TB_Operator.ClientID%>").prop("disabled", true);
                }
            });
        }

        function LaodPDCheckData() {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainPDCheckGet.ashx")%>",
                data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val() },
                CallBackFunction: function (data) {
                    $("#<%=TB_PDCheckTimeStart.ClientID%>").val(data.PDCheckTimeStart);
                    $("#<%=TB_PDCheckTimeEnd.ClientID%>").val(data.PDCheckTimeEnd);
                    $("#<%=TB_PDCheckMinute.ClientID%>").val(data.PDCheckMinute);
                    $("#<%=TB_PDCheckWorkCode.ClientID%>").val(data.PDCheckAccountWorkCode);

                    if (data.PDCheckTimeStart != "")
                        $("#BT_PDCheckGoin").addClass("disabled");

                    if (data.PDCheckTimeStart != "" && data.PDCheckAccountID < 0) {
                        $("#BT_PDCheckGoOut").removeClass("disabled");

                        $("#<%=TB_PDCheckWorkCode.ClientID%>").prop("disabled", false);

                        $("#BT_PDCheckGoin").addClass("disabled");
                    }

                    $("#BT_AddMaintain").addClass("disabled");

                    $("#<%=TB_Operator.ClientID%>").prop("disabled", true);
                }
            });
        }

        function LoadWaitReportData() {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainWaitReportData.ashx")%>",
                data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val() },
                CallBackFunction: function (data) {
                    $("#MaintainInfoOperatorDiv").show();

                    $("#<%=TB_MaintainMinute.ClientID%>").val(data.TotalMaintainMinute);

                    $("#<%=TB_MaintainMinuteByMachine.ClientID%>").val(data.TotalMaintainMinuteByMachine);

                    OperatorWorkCodeColumnName = data.OperatorWorkCodeColumnName;

                    if ($.StringConvertBoolean(data.IsHaveOperator) || $.StringConvertBoolean(data.IsGoToQACheck) || $.StringConvertBoolean(data.IsGoToPDCheck)) {
                        $("#BT_MaintainFaultByFirstAdd,#BT_MaintainFaultByFirstDelete").addClass("disabled").hide();

                        $("#<%=DDL_Responsible.ClientID%>").prop("disabled", true);

                        $("#<%=DDL_FaultCategory.ClientID%>").val("").prop("disabled", true).trigger("change");
                    }

                    if ($.StringConvertBoolean(data.IsHaveOperator) && $.StringConvertBoolean(data.IsGoToQACheck) && !$.StringConvertBoolean(data.IsGoToPDCheck)) {
                        LaodQACheckData();

                        $("#MaintainInfoDiv").show();
                    }

                    if ($.StringConvertBoolean(data.IsHaveOperator) && $.StringConvertBoolean(data.IsQACheckFinish) && !$.StringConvertBoolean(data.IsGoToPDCheck)) {
                        LaodQACheckData();

                        $("#<%=TB_QACheckWorkCode.ClientID%>").prop("disabled", true);

                        $("#BT_QACheckGoOut").addClass("disabled");

                        $("#MaintainInfoDiv").show();

                        if ($("#MaintainQACheck").hasClass("in"))
                            $("#MaintainQACheck").collapse("toggle");
                    }
                    else if ($.StringConvertBoolean(data.IsHaveOperator) && $.StringConvertBoolean(data.IsQACheckFinish) && $.StringConvertBoolean(data.IsGoToPDCheck)) {
                        LaodQACheckData();

                        LaodPDCheckData();

                        $("#<%=TB_QACheckWorkCode.ClientID%>").prop("disabled", true);

                        $("#BT_QACheckGoOut").addClass("disabled");

                        $("#<%=TB_ParentMaintainID.ClientID%>").prop("disabled", true);

                        $("#BT_Finish,#BT_Delete").addClass("disabled").hide();

                        $("#MaintainQACheckDiv,#MaintainInfoDiv,#MaintainPDCheckDiv").show();

                        if ($("#MaintainQACheck").hasClass("in"))
                            $("#MaintainQACheck").collapse("toggle");
                        if ($("#MaintainInfo").hasClass("in"))
                            $("#MaintainInfo").collapse("toggle");
                    }
                    else if (!$.StringConvertBoolean(data.IsHaveOperator)) {
                        $("#BT_Fault,#BT_Finish").addClass("disabled");

                        $("#MaintainInfoDiv").show();

                        if ($("#MaintainQACheck").hasClass("in"))
                            $("#MaintainQACheck").collapse("toggle");
                    }

                    LoadGridData({
                        JQGridDataValue: data,
                        IsShowJQGridPager: false,
                        ListID: MaintainInfoOperatorListID,
                        TableID: MaintainInfoOperatorListTableID,
                        PagerID: MaintainInfoOperatorListPagerID
                    });

                    // 讓畫面垂直滾軸往到最下面
                    $("html,body").animate({ scrollTop: $(document).height() }, 1000);

                    if ($("#MaintainAlertDiv").find("strong").text().length > 0 && data.Rows.length > 0)
                        $("#MaintainAlertDiv").show();
                }
            });
        }

        function JqEventBind(PO) {
            if (PO.TableID != MaintainInfoOperatorListTableID)
                return;

            $("#" + MaintainInfoOperatorListTableID).bind("jqGridLoadComplete", function () {
                $(".FinishButton").click(function () {
                    var operator = $(this).data("operator");

                    VerifyWorkCode([$(this).data("operatorworkcode")], "<%=(string)GetLocalResourceObject("Str_VerifyOperatorWorkCode") %>", "<%= (string)GetLocalResourceObject("Str_VerifyOperatorWorkCodeFail") %>", function () {
                        $.ConfirmMessage({
                            Message: "<%=(string)GetLocalResourceObject("Str_ConfirmMessageByFinishOperator")%>", IsHtmlElement: true, CloseEvent: function (Result) {
                                if (!Result) {
                                    event.preventDefault();

                                    return;
                                }

                                GoToFinishByOperator(operator);
                            }
                        });
                    });
                });

                $(".CancelButton").click(function () {
                    var operator = $(this).data("operator");

                    VerifyWorkCode([$(this).data("operatorworkcode")], "<%=(string)GetLocalResourceObject("Str_VerifyOperatorWorkCode") %>", "<%= (string)GetLocalResourceObject("Str_VerifyOperatorWorkCodeFail") %>", function () {
                        $.ConfirmMessage({
                            Message: "<%=(string)GetLocalResourceObject("Str_ConfirmMessageByCancelOperator")%>", IsHtmlElement: true, CloseEvent: function (Result) {
                                if (!Result) {
                                    event.preventDefault();
                                    return;
                                }

                                GoToCancelByOperator(operator);
                            }
                        });
                    });

                });
            });
        }

        //指定OperatorWorkCode驗證工號
        function VerifyWorkCode(OperatorWorkCode, TitleBarText, VerifyFailMessage, SuccessCallBackFunction) {
            var FrameID = "VerifyWorkCode_FrameID";

            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/WorkCodeInput.aspx") %>",
                iFrameOpenParameters: { IsRequired: true },
                TitleBarText: TitleBarText,
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 710,
                height: 560,
                NewWindowPageDivID: "VerifyWorkCode_DivID",
                NewWindowPageFrameID: FrameID,
                CloseEvent: function () {
                    var Frame = $("#" + FrameID + "").contents();

                    if (Frame != null) {
                        var WorkCode = Frame.find("#TB_WorkCode").val();

                        if ($.grep(OperatorWorkCode, function (Node) { return Node.toString().toUpperCase() == WorkCode.toUpperCase(); }).length > 0 && SuccessCallBackFunction != null)
                            SuccessCallBackFunction();
                        else
                            $.AlertMessage({ Message: VerifyFailMessage });
                    }
                }
            });
        }

        //指定operator設定完成維修
        function GoToFinishByOperator(operator) {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainPreOut.ashx")%>",
                data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val(), Operator: operator },
                CallBackFunction: function (data) {
                    LoadWaitReportData();
                }
            });
        }

        //指定operator取消維修
        function GoToCancelByOperator(operator) {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainCancel.ashx")%>",
                data: { MaintainID: $("#<%=HF_MaintainID.ClientID%>").val(), Operator: operator },
                CallBackFunction: function (data) {
                    LoadWaitReportData();
                }
            });
        }
    </script>
    <style>
        #MaintainAlertDiv {
            display: none;
            position: fixed;
            z-index: 99;
            border: none;
            outline: none;
            background-color: rgba(255, 255, 102, 0.6);
            color: red;
            padding: 10px;
            border-radius: 4px;
            text-align: center;
        }

        .blink {
            font-size: 54px;
            animation-duration: 2s;
            animation-name: blink;
            animation-iteration-count: infinite;
            animation-direction: alternate;
            animation-timing-function: ease-in-out;
        }

        @keyframes blink {
            0% {
                opacity: 1;
            }

            80% {
                opacity: 1;
            }

            81% {
                opacity: 0;
            }

            100% {
                opacity: 0;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_Div" runat="server" />
    <asp:HiddenField ID="HF_MaintainID" runat="server" />
    <asp:HiddenField ID="HF_ProcessID" runat="server" />
    <asp:HiddenField ID="HF_AUFPL" runat="server" />
    <asp:HiddenField ID="HF_APLZL" runat="server" />
    <asp:HiddenField ID="HF_VORNR" runat="server" />
    <asp:HiddenField ID="HF_PLNBEZ" runat="server" />
    <asp:HiddenField ID="HF_DeviceID" runat="server" />
    <asp:HiddenField ID="HF_SecondOperatorWorkCode" runat="server" />
    <asp:HiddenField ID="HF_IsHaveMaintain" runat="server" ClientIDMode="Static" Value="0" />
    <asp:HiddenField ID="HF_IsOnMaintain" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="HF_IsComplete" runat="server" Value="0" ClientIDMode="Static" />
    <div id="MaintainAlertDiv" style="width: 100%">
        <p class="blink"><strong><%=(string)GetLocalResourceObject("Str_StartMaintainAlertContent") %></strong></p>
    </div>
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#TicketInfo">
            <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo%>"></asp:Literal>
        </div>
        <div id="TicketInfo" class="panel-collapse collapse in" aria-expanded="true">
            <div class="panel-body">
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_TicketID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_TicketID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MachineID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_MachineName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MachineName%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MachineName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_MAKTX%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group" style="display: none">
                    <label for="<%= TB_RoutingName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_RoutingName%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_RoutingName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_ProcessName.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_ProcessName%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ProcessName" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_ParentMaintainID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_ParentMaintainID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ParentMaintainID" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_WaitTimeStart.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_WaitTimeStart%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_WaitTimeStart" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_WaitTimeEnd.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_WaitTimeEnd%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_WaitTimeEnd" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_Operator.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketInfo_Operator%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_Operator" runat="server" CssClass="form-control"></asp:TextBox>
                        <span class="input-group-btn">
                            <input type="button" class="btn btn-primary" id="BT_AddMaintain" value="<%=(string)GetLocalResourceObject("Str_BT_AddMaintain")%>" />
                        </span>
                    </div>
                </div>
                <div class="col-xs-12 form-group">
                    <div id="MaintainFaultByFirst" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor7") %>">
                        <div class="panel-heading text-center">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainFaultByFirstListTitle%>"></asp:Literal>
                        </div>
                        <div class="panel-body">
                            <div class="col-xs-4 form-group required">
                                <label for="<%= DDL_FaultCategory.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:Str_FaultCategory%>"></asp:Literal>
                                </label>
                                <asp:DropDownList ID="DDL_FaultCategory" runat="server" CssClass="form-control selectpicker show-tick">
                                </asp:DropDownList>
                            </div>
                            <div class="col-xs-4 form-group required">
                                <label for="<%= DDL_Fault.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:Str_Fault%>"></asp:Literal>
                                </label>
                                <asp:DropDownList ID="DDL_Fault" runat="server" CssClass="form-control" data-live-search="true">
                                </asp:DropDownList>
                            </div>
                            <div class="col-xs-4 form-group required">
                                <label for="<%= DDL_Responsible.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:Str_Responsible%>"></asp:Literal>
                                </label>
                                <asp:DropDownList ID="DDL_Responsible" runat="server" CssClass="form-control selectpicker show-tick" multiple>
                                </asp:DropDownList>
                            </div>
                            <div class="col-xs-12 form-group">
                                <input type="button" class="btn btn-primary" id="BT_MaintainFaultByFirstAdd" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName")%>" />
                                <input type="button" class="btn btn-warning" id="BT_MaintainFaultByFirstDelete" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName")%>" />
                            </div>
                            <div class="col-xs-12 form-group">
                                <div id="MaintainFaultByFirstList"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div id="MaintainInfoOperatorDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#OperatorList">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfoOperator%>"></asp:Literal>
        </div>
        <div id="OperatorList" class="panel-collapse collapse in" aria-expanded="true">
            <div class="panel-body">
                <div id="MaintainInfoOperatorList"></div>
            </div>
        </div>
    </div>
    <div id="MaintainQACheckDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor2") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#MaintainQACheck">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainQACheck%>"></asp:Literal>
        </div>
        <div id="MaintainQACheck" class="panel-collapse collapse in" aria-expanded="true">
            <div class="panel-body">
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_QACheckTimeStart.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainQACheckInfo_QACheckTimeStart%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_QACheckTimeStart" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                        <span class="input-group-btn">
                            <input type="button" class="btn btn-primary" id="BT_QACheckGoin" value="<%=(string)GetLocalResourceObject("Str_BT_QACheckGoin")%>" />
                        </span>
                    </div>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_QACheckTimeEnd.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainQACheckInfo_QACheckTimeEnd%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_QACheckTimeEnd" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_QACheckMinute.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainQACheckInfo_QACheckMinute%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_QACheckMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_QACheckWorkCode.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainQACheckInfo_QACheckWorkCode%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_QACheckWorkCode" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                        <span class="input-group-btn">
                            <input type="button" class="btn btn-primary disabled" id="BT_QACheckGoOut" value="<%=(string)GetLocalResourceObject("Str_BT_QACheckGoOut")%>" />
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div id="MaintainInfoDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor8") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#MaintainInfo">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo%>"></asp:Literal>
        </div>
        <div id="MaintainInfo" class="panel-collapse collapse in" aria-expanded="true">
            <div class="panel-body">
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_MaintainMinute.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_MaintainMinute%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_MaintainMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                        <span class="input-group-btn">
                            <input type="button" class="btn btn-primary" id="BT_Fault" value="<%=(string)GetLocalResourceObject("Str_BT_Fault")%>" />
                        </span>
                    </div>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_MaintainMinuteByMachine.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_MaintainMinuteByMachine%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MaintainMinuteByMachine" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= DDL_IsConfirm.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_IsConfirm%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsConfirm" runat="server" CssClass="form-control">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_ConfirmWorkCode.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_ConfirmWorkCode%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_ConfirmWorkCode" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= DDL_IsTrace.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_IsTrace%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsTrace" runat="server" CssClass="form-control">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TraceQty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TraceQty%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TraceQty" runat="server" CssClass="form-control" Text="0" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TraceGoodQty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TraceGoodQty%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TraceGoodQty" runat="server" CssClass="form-control MumberType" Text="0" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TraceNGQty.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TraceNGQty%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TraceNGQty" runat="server" CssClass="form-control MumberType" Text="0" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TestQty1.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TestQty1%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TestQty1" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TestTicketID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TestTicketID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TestTicketID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TestQty2.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_TestQty2%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TestQty2" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= DDL_IsAlert.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_IsAlert%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsAlert" runat="server" CssClass="form-control">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Selected="True" Value="0"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= DDL_IsCancel.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_IsCancel%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsCancel" runat="server" CssClass="form-control">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Selected="True" Value="0"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-12 form-group">
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_Remark1.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_Remark1%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_Remark1" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_Remark2.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_Remark2%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_Remark2" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_Remark3.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainInfo_Remark3%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_Remark3" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>
                </div>
                <div class="col-xs-12 form-group text-center">
                    <input type="button" class="btn btn-warning" id="BT_Finish" value="<%=(string)GetLocalResourceObject("Str_BT_FinishName")%>" />
                    <%-- 2023/10/18 阿苟提出，維修單不能取消議題，開會討論後決議不給取消。--%>
                    <%--<input type="button" class="btn btn-danger disabled" id="BT_Delete" style="display:none;" value="<%=(string)GetLocalResourceObject("Str_BT_DeleteName")%>" />--%>
                </div>
            </div>
        </div>
    </div>
    <div id="MaintainPDCheckDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor6") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#MaintainPDCheck">
            <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainPDCheck%>"></asp:Literal>
        </div>
        <div id="MaintainPDCheck" class="panel-collapse collapse in" aria-expanded="true">
            <div class="panel-body">
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_PDCheckTimeStart.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainPDCheckInfo_PDCheckTimeStart%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_PDCheckTimeStart" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                        <span class="input-group-btn">
                            <input type="button" class="btn btn-primary" id="BT_PDCheckGoin" value="<%=(string)GetLocalResourceObject("Str_BT_PDCheckGoin")%>" />
                        </span>
                    </div>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_PDCheckTimeEnd.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainPDCheckInfo_PDCheckTimeEnd%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PDCheckTimeEnd" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group">
                    <label for="<%= TB_PDCheckMinute.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainPDCheckInfo_PDCheckMinute%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PDCheckMinute" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                </div>
                <div class="col-xs-4 form-group required">
                    <label for="<%= TB_PDCheckWorkCode.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainPDCheckInfo_PDCheckWorkCode%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_PDCheckWorkCode" runat="server" CssClass="form-control" disabled="true"></asp:TextBox>
                        <span class="input-group-btn">
                            <input type="button" class="btn btn-primary disabled" id="BT_PDCheckGoOut" value="<%=(string)GetLocalResourceObject("Str_BT_PDCheckGoOut")%>" />
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
