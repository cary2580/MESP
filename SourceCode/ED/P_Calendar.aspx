<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="P_Calendar.aspx.cs" Inherits="ED_P_Calendar" %>

<%@ Register Src="~/WUC/WUC_Calendar.ascx" TagPrefix="uc1" TagName="WUC_Calendar" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">

        function CalendarSelected(info) {
            var StartDate = dayjs(info.startStr).format("L");

            OpenMPage({ PDate: $.base64.encode(StartDate) });
        }

        function CalendarEventClicked(info) {
            OpenMPage({ PID: info.event.id });
        }

        function CalendarEventDroped(info) {
            $.Ajax({
                url: "<%= ResolveClientUrl(@"~/ED/Service/ParametersDateChange.ashx")%>",
                data: { PID: info.event.id, TargetDate: dayjs(info.event.start).format("L"), PIDType: $("#<%=HF_PIDType.ClientID%>").val() },
                ErrorCallBackFunction: function (data) {
                    info.revert();
                }
            });
        }

        function OpenMPage(Parameters) {
            $.OpenPage({
                Framesrc: $("#<%=HF_MpageURL.ClientID%>").val(),
                iFrameOpenParameters: Parameters,
                TitleBarText: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_ED_P_M_TitleBarText") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: $("#<%=HF_MpageWidth.ClientID%>").val(),
                height: $("#<%=HF_MpageHeight.ClientID%>").val(),
                NewWindowPageDivID: "P_M_DivID",
                NewWindowPageFrameID: "P_M_Frame",
                CloseEvent: function (result) {
                    calendar.refetchEvents();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ContentPage" runat="Server">
    <asp:HiddenField ID="HF_PIDType" runat="server" />
    <asp:HiddenField ID="HF_MpageURL" runat="server" />
    <asp:HiddenField ID="HF_MpageWidth" runat="server" />
    <asp:HiddenField ID="HF_MpageHeight" runat="server" />
    <uc1:WUC_Calendar runat="server" ID="WUC_Calendar" />
</asp:Content>
