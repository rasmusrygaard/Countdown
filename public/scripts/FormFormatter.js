function FormFormatter(formId) {
	this.formId = formId;
	this.defaults = {};
	this.defaultClass = 'default-field';
}

FormFormatter.prototype.addField = function(fieldId, defaultText) {
	$field = $($('#' + this.formId).select('input').find('#' + fieldId)[0]);
	$field.val(defaultText);
	$field.addClass('default-field');
	var obj = this;
	$field.focusout(function(event) {
		var $this = $(this);
		if ($this.val() === "") {
			$this.val(defaultText);
			$this.addClass(obj.defaultClass);
		}
	});
	$field.focus(function(event) {
		var $this = $(this);
		if ($this.hasClass(obj.defaultClass)) {
			$this.val('');
			$this.removeClass(obj.defaultClass);
		}
	});
	this.defaults[fieldId] = defaultText;
};

FormFormatter.prototype.valueAdded = function(fieldId) {
	$('#' + fieldId).removeClass(this.defaultClass);
};

FormFormatter.prototype.valueCleared = function(fieldId) {
	$('#' + fieldId).addClass(this.defaultClass);
};