$(document).ready(function () {
	$('#timezone-field').val(new Date().getTimezoneOffset());
	$("#date-field").datepicker({
		onSelect: function(dateText, inst) {
			formatter.valueAdded('date-field');
		},
		onClose: function(dateText, inst) {
			if (dateText === "") 
				formatter.valueCleared('date-field');
		},
		minDate: 0
	});
})