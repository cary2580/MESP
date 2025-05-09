<%@ Control Language="C#" AutoEventWireup="true" CodeFile="WUC_File.ascx.cs" Inherits="WUC_WUC_File" %>

<script type="text/javascript">

    var FileSerialNoColumnName = "";

    function DeleteFileGridRow()
    {
        var SelectCBKArrayID = new Array();

        var GridTable = $("#" + $("#<%=HF_JQGridContainerTableName.ClientID%>").val());

        var rowKey = GridTable.jqGrid("getGridParam", "selrow");

        if (!rowKey)
        {
            $.AlertMessage({ Message: "<%= (string)GetGlobalResourceObject("GlobalRes" ,"Str_GridSelectZeroAlertMessage") %>" });
            return false;
        }

        var ColumnModel = GridTable.jqGrid("getGridParam", "colModel");

        $.each(GridTable.getGridParam("selarrrow"), function (i, item)
        {
            var FileSerialNo = "";

            if ($.grep(ColumnModel, function (Node) { return Node.name == FileSerialNoColumnName; }).length > 0)
                FileSerialNo = GridTable.jqGrid("getCell", item, FileSerialNoColumnName);
            if (FileSerialNo != "")
                SelectCBKArrayID.push(FileSerialNo);
        });

        $.ConfirmMessage({
            Message: "<%=(string)GetLocalResourceObject("Str_DeleteConfirmMessage") %>", IsHtmlElement: true, CloseEvent: function (result)
            {
                if (result)
                {
                    $.Ajax({
                        url: "<%=ResolveClientUrl("~/Service/DeleteUploadFile.ashx") %>", data: {
                            FileID: $("#<%=HF_FileID.ClientID%>").val(),
                            SerialNoS: JSON.stringify(SelectCBKArrayID)
                        }, CallBackFunction: function (data)
                        {
                            GetFileData();
                        }
                    });
                }
            }
        });
    }

    function SetFileGridData(NewData)
    {
        $("#" + $("#<%=HF_JQGridElementID.ClientID%>").val()).children().remove();

        var ChildrenHTML = "<table id=" + $("#<%=HF_JQGridContainerTableName.ClientID%>").val() + "></table><div id=" + $("#<%=HF_JQGridContainerPagerName.ClientID%>").val() + "></div>";

        $("#" + $("#<%=HF_JQGridElementID.ClientID%>").val()).append(ChildrenHTML);

        var data = null;

        if (NewData != null)
            data = NewData;

        if (data == null)
            return;

        var ColumnClassesName = data.ColumnClassesName;

        FileSerialNoColumnName = data.FileSerialNoColumnName;

        var colModel = typeof data.colModel != "object" ? $.parseJSON(data.colModel) : data.colModel;

        var Rows = typeof data.Rows != "object" ? $.parseJSON(data.Rows) : data.Rows;

        var Grid = $("#" + $("#<%=HF_JQGridContainerTableName.ClientID%>").val());

        Grid.jqGrid({
            data: Rows,
            colModel: colModel,
            multiSort: true,
            multiselect: true,
            pager: "#" + $("#<%=HF_JQGridContainerPagerName.ClientID%>").val(),
            beforeSelectRow: function (rowid, e)
            {
                iCol = $.jgrid.getCellIndex($(e.target).closest("td")[0]);
                cm = $(this).jqGrid("getGridParam", "colModel");

                if (cm[iCol].classes === ColumnClassesName)
                {
                    var columnNames = $(this).jqGrid("getGridParam", "colNames");
                    var FileSerialNo = "";

                    if ($.inArray(FileSerialNoColumnName, columnNames) > -1)
                        FileSerialNo = $(this).jqGrid("getCell", rowid, FileSerialNoColumnName);

                    if (FileSerialNo != "")
                    {
                        parent.$.Ajax({
                            url: "<%=ResolveClientUrl("~/Service/GetUploadFilePath.ashx") %>", data: {
                                FileID: $("#<%=HF_FileID.ClientID%>").val(),
                                SerialNo: FileSerialNo,
                            }, CallBackFunction: function (data)
                            {
                                if (data != null && data.Result && data.AccessGUID != null && data.AccessGUID != "")
                                {
                                    var Url = "<%=ResolveClientUrl("~/DownloadFileByFullPath/") %>";

                                    Url += "/" + data.AccessGUID;

                                    if ($.ispAad())
                                        window.open(Url);
                                    else
                                        OpenWindowDownloadFile(Url);
                                }
                                else
                                {
                                    $.AlertMessage({
                                        Message: "<%=(string)GetLocalResourceObject("Str_FileNoExistAlertMessage") %>",
                                        parentWindow: parent,
                                        CloseEvent: function ()
                                        {
                                            GetFileData();
                                        }
                                    });
                                }
                            }
                        });
                        return false;
                    }
                }
            },
            loadComplete: function () { $("#" + $("#<%=HF_JQGridContainerPagerName.ClientID%>").val() + " option[value=100000000]").text("ALL"); $(".ui-inline-del").css("cursor", "pointer"); }
        });

        Grid.trigger("resize");
    }

    function GetFileData()
    {
        $.Ajax({
            url: "<%=ResolveClientUrl("~/Service/GetUploadFileList.ashx") %>", data: {
                FileID: $("#<%=HF_FileID.ClientID%>").val()
            }, CallBackFunction: function (data)
            {
                SetFileGridData(data);
            }
        });
    }

    $(function ()
    {
        $("#<%=BT_FileUpload.ClientID%>").click(function ()
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl("~/UploadFile.aspx") %>",
                iFrameOpenParameters: { FileID: $("#<%=HF_FileID.ClientID%>").val(), FileCategoryID: $("#<%=HF_FileCategoryID.ClientID%>").val() },
                TitleBarText: "<%=(string)GetLocalResourceObject("Str_UploadFileTitleBarText") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/document-arrow-up-icon.png") %>",
                width: 1000,
                height: 620,
                NewWindowPageDivID: "UploadFileDivID_" + $("#<%= HF_JQGridElementID.ClientID %>").val(),
                NewWindowPageFrameID: "UploadFileFrame_" + $("#<%= HF_JQGridElementID.ClientID %>").val(),
                parentWindow: window.parent,
                CloseEvent: function (result)
                {
                    GetFileData();
                }
            });

            return false;
        });

        $("#<%=BT_FileDelete.ClientID%>").click(function ()
        {
            DeleteFileGridRow();

            return false;
        });
    });

</script>
<asp:HiddenField ID="HF_JQGridElementID" runat="server" />
<asp:HiddenField ID="HF_JQGridContainerTableName" runat="server" />
<asp:HiddenField ID="HF_JQGridContainerPagerName" runat="server" />
<asp:HiddenField ID="HF_FileID" runat="server" />
<asp:HiddenField ID="HF_FileCategoryID" runat="server" />
<div class="row">
    <div class="text-center">
        <button id="BT_FileUpload" runat="server" class="btn btn-primary"><i class="fa fa-cloud-upload"></i><%= " "+(string)GetGlobalResourceObject("GlobalRes","Str_BTAttachUploadName") %></button>
        <button id="BT_FileDelete" runat="server" class="btn btn-danger"><i class="fa fa-times"></i><%= " "+(string)GetGlobalResourceObject("GlobalRes","Str_BTAttachDeletedName") %></button>
    </div>
</div>
<p></p>
<div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_JqgridTitleColor") %>">
    <div class="panel-heading text-center">
        <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_AttachListTitleName %>"></asp:Literal>
    </div>
    <div class="panel-body">
        <div id="<%= HF_JQGridElementID.Value %>"></div>
    </div>
</div>
