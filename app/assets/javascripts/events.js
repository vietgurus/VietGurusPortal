$(document).ready(function() {
  var $event_start_time = $("#event_start_time")
  var $event_end_time = $("#event_end_time")
  var $calendar = $('#calendar')

  $calendar.fullCalendar({
    googleCalendarApiKey: 'AIzaSyDh22GkOyrdOIIIyrmqwciNlgOndM-iZAk',
    eventSources: [
        {
            googleCalendarId: 'vi.vietnamese#holiday@group.v.calendar.google.com',
        },
        {
            googleCalendarId: 'vq6tkrsdc39fae7u4r7a1oo710@group.calendar.google.com',

        }
    ],
    eventClick: function(event) {
        var new_window = window.open(event.url, 'gcalevent', 'width=700,height=600');
        new_window.onbeforeunload = function(){
          $calendar.fullCalendar('refetchEvents')
        }
        return false;
    }
  });

  $event_start_time
    .datetimepicker({
        format: 'D-M-YYYY HH:mm'
    })
    .on("dp.change", function (e) {
        $event_end_time.data("DateTimePicker").minDate(e.date);
    });
  $event_end_time
    .datetimepicker({
        format: 'D-M-YYYY HH:mm',
        useCurrent: false
    })
    .on("dp.change", function (e) {
        $event_start_time.data("DateTimePicker").maxDate(e.date);
    });
});

