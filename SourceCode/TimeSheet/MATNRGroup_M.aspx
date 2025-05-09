<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="MATNRGroup_M.aspx.cs" Inherits="TimeSheet_MATNRGroup_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            if ($.StringConvertBoolean($("#<%= HF_IsNewGroup.ClientID %>").val()))
                $("#<%= BT_Delete.ClientID%>").hide();

            $("#BT_AddMATNR").click(function ()
            {
                var FrameID = "MATNRSelect_FrameID";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/MATNRSelect.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_MATNRSelect_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 920,
                    height: 770,
                    NewWindowPageDivID: "MATNRSelect_DivID",
                    NewWindowPageFrameID: FrameID,
                    parentWindow: window.parent,
                    CloseEvent: function (result)
                    {
                        var MATNRJson = $(result).find("#" + FrameID).contents().find("#HF_MATNR").val();

                        var MATNRList = $.parseJSON(MATNRJson);

                        var JqGrid = $("#" + JqGridParameterObject.TableID);

                        var jqdata = JqGrid.jqGrid("getRowData");

                        var AddNewMATNRList = new Array();

                        $.each(MATNRList, function (index, item)
                        {
                            var RowData = {
                                MATNR: item.MATNR,
                                MAKTX: item.MAKTX
                            };

                            if ((jqdata.filter(F => F.MATNR === RowData.MATNR && F.MAKTX == RowData.MAKTX).length) < 1)
                                AddNewMATNRList.push(RowData);
                        });

                        var RowId = JqGrid.jqGrid("getDataIDs");

                        JqGrid.jqGrid("addRowData", RowId, AddNewMATNRList, "last");
                    }
                });
            });

            $("#BT_DeleteMATNR").click(function ()
            {
                var JqGrid = $("#" + JqGridParameterObject.TableID);

                var SelRcowId = JqGrid.jqGrid("getGridParam", "selarrrow");

                /* 只能倒者刪除，不然每刪除一筆selarrrow會跟著邊化 */
                for (var row = SelRcowId.length - 1; row >= 0; row--)
                {
                    JqGrid.jqGrid('delRowData', SelRcowId[row]);
                }

                JqGrid.trigger("reloadGrid");
            });
        });

        function CheckSubmit(IsDeleteAction)
        {
            var JqGrid = $("#" + JqGridParameterObject.TableID);

            var MATNRList = new Array();

            $.each(JqGrid.jqGrid("getGridParam", "data"), function (index, item)
            {
                MATNRList.push({
                    MATNR: item.MATNR,
                    MAKTX: item.MAKTX
                });
            });

            if (isNaN($("#<%# TB_SortID.ClientID%>").val()) && !$.StringConvertBoolean(IsDeleteAction))
            {
                $.AlertMessage({ Message: "<%= (string)GetLocalResourceObject("Str_SortIDTypeErrorMessage")%>" });

                return false;
            }

            if (MATNRList.length < 1 && !$.StringConvertBoolean(IsDeleteAction))
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_GridRequiredOneDataAlertMessage")%>" });

                return false;
            }

            $("#<%= HF_GroupItem.ClientID%>").val(JSON.stringify(MATNRList));

            return true;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DivID" runat="server" />
    <asp:HiddenField ID="HF_GroupID" runat="server" />
    <asp:HiddenField ID="HF_IsNewGroup" runat="server" />
    <asp:HiddenField ID="HF_GroupItem" runat="server" />

    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_MATNRGroupInfo%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-xs-12 form-group ">
                        <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClientClick="return CheckSubmit(0);" OnClick="BT_Submit_Click" />
                        <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClientClick="return CheckDelete(1);" OnClick="BT_Delete_Click" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-3 form-group required">
                        <label for="<%= TB_GroupID.ClientID%>" class="control-label ">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_GroupID %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_GroupID" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group required">
                        <label for="<%= TB_GroupName.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_GroupName %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_GroupName" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                    </div>
                    <div class="col-xs-3 form-group required">
                        <label for="<%= DDL_Section.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_Section %>"></asp:Literal>
                        </label>
                        <asp:DropDownList ID="DDL_Section" runat="server" CssClass="form-control" required="required">
                        </asp:DropDownList>
                    </div>
                    <div class="col-xs-3 form-group required">
                        <label for="<%= TB_SortID.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_SortID %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_SortID" runat="server" CssClass="form-control" required="required" Text="0"></asp:TextBox>
                    </div>
                </div>
                <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                    <div class="panel-heading text-center">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MATNRList%>"></asp:Literal>
                    </div>
                    <div class="panel-body">
                        <div>
                            <input type="button" class="btn btn-brown" id="BT_AddMATNR" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_AddName")%>" />
                            <input type="button" class="btn btn-orange" id="BT_DeleteMATNR" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_BT_DeleteName")%>" />
                        </div>
                        <p></p>
                        <div id="JQContainerList"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>


