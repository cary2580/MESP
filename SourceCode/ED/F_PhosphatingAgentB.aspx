<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="F_PhosphatingAgentB.aspx.cs" Inherits="ED_F_PhosphatingAgentB" %>

<%@ Register Src="~/WUC/WUC_Calendar.ascx" TagPrefix="uc1" TagName="WUC_Calendar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        function CalendarSelected(info) {
            var StartDate = dayjs(info.startStr).format("L");

            OpenMPage({ PADate: $.base64.encode(StartDate) });
        }

        function CalendarEventClicked(info) {
            OpenMPage({ PAID: info.event.id });
        }

        function CalendarEventDroped(info) {
            $.Ajax({
                url: "<%= ResolveClientUrl(@"~/ED/Service/FormulaDateChange.ashx?IsB=") + true.ToStringValue() %>",
                data: { PAID: info.event.id, TargetDate: dayjs(info.event.start).format("L") },
                CallBackFunction: function (data) {
                    calendar.refetchEvents();
                },
                ErrorCallBackFunction: function (data) {
                    info.revert();
                }
            });
        }

        function OpenMPage(Parameters) {
            $.OpenPage({
                Framesrc: "<%= ResolveClientUrl(@"~/ED/F_PhosphatingAgentB_M.aspx") %>",
                iFrameOpenParameters: Parameters,
                TitleBarText: "<%=(string)GetGlobalResourceObject("ProjectGlobalRes","Str_ED_F_M_TitleBarText") %>",
                TitleBarImg: "<%= ResolveClientUrl("~/Image/make-icon.png") %>",
                width: 800,
                height: 680,
                NewWindowPageDivID: "F_PhosphatingAgentB_M_DivID",
                NewWindowPageFrameID: "F_PhosphatingAgentB_M_Frame",
                CloseEvent: function (result) {
                    calendar.refetchEvents();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <uc1:WUC_Calendar runat="server" ID="WUC_Calendar" />
</asp:Content>


