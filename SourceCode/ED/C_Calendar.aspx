<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="C_Calendar.aspx.cs" Inherits="ED_C_Calendar" %>

<%@ Register Src="~/WUC/WUC_Calendar.ascx" TagPrefix="uc1" TagName="WUC_Calendar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        function CalendarSelected(info)
        {
            var StartDate = dayjs(info.startStr).format("L");

            OpenMPage({ CleanDate: $.base64.encode(StartDate), PLID: $.base64.encode($("#<%=DDL_PLID.ClientID%>").val()) });
        }

        function CalendarEventClicked(info)
        {
            OpenMPage({ CID: info.event.id });
        }

        function CalendarEventDroped(info)
        {
            $.Ajax({
                url: "<%= ResolveClientUrl(@"~/ED/Service/CleanDateChange.ashx")%>",
                data: { CID: info.event.id, TargetDate: dayjs(info.event.start).format("L") },
                CallBackFunction: function (data)
                {
                    calendar.refetchEvents();
                },
                ErrorCallBackFunction: function (data)
                {
                    info.revert();
                }
            });
        }

        function OpenMPage(Parameters)
        {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/ED/C_Calendar_M.aspx") %>",
                iFrameOpenParameters: Parameters,
                TitleBarText: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_ED_C_M_TitleBarText") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 810,
                height: 560,
                NewWindowPageDivID: "C_Calendar_M_DivID",
                NewWindowPageFrameID: "C_Calendar_M_Frame",
                CloseEvent: function (result)
                {
                    calendar.refetchEvents();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor9") %>">
        <div class="panel-heading text-center">
            <asp:Literal runat="server" Text="<%$ Resources:GlobalRes,Str_SearchCondition %>"></asp:Literal>
        </div>
        <div class="panel-body">
            <asp:Button ID="BT_Search" runat="server" Text="<%$ Resources:GlobalRes,Str_Search %>" CssClass="btn btn-warning" OnClick="BT_Search_Click" />
            <p></p>
            <div class="col-xs-6 form-group required">
                <label for="<%= DDL_PLID.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_PLID %>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_PLID" runat="server" class="form-control" required="required">
                </asp:DropDownList>
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%= DDL_WorkClass.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_P_WorkClass %>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_WorkClass" runat="server" class="form-control">
                </asp:DropDownList>
            </div>
            <div class="col-xs-6 form-group">
                <label for="<%= DDL_Process.ClientID%>" class="control-label">
                    <asp:Literal runat="server" Text="<%$ Resources:ProjectGlobalRes,Str_ED_C_Process %>"></asp:Literal>
                </label>
                <asp:DropDownList ID="DDL_Process" runat="server" class="form-control">
                </asp:DropDownList>
            </div>
        </div>
    </div>
    <p></p>
    <uc1:WUC_Calendar runat="server" ID="WUC_Calendar" />
</asp:Content>
