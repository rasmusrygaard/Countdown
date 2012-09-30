//  CountdownTimer()
// ------------------------
// Create a new Refresher object.
// Parameters:
//	countdownId: The ID of a countdown used to fetch the remaining time.

function CountdownTimer(apiUrl, updateFunction, stopFunction, errorFunction) {	
	
	this.updateCallback = updateFunction;
	this.stopCallback = stopFunction;
	this.errorCallback = errorFunction;
	//  + countdownId
	var obj = this;
	$.ajax({
		url: apiUrl,
		success: function(data, textStatus, jqXHR) {

			var endDate = new Date(JSON.parse(data));
			obj.intervalToken
			obj.startFiringCallbacks(JSON.parse(data))
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

CountdownTimer.prototype.startFiringCallbacks = function(data) {
	var endDate = new Date(JSON.parse(data));
	var now = new Date();
	var intervalToken = null;
	// If the timer has not fired, and we have an update function to call.
	if (now < endDate && this.updateCallback) {
		var obj = this;

		intervalToken = setInterval(function() {
			// Invoke the callback with the number of remaining seconds.
			obj.updateCallback(Math.floor((endDate.getTime() - new Date().getTime()) / 1000));
		}, 200);
		setTimeout(function() {
			clearInterval(intervalToken);
			obj.stopCallback();
		}, Math.floor((endDate.getTime() - new Date().getTime())))
	} else {
		if (intervalToken) {
			clearInterval(intervalToken);
		}
		if (this.stopCallback) {
			this.stopCallback();
		} 	
	}
};