<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="P_WaterRinsing.aspx.cs" Inherits="ED_P_WaterRinsing" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>
<%@ Register Src="~/WUC/WUC_DataCreateInfo.ascx" TagPrefix="uc1" TagName="WUC_DataCreateInfo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
            <div class="panel-body">
                <asp:HiddenField ID="HF_PID" runat="server" />
                <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click" />
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
                <p></p>
                <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                    <div class="panel-heading text-center">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ED_P_M_HeadText %>"></asp:Literal>
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
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PHValue1.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue1" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue1" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_ProcessSecondValue1.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_ProcessSecondValue1" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecondValue1" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PHValue2.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue2" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue2" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_ProcessSecondValue2.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_ProcessSecondValue2" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecondValue2" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-xs-12 well well-sm TransparentBackground">
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PHValue3.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue3" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue3" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_ProcessSecondValue3.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_ProcessSecondValue3" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecondValue3" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PHValue4.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue4" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue4" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_ProcessSecondValue4.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_ProcessSecondValue4" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecondValue4" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-xs-12 well well-sm">
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PHValue5.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue5" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue5" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_ProcessSecondValue5.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_ProcessSecondValue5" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecondValue5" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PHValue6.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue6" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue6" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_ProcessSecondValue6.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_ProcessSecondValue6" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecondValue6" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-xs-12 well well-sm TransparentBackground">
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PHValue7.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue7" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue7" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_ProcessSecondValue7.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_ProcessSecondValue7" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecondValue7" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PHValue8.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue8" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue8" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_ProcessSecondValue8.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_ProcessSecondValue8" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecondValue8" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-xs-12 well well-sm">
                            <div class="col-xs-4 form-group">
                                <label for="<%= TB_PHValue9.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue9" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue9" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-4 form-group">
                                <label for="<%= TB_ConductivityValue9.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_TB_ConductivityValue9" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Conductivity %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ConductivityValue9" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-4 form-group">
                                <label for="<%= TB_ProcessSecondValue9.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_ProcessSecondValue9" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecondValue9" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-xs-12 well well-sm TransparentBackground">
                            <div class="col-xs-4 form-group">
                                <label for="<%= TB_PHValue10.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue10" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue10" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-4 form-group">
                                <label for="<%= TB_ConductivityValue10.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_TB_ConductivityValue10" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Conductivity %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ConductivityValue10" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-4 form-group">
                                <label for="<%= TB_ProcessSecondValue10.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_ProcessSecondValue10" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecondValue10" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
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
