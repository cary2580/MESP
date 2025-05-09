<%@ Control Language="C#" AutoEventWireup="true" CodeFile="WUC_Calendar.ascx.cs" Inherits="ED_WUC_WUC_Calendar" %>

<script type="text/javascript">
    var Calendar;

    $(function () {
        var CalendarDataURL = $("#<%=HF_CalendarDataURL.ClientID%>").val();

        var CalendarDataParameters = $("#<%=HF_CalendarDataParameters.ClientID%>").val();

        if (CalendarDataURL == "")
            return;

        calendar = new FullCalendar.Calendar(document.getElementById("CalendarDiv"), {
            initialView: "dayGridMonth", //檢視模式
            themeSystem: "bootstrap3", //外觀主題
            locale: "<%= System.Threading.Thread.CurrentThread.CurrentUICulture.Name.ToLower().Replace("-us",string.Empty) %>", // 本地語系話
            firstDay: 1, // 週的第一天是星期幾
            fixedWeekCount: false, //是否固定週數
            businessHours: true, // 是否將六、日顯示出不同顏色
            dayMaxEvents: true, // event 如果超過當天日期可以存放的大小是否要縮放
            selectable: true, // 日期是否可以觸發選取的事件
            eventOverlap: true, //event 是否可以有托放事件
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: ""
            },
            //dateClick: function (info)
            //{
            //    if (typeof CalendarClicked == "function")
            //        CalendarClicked(info);
            //},
            select: function (info) {
                if (typeof CalendarSelected == "function")
                    CalendarSelected(info);
            },
            eventDrop: function (info) {
                //lert("id : " + info.event.id + "\r\ntitle : " + info.event.title + " was dropped on " + moment(info.event.start).format("YYYY/MM/DD HH:mm:ss"));

                if (!$.StringConvertBoolean($("#<%=HF_IsCanDrop.ClientID%>").val())) {
                    info.revert();

                    event.preventDefault();

                    return;
                }

                $.ConfirmMessage({
                    Message: "<%=(string)GetLocalResourceObject("Str_EventDropConfirm") %>", IsHtmlElement: true, CloseEvent: function (result) {
                        if (!result)
                            info.revert();
                        else if (typeof CalendarEventDroped == "function")
                            CalendarEventDroped(info);
                    }
                });
            },
            eventClick: function (info) {
                //alert('id: ' + info.event.id);
                //alert('Event: ' + info.event.title);
                //alert('Coordinates: ' + info.jsEvent.pageX + ',' + info.jsEvent.pageY);
                //alert('View: ' + info.view.type);

                $(".fc-popover").remove();

                if (typeof CalendarEventClicked == "function")
                    CalendarEventClicked(info);
            },
            eventContent: function (args, createElement) {
                return { html: args.event.title };
            },
            events: function (info, successCallback, failureCallback) {
                var UploadParameters = {};

                if (CalendarDataParameters != "")
                    UploadParameters = JSON.parse(CalendarDataParameters);

                var UploadData = $.extend(UploadParameters, {
                    StartDateTime: dayjs(info.startStr).format("L"),
                    EndDateTime: dayjs(info.endStr).format("L")
                });

                $.Ajax({
                    url: CalendarDataURL, data: UploadData,
                    CallBackFunction: function (data) {
                        successCallback(
                            $.each(data, function (index, itme) {
                                return {
                                    id: itme.id,
                                    title: itme.title,
                                    start: itme.start,
                                    end: itme.end,
                                    allDay: itme.allDay,
                                    editable: itme.editable
                                }
                            })
                        );

                    }, ErrorCallBackFunction: function (data) {
                        failureCallback(data);
                    }
                });
            }
        });

        calendar.render();
    });

</script>

<asp:HiddenField ID="HF_CalendarDataURL" runat="server" />
<asp:HiddenField ID="HF_CalendarDataParameters" runat="server" />
<asp:HiddenField ID="HF_IsCanDrop" runat="server" Value="1" />

<div class="panel <%=(string)GetGlobalResourceObject("GlobalRes","Str_FormPanelTitleColor1") %>">
    <div class="panel-body">
        <div id="CalendarDiv"></div>
    </div>
</div>
