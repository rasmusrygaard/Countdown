$(document).ready(function () {
	var url = document.URL;
	var lastSlashIndex = url.lastIndexOf('/');
	var refresher = new Refresher();
	var countdownTimer = new CountdownTimer(
		"/api/countdown/" + url.substring(lastSlashIndex + 1, url.length),
		function(secondsLeft) {
			refresher.updateRemainingTime(secondsLeft);
		},
		function() {
			refresher.stopUpdating();
		},
		function () {
			refresher.updateError()
		});
});