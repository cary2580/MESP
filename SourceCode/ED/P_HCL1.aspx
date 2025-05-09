<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="P_HCL1.aspx.cs" Inherits="ED_P_HCL1" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>
<%@ Register Src="~/WUC/WUC_DataCreateInfo.ascx" TagPrefix="uc1" TagName="WUC_DataCreateInfo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        function PostBackCheck()
        {
            var IsPostBack = true;

            IsPostBack = LotNumberRequiredCheck();

            return IsPostBack;
        }

        function LotNumberRequiredCheck()
        {
            var IsPostBack = true;

            $.each($(".CAGroup"), function (index, item)
            {
                if ($(item).find(".LotNumber").val() != "" && ($(item).find(".AddDateTime").val() == "" || $(item).find(".Qty").val() == "" || parseFloat($(item).find(".Qty").val()) <= 0))
                {
                    $(item).find(".Qty").focus();

                    IsPostBack = false;

                    return;
                }
            });

            if (!IsPostBack)
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage") %>" });

            return IsPostBack;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
            <div class="panel-body">
                <asp:HiddenField ID="HF_PID" runat="server" />
                <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClientClick="return PostBackCheck();" OnClick="BT_Submit_Click" />
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
                <p></p>
                <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                    <div class="panel-heading text-center">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ED_P_M_HeadText %>"></asp:Literal>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-xs-4 form-group required">
                                <label for="<%= TB_PDate.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PDate %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PDate" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                            </div>
                            <div class="col-xs-4 form-group required">
                                <label for="<%= DDL_WorkClass.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_WorkClass %>"></asp:Literal>
                                </label>
                                <asp:DropDownList ID="DDL_WorkClass" runat="server" class="form-control" required="required">
                                </asp:DropDownList>
                            </div>
                            <div class="col-xs-4 form-group required">
                                <label for="<%= DDL_PLID.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PLID %>"></asp:Literal>
                                </label>
                                <asp:DropDownList ID="DDL_PLID" runat="server" class="form-control" required="required">
                                </asp:DropDownList>
                            </div>

                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PHValue.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_ProcessSecond.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecond" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PValue1.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:Str_ED_P_PValue1 %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PValue1" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="1" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PValue2.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:Str_ED_P_PValue2 %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PValue2" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="1" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>

                            <div class="col-xs-12 form-group">
                                <label for="<%= TB_Remark.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Remark %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Remark" runat="server" Rows="3" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                            </div>

                            <div class="col-xs-12 form-group">
                                <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
                                    <div class="panel-heading text-center">
                                        <asp:Literal ID="CA1_Title" runat="server"></asp:Literal>
                                    </div>
                                    <div class="panel-body">
                                        <div class="CAGroup">
                                            <div class="col-xs-4 form-group">
                                                <label for="<%= TB_CA1_AddDateTime.ClientID%>" class="control-label">
                                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                                </label>
                                                <div class="input-group">
                                                    <asp:TextBox ID="TB_CA1_AddDateTime" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                    <span class="input-group-btn" title="Clear">
                                                        <button class="btn btn-default ClearDate" type="button">
                                                            <i class="fa fa-times"></i>
                                                        </button>
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="col-xs-4 form-group">
                                                <label for="<%= TB_CA1_Qty.ClientID%>" class="control-label">
                                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                                </label>
                                                <asp:TextBox ID="TB_CA1_Qty" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                            </div>
                                            <div class="col-xs-4 form-group">
                                                <label for="<%= TB_CA1_LotNumber.ClientID%>" class="control-label">
                                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                                </label>
                                                <asp:TextBox ID="TB_CA1_LotNumber" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <uc1:WUC_DataCreateInfo runat="server" ID="WUC_DataCreateInfo" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
