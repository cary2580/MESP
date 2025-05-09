<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="BaseRouting.aspx.cs" Inherits="TimeSheet_BaseRouting" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">

    <script type="text/javascript">

        var ColumnClassesName = "";
        var IsTSProcessValueColumnName = "";
        var PLNNRColumnName = "";
        var PLNALColumnName = "";
        var PLNKNColumnName = "";
        var ProcessIDColumnName = "";
        var DeviceGroupIDColumnName = "";
        var ProcessTypeNameColumnName = "";
        var ProcessReWorkStandardDayColumnName = "";
        var ProcessStandardDayColumnName = "";
        var IsOutputResultMinuteColumnName = "";
        var IsOutputResultMinuteForManColumnName = "";

        $(function ()
        {
            $("#BT_Search").click(function ()
            {
                LoadData();
            });

            $("#BT_ReloadSAPData").click(function ()
            {
                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_ReloadSAPData_ConfirmMessage")%>", IsHtmlElement: true, CloseEvent: function (Result)
                    {
                        if (!Result)
                        {
                            event.preventDefault();
                            return;
                        }

                        $.Ajax({
                            url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/BaseRoutingGetList.ashx")%>",
                            timeout: 300 * 1000,
                            data: {
                                PLNNR: $("#<%=TB_PLNNR.ClientID%>").val(),
                                PLNAL: $("#<%=TB_PLNAL.ClientID%>").val(),
                                ReloadData: true
                            },
                            CallBackFunction: function ()
                            {
                                LoadData();
                            }
                        });
                    }
                });
            });
        });

        function LoadData()
        {
            $("#BT_ReloadSAPData").addClass("hide");

            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/BaseRoutingGetList.ashx")%>",
                timeout: 300 * 1000,
                data: {
                    PLNNR: $("#<%=TB_PLNNR.ClientID%>").val(),
                    PLNAL: $("#<%=TB_PLNAL.ClientID%>").val()
                },
                CallBackFunction: function (data)
                {
                    if (data.Rows.length > 0)
                    {
                        ColumnClassesName = data.ColumnClassesName;
                        IsTSProcessValueColumnName = data.IsTSProcessValueColumnName;
                        PLNNRColumnName = data.PLNNRColumnName;
                        PLNALColumnName = data.PLNALColumnName;
                        PLNKNColumnName = data.PLNKNColumnName;
                        ProcessIDColumnName = data.ProcessIDColumnName;
                        DeviceGroupIDColumnName = data.DeviceGroupIDColumnName;
                        ProcessTypeNameColumnName = data.ProcessTypeNameColumnName;
                        ProcessReWorkStandardDayColumnName = data.ProcessReWorkStandardDayColumnName;
                        ProcessStandardDayColumnName = data.ProcessStandardDayColumnName;
                        IsOutputResultMinuteColumnName = data.IsOutputResultMinuteColumnName;
                        IsOutputResultMinuteForManColumnName = data.IsOutputResultMinuteForManColumnName;

                        LoadGridData({
                            IsShowJQRowNumbers: false,
                            IsShowJQGridPager: false,
                            JQGridDataValue: data
                        });

                        $("#PL_Result").show();
                        //$("#BT_ReloadSAPData").removeClass("hide");
                    }
                }, ErrorCallBackFunction: function (data)
                {
                    $("#PL_Result").hide();
                    //$("#BT_ReloadSAPData").addClass("hide");
                }
            });
        }

        function OpenMPage(Parameters)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/BaseRouting_M.aspx") %>",
                iFrameOpenParameters: Parameters,
                TitleBarText: (Parameters.IsModify ? "<%=(string)GetLocalResourceObject("Str_Modify") %>" : "<%=(string)GetLocalResourceObject("Str_Insert")%>") + "<%=(string)GetLocalResourceObject("Str_BaseRouting_TitleBarText") %>",
                TitleBarImg:  "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 810,
                height: 560,
                NewWindowPageDivID: "BaseRouting_M_DivID",
                NewWindowPageFrameID: "BaseRouting_M_Frame",
                CloseEvent: function (result)
                {
                    LoadData();
                }
            });
        }

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridDblClickRow", function (e, RowID)
            {
                var rowData = $(this).jqGrid("getRowData", RowID);

                var UploadObject = {
                    PLNNR: rowData[PLNNRColumnName],
                    PLNAL: rowData[PLNALColumnName],
                    PLNKN: rowData[PLNKNColumnName],
                    ProcessID: rowData[ProcessIDColumnName],
                    IsModify: false
                }

                OpenMPage(UploadObject);
            });

            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === ColumnClassesName)
                {
                    var rowData = $(this).jqGrid("getRowData", RowID);

                    if (cm[CellIndex].name == DeviceGroupIDColumnName)
                    {
                        $.OpenPage({
                            Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/ProcessDeviceGroup_M.aspx") %>",
                            iFrameOpenParameters: { PLNNR: rowData[PLNNRColumnName], PLNAL: rowData[PLNALColumnName], PLNKN: rowData[PLNKNColumnName], ProcessID: rowData[ProcessIDColumnName] },
                            TitleBarText: "<%=(string)GetLocalResourceObject("Str_TitleBarText_DeviceGroupID") %>",
                            TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                            width: 510,
                            height: 560,
                            NewWindowPageDivID: "DeviceGroupID_M_DivID",
                            NewWindowPageFrameID: "DeviceGroupID_M_Frame",
                            CloseEvent: function (result)
                            {
                                LoadData();
                            }
                        });
                    }
                    else if (cm[CellIndex].name == ProcessTypeNameColumnName)
                    {
                        $.OpenPage({
                            Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/BaseRouting_M_ProcessType.aspx") %>",
                            iFrameOpenParameters: { PLNNR: rowData[PLNNRColumnName], PLNAL: rowData[PLNALColumnName], PLNKN: rowData[PLNKNColumnName], ProcessID: rowData[ProcessIDColumnName] },
                            TitleBarText: "<%=(string)GetLocalResourceObject("Str_TitleBarText_ProcessType") %>",
                            TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                            width: 510,
                            height: 560,
                            NewWindowPageDivID: "ProcessType_M_DivID",
                            NewWindowPageFrameID: "ProcessType_M_Frame",
                            CloseEvent: function (result)
                            {
                                LoadData();
                            }
                        });
                    }
                    else if (cm[CellIndex].name == ProcessReWorkStandardDayColumnName || cm[CellIndex].name == ProcessStandardDayColumnName)
                    {
                        $.OpenPage({
                            Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/BaseRouting_M_ProcessStandardDay.aspx") %>",
                            iFrameOpenParameters: { PLNNR: rowData[PLNNRColumnName], PLNAL: rowData[PLNALColumnName], PLNKN: rowData[PLNKNColumnName], ProcessID: rowData[ProcessIDColumnName] },
                            TitleBarText: "<%=(string)GetLocalResourceObject("Str_TitleBarText_ProcessStandardDay") %>",
                            TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                            width: 510,
                            height: 560,
                            NewWindowPageDivID: "ProcessStandardDay_M_DivID",
                            NewWindowPageFrameID: "ProcessStandardDay_M_Frame",
                            CloseEvent: function (result)
                            {
                                LoadData();
                            }
                        });
                    }
                    else if (cm[CellIndex].name == IsOutputResultMinuteColumnName || cm[CellIndex].name == IsOutputResultMinuteForManColumnName)
                    {
                        $.OpenPage({
                            Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/BaseRouting_M_OutputResultMinute.aspx") %>",
                            iFrameOpenParameters: { PLNNR: rowData[PLNNRColumnName], PLNAL: rowData[PLNALColumnName], PLNKN: rowData[PLNKNColumnName], ProcessID: rowData[ProcessIDColumnName] },
                            TitleBarText: "<%=(string)GetLocalResourceObject("Str_TitleBarText_OutputResultMinute") %>",
                            TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                            width: 510,
                            height: 560,
                            NewWindowPageDivID: "OutputResultMinute_M_DivID",
                            NewWindowPageFrameID: "OutputResultMinute_M_Frame",
                            CloseEvent: function (result)
                            {
                                LoadData();
                            }
                        });
                    }
                    else if ($.StringConvertBoolean(rowData[IsTSProcessValueColumnName]))
                    {
                        var UpdateLoadData = {
                            PLNNR: rowData[PLNNRColumnName],
                            PLNAL: rowData[PLNALColumnName],
                            PLNKN: rowData[PLNKNColumnName],
                            ProcessID: rowData[ProcessIDColumnName],
                            IsModify: true
                        };

                        OpenMPage(UpdateLoadData);
                    }
                }
            });
        }
    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DivID" runat="server" />
    <div class="col-xs-12">
        <div class="col-xs-4 form-group required">
            <label for="<%= TB_PLNNR.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_PLNNR %>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_PLNNR" runat="server" CssClass="form-control" required="required"></asp:TextBox>
        </div>
        <div class="col-xs-4 form-group required">
            <label for="<%= TB_PLNAL.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_PLNAL %>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_PLNAL" runat="server" CssClass="form-control" required="required"></asp:TextBox>
        </div>
        <div class="col-xs-12 form-group ">
            <input type="button" class="btn btn-primary" id="BT_Search" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_Search") %>" />
            <input type="button" class="btn btn-danger hide" id="BT_ReloadSAPData" value="<%= (string)GetLocalResourceObject("Str_ReloadSAPData")%>" style="display: none;" />
        </div>
        <div class="col-xs-12" id="PL_Result" style="display: none;">
            <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
                <div class="panel-heading text-center">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ResultList %>"></asp:Literal>
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="panel-body">
                            <div id="JQContainerList"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>


