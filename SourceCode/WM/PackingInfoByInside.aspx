<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="PackingInfoByInside.aspx.cs" Inherits="WM_PackingInfoByInside" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#<%=TB_PackingID.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data) {
                        if (data.A8 == null) {

                            $("#<%=TB_PackingID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_WM_Empty_PackingID")%>" });

                            return;
                        }

                        $("#<%=TB_PackingID.ClientID%>").val(data.A8);

                        $("#<%=BT_Search.ClientID%>").trigger("click");
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_PackingID.ClientID%>").val("");
                    }
                });

            }).focus();

            if ($.StringConvertBoolean($("#<%=HF_IsShowResult.ClientID%>").val())) {
                $("#PackingInftDiv,#PackingListDiv").show();

                if (!$("#PackingInftDiv").hasClass("in"))
                    $("#PackingInftDiv").collapse("toggle");
            }
            else
                $("#PackingInftDiv,#PackingListDiv").hide();

            $("#<%=BT_PrintPacking.ClientID%>").click(function () {
                /*打印领料单*/
                window.open("<%=ResolveClientUrl(@"~/WM/RPT_003.aspx?PackingID=")%>" + $("#<%=HF_PackingID.ClientID%>").val(), "_blank", "toolbar=false,location=false,menubar=false,width=" + screen.availWidth + ",height=" + screen.availHeight + "");
            });

            //汇出领料单资讯
            $("#BT_Export").click(function () {
                if ($("#<%=HF_PackingID.ClientID%>").val() == "") {
                    $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                    return;
                }
                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/WM/Service/RPT_004.ashx")%>",
                    data: { PackingID: $("#<%=HF_PackingID.ClientID%>").val() },
                    CallBackFunction: function (data) {
                        if (data.Result && data.GUID != null) {
                            if ($.ispAad())
                                window.open("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                            else
                                OpenWindowDownloadFile("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                        }
                    }
                });
            });
        });

        function RemovePacking() {

            $("#<%=HF_IsShowResult.ClientID%>").val("");

            let PackingListJqGrid = $("#" + JqGridParameterObject.TableID);

            let SelRcowId = PackingListJqGrid.jqGrid("getGridParam", "selarrrow");

            let BoxNoList = new Array();

            for (var row = SelRcowId.length - 1; row >= 0; row--) {
                let RowData = PackingListJqGrid.jqGrid("getRowData", SelRcowId[row]);

                BoxNoList.push(RowData[BoxNoColumnName])
            }

            if (BoxNoList.length < 1) {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_GridSelectZeroAlertMessage")%>" });

                return false;
            }

            $("#<%=HF_RemovePackingBoxNoList.ClientID%>").val(JSON.stringify(BoxNoList));
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_PackingID" runat="server" />
    <asp:HiddenField ID="HF_IsShowResult" runat="server" Value="0" />
    <asp:HiddenField ID="HF_RemovePackingBoxNoList" runat="server" Value="0" />
    <asp:HiddenField ID="HF_PackingQty" runat="server" Value="0" />
    <div class="col-xs-4 form-group required">
        <label for="<%= TB_PackingID.ClientID%>" class="control-label">
            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PackingID%>"></asp:Literal>
        </label>
        <asp:TextBox ID="TB_PackingID" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_WM_ScanPackingID %>"></asp:TextBox>
    </div>
    <div class="col-xs-12">
        <asp:Button ID="BT_Search" runat="server" CssClass="btn btn-warning" Text="<%$ Resources:GlobalRes,Str_Search %>" OnClick="BT_Search_Click" />
    </div>
    <div class="col-xs-12">
        <p></p>
    </div>
    <div class="col-xs-12">
        <div id="PackingInftDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center" role="button" aria-expanded="true" data-toggle="collapse" href="#PackingInfoContent">
                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PackingInfo%>"></asp:Literal>
            </div>
            <div id="PackingInfoContent" class="panel-collapse collapse in" aria-expanded="true">
                <div class="panel-body">
                    <div class="row">
                        <div class="col-xs-12 form-group">
                            <asp:Button ID="BT_SaveRemark" runat="server" CssClass="btn btn-success" OnClick="BT_SaveRemark_Click" />
                            <asp:Button ID="BT_PrintPacking" runat="server" CssClass="btn btn-pink" />
                            <input id="BT_Export" type="button" class="btn btn-info" value="<%=(string)GetGlobalResourceObject("GlobalRes","Str_BT_ExportName") %>" />
                        </div>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_MATNR.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_MATNR%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_MATNR" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_MAKTX.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_MAKTX%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_MAKTX" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    </div>
                    <div class="col-xs-12 form-group">
                        <label for="<%= TB_Remark.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_Remark%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_Remark" runat="server" CssClass="form-control" MaxLength="3" TextMode="MultiLine"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_CreateAccountName.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_CreateAccountName%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_CreateAccountName" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_CreateDate.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_CreateDate%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_CreateDate" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_IsConfirm.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PackingIsConfirm%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_IsConfirm" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_IsSendOut.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PackingIsSendOut%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_IsSendOut" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_ConfirmAccountName.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PackingConfirmAccountName%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_ConfirmAccountName" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_ConfirmDate.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PackingConfirmDate%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_ConfirmDate" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group">
                        <label for="<%= TB_SendOutDate.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PackingSendOutDate%>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_SendOutDate" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xs-12">
        <div id="PackingListDiv" style="display: none;" class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_PackingList%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-xs-12 form-group">
                        <asp:Button ID="BT_RemovePacking" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" OnClientClick="return RemovePacking();" OnClick="BT_RemovePacking_Click" Visible="false" />
                    </div>
                </div>
                <div id="JQContainerList"></div>
            </div>
        </div>
    </div>
</asp:Content>
