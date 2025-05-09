<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="PlanWorkMinute_M.aspx.cs" Inherits="TimeSheet_PlanWorkMinute_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=DDL_WorkShift.ClientID%>").change(function ()
            {
                var ScheduledMinute = $(this).find(":selected").data("ScheduledMinute".toLowerCase());

                $("#<%=TB_PlanWorkMinute.ClientID%>").val(ScheduledMinute).trigger("change");
            });

            if ($.StringConvertBoolean($("#<%=HF_IsNewData.ClientID%>").val()))
                $("#<%=DDL_WorkShift.ClientID%>").trigger("change");

            $("#<%=TB_MachineID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "" || $(this).hasClass("readonly"))
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        if (data.A4 == null || data.A5 == null)
                        {
                            $("#<%=TB_MachineID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_TS_Empty_DeviceID")%>" });

                            return;
                        }

                        $("#<%=TB_MachineID.ClientID%>").val(data.A5);
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_MachineID.ClientID%>").val("");
                    }
                });

            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsNewData" runat="server" />
    <asp:HiddenField ID="HF_DeviceID" runat="server" />
    <asp:HiddenField ID="HF_WorkShift" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor5") %>">
        <div class="panel-body">
            <div class="row">
                <div class="col-xs-12 form-group ">
                    <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClick="BT_Submit_Click" />
                    <asp:Button ID="BT_Delete" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_DeleteName %>" CssClass="btn btn-danger" OnClick="BT_Delete_Click" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_ReportDate.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_ReportDate %>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_ReportDate" runat="server" CssClass="form-control DateDatepicker readonly" required="required"></asp:TextBox>
                        <span class="input-group-btn" title="Clear">
                            <button class="btn btn-default ClearDate" type="button">
                                <i class="fa fa-times"></i>
                            </button>
                        </span>
                    </div>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanMachineID %>" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= DDL_WorkShift.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_WorkShift%>"></asp:Literal>
                    </label>
                    <asp:DropDownList ID="DDL_WorkShift" runat="server" CssClass="form-control" required="required">
                    </asp:DropDownList>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_PlanWorkMinute.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_PlanWorkMinute%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_PlanWorkMinute" runat="server" CssClass="form-control MumberType" data-MumberTypeDecimals="2" data-MumberTypeLimitMaxValue="800" required="required"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCode%>"></asp:Literal>
                    </label>
                    <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
                </div>
                <div class="col-xs-3 form-group required">
                    <label for="<%= TB_Password.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_Password%>"></asp:Literal>
                    </label>
                    <div class="input-group">
                        <asp:TextBox ID="TB_Password" runat="server" CssClass="form-control" required="required" TextMode="Password"></asp:TextBox>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
