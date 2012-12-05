$("#manyswitch").click(function() {
  $("#manyswitch").fadeOut(300);
  setTimeout(function() {
  	$(".manyinput").fadeIn(300);
  	$("#manyaction").slideDown(300);
  }, 300);
  return false;
});

$("#manyclose").click(function() {
  $(".manyinput").fadeOut(300, function() {
  	$(".manyinput").attr("style", "display:none;");
  });
  $("#manyaction").slideUp(300);
  setTimeout(function() {
  	$("#manyswitch").fadeIn(500);	
  }, 300);
  
  return false;
});

if(typeof reservationsFeed != 'undefined') {
	$("#calendar").fullCalendar({
		events: reservationsFeed,
		theme: true,
		firstDay: 1,
		aspectRatio: 2,
		allDaySlot: false,
		axisFormat: "HH:mm",
		timeFormat: {
			agenda: "HH:mm{ - HH:mm}",
			"": "H'h'"			
		},
		header: {
					left: "prev,next today",
					center: "title",
					right: "month,agendaWeek,agendaDay"
		},
		
		eventClick: function(event) {
			fillReservationModal(event);
			
			$("#reservationModal").modal({
				show: true
			});
			
			return false;
		},
		
		dayClick: function(date, allDay, jsEvent, view) {
			var view = $("#calendar").fullCalendar("getView").name;
			if(view == "month") {
				$("#calendar").fullCalendar("changeView", "agendaWeek");
			} else {
				$("#calendar").fullCalendar("changeView", "agendaDay");
			}
			
			$("#calendar").fullCalendar("gotoDate", date);
		}
		
		
					
	});
}

function fillReservationModal(event) {
	//permanent fields
	$("#reservationModal #reservationLabel").html(event.title);
	$("#reservationModal #startField").html(formatDate(event.start));
	$("#reservationModal #endField").html(formatDate(event.end));
	$("#reservationModal #descriptionField").html(event.description);
	$("#reservationModal #editLink").attr("href", "/rooms/" + event.room.id + "/reservations/" + event.id + "/edit");
	$("#reservationModal #deleteLink").attr("href", "/rooms/" + event.room.id + "/reservations/" + event.id);
	$("#reservationModal #deleteLink").attr("data-method", "delete");
	
	//non-permanent fields
	author = $("#reservationModal #authorField");
	if(author.size() != 0) {
		author.html('<a href="/users/show/' + event.author.id + '">' + event.author.login + '</a>');
	}
	
	room = $("#reservationModal #roomField");
	if(room.size() != 0) {
		room.html('<a href="/rooms/' + event.room.id + '">' + event.room.name + '</a>')
	}
	
}

function formatDate(date) {
	var m = date.getMonth()+1;
	var d = date.getDate();
	var y = date.getFullYear();
	var h = date.getHours();
	var min = date.getMinutes();
	
	return m + "/" + d + "/" + y + " " + h + ":" + min.toString().lpad("0",2); 
}


String.prototype.lpad = function(padString, length) {
	var str = this;
    while (str.length < length)
        str = padString + str;
    return str;
}
