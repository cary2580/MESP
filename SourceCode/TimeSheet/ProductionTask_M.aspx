<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="ProductionTask_M.aspx.cs" Inherits="TimeSheet_ProductionTask_M" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            if ($.StringConvertBoolean($("#<%= HF_IsInport.ClientID%>").val()))
            {
                $("#ManageDiv").hide();

                $("#InportDiv").show();

                $("#<%=BT_UpLoad.ClientID%>").hide();

                $("#<%=FU_File.ClientID%>").fileinput({
                    theme: "fa4",
                    allowedFileExtensions: ["xls", "xlsx"],
                    showUpload: false,
                    showPreview: false,
                    showRemove: false,
                    required: true
                });
            }

            $("#<%= TB_PVGroupID.ClientID%>").css("cursor", "pointer").click(function ()
            {
                var FrameID = "ProductionVersionGroupSelect_FrameID";

                $.OpenPage({
                    Framesrc: "<%= ResolveClientUrl(@"~/TimeSheet/ProductionVersionGroupSelect.aspx") %>",
                    TitleBarText: "<%=(string)GetLocalResourceObject("Str_ProductionVersionGroupSelect_Title") %>",
                    TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                    width: 920,
                    height: 770,
                    NewWindowPageDivID: "PProductionVersionGroupSelect_DivID",
                    NewWindowPageFrameID: FrameID,
                    parentWindow: window.parent,
                    CloseEvent: function (result)
                    {
                        var PVGroupID = $(result).find("#" + FrameID).contents().find("#HF_PVGroupID").val();
                        var PVGroupName = $(result).find("#" + FrameID).contents().find("#HF_PVGroupName").val();

                        $("#<%= TB_PVGroupID.ClientID%>").val(PVGroupID);
                        $("#<%= TB_PVGroupName.ClientID%>").val(PVGroupName);
                    }
                });
            });
        });

        function CheckRequired()
        {
            var TaskQty = parseInt($("#<%= TB_TaskQty.ClientID%>").val());

            if ($("#<%= TB_TaskDateTime.ClientID%>").val() == "" || $("#<%= TB_PVGroupID.ClientID%>").val() == "" || TaskQty < 0)
            {
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_RequiredAlertMessage")%>" });

                return false;
            }

            return true;
        }

        function PostFileCheck()
        {
            if ($("#<%=FU_File.ClientID%>").val() == "")
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_NoUploadFileMessage") %>" });
            else
                $("#<%=BT_UpLoad.ClientID%>").trigger("click");
        }

        function DoDownloadTemplate()
        {
            if ($("#<%= HF_DownloadFileFullPath.ClientID%>").val() == "")
                return;

            if ($.ispAad())
                window.open("<%=ResolveClientUrl(@"~/Service/DownloadFile.ashx?DownloadFileFullPath=")%>" + $("#<%= HF_DownloadFileFullPath.ClientID%>").val());
            else
                OpenWindowDownloadFile("<%=ResolveClientUrl(@"~/Service/DownloadFile.ashx?DownloadFileFullPath=")%>" + $("#<%= HF_DownloadFileFullPath.ClientID%>").val());
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_IsInport" runat="server" />
    <div id="ManageDiv">
        <asp:HiddenField ID="HF_TaskDateTime" runat="server" />
        <asp:HiddenField ID="HF_PVGroupID" runat="server" />
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_ProductionTaskInfo%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-xs-12 form-group ">
                        <asp:Button ID="BT_Submit" runat="server" Text="<%$ Resources:GlobalRes,Str_BT_SubmitName %>" CssClass="btn btn-warning" OnClientClick="return CheckRequired();" OnClick="BT_Submit_Click" />
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_TaskDateTime.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TaskDateTime %>"></asp:Literal>
                        </label>
                        <div class="input-group">
                            <asp:TextBox ID="TB_TaskDateTime" runat="server" CssClass="form-control DateDatepicker readonly"></asp:TextBox>
                            <span class="input-group-btn" title="Clear">
                                <button class="btn btn-default ClearDate" type="button">
                                    <i class="fa fa-times"></i>
                                </button>
                            </span>
                        </div>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_PVGroupID.ClientID%>" class="control-label ">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_PVGroupID %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PVGroupID" runat="server" CssClass="form-control readonly"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_PVGroupName.ClientID%>" class="control-label ">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_PVGroupName %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_PVGroupName" runat="server" CssClass="form-control readonly readonlyColor"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_TaskQty.ClientID%>" class="control-label ">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TaskQty %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TaskQty" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_TaskQtyExtra.ClientID%>" class="control-label ">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TaskQtyExtra %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TaskQtyExtra" runat="server" CssClass="form-control MumberType" Text="0" data-MumberTypeLimitMinValue="-999999999"></asp:TextBox>
                    </div>
                    <div class="col-xs-4 form-group required">
                        <label for="<%= TB_TaskQtyByMonth.ClientID%>" class="control-label ">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_TaskQtyByMonth %>"></asp:Literal>
                        </label>
                        <asp:TextBox ID="TB_TaskQtyByMonth" runat="server" CssClass="form-control MumberType" Text="0"></asp:TextBox>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div id="InportDiv" style="display: none;">
        <asp:HiddenField ID="HF_DownloadFileFullPath" runat="server" />
        <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
            <div class="panel-heading text-center">
                <asp:Literal runat="server" Text="<%$ Resources:Str_ProductionTaskBathInportInfo%>"></asp:Literal>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div id="FileContent" class="col-xs-12 form-group">
                        <label for="<%= FU_File.ClientID%>" class="control-label">
                            <asp:Literal runat="server" Text="<%$ Resources:Str_FileUploadName %>"></asp:Literal>
                        </label>
                        <asp:FileUpload ID="FU_File" runat="server" />
                    </div>
                    <div class="col-xs-12 form-group text-center">
                        <asp:Button ID="BT_UpLoad" runat="server" Text="Button" OnClick="BT_UpLoad_Click" />
                        <button id="BT_UpLoad_DisyPlay" runat="server" class="btn btn-warning" onclick="PostFileCheck(); return false;">
                            <i class="fa fa-upload fa-fw"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:Str_BT_UpLoadName %>"></asp:Literal></button>
                        <button id="BT_TemplateDownload" runat="server" class="btn btn-success" onclick="DoDownloadTemplate(); return false;">
                            <i class="fa fa-download fa-fw"></i>
                            <asp:Literal runat="server" Text="<%$ Resources:Str_BT_DownLoadName %>"></asp:Literal></button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
