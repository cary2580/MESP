<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="DevicePrint.aspx.cs" Inherits="TimeSheet_DevicePrint" %>

<%@ MasterType VirtualPath="~/MasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=TB_MachineID.ClientID%>").keydown(function (e)
            {
                var code = e.keyCode || e.which;
                if (code != 13)
                    return;

                if ($(this).val() == "")
                    return;

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/Service/GetQRCodeInfo.ashx")%>",
                    data: { QRCode: $(this).val() },
                    CallBackFunction: function (data)
                    {
                        if (data.A4 == null || data.A5 == null)
                        {
                            $("#<%=TB_MachineID.ClientID%>").val("");

                            $.AlertMessage({ Message: "<%=GetLocalResourceObject("Str_Error_DeviceID")%>" });

                            return;
                        }

                        $("#<%=TB_MachineID.ClientID%>").val(data.A5);
                    },
                    ErrorCallBackFunction: function (data)
                    {
                        $("#<%=TB_MachineID.ClientID%>").val("");
                    }
                });
            }).focus();

            $("#BT_Print").click(function ()
            {
                var UploadObject = {
                    MachineID: $("#<%= TB_MachineID.ClientID %>").val()
                };

                $.Ajax({
                    url: "<%=ResolveClientUrl(@"~/TimeSheet/Service/RPT_002.ashx")%>",
                    data: UploadObject,
                    CallBackFunction: function (data)
                    {
                        if (data.Result && data.GUID != null)
                        {
                            if ($.ispAad())
                                window.open("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                            else
                                OpenWindowDownloadFile("<%=ResolveClientUrl(@"~/DownloadFileByFullPath/")%>" + data.GUID);
                        }
                    }
                });
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="col-xs-12">
        <div class="col-xs-4 form-group required">
            <label for="<%= TB_MachineID.ClientID%>" class="control-label">
                <asp:Literal runat="server" Text="<%$ Resources:Str_MachineID %>"></asp:Literal>
            </label>
            <asp:TextBox ID="TB_MachineID" runat="server" CssClass="form-control" required="required" placeholder="<%$ Resources:ProjectGlobalRes,Str_TS_ScanMachineID %>"></asp:TextBox>
        </div>
    </div>
    <div class="col-xs-12">
        <div class="col-xs-2 form-group">
            <input type="button" class="btn btn-primary" id="BT_Print" value="<%= (string)GetGlobalResourceObject("GlobalRes","Str_DownloadFileTitleBarText") %>" />
        </div>
    </div>
</asp:Content>

