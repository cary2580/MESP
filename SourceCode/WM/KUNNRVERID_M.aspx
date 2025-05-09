<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="KUNNRVERID_M.aspx.cs" Inherits="WM_KUNNRVERID_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#BT_AddProductionVersion").click(function () {
                var FrameID = "ProductionVersionSelect_FrameID";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/ProductionVersionSelect.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_ProductionVersionSelect_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 920,
                    height: 770,
                    NewWindowPageDivID: "ProductionVersionSelect_DivID",
                    NewWindowPageFrameID: FrameID,
                    parentWindow: window.parent,
                    CloseEvent: function (result) {
                        var ProductionVersionJson = $(result).find("#" + FrameID).contents().find("#HF_ProductionVersion").val();

                        var ProductionVersionList = $.parseJSON(ProductionVersionJson);

                        var JqGrid = $("#" + JqGridParameterObject.TableID);

                        var jqdata = JqGrid.jqGrid("getRowData");

                        var AddNewProductionVersion = new Array();

                        $.each(ProductionVersionList, function (index, item) {
                            var RowData = {
                                MATNR: item.MATNR,
                                VERID: item.VERID,
                                TEXT1: item.TEXT1
                            };

                            if ((jqdata.filter(F => F.MATNR === RowData.MATNR && F.VERID == RowData.VERID).length) < 1)
                                AddNewProductionVersion.push(RowData);
                        });

                        var RowId = JqGrid.jqGrid("getDataIDs");

                        JqGrid.jqGrid("addRowData", RowId, AddNewProductionVersion, "last");
                    }
                });
            });

            $("#BT_DeleteProductionVersion").click(function () {
                var JqGrid = $("#" + JqGridParameterObject.TableID);

                var SelRcowId = JqGrid.jqGrid("getGridParam", "selarrrow");

                /* 只能倒者刪除，不然每刪除一筆selarrrow會跟著邊化 */
                for (var row = SelRcowId.length - 1; row >= 0; row--) {
                    JqGrid.jqGrid('delRowData', SelRcowId[row]);
                }

                JqGrid.trigger("reloadGrid");
            });
        })

        function CheckSubmit(IsDeleteAction) {
            var JqGrid = $("#" + JqGridParameterObject.TableID);

            var ProductionVersionList = new Array();

            $.each(JqGrid.jqGrid("getGridParam", "data"), function (index, item) {
                var ProductionVersion = {
                    MATNR: item.MATNR,
                    VERID: item.VERID
                };

                ProductionVersionList.push(ProductionVersion);
            });

            if (ProductionVersionList.length < 1) {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_GridRequiredOneDataAlertMessage")%>" });

                return false;
            }

            $("#<%= HF_PVL.ClientID%>").val(JSON.stringify(ProductionVersionList));

            return true;
        }
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_KUNNR" runat="server" />
    <asp:HiddenField ID="HF_PVL" runat="server" />
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_KUNNRVERIDInfo%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-xs-12 form-group ">
                        <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClientClick="return CheckSubmit(0);" OnClick="BT_Submit_Click" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-3 form-group required">
                        <label for="<%= TB_KUNNR.ClientID%>" class="control-label ">
                            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_KUNNR %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_KUNNR" runat="server" CssClass="form-control" required="required" ReadOnly="true"></asp:TextBox>
                    </div>
                    <div class="col-xs-9 form-group required">
                        <label for="<%= TB_KUNNR_Name.ClientID%>" class="control-label ">
                            <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_WM_KUNNR_Name %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_KUNNR_Name" runat="server" CssClass="form-control" required="required" ReadOnly="true"></asp:TextBox>
                    </div>
                </div>
                <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                    <div class="panel-heading text-center">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ProductionVersionList%>"></asp:Literal>
                    </div>
                    <div class="panel-body">
                        <div>
                            <input type="button" class="btn btn-brown" id="BT_AddProductionVersion" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName")%>" />
                            <input type="button" class="btn btn-orange" id="BT_DeleteProductionVersion" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName")%>" />
                        </div>
                        <p></p>
                        <div id="JQContainerList"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>


