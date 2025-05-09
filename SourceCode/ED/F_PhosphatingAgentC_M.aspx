<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="F_PhosphatingAgentC_M.aspx.cs" Inherits="ED_F_PhosphatingAgentC_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>
<%@ Register Src="~/WUC/WUC_DataCreateInfo.ascx" TagPrefix="uc1" TagName="WUC_DataCreateInfo" %>
<%@ Register Src="~/WUC/WUC_File.ascx" TagPrefix="uc1" TagName="WUC_File" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <style>
        .table tr td, .table thead tr th {
            padding: 2px !important;
            text-align: center;
        }

        .table > tbody > tr > td {
            vertical-align: middle;
        }
    </style>
    <script type="text/javascript">
        $(function ()
        {
            GetFileData();
        });

        function PostBackCheck()
        {
            var Result = false;

            var IsHaveValue = false;

            $.each($(".ReportData"), function (index, item)
            {
                if ($(this).val() != "")
                    IsHaveValue = true;
            });

            if (IsHaveValue)
                Result = (CheckFirstData() && CheckReportData())
            else
                Result = (CheckFirstData());

            return Result;
        }

        function CheckFirstData()
        {
            var Result = false;

            var FirstDataCount = 0;

            $.each($(".FirstData"), function (index, item)
            {
                if ($(this).val() != "")
                    FirstDataCount++;
                else
                {
                    $(item).focus();
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage") %>" });
                    return false;
                }
            });

            if (FirstDataCount > 0)
                Result = true;

            return Result;
        }

        function CheckReportData()
        {
            var ReportValueCount = 0;

            var Result = false;

            $.each($(".ReportData"), function (index, item)
            {
                if ($(this).val() != "")
                    ReportValueCount++;
                else
                {
                    $(item).focus();
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage") %>" });
                    return false;

                }
            });

            if (ReportValueCount > 3)
            {
                if (JqGridRowData.length < 1)
                    $.AlertMessage({ Message: "<%=(string)GetLocalResourceObject("Str_ED_F_EmptyAttachMSG")%>" });
                else
                    Result = true;
            }

            return Result;
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel-group">
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %> ">
            <div class="panel-body">
                <asp:HiddenField ID="HF_PAID" runat="server" />
                <asp:HiddenField ID="HF_IsNewData" runat="server" />
                <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClientClick="return PostBackCheck();" OnClick="BT_Submit_Click" />
                <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
                <p></p>
                <div class="row">
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_PADate.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_ED_F_PADate %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PADate" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                    </div>
                </div>
                <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
                    <div class="panel-heading text-center ">
                        <%=(string)GetLocalResourceObject("Str_ED_F_M_HeadText")%>
                    </div>
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th style="width: 15%;"><%=(string)GetLocalResourceObject("Str_ED_F_M_TableHead_Code")%></th>
                                <th style="width: 20%;"><%=(string)GetLocalResourceObject("Str_ED_F_M_TableHead_Qty")%></th>
                                <th style="width: 25%;"><%=(string)GetLocalResourceObject("Str_ED_F_M_TableHead_LotNumber")%></th>
                                <th style="width: 40%;"><%=(string)GetLocalResourceObject("Str_ED_F_M_TableHead_Remark")%></th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="align-middle"><asp:Literal ID="L_Y001" runat="server" Text="Y001"></asp:Literal></td>
                                <td>
                                    <asp:TextBox ID="TB_Y001_Qty" runat="server" CssClass="form-control MumberType FirstData" data-MumberTypeDecimals="2" required="required"></asp:TextBox>
                                </td>
                                <td class="col-md-3">
                                    <asp:TextBox ID="TB_Y001_LotNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                </td>
                                <td class="col-md-3">
                                    <asp:TextBox ID="TB_Y001_Remark" runat="server" CssClass="form-control"></asp:TextBox>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
                    <div class="panel-heading text-center ">
                        <%=(string)GetLocalResourceObject("Str_ED_F_M_HeadText_Report")%>
                    </div>
                    <div class="panel-body">
                        <div class="col-xs-3 form-group">
                            <label for="TB_AgentDensity" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_F_CAgentDensity %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_AgentDensity" runat="server" CssClass="form-control MumberType ReportData" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                        </div>
                        <div class="col-xs-3 form-group">
                            <label for="TB_PHValue" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_F_PHValue %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_PHValue" runat="server" CssClass="form-control MumberType ReportData" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                        </div>
                        <div class="col-xs-3 form-group">
                            <label for="<%= TB_ColorStatus.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_F_ColorStatus %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_ColorStatus" runat="server" CssClass="form-control ReportData" data-toggle="tooltip" data-html="true"></asp:TextBox>
                        </div>
                        <div class="col-xs-3 form-group">
                            <label for="<%= DDL_EDResultID.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_F_EDResultID %>"></asp:Literal>
                            </label>
                            <asp:DropDownList ID="DDL_EDResultID" DataCodeType="EDResultOKNG" runat="server" class="form-control ReportData">
                            </asp:DropDownList>
                        </div>
                        <div class="col-xs-12 form-group">
                            <label for="<%= TB_Remark.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_F_Remark %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_Remark" runat="server" Rows="3" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <uc1:WUC_File runat="server" ID="WUC_File" />
                </div>
                <p></p>
                <uc1:WUC_DataCreateInfo runat="server" ID="WUC_DataCreateInfo" />
            </div>
        </div>
    </div>
</asp:Content>
