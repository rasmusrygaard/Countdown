//  CountdownTimer()
// ------------------------
// Create a new Refresher object.
// Parameters:
//	countdownId: The ID of a countdown used to fetch the remaining time.

function CountdownTimer(apiUrl, updateFunction, stopFunction, errorFunction) {	
	
	this.updateCallback = updateFunction;
	this.stopCallback = stopFunction;
	this.errorCallback = errorFunction;
	// "/api/countdown/" + countdownId
	var obj = this;
	$.ajax({
		url: apiUrl,
		success: function(data, textStatus, jqXHR) {
			var seconds = data * 1000;
			alert (seconds);
			var endDate = new Date(seconds);
			obj.intervalToken
			obj.startFiringCallbacks(seconds)
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

CountdownTimer.prototype.startFiringCallbacks = function(seconds) {
	var endDate = new Date(seconds);
	var now = new Date();

	var intervalToken = null;
	// If the timer has not fired, and we have an update function to call.
	if (now < endDate && this.updateCallback) {
		intervalToken = setInterval(function() {
			// Invoke the callback with the number of remaining seconds.
			this.updateCallback(Math.floor((endDate.getTime() - now.getTime()) / 1000));
		});
	} else {
		if (intervalToken) {
			clearInterval(intervalToken);
		}
		if (this.stopCallback) {
			this.stopCallback();
		} 	
	}
};