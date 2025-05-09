<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="UploadFile.aspx.cs" Inherits="UploadFile" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function ()
        {
            $("#<%=BT_UpLoad.ClientID%>").hide();

            $("#<%=FU_File.ClientID%>").fileinput({
                theme: "fa4",
                initialPreviewAsData: true,
                browseOnZoneClick: true,
                autoReplace: true,
                maxFileCount: 5,
                showUpload: false,
                showRemove: false,
            });
        });

        function PostBackCheck()
        {
            if ($("#<%=FU_File.ClientID%>").val() == "")
                $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes","Str_NoUploadFileMessage") %>" });
            else
                $("#<%=BT_UpLoad.ClientID%>").trigger("click");
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
        <div class="panel-body">
            <div class="row">
                <asp:HiddenField ID="HF_FileID" runat="server" />
                <asp:HiddenField ID="HF_FileCategoryID" runat="server" />
                <div id="FileContent" class="col-xs-12 form-group">
                    <label for="<%= FU_File.ClientID%>" class="control-label">
                        <asp:Literal runat="server" Text="<%$ Resources:Str_FileUploadName %>"></asp:Literal>
                    </label>
                    <asp:FileUpload ID="FU_File" runat="server" AllowMultiple="true" />
                </div>
                <div class="col-xs-12 form-group text-center">
                    <asp:Button ID="BT_UpLoad" runat="server" Text="Button" OnClick="BT_UpLoad_Click" />
                    <button id="BT_UpLoad_DisyPlay" runat="server" class="btn btn-warning" onclick="PostBackCheck(); return false;">
                        <i class="fa fa-upload fa-fw"></i>
                        <asp:Literal runat="server" Text="<%$ Resources:Str_BT_UpLoadName %>"></asp:Literal></button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
