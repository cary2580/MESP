<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="MaintainSearch.aspx.cs" Inherits="TimeSheet_MaintainSearch" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            if ($.StringConvertBoolean($("#<%=HF_IsShowResultList.ClientID%>").val()))
            {
                $("#SearchConditions").removeClass("in");

                $("#SearchResultListDiv").show();
            }
            else
                $("#SearchResultListDiv").hide();

            $("#<%=TB_MachineID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        if (data.A4 == null || data.A5 == null)
                        {
                            $("#<%=TB_MachineID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=GetLocalResourceObject("Str_Error_DeviceID")%>" });

                            return;
                        }

                        $("#<%=TB_MachineID.ClientID%>").val(data.A5);
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_MachineID.ClientID%>").val("");
                    }
                });
            });

            $("#<%=TB_TicketID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        if (data.A2 == null)
                        {
                            $("#<%=TB_TicketID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_TS_Empty_TicketID")%>" });

                            return;
                        }

                        $("#<%=TB_TicketID.ClientID%>").val(data.A2);
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_TicketID.ClientID%>").val("");
                    }
                });
            });
        });

        function JqEventBind()
        {
            $("#" + JqGridParameterObject.TableID).bind("jqGridCellSelect", function (e, RowID, CellIndex)
            {
                var cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[CellIndex].classes === JQGridDataValue.ColumnClassesName)
                {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var MaintainIDValue = "";

                    if ($.inArray(JQGridDataValue.MaintainIDColumnName, columnNames) > 0)
                        MaintainIDValue = $(this).jqGrid("getCell", RowID, JQGridDataValue.MaintainIDColumnName);

                    if (MaintainIDValue != "")
                        OpenMaintainPage(MaintainIDValue);
                }
            });
        }

        function OpenMaintainPage(MaintainID)
        {
            var FrameID = "Maintain_M_Frame";

            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/Maintain_M.aspx") %>",
                iFrameOpenParameters: { MaintainID: MaintainID },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_MaintainTitleBarText") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                TitleBarCloseButtonTriggerCloseEvent: true,
                width: 1110,
                height: 910,
                NewWindowPageDivID: "Maintain_M_DivID",
                NewWindowPageFrameID: FrameID,
                CloseEvent: function ()
                {
                    var Frame = $("#" + FrameID + "").contents();

                    if (Frame != null)
                    {
                        var MaintainID = Frame.find("#TB_MaintainID").val();

                        $.Ajax({
                            url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/TicketMaintainFaultGet.ashx")%>",
                            data: { MaintainID: MaintainID },
                            CallBackFunction: function (data)
                            {
                                var IsCancel = $.StringConvertBoolean(data.IsCancel);

                                var Rows = typeof data.Rows != "object" ? $.parseJSON(data.Rows) : data.Rows;

                                if (Rows.length < 1 && !IsCancel)
                                {
                                    $.AlertMessage({
                                        Message: "<%=(string)GetLocalResourceObject("Str_Error_NoFaultCodeRow")%>", CloseEvent: function ()
                                        {
                                            OpenMaintainPage(MaintainID);
                                        }
                                    });
                                }
                            }
                        });
                    }
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsShowResultList" runat="server" Value="0" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#SearchConditions">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_SearchCondition%>"></asp:Literal>
        </div>
        <div id="SearchConditions" class="panel-collapse collapse in" aria-expanded="true">
            <div class="panel-body">
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_OperatorWorkCode.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_OperatorWorkCode%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_OperatorWorkCode" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_MaintainStartTime.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainStartTime%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_MaintainStartTime" runat="server" CssClass="form-control DateDatepicker readonly"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearDate" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_MaintainEndTime.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainEndTime%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_MaintainEndTime" runat="server" CssClass="form-control DateDatepicker readonly"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearDate" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_MaintainID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MaintainID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MaintainID" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanMachineID %>"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= DDL_IsAlert.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_IsAlert%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsAlert" runat="server" CssClass="form-control">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= DDL_IsCompleteTrace.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_IsCompleteTrace%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_IsCompleteTrace" runat="server" CssClass="form-control">
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText%>" Value=""></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_No%>" Value="0"></asp:ListItem>
                        <asp:ListItem Text="<%$ Resources:GlobalRes,Str_Yes%>" Value="1"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-xs-3 form-group">
                    <label for="<%= TB_TicketID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_TicketID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_TicketID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanTicketID %>"></asp:TextBox>
                </div>
                <div class="col-xs-12 form-group text-center">
                    <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_BT_SearchName %>" OnClick="BT_Search_Click" />
                </div>
            </div>
        </div>
    </div>
    <div id="SearchResultListDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_SearchResultList%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>
