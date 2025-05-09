<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="C_Calendar_M.aspx.cs" Inherits="ED_C_Calendar_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>
<%@ Register Src="~/WUC/WUC_DataCreateInfo.ascx" TagPrefix="uc1" TagName="WUC_DataCreateInfo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
            <div class="panel-body">
                <asp:HiddenField ID="HF_CID" runat="server" />
                <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click" />
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
                <p></p>
                <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                    <div class="panel-heading text-center">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ED_C_M_HeadText %>"></asp:Literal>
                    </div>
                    <div class="panel-body">
                        <div class="col-xs-3 form-group required">
                            <label for="<%= TB_CleanDate.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:Str_CleanDate %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_CleanDate" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                        </div>
                        <div class="col-xs-3 form-group required">
                            <label for="<%= DDL_WorkClass.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_WorkClass %>"></asp:Literal>
                            </label>
                            <asp:DropDownList ID="DDL_WorkClass" runat="server" class="form-control" required="required">
                            </asp:DropDownList>
                        </div>
                        <div class="col-xs-3 form-group required">
                            <label for="<%= DDL_PLID.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PLID %>"></asp:Literal>
                            </label>
                            <asp:DropDownList ID="DDL_PLID" runat="server" class="form-control" required="required">
                            </asp:DropDownList>
                        </div>
                        <div class="col-xs-3 form-group required">
                            <label for="<%= DDL_Process.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:Str_Process %>"></asp:Literal>
                            </label>
                            <asp:DropDownList ID="DDL_Process" runat="server" class="form-control" required="required">
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
