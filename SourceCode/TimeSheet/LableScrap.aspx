<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="LableScrap.aspx.cs" Inherits="TimeSheet_LableScrap" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">     
        $(function () {
            $("#<%=TB_ExcessiveLableID.ClientID%>").val("").focus();

            $("#<%=TB_MachineID.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data) {
                        if (data.A4 == null || data.A5 == null) {
                            $("#<%=TB_MachineID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=GetLocalResourceObject("Str_Error_DeviceID")%>" });

                            return;
                        }

                        $("#<%=TB_MachineID.ClientID%>").val(data.A5);

                        $("#<%=TB_ExcessiveLableID.ClientID%>").val("").focus();

                        if ($("#<%=DDL_WorkShift.ClientID%>").val() != "")
                            $("#<%=BT_Load.ClientID%>").trigger("click");
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_MachineID.ClientID%>").val("");
                    }
                });

            });

            $("#<%=DDL_WorkShift.ClientID%>").change(function () {
                if ($("#<%=TB_MachineID.ClientID%>").val() != "")
                    $("#<%=BT_Load.ClientID%>").trigger("click");
            });

            $("#<%=BT_Add.ClientID%>,#<%=BT_Load.ClientID%>").hide();

            $("#<%=TB_ExcessiveLableID.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;
                else
                    $("#<%=BT_Add.ClientID%>").trigger("click");
            });
        });

        function IsRepeat() {
            if ($.StringConvertBoolean($("#<%=HF_IsRepeat.ClientID%>").val())) {
                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/WorkCodeVerify.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_VerifySupervisorWorkCodeTitleBarText")%>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 710,
                    height: 560,
                    NewWindowPageDivID: "VerifySupervisorWorkCode_DivID",
                    IsForciblyPage: true,
                    IsShowTitleBarCloseButton: false
                });
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsRepeat" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_ExcessiveLableID%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-3 form-group required">
                <label for="<%= DDL_WorkShift.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_WorkShift%>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_WorkShift" runat="server" CssClass="form-control" required="required">
                </asp:DropDownList>
            </div>
            <div class="col-xs-3 form-group required">
                <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanMachineID %>" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-6 form-group required">
                <label for="<%= TB_ExcessiveLableID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_ExcessiveLableID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_ExcessiveLableID" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
        </div>
        <div class="col-xs-6 form-group" style="text-align: center">
            <asp:Button ID="BT_Add" runat="server" OnClick="BT_Add_Click" />
            <asp:Button ID="BT_Load" runat="server" OnClick="BT_Load_Click" />
        </div>
        <div class="col-xs-12">
            <div id="JQContainerList"></div>
        </div>
    </div>
</asp:Content>


