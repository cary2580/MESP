<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="P_PreDegreasingChart.aspx.cs" Inherits="ED_P_PreDegreasingChart" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>
<%@ Register Src="~/ED/WUC/WUC_ChartParameter.ascx" TagPrefix="uc1" TagName="WUC_ChartParameter" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        function PostBackCheck()
        {
            var IsPostBack = true;

            if (!$("#<%=CB_PreDegreasing.ClientID%>,#<%=CB_UCDegreasing1.ClientID%>,#<%=CB_UCDegreasing2.ClientID%>").is(":checked"))
            {
                IsPostBack = false;
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("ProjectGlobalRes","Str_ED_P_RequiredProcess") %>" });
            }

            if (IsPostBack && !$(".WorkClass").find("input[type='checkbox']").is(":checked"))
            {
                IsPostBack = false;
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("ProjectGlobalRes","Str_ED_P_RequiredByWorkClass") %>" });
            }

            if (IsPostBack && !$(".PLID").find("input[type='checkbox']").is(":checked"))
            {
                IsPostBack = false;
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("ProjectGlobalRes","Str_ED_P_RequiredByPL") %>" });
            }

            return IsPostBack;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_SearchCondition %>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="col-xs-6 form-group required">
                    <label for="<%= TB_StartPDate.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PDate %>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_StartPDate" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearDate" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-xs-6 form-group required">
                    <label for="<%= TB_EndPDate.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PDate %>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_EndPDate" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearDate" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-xs-6 form-group">
                    <label>
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessName %>"></asp:Literal></label>
                    <p></p>
                    <label class="checkbox-inline">
                        <asp:CheckBox ID="CB_PreDegreasing" runat="server" />
                        <asp:Literal ID="L_PreDegreasing" runat="server"></asp:Literal>
                    </label>
                    <label class="checkbox-inline">
                        <asp:CheckBox ID="CB_UCDegreasing1" runat="server" />
                        <asp:Literal ID="L_UCDegreasing1" runat="server"></asp:Literal>
                    </label>
                    <label class="checkbox-inline">
                        <asp:CheckBox ID="CB_UCDegreasing2" runat="server" />
                        <asp:Literal ID="L_UCDegreasing2" runat="server"></asp:Literal>
                    </label>
                </div>
                <div class="col-xs-6 form-group">
                    <label>
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ParameterName %>"></asp:Literal></label>
                    <p></p>
                    <label class="radio-inline">
                        <asp:RadioButton ID="RB_PH" runat="server" GroupName="RB_Parameter" Checked="true" />
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                    </label>
                    <label class="radio-inline">
                        <asp:RadioButton ID="RB_HValue" runat="server" GroupName="RB_Parameter" />
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_HValue %>"></asp:Literal>
                    </label>
                    <label class="radio-inline">
                        <asp:RadioButton ID="RB_Temperature" runat="server" GroupName="RB_Parameter" />
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Temperature %>"></asp:Literal>
                    </label>
                </div>
                <div class="col-xs-6 form-group">
                    <label>
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_WorkClass %>"></asp:Literal></label>
                    <p></p>
                    <asp:CheckBoxList ID="CBL_WorkClass" runat="server" RepeatDirection="Horizontal" CssClass="WorkClass"></asp:CheckBoxList>
                </div>
                <div class="col-xs-6 form-group">
                    <label>
                        <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PLID %>"></asp:Literal></label>
                    <p></p>
                    <asp:CheckBoxList ID="CBL_PLID" runat="server" RepeatDirection="Horizontal" CssClass="PLID"></asp:CheckBoxList>
                </div>
                <div class="col-xs-12 text-center">
                    <asp:Button ID="BT_CreateChart" runat="server" Text="<%$ Resources:GlobalRes,Str_Search %>" CssClass="btn btn-primary" OnClientClick="return PostBackCheck();" OnClick="BT_CreateChart_Click" />
                </div>
            </div>
        </div>
        <uc1:WUC_ChartParameter runat="server" ID="WUC_ChartParameter" />
    </div>
</asp:Content>
