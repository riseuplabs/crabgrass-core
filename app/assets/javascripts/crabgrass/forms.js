//
// CRABGRASS FORM UTILITY
//

// ujs enhancements
//
// Display spinning wheels and reset forms
//
// If there is a spinning wheel in a form or a div.buttons
// it will be displayed when an ajax request is triggered from within
//
// If the form has the data attribute clear set to a valid value
// the form will be reset after submitting it.
//
(function () {
  document.observe("dom:loaded", function() {
    function startSpinner(wrapper) {
      wrapper.select('img.spin, span.spin').each(function(spinner) {
        spinner.show();
      });
    }

    function stopSpinner(wrapper) {
      wrapper.select('img.spin, span.spin').each(function(spinner) {
        spinner.hide();
      });
    }

    document.on('ajax:create', 'form', function(event, form) {
      if (form == event.findElement()) {
        startSpinner(form);
        if (form.readAttribute('data-clear')) form.reset();
      }
      if (wrapper = form.up('div.buttons')) startSpinner(wrapper);
    });
    document.on('ajax:complete', 'form', function(event, form) {
      if (form == event.findElement()) stopSpinner(form);
      if (wrapper = form.up('div.buttons')) stopSpinner(wrapper);
    });
  });
})();

// submit enhancements
//
// submit a form with ctrl+enter
//

(function() {
  function keyHandler (event, element){
    var key = event.which || event.keyCode;
    var input = element || event.currentTarget;
    var button = input.form.select('.btn-primary').first();
    switch (key) {
      default:
      break;
      case Event.KEY_RETURN:
      if (event.ctrlKey) button.click();
      break;
    }
  }

  document.on('keydown', 'form textarea', keyHandler)
})();


// Toggle the visibility of another element based on if a checkbox is checked or
// not. Additionally, sets the focus to the first input or textarea that is visible.
function checkboxToggle(checkbox, element) {
  if (checkbox.checked) {
    $(element).show();
    var focusElm = $(element).select('input[type=text]), textarea').first();
    var isVisible = focusElm.visible() && !focusElm.ancestors().find(function(e){return !e.visible()});
    if (focusElm && isVisible) {
      focusElm.focus();
    }
  } else {
    $(element).hide();
  }
}

// Toggle the visibility of another element using a link with an
// expanding/contracting arrow. call optional function when it
// becomes visible.
function linkToggle(link, element, functn) {
  if (link) {
    link = Element.extend(link);
    link.toggleClassName('right_16');
    link.toggleClassName('sort_down_16');
    $(element).toggle();
    if ($(element).visible() && functn) {functn();}
  }
}

//
// Checks if this element is in an disabled part of the DOM
// Can be used as a condition for onclick actions that should
// not happen within elements with class 'disabled'
//
function isEnabled(element) {
  if (element.hasClassName('disabled')) { return false; }
  if (!element.up(0)) { return true; }
  return isEnabled(element.up());
}

// submits a form, from the onclick of a link.
// use like <a href='' onclick='submitForm(this,"bob")'>bob</a>
// value is optional.
function submitForm(form_element, name, value) {
  var e = form_element;
  var form = null;
  do {
    if(e.tagName == 'FORM'){form = e; break}
  } while(e = e.parentNode)
  if (form) {
    var input = document.createElement("input");
    input.name = name;
    input.type = "hidden";
    input.value = value;
    form.appendChild(input);
    if (form.onsubmit) {
      form.onsubmit(); // for ajax forms.
    } else {
      form.submit();
    }
  }
}

// submit a form which updates a nested resource where the parent resource can
// be selected by the user since the parent resource is part of the form action
// path, the form action attribute has to be dynamically updated
//
// resource_url_template looks like /message/__ID__/posts resource_id_field is
// the DOM id for the input element which has the value for the resource id
// (the __ID__ value) (for example resource_id_field with DOM id 'user_name'
// has value 'gerrard'. 'gerrard' is the resource id) if ignore_default_value
// is true, then form will not get submited unless resource_id_field was
// changed by the user from the time the page was loaded
// dont_submit_default_value is useful for putting help messages into the
// field. if the user does not edit the field the help message should not be
// submitted as the resource id
function submitNestedResourceForm(resource_id_field, resource_url_template,
    dont_submit_default_value) { var input = $(resource_id_field);
  // we can submit the default value or the value has changed and isn't blank
  if(dont_submit_default_value == false || (input.value != '' && input.value !=
        input.defaultValue)) { var form = input.form; var resource_id =
    input.value; form.action = resource_url_template.gsub('__ID__',
        resource_id); form.submit(); } }

