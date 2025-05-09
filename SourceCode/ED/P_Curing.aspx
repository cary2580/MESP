<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="P_Curing.aspx.cs" Inherits="ED_P_Curing" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>
<%@ Register Src="~/WUC/WUC_DataCreateInfo.ascx" TagPrefix="uc1" TagName="WUC_DataCreateInfo" %>
<%@ Register Src="~/WUC/WUC_File.ascx" TagPrefix="uc1" TagName="WUC_File" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            GetFileData();
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %> ">
            <div class="panel-body">
                <asp:HiddenField ID="HF_PID" runat="server" />
                <asp:HiddenField ID="HF_IsNewData" runat="server" />
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
                        <div class="col-xs-12 well well-sm">
                            <div class="col-xs-4 form-group">
                                <label for="TB_Zone1Fan1Temperature1" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Zone1Fan1Temperature1 %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Zone1Fan1Temperature1" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-4 form-group">
                                <label for="TB_Zone1Fan1Temperature2" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Zone1Fan1Temperature2 %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Zone1Fan1Temperature2" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-xs-12 well well-sm TransparentBackground">
                            <div class="col-xs-4 form-group">
                                <label for="TB_Zone2Fan2Temperature1" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Zone2Fan2Temperature1 %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Zone2Fan2Temperature1" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-4 form-group">
                                <label for="TB_Zone2Fan2Temperature2" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Zone2Fan2Temperature2 %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Zone2Fan2Temperature2" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-xs-12 well well-sm">
                            <div class="col-xs-4 form-group">
                                <label for="TB_CombustorTemperature1" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CombustorTemperature1 %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_CombustorTemperature1" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-4 form-group">
                                <label for="TB_CombustorTemperature2" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CombustorTemperature2 %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_CombustorTemperature2" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-xs-4 form-group">
                            <label for="TB_PassingTime" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PassingTime %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_PassingTime" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                        </div>
                        <div class="col-xs-4 form-group">
                            <label for="TB_SettingTemperature" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_SettingTemperature %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_SettingTemperature" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                        </div>
                        <div class="col-xs-12 form-group">
                            <label for="<%= TB_Remark.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Remark %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_Remark" runat="server" Rows="3" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-xs-12 form-group">
                            <uc1:WUC_File runat="server" ID="WUC_File" />
                        </div>
                        <p></p>
                        <uc1:WUC_DataCreateInfo runat="server" ID="WUC_DataCreateInfo" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
