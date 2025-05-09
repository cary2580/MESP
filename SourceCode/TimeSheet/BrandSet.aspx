<%@ Page Title="" Language="C#" MasterPageFile="~/TimeSheet/TimeSheet.master" AutoEventWireup="true" CodeFile="BrandSet.aspx.cs" Inherits="TimeSheet_BrandSet" %>

<%@ MasterType VirtualPath="~/TimeSheet/TimeSheet.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=TB_MachineID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                var MachineID = $(this).val();

                if (MachineID == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: MachineID },
                    CallBackFunction: function (data)
                    {
                        if (data.A4 == null || data.A5 == null)
                        {
                            $("#<%=TB_MachineID.ClientID%>").val("");

                            $("#<%=HF_DeviceID.ClientID%>").val("");

                            $("#<%=TB_CurrBrandNo.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=GetLocalResourceObject("Str_Error_DeviceID")%>" });

                            return;
                        }

                        $("#<%=TB_MachineID.ClientID%>").val(data.A5);

                        $("#<%=HF_DeviceID.ClientID%>").val(data.A4);

                        LoadCurrBrand();
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_MachineID.ClientID%>").val("");

                        $("#<%=HF_DeviceID.ClientID%>").val("");

                        $("#<%=TB_CurrBrandNo.ClientID%>").val("");
                    }
                });
            }).focus();
        });

        function LoadCurrBrand()
        {
            $.Ajax({
                url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/BrandCurrGet.ashx")%>",
                timeout: 300 * 1000,
                data: { DeviceID: $("#<%=HF_DeviceID.ClientID%>").val() },
                CallBackFunction: function (data)
                {
                    $("#<%=TB_CurrBrandNo.ClientID%>").val(data.Brand);

                    if ($("#<%=TB_CurrBrandNo.ClientID%>").val() == "")
                        $("#<%=BT_BrandDisable.ClientID%>").hide();
                    else
                        $("#<%=BT_BrandDisable.ClientID%>").show();
                },
                ErrorCallBackFunction: function (data)
                {
                    $("#<%=TB_CurrBrandNo.ClientID%>").val("");

                    $("#<%=BT_BrandDisable.ClientID%>").hide();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_DeviceID" runat="server" />
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:Str_BrandInfo%>"></asp:Literal>
        </div>
        <div class="panel-body">
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanMachineID %>"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group">
                <label for="<%= TB_CurrBrandNo.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_CurrBrandNo%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_CurrBrandNo" runat="server" CssClass="form-control readonlyColor readonly"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_BrandNo.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_BrandNo%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_BrandNo" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_WorkCode.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCode%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_WorkCode" runat="server" CssClass="form-control readonlyColor readonly" required="required"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_MPWorkCode.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCodeByMP%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_MPWorkCode" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
            </div>
            <div class="col-xs-4 form-group required">
                <label for="<%= TB_QAWorkCode.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:Str_WorkCodeByQA%>"></asp:Literal>
                </label>
                <asp:TextBox ID="TB_QAWorkCode" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanWorkCode %>"></asp:TextBox>
            </div>
        </div>
    </div>
    <div class="col-xs-12 form-group text-center">
        <asp:Button ID="BT_BrandSet" runat="server" CssClass="btn btn-primary" Text="<%$ Resources:Str_BT_BrandSet%>" UseSubmitBehavior="false" OnClick="BT_BrandSet_Click" />
        <asp:Button ID="BT_BrandDisable" runat="server" CssClass="btn btn-danger" Text="<%$ Resources:Str_BT_BrandDisable%>" UseSubmitBehavior="false" OnClick="BT_BrandDisable_Click" />
    </div>
</asp:Content>
