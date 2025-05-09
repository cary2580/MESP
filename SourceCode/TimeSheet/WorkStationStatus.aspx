<%@ Page Title="" Language="C#" MasterPageFile="~/NoFrame.master" AutoEventWireup="true" CodeFile="WorkStationStatus.aspx.cs" Inherits="TimeSheet_WorkStationStatus" Async="true" %>

<%@ MasterType VirtualPath="~/NoFrame.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MasterHead" runat="Server">
    <script type="text/javascript">
        $(function () {
            if (typeof (WorkStationDataValue) != "undefined") {

                let DataValue = typeof WorkStationDataValue != "object" ? $.parseJSON(WorkStationDataValue) : WorkStationDataValue;

                $.each(DataValue, function (i, item) {
                    var ItemHtml = "<div class=\"col-lg-3 col-md-6\">";

                    ItemHtml += "<div class=\"" + item.ColorClass + "\">";

                    ItemHtml += "<div class=\"panel-heading\">";

                    if (IsViewShortTemplet)
                        ItemHtml += "<div ><h1 style=\"font-size:50px;margin-top:1px;\" class=\"Text-Black\"><strong>" + item.MachineName + "</strong></h1>";
                    else
                        ItemHtml += "<div ><div style=\"white-space: nowrap;overflow: hidden;text-overflow:ellipsis;\"><h1 class=\"Text-Black\" style=\"font-size:50px;margin-top:1px;\">" + item.MachineName + "</h1></div>";

                    if (!IsViewShortTemplet)
                        ItemHtml += "<div><h5 class=\"Text-Black\"><%=(string)GetLocalResourceObject("Str_StatusName")%> : <strong>" + item.StatusName + "</strong></h5></div>";

                    if (IsViewShortTemplet)
                        ItemHtml += "<div style=\"text-overflow: ellipsis;white-space: nowrap;text-overflow:hidden;\"><h4 class=\"Text-Black\"><%=(string)GetLocalResourceObject("Str_OperatorName")%> : " + item.OperatorWorkCode + "</h4></div>";
                    else
                        ItemHtml += "<div style=\"text-overflow: ellipsis;white-space: nowrap;text-overflow:hidden;\"><h4 class=\"Text-Black\"><%=(string)GetLocalResourceObject("Str_OperatorName")%> : " + item.OperatorName + "</h4></div>";

                    ItemHtml += "<div><h4 class=\"Text-Black\"><%=(string)GetLocalResourceObject("Str_EventTime")%> : " + item.EventTime + "   " + item.EventMinute + "</h4></div>";

                    if (!IsViewShortTemplet)
                        ItemHtml += "<div><h4 class=\"Text-Black\"><%=(string)GetLocalResourceObject("Str_WorkShiftName")%> : " + item.WorkShiftName + "</h4></div>";

                    ItemHtml += "<div><h4 class=\"Text-Black\"><%=(string)GetLocalResourceObject("Str_Responsible")%> : " + item.ResponsibleName + "</h4></div>";

                    if (IsViewShortTemplet)
                        ItemHtml += "<div><h5><strong class=\"Text-White\" style=\"font-size:50px;\"><%=(string)GetLocalResourceObject("Str_TotalGoodQty")%> : " + item.TotalGoodQty + "</strong></h5></div>";

                    ItemHtml += "</div></div>";

                    if (!IsViewShortTemplet) {
                        ItemHtml += "<div class=\"panel-footer\"><span class=\"pull-left\"><%=(string)GetLocalResourceObject("Str_TicketID")%> : " + item.TicketID + "</span><br>";

                        ItemHtml += "<span class=\"pull-left\"><%=(string)GetLocalResourceObject("Str_ProcessName")%> : " + item.ProcessName + "</span><br>";

                        ItemHtml += "<span style=\"white-space: nowrap;overflow: hidden;text-overflow:ellipsis;\" class=\"pull-left\"><%=(string)GetLocalResourceObject("Str_TEXT1")%> : " + item.TEXT1 + "</span><br>";

                        ItemHtml += "<span class=\"pull-left\"><%=(string)GetLocalResourceObject("Str_TotalGoodQty")%> : " + item.TotalGoodQty + "</span><br>";

                        ItemHtml += "<span class=\"pull-left\"><%=(string)GetLocalResourceObject("Str_TotalReWorkQty")%> : " + item.TotalReWorkQty + "</span><br>";

                        ItemHtml += "<span class=\"pull-left\"><%=(string)GetLocalResourceObject("Str_TotalScrapQty")%> : " + item.TotalScrapQty + "</span><br>";

                        ItemHtml += "</div>";
                    }

                    $("#WorkStationDiv").append(ItemHtml);
                });

                $("form").everyTime("120s", "ReLoadPage", function () {
                    $(this).stopTime("ReLoadPage");

                    window.location.reload();
                });

                $("#WorkStationDiv").everyTime("10s", "ReLoadAudio", function () {

                    if (typeof (TokenID) == "undefined") {
                        $(this).stopTime("ReLoadAudio");
                        return;
                    }

                    $("audio")[0].src = "<%= ResolveClientUrl(@"~/Service/GetMediaFile.ashx?TokenID=") %>" + TokenID;
                    $("audio")[0].load();
                    $("audio")[0].play();

                    $(this).stopTime("ReLoadAudio");
                });
            }
        });
    </script>
    <style>
        .Text-Black {
            color: black;
        }

        .Text-White {
            color: #fff;
        }

        .panel-info > .panel-heading {
            background-color: #97CBFF !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPage" runat="Server">
    <p></p>
    <div id="WorkStationDiv" class="row col-xs-12">
    </div>
    <audio controls loop autoplay controlslist="nodownload" oncontextmenu="return false;" style="width: 1px; height: 1px;">
        <source src="" type="audio/wav" />
        Your browser does not support the audio element.
    </audio>

</asp:Content>
