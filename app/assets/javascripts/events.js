  $(document).ready(function() {
    $('#calendar').fullCalendar({
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
        // opens events in a popup window
        var new_window = window.open(event.url, 'gcalevent', 'width=700,height=600');
        new_window.onbeforeunload = function(){
            console.log('unload');
            $('#calendar').fullCalendar('refetchEvents')
        }
        return false;
    }
  });

      $('#event_start_time').datetimepicker({
          format: 'D-M-YYYY HH:mm',
      });
      $('#event_end_time').datetimepicker({
          format: 'D-M-YYYY HH:mm',
          useCurrent: false
      });
      $("#event_start_time").on("dp.change", function (e) {
          $('#event_end_time').data("DateTimePicker").minDate(e.date);
      });
      $("#event_end_time").on("dp.change", function (e) {
          $('#event_start_time').data("DateTimePicker").maxDate(e.date);
      });
});

