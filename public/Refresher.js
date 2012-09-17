//  Refresher(countdownId)
// ------------------------
// Create a new Refresher object.
// Parameters:
//	countdownId: The ID of a countdown used to fetch the remaining time.

function Refresher(countdownId) {
	this.daysField    = $('#days_left');
	this.hoursField   = $('#hours_left');
	this.minutesField = $('#minutes_left');
	this.secondsField = $('#seconds_left');
	
	var obj = this;
	$.ajax({
		url: "/api/countdown/" + countdownId,
		success: function(data, textStatus, jqXHR) {
			obj.startUpdating(JSON.parse(data))
		},
		error: function() {
			alert('error')
		}
	})
}

// 	startUpdating(data)
// ---------------------
// Start updating the HTML page with the remaining time.
// Parameters:
// 	data: A JSON string parseable as a Date object.

Refresher.prototype.startUpdating = function(data) {
	var endDate = new Date(JSON.parse(data));
	var obj = this;
	this.intervalToken = setInterval(function() {
		obj.updateRemainingTime(endDate, obj.updateTime, obj.stopUpdating);
	}, 300);
};

// 	updateRemainingTime(endDate, updateCallback, stopCallback)
// ------------------------------------------------------------
// Update the HTML page to reflect the amount of time remaining until endDate is reached.
// If we have not yet reached that date, call the updateCallback. Otherwise call the
// stopCallback to stop the update invocations.
// Parameters:
// 	endDate: The date we are counting down to on the page.
//	updateCallback: A callback to invoke with the number of seconds left as a parameter.
//	stopCallback: A callback to invoke if the endDate has been reached.

Refresher.prototype.updateRemainingTime = function(endDate, updateCallback, stopCallback) {
	var secondsLeft = Math.floor((endDate.getTime() - new Date().getTime()) / 1000);
	if (secondsLeft < 0) {
		this.stopUpdating();
	} else {
		this.updateTime(secondsLeft);
	}
};

// 	updateTime(secondsLeft)
// -------------------------
// Update the HTML page to reflect that there are secondsLeft seconds remaining until tehe
// countdown date and time.
// Parameters:
// 	secondsLeft: The number of seconds remaining until the countdown is finished.

Refresher.prototype.updateTime = function(secondsLeft) {
	var minutesLeft, hoursLeft, daysLeft;
	minutesLeft = Math.floor(secondsLeft / 60);
	hoursLeft   = Math.floor(minutesLeft / 60);
	daysLeft    = Math.floor(hoursLeft / 24);
	this.secondsField.text(secondsLeft % 60);
	this.minutesField.text(minutesLeft % 60);
	this.hoursField.text(hoursLeft % 24);
	this.daysField.text(daysLeft);
};

//  stopUpdating()
// ----------------
// Stop calling the update method.

Refresher.prototype.stopUpdating = function() {
	if (this.intervalToken) clearInterval(this.intervalToken);
};

$(document).ready(function () {
	var url = document.URL;
	var lastSlashIndex = url.lastIndexOf('/');
	var r = new Refresher(url.substring(lastSlashIndex + 1, url.length));
});