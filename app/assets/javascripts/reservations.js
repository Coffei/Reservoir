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

$("#selectpast").click(selectPastEvents);

$("#recurrence #untilField").datetimepicker({
	firstDay: 1
});

$("#recurrence #freqSelect").change(function() {
	var index = $("#recurrence #freqSelect").val();
	if(index == "2") {
		$("#recurrence #weeklyoptions").fadeIn(300);
	} else {
		$("#recurrence #weeklyoptions").fadeOut(300);

	}
	
	if(index == "4") {
		$("#recurrence #yearlyoptions").fadeIn(300);
	} else {
		$("#recurrence #yearlyoptions").fadeOut(300);

	}
});

if(typeof reservationsFeeds != 'undefined') {
	$("#calendar").fullCalendar({
		eventSources: reservationsFeeds,
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
		},
		
		loading: function(isLoading) {
			if(isLoading) {
				$("#loading").html("(loading)");
			} else {
				$("#loading").html("");
			}
		}
					
	});
}

function fillReservationModal(event) {
	//permanent fields
	$("#reservationModal #reservationLabel").html(event.title);
	$("#reservationModal #startField").html(formatDate(event.start));
	$("#reservationModal #endField").html(formatDate(event.end));
	$("#reservationModal #descriptionField").html(event.description);
	if(event.recurrence!=null) {
		$("#reservationModal #recField").html(event.recurrence);
	} else {
		$("#reservationModal #recField").html('<p class="muted" style="margin-bottom: 0px;">no recurrence</p>');
	}
	
	if(event.type=="remote") {
		
		$("#reservationModal #editLink").attr("style", "display: none;");
		$("#reservationModal #deleteLink").attr("style", "display: none;");
		$("#reservationModal #editLink").attr("href", "#");
		$("#reservationModal #deleteLink").attr("href", "#");
		$("#reservationModal #deleteLink").attr("data-method", "");
				
	} else {
		
		$("#reservationModal #editLink").attr("style", "");
		$("#reservationModal #deleteLink").attr("style", "");
		$("#reservationModal #editLink").attr("href", root_path + "/rooms/" + event.room.id + "/reservations/" + event.id + "/edit");
		$("#reservationModal #deleteLink").attr("href", root_path + "/rooms/" + event.room.id + "/reservations/" + event.id);
		$("#reservationModal #deleteLink").attr("data-method", "delete");
	
	}
	
	//non-permanent fields
	author = $("#reservationModal #authorField");
	if(author.size() != 0) {
		if(event.author!=null) {
			author.html('<a href= "' + root_path + '/users/show/' + event.author.id + '">' + event.author.login + '</a>');
		} else {
			author.html('<p class="muted" style="margin-bottom: 0px;">none</p>');
		}
	}
	
	room = $("#reservationModal #roomField");
	if(room.size() != 0) {
		room.html('<a href="' + root_path + '/rooms/' + event.room.id + '">' + event.room.name + '</a>')
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

function selectPastEvents() {
	boxes = $(".pastevent")
	for(i = 0; i < boxes.size(); i++) {
		boxes[i].checked = true;
	}
	
	return false;
}

String.prototype.lpad = function(padString, length) {
	var str = this;
    while (str.length < length)
        str = padString + str;
    return str;
}
