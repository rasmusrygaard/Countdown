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
}

// 	updateTime(secondsLeft)
// -------------------------
// Update the HTML page to reflect that there are secondsLeft seconds remaining until tehe
// countdown date and time.
// Parameters:
// 	secondsLeft: The number of seconds remaining until the countdown is finished.

Refresher.prototype.updateRemainingTime = function(secondsLeft) {
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
	alert("DONE!");
};