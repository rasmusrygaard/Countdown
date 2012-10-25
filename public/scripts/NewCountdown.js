$(document).ready(function () {
	$('#timezone-field').val(new Date().getTimezoneOffset());
	var formatter = new FormFormatter('countdown-form');
	formatter.addField('hour-field', '12');
	formatter.addField('minute-field', '51');
	formatter.addField('date-field', '13/07/2013');
	formatter.addField('description-field', 'Something happens...');
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