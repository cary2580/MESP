<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="P_ECoating.aspx.cs" Inherits="ED_P_ECoating" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>
<%@ Register Src="~/WUC/WUC_DataCreateInfo.ascx" TagPrefix="uc1" TagName="WUC_DataCreateInfo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            ReSetCAControl();

            $(".Qty").change(function ()
            {
                ReSetCAControl();
            });

        });

        function ReSetCAControl()
        {
            $.each($(".CAGroup"), function (index, item) 
            {
                var CAGroupIndex = parseInt($(item).data("cagroupindex"));

                /* 第一個永遠都是開啟的 */
                if (CAGroupIndex == 1)
                    return;

                /* 如果上一個CA數量有輸入的話就開啟，反之關閉 */
                if (parseFloat($(item).prev().find(".Qty").val()) > 0)
                    SetCAControlOpen($(item));
                else
                    SetCAControlClose($(item));
            });
        }

        function SetCAControlClose(CAGroup)
        {
            $(CAGroup).find(".LotNumber,.Qty,.AddDateTime").val("").addClass("readonlyColor").prop("disabled", true);

            $.datepicker._clearDate($(CAGroup).find(".AddDateTime"));
        }

        function SetCAControlOpen(CAGroup)
        {
            $(CAGroup).find(".LotNumber,.Qty,.AddDateTime").removeClass("readonlyColor").prop("disabled", false);
        }

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
                                <label for="<%= TB_PHValue2.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue2" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue2" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PHValue3.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue3" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue3" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PHValue4.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_PHValue4" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PHValue %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PHValue4" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-xs-12 well well-sm TransparentBackground">
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_ProcessSecond.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_ProcessSecond %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_ProcessSecond" runat="server" CssClass="form-control MumberType" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_Solid.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Solid %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Solid" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_PB.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PB %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_PB" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="4" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_SolventHold.ClientID%>" class="control-label">
                                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_SolventHold %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_SolventHold" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-xs-12 well well-sm">
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_Conductivity1.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_Conductivity1" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Conductivity %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Conductivity1" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_Conductivity2.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_Conductivity2" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Conductivity %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Conductivity2" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_Conductivity3.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_Conductivity3" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Conductivity %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Conductivity3" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_Conductivity4.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_Conductivity4" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Conductivity %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Conductivity4" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-xs-12 well well-sm TransparentBackground">
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_Temperature1.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_Temperature1" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Temperature %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Temperature1" runat="server" CssClass="form-control MumberType" data-decimals="1" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_Temperature2.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_Temperature2" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Temperature %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Temperature2" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="1" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_Temperature3.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_Temperature3" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Temperature %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Temperature3" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="1" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                            <div class="col-xs-3 form-group">
                                <label for="<%= TB_Temperature4.ClientID%>" class="control-label">
                                    <asp:Literal ID="L_Temperature4" runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Temperature %>"></asp:Literal>
                                </label>
                                <asp:TextBox ID="TB_Temperature4" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="1" data-toggle="tooltip" data-html="true"></asp:TextBox>
                            </div>
                        </div>

                        <div class="col-xs-12 form-group">
                            <label for="<%= TB_Remark.ClientID%>" class="control-label">
                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_Remark %>"></asp:Literal>
                            </label>
                            <asp:TextBox ID="TB_Remark" runat="server" Rows="3" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-xs-6 form-group">
                            <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
                                <div class="panel-heading text-center">
                                    <asp:Literal ID="CA1_Title" runat="server"></asp:Literal>
                                </div>
                                <div class="panel-body">
                                    <div class="CAGroup" data-cagroupindex="1">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA1_AddDateTime1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA1_AddDateTime1" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA1_Qty1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA1_Qty1" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA1_LotNumber1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA1_LotNumber1" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="CAGroup" data-cagroupindex="2">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA1_AddDateTime2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA1_AddDateTime2" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA1_Qty2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA1_Qty2" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA1_LotNumber2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA1_LotNumber2" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="CAGroup" data-cagroupindex="3">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA1_AddDateTime3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA1_AddDateTime3" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA1_Qty3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA1_Qty3" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA1_LotNumber3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA1_LotNumber3" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-xs-6 form-group">
                            <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
                                <div class="panel-heading text-center">
                                    <asp:Literal ID="CA2_Title" runat="server"></asp:Literal>
                                </div>
                                <div class="panel-body">
                                    <div class="CAGroup" data-cagroupindex="1">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA2_AddDateTime1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA2_AddDateTime1" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA2_Qty1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA2_Qty1" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA2_LotNumber1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA2_LotNumber1" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="CAGroup" data-cagroupindex="2">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA2_AddDateTime2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA2_AddDateTime2" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA2_Qty2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA2_Qty2" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA2_LotNumber2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA2_LotNumber2" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="CAGroup" data-cagroupindex="3">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA2_AddDateTime3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA2_AddDateTime3" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA2_Qty3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA2_Qty3" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA2_LotNumber3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA2_LotNumber3" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-xs-6 form-group">
                            <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
                                <div class="panel-heading text-center">
                                    <asp:Literal ID="CA3_Title" runat="server"></asp:Literal>
                                </div>
                                <div class="panel-body">
                                    <div class="CAGroup" data-cagroupindex="1">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA3_AddDateTime1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA3_AddDateTime1" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA3_Qty1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA3_Qty1" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA3_LotNumber1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA3_LotNumber1" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="CAGroup" data-cagroupindex="2">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA3_AddDateTime2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA3_AddDateTime2" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA3_Qty2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA3_Qty2" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA3_LotNumber2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA3_LotNumber2" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="CAGroup" data-cagroupindex="3">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA3_AddDateTime3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA3_AddDateTime3" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA3_Qty3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA3_Qty3" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA3_LotNumber3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA3_LotNumber3" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-xs-6 form-group">
                            <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
                                <div class="panel-heading text-center">
                                    <asp:Literal ID="CA4_Title" runat="server"></asp:Literal>
                                </div>
                                <div class="panel-body">
                                    <div class="CAGroup" data-cagroupindex="1">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA4_AddDateTime1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA4_AddDateTime1" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA4_Qty1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA4_Qty1" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA4_LotNumber1.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA4_LotNumber1" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="CAGroup" data-cagroupindex="2">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA4_AddDateTime2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA4_AddDateTime2" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA4_Qty2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA4_Qty2" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA4_LotNumber2.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA4_LotNumber2" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="CAGroup" data-cagroupindex="3">
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA4_AddDateTime3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_AddDateTime %>"></asp:Literal>
                                            </label>
                                            <div class="input-group">
                                                <asp:TextBox ID="TB_CA4_AddDateTime3" runat="server" CssClass="form-control AddDateTime TimeDatepicker readonly"></asp:TextBox>
                                                <span class="input-group-btn" title="Clear">
                                                    <button class="btn btn-default ClearDate" type="button">
                                                        <i class="fa fa-times"></i>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA4_Qty3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_Qty %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA4_Qty3" runat="server" CssClass="form-control Qty MumberType" data-MumberTypeDecimals="2"></asp:TextBox>
                                        </div>
                                        <div class="col-xs-4 form-group">
                                            <label for="<%= TB_CA4_LotNumber3.ClientID%>" class="control-label">
                                                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_CA_LotNumber %>"></asp:Literal>
                                            </label>
                                            <asp:TextBox ID="TB_CA4_LotNumber3" runat="server" CssClass="form-control LotNumber"></asp:TextBox>
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
</asp:Content>
