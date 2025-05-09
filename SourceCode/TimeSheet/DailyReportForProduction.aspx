<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="DailyReportForProduction.aspx.cs" Inherits="TimeSheet_DailyReportForProduction" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">

    <script type="text/javascript">

        var NavButton = new Array();

        $(function ()
        {
            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
                $("#SearchResultListDiv").show();
            else
                $("#SearchResultListDiv").hide();
        });

        function LoadGridDataCustomColModel(PO, colModel)
        {
            $.each(colModel, function (Index, Item)
            {
                let FilterSelectColumn = $.grep(JQGridDataValue.FilterSelectColumnNames, function (FCN)
                {
                    return FCN === Item.name;
                });

                if (FilterSelectColumn.length > 0)
                {
                    colModel[Index].stype = "select";
                    colModel[Index].searchoptions.dataInit = function (elem)
                    {
                        $(elem).addClass("selectpicker").data("container", "body").data("live-search", "true").data("actions-box", "true").data("selected-text-format", "count > 5");

                        $(elem).selectpicker("render");

                        $(elem).selectpicker("refresh");
                    }
                }
            });

            return colModel;
        }

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName)
                {
                    var columnNames = $.map(cm, function (value, index) { return value.name; });

                    var TaskDateTime = "";
                    var PVGroupID = "";
                    var ProcessTypeID = "";

                    if ($.inArray(JQGridDataValue.TaskDateTimeColumnName, columnNames) > 0)
                        TaskDateTime = $(this).jqGrid("getCell", RowID, JQGridDataValue.TaskDateTimeColumnName);

                    if ($.inArray(JQGridDataValue.PVGroupIDColumnName, columnNames) > 0)
                        PVGroupID = $(this).jqGrid("getCell", RowID, JQGridDataValue.PVGroupIDColumnName);

                    if ($.inArray(JQGridDataValue.ProcessTypeIDColumnName, columnNames) > 0)
                        ProcessTypeID = $(this).jqGrid("getCell", RowID, JQGridDataValue.ProcessTypeIDColumnName);

                    if (TaskDateTime != "" && PVGroupID != "" && ProcessTypeID != "")
                    {
                        var FrameID = "DailyReportForProductionRemark_FrameID";

                        $.OpenPage({
                            Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/DailyReportForProduction_Remark.aspx") %>",
                            iFrameOpenParameters: { TaskDateTime: TaskDateTime, PVGroupID: PVGroupID, ProcessTypeID: ProcessTypeID },
                            TitleBarText: "<%=(string)GetLocalResourceObject("Str_DailyReportForProductionRemark_Title") %>",
                            TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                            width: 720,
                            height: 660,
                            NewWindowPageDivID: "DailyReportForProductionRemark_M_DivID",
                            NewWindowPageFrameID: FrameID,
                            CloseEvent: function (result)
                            {
                                var Remark = $(result).find("#" + FrameID).contents().find("#TB_Remark").val();

                                $("#" + JqGridParameterObject.TableID).jqGrid("setCell", RowID, JQGridDataValue.RemarkColumnName, Remark == "" ? null : Remark);
                            }
                        });
                    }
                }
            });

            $("#" + JqGridParameterObject.TableID).bind("jqGridAfterGridComplete", function ()
            {
                var Rows = $(this).jqGrid("getDataIDs");

                var TotalTaskQty = 0;
                var TotalGoodQty = 0;
                var TotalDifferenceQty = 0;
                var TotalACCTaskQtyByMonth = 0;
                var TotalACCTaskQty = 0;
                var TotalACCGoodQty = 0;
                var TotalACCDifferenceQty = 0;

                for (var i = 0; i < Rows.length; i++)
                {
                    var RowID = Rows[i];

                    TotalTaskQty += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.TaskQtyColumnName)).value();
                    TotalGoodQty += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.GoodQtyColumnName)).value();

                    var DifferenceQty = numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.DifferenceQtyColumnName)).value();
                    TotalDifferenceQty += DifferenceQty;

                    if (DifferenceQty < 0)
                        $(this).jqGrid("setCell", RowID, JQGridDataValue.DifferenceQtyColumnName, "", { background: JQGridDataValue.DifferenceQtyColumnName, color: "red", "font-weight": "bold" });

                    TotalACCTaskQtyByMonth += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.ACCTaskQtyByMonthColumnName)).value();
                    TotalACCTaskQty += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.ACCTaskQtyColumnName)).value();
                    TotalACCGoodQty += numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.ACCGoodQtyColumnName)).value();

                    var ACCDifferenceQty = numeral($(this).jqGrid("getCell", RowID, JQGridDataValue.ACCDifferenceQtyColumnName)).value();
                    TotalACCDifferenceQty += ACCDifferenceQty;

                    if (ACCDifferenceQty < 0)
                        $(this).jqGrid("setCell", RowID, JQGridDataValue.ACCDifferenceQtyColumnName, "", { background: JQGridDataValue.ACCDifferenceQtyColumnName, color: "red", "font-weight": "bold" });
                }

                $(this).jqGrid("footerData", "set", {
                    [JQGridDataValue.ProcessTypeNameColumnName]: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_SubTotal")%>",
                    [JQGridDataValue.TaskQtyColumnName]: numeral(TotalTaskQty).format("0,0"),
                    [JQGridDataValue.GoodQtyColumnName]: numeral(TotalGoodQty).format("0,0"),
                    [JQGridDataValue.DifferenceQtyColumnName]: TotalDifferenceQty < 0 ? "<span style=\"color:red\">" + numeral(TotalDifferenceQty).format("0,0") + "</span>" : numeral(TotalDifferenceQty).format("0,0"),
                    [JQGridDataValue.ACCTaskQtyByMonthColumnName]: numeral(TotalACCTaskQtyByMonth).format("0,0"),
                    [JQGridDataValue.ACCTaskQtyColumnName]: numeral(TotalACCTaskQty).format("0,0"),
                    [JQGridDataValue.ACCGoodQtyColumnName]: numeral(TotalACCGoodQty).format("0,0"),
                    [JQGridDataValue.ACCDifferenceQtyColumnName]: TotalACCDifferenceQty < 0 ? "<span style=\"color:red\">" + numeral(TotalACCDifferenceQty).format("0,0") + "</span>" : numeral(TotalACCDifferenceQty).format("0,0")
                });
            });

            NavButton = new Array();

            NavButton.push({
                caption: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName")%>",
                buttonicon: "fa fa-file-excel-o",
                position: "last",
                onClickButton: function ()
                {
                    $.Ajax({
                        url: "<%=ResolveClientUrl(@"~/Service/ExportJQGridData.ashx")%>",
                        data: { JQGridDataValue: JSON.stringify(JQGridDataValue) },
                        timeout: 1200 * 1000,
                        CallBackFunction: function (data)
                        {
                            if (data.Result && data.GUID != null)
                            {
                                if ($.ispAad())
                                    window.open("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                                else
                                    OpenWindowDownloadFile("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                            }
                        }
                    });
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsShowResultList" runat="server" Value="0" />
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_DateStart.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DateStart %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_DateStart" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group required">
        <label for="<%= TB_DateEnd.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_DateEnd %>"></asp:Literal>
        </label>
        <div class="input-group">
            <asp:TextBox ID="TB_DateEnd" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
            <span class="input-group-btn" title="Clear">
                <button class="btn btn-default ClearDate" type="button">
                    <i class="fa fa-times"></i>
                </button>
            </span>
        </div>
    </div>
    <div class="col-xs-3 form-group">
        <label for="<%= TB_PVGroupName.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_PVGroupName %>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_PVGroupName" runat="server" CssClass="form-control"></asp:TextBox>
    </div>
    <div class="col-xs-3 form-group">
        <label for="<%= DDL_ProcessType.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ProcessType %>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_ProcessType" runat="server" CssClass="form-control">
        </asp:DropDownList>
    </div>
    <div class="col-xs-3 form-group">
        <label for="<%= DDL_IsViewOnlyAchieve.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsViewOnlyAchieve %>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsViewOnlyAchieve" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value="-1" Selected="True"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="0"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="1"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-3 form-group">
        <label for="<%= DDL_IsViewHaveRemark.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:Str_IsViewHaveRemark %>"></asp:Literal>
        </label>
        <asp:DropDownList ID="DDL_IsViewHaveRemark" runat="server" CssClass="form-control" required="required">
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value="-1" Selected="True"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
            <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
        </asp:DropDownList>
    </div>
    <div class="col-xs-12">
        <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
    </div>
    <div class="col-xs-12">
        <p></p>
    </div>
    <div class="col-xs-12">
        <div id="SearchResultListDiv" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
