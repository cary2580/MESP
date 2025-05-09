<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="P_CoatingTestForPD.aspx.cs" Inherits="ED_P_CoatingTestForPD" %>

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
                if ($(item).find(".LotNumber").val() != "" && ($(item).find(".Qty").val() == "" || parseFloat($(item).find(".Qty").val()) <= 0))
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
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %> ">
            <div class="panel-body">
                <asp:HiddenField ID="HF_PID" runat="server" />
                <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClientClick="return PostBackCheck();" OnClick="BT_Submit_Click" />
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
                <p></p>
                <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                    <div class="panel-heading text-center ">
                        <%=(string)GetLocalResourceObject("Str_ED_P_M_HeadText")%>
                    </div>
                    <div class="panel-body">
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
                        <div class="col-xs-3 form-group required">
                            <label for="TB_FilmThicknessValue" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_FilmThicknessValue %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_FilmThicknessValue" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="1" data-toggle="tooltip" data-html="true" required="required"></asp:TextBox>
                        </div>
                        <div class="col-xs-3 form-group">
                            <label for="<%= DDL_HardnessID.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_HardnessID %>"></asp:Literal>
                            </label>
                            <asp:DropDownList ID="DDL_HardnessID" DataCodeType="HardnessID" runat="server" class="form-control" data-toggle="tooltip" data-html="true">
                            </asp:DropDownList>
                        </div>
                        <div class="col-xs-3 form-group">
                            <label for="<%= DDL_FlexibilityID.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_FlexibilityID %>"></asp:Literal>
                            </label>
                            <asp:DropDownList ID="DDL_FlexibilityID" DataCodeType="EDResultOKNG" runat="server" class="form-control" data-toggle="tooltip" data-html="true">
                            </asp:DropDownList>
                        </div>
                        <div class="col-xs-3 form-group">
                            <label for="<%= DDL_ImpactResistanceID.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ImpactResistanceID %>"></asp:Literal>
                            </label>
                            <asp:DropDownList ID="DDL_ImpactResistanceID" DataCodeType="EDResultOKNG" runat="server" class="form-control" data-toggle="tooltip" data-html="true">
                            </asp:DropDownList>
                        </div>
                        <div class="col-xs-3 form-group">
                            <label for="<%= DDL_AdhesionID.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_AdhesionID %>"></asp:Literal>
                            </label>
                            <asp:DropDownList ID="DDL_AdhesionID" DataCodeType="AdhesionID" runat="server" class="form-control" data-toggle="tooltip" data-html="true">
                            </asp:DropDownList>
                        </div>
                        <div class="col-xs-3 form-group">
                            <label for="<%= DDL_AlcoholFrictionID.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_AlcoholFrictionID %>"></asp:Literal>
                            </label>
                            <asp:DropDownList ID="DDL_AlcoholFrictionID" DataCodeType="AlcoholFrictionID" runat="server" class="form-control" data-toggle="tooltip" data-html="true">
                            </asp:DropDownList>
                        </div>
                        <div class="col-xs-3 form-group">
                            <label for="<%= DDL_QuickCorrosionID.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_QuickCorrosionID %>"></asp:Literal>
                            </label>
                            <asp:DropDownList ID="DDL_QuickCorrosionID" DataCodeType="EDResultOKNG" runat="server" class="form-control" data-toggle="tooltip" data-html="true">
                            </asp:DropDownList>
                        </div>
                        <div class="col-xs-12 form-group">
                            <label for="<%= TB_Remark.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Remark %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_Remark" runat="server" Rows="3" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                        </div>
                        <uc1:WUC_DataCreateInfo runat="server" ID="WUC_DataCreateInfo" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

