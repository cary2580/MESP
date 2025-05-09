<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="WorkStationGoIn.aspx.cs" Inherits="TimeSheet_WorkStationGoIn" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            $("#<%=TB_WorkCode.ClientID%>").focus();

            $("#<%=TB_WorkCode.ClientID%>").keydown(function (e) {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() != "")
                    $("#<%=DDL_WorkShift.ClientID%>").focus();
            });

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
                    },
                    ErrorCallBackFunction: function (data) {
                        $("#<%=TB_MachineID.ClientID%>").val("");
                    }
                });

            });

            $("#<%=BT_Submit.ClientID%>").hide();

            $("#<%=BT_Submit_DisPlay.ClientID%>").click(function () {
                var Coefficient = parseFloat($("#<%=DDL_Coefficient.ClientID%>").selectpicker("val"));

                if (isNaN(Coefficient) || $("#<%=TB_WorkCode.ClientID%>").val() == "" || $("#<%=DDL_WorkShift.ClientID%>").selectpicker("val") == "" || $("#<%=TB_MachineID.ClientID%>").val() == "") {
                    $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage") %>" });

                    return;
                }

                /* 241213 亞當說要拿掉，因為班長來不及去確認 */
                $("#<%=BT_Submit.ClientID%>").trigger("click");

<%--                var SecondCoefficientIsAlert = (
                    parseFloat($("#<%=DDL_SecondCoefficient1.ClientID%>").val()) < 0.5 ||
                    parseFloat($("#<%=DDL_SecondCoefficient2.ClientID%>").val()) < 0.5 ||
                    parseFloat($("#<%=DDL_SecondCoefficient3.ClientID%>").val()) < 0.5 ||
                    parseFloat($("#<%=DDL_SecondCoefficient4.ClientID%>").val()) < 0.5 ||
                    parseFloat($("#<%=DDL_SecondCoefficient5.ClientID%>").val()) < 0.5 ||
                    parseFloat($("#<%=DDL_SecondCoefficient6.ClientID%>").val()) < 0.5 ||
                    parseFloat($("#<%=DDL_SecondCoefficient7.ClientID%>").val()) < 0.5 ||
                    parseFloat($("#<%=DDL_SecondCoefficient8.ClientID%>").val()) < 0.5 ||
                    parseFloat($("#<%=DDL_SecondCoefficient9.ClientID%>").val()) < 0.5
                );

                if (Coefficient < 1 || SecondCoefficientIsAlert)
                {
                    var FrameID = "VerifySupervisorWorkCode_FrameID";

                    $.OpenPage({
                        Framesrc: "<%= ResolveClientUrl(@"~/WorkCodeVerify.aspx") %>",
                        TitleBarText: "<%=(string)GetLocalResourceObject("Str_VerifySupervisorWorkCodeTitleBarText")%>",
                        TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                        width: 710,
                        height: 560,
                        NewWindowPageDivID: "VerifySupervisorWorkCode_DivID",
                        NewWindowPageFrameID: FrameID,
                        TitleBarCloseButtonTriggerCloseEvent: true,
                        CloseEvent: function ()
                        {
                            var Frame = $("#" + FrameID + "").contents();

                            if (Frame != null)
                            {
                                var IsVerifySuccess = $.StringConvertBoolean(Frame.find("#HF_IsVerifySuccess").val());

                                if (IsVerifySuccess)
                                    $("#<%=BT_Submit.ClientID%>").trigger("click");
                            }
                        }
                    });
                }
                else
                    $("#<%=BT_Submit.ClientID%>").trigger("click");--%>
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="col-xs-12">
        <div class="col-xs-2 form-group required">
            <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_WorkCode%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
        </div>
        <div class="col-xs-4 form-group required">
            <label for="<%= DDL_WorkShift.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_TS_WorkShift%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_WorkShift" runat="server" CssClass="form-control selectpicker" required="required">
            </asp:DropDownList>
        </div>
        <div class="col-xs-2 form-group required">
            <label for="<%= DDL_Coefficient.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Coefficient%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_Coefficient" runat="server" CssClass="form-control selectpicker" required="required">
                <asp:ListItem Value="" Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText %>"></asp:ListItem>
                <asp:ListItem Value="1" Text="<%$ Resources:Str_Coefficient1%>"></asp:ListItem>
                <asp:ListItem Value="0.5" Text="<%$ Resources:Str_Coefficient2%>"></asp:ListItem>
                <asp:ListItem Value="0.33" Text="<%$ Resources:Str_Coefficient3%>"></asp:ListItem>
                <asp:ListItem Value="0.25" Text="<%$ Resources:Str_Coefficient4%>"></asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="col-xs-2 form-group required">
            <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanMachineID %>" required="required"></asp:TextBox>
        </div>
    </div>
    <div class="col-xs-12">
        <div class="col-xs-2 form-group">
            <label for="<%= TB_WorkCodeSecond1.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_WorkCodeSecond%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_WorkCodeSecond1" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= DDL_SecondCoefficient1.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Coefficient%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_SecondCoefficient1" runat="server" CssClass="form-control selectpicker">
                <asp:ListItem Value="" Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText %>"></asp:ListItem>
                <asp:ListItem Value="1" Text="<%$ Resources:Str_Coefficient5%>"></asp:ListItem>
                <asp:ListItem Value="0.5" Text="<%$ Resources:Str_Coefficient6%>"></asp:ListItem>
                <asp:ListItem Value="0.33" Text="<%$ Resources:Str_Coefficient7%>"></asp:ListItem>
                <asp:ListItem Value="0.25" Text="<%$ Resources:Str_Coefficient8%>"></asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= TB_WorkCodeSecond2.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_WorkCodeSecond%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_WorkCodeSecond2" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= DDL_SecondCoefficient2.ClientID%>" class="control-label selectpicker">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Coefficient%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_SecondCoefficient2" runat="server" CssClass="form-control selectpicker">
                <asp:ListItem Value="" Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText %>"></asp:ListItem>
                <asp:ListItem Value="1" Text="<%$ Resources:Str_Coefficient5%>"></asp:ListItem>
                <asp:ListItem Value="0.5" Text="<%$ Resources:Str_Coefficient6%>"></asp:ListItem>
                <asp:ListItem Value="0.33" Text="<%$ Resources:Str_Coefficient7%>"></asp:ListItem>
                <asp:ListItem Value="0.25" Text="<%$ Resources:Str_Coefficient8%>"></asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= TB_WorkCodeSecond3.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_WorkCodeSecond%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_WorkCodeSecond3" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= DDL_SecondCoefficient3.ClientID%>" class="control-label selectpicker">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Coefficient%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_SecondCoefficient3" runat="server" CssClass="form-control selectpicker">
                <asp:ListItem Value="" Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText %>"></asp:ListItem>
                <asp:ListItem Value="1" Text="<%$ Resources:Str_Coefficient5%>"></asp:ListItem>
                <asp:ListItem Value="0.5" Text="<%$ Resources:Str_Coefficient6%>"></asp:ListItem>
                <asp:ListItem Value="0.33" Text="<%$ Resources:Str_Coefficient7%>"></asp:ListItem>
                <asp:ListItem Value="0.25" Text="<%$ Resources:Str_Coefficient8%>"></asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>

    <div class="col-xs-12">
        <div class="col-xs-2 form-group">
            <label for="<%= TB_WorkCodeSecond4.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_WorkCodeSecond%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_WorkCodeSecond4" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= DDL_SecondCoefficient4.ClientID%>" class="control-label selectpicker">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Coefficient%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_SecondCoefficient4" runat="server" CssClass="form-control selectpicker">
                <asp:ListItem Value="" Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText %>"></asp:ListItem>
                <asp:ListItem Value="1" Text="<%$ Resources:Str_Coefficient5%>"></asp:ListItem>
                <asp:ListItem Value="0.5" Text="<%$ Resources:Str_Coefficient6%>"></asp:ListItem>
                <asp:ListItem Value="0.33" Text="<%$ Resources:Str_Coefficient7%>"></asp:ListItem>
                <asp:ListItem Value="0.25" Text="<%$ Resources:Str_Coefficient8%>"></asp:ListItem>
            </asp:DropDownList>
        </div>

        <div class="col-xs-2 form-group">
            <label for="<%= TB_WorkCodeSecond5.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_WorkCodeSecond%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_WorkCodeSecond5" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= DDL_SecondCoefficient5.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Coefficient%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_SecondCoefficient5" runat="server" CssClass="form-control selectpicker">
                <asp:ListItem Value="" Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText %>"></asp:ListItem>
                <asp:ListItem Value="1" Text="<%$ Resources:Str_Coefficient5%>"></asp:ListItem>
                <asp:ListItem Value="0.5" Text="<%$ Resources:Str_Coefficient6%>"></asp:ListItem>
                <asp:ListItem Value="0.33" Text="<%$ Resources:Str_Coefficient7%>"></asp:ListItem>
                <asp:ListItem Value="0.25" Text="<%$ Resources:Str_Coefficient8%>"></asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= TB_WorkCodeSecond6.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_WorkCodeSecond%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_WorkCodeSecond6" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= DDL_SecondCoefficient5.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Coefficient%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_SecondCoefficient6" runat="server" CssClass="form-control selectpicker">
                <asp:ListItem Value="" Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText %>"></asp:ListItem>
                <asp:ListItem Value="1" Text="<%$ Resources:Str_Coefficient5%>"></asp:ListItem>
                <asp:ListItem Value="0.5" Text="<%$ Resources:Str_Coefficient6%>"></asp:ListItem>
                <asp:ListItem Value="0.33" Text="<%$ Resources:Str_Coefficient7%>"></asp:ListItem>
                <asp:ListItem Value="0.25" Text="<%$ Resources:Str_Coefficient8%>"></asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>

    <div class="col-xs-12">
        <div class="col-xs-2 form-group">
            <label for="<%= TB_WorkCodeSecond4.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_WorkCodeSecond%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_WorkCodeSecond7" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= DDL_SecondCoefficient7.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Coefficient%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_SecondCoefficient7" runat="server" CssClass="form-control selectpicker">
                <asp:ListItem Value="" Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText %>"></asp:ListItem>
                <asp:ListItem Value="1" Text="<%$ Resources:Str_Coefficient5%>"></asp:ListItem>
                <asp:ListItem Value="0.5" Text="<%$ Resources:Str_Coefficient6%>"></asp:ListItem>
                <asp:ListItem Value="0.33" Text="<%$ Resources:Str_Coefficient7%>"></asp:ListItem>
                <asp:ListItem Value="0.25" Text="<%$ Resources:Str_Coefficient8%>"></asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= TB_WorkCodeSecond8.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_WorkCodeSecond%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_WorkCodeSecond8" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= DDL_SecondCoefficient8.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Coefficient%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_SecondCoefficient8" runat="server" CssClass="form-control selectpicker">
                <asp:ListItem Value="" Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText %>"></asp:ListItem>
                <asp:ListItem Value="1" Text="<%$ Resources:Str_Coefficient5%>"></asp:ListItem>
                <asp:ListItem Value="0.5" Text="<%$ Resources:Str_Coefficient6%>"></asp:ListItem>
                <asp:ListItem Value="0.33" Text="<%$ Resources:Str_Coefficient7%>"></asp:ListItem>
                <asp:ListItem Value="0.25" Text="<%$ Resources:Str_Coefficient8%>"></asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= TB_WorkCodeSecond9.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Scan_WorkCodeSecond%>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_WorkCodeSecond9" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
        </div>
        <div class="col-xs-2 form-group">
            <label for="<%= DDL_SecondCoefficient9.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_Coefficient%>"></asp:Literal>
            </label>
            <asp:DropDownList ID="DDL_SecondCoefficient9" runat="server" CssClass="form-control selectpicker">
                <asp:ListItem Value="" Text="<%$ Resources:GlobalRes,Str_DropDownListDefaultText %>"></asp:ListItem>
                <asp:ListItem Value="1" Text="<%$ Resources:Str_Coefficient5%>"></asp:ListItem>
                <asp:ListItem Value="0.5" Text="<%$ Resources:Str_Coefficient6%>"></asp:ListItem>
                <asp:ListItem Value="0.33" Text="<%$ Resources:Str_Coefficient7%>"></asp:ListItem>
                <asp:ListItem Value="0.25" Text="<%$ Resources:Str_Coefficient8%>"></asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>
    <div class="col-xs-12">
        <div class="col-xs-2 form-group">
            <input type="button" id="BT_Submit_DisPlay" runat="server" value="<%$ Resources:Str_Button_SubmitName%>" class="btn btn-primary" />
            <asp:Button ID="BT_Submit" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:Str_Button_SubmitName%>" OnClick="BT_Submit_Click" UseSubmitBehavior="false" />
        </div>
    </div>
</asp:Content>
