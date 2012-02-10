
//
// CRABGRASS HELPERS
//

// shows the alert message. if there is a modalbox currently open, then the
// messages shows up there. set msg to "" in order to hide it.
function showAlertMessage(msg) {
  Autocomplete.hideAll();
  var alert_area = null;
  var modal    = $('modal_alert_messages');
  var nonmodal = $('alert_messages');
  if (modal && !modal.ancestors().detect(function(e){return !e.visible()})) {
    alert_area = modal;
  } else if (nonmodal) {
    alert_area = nonmodal;
  }
  if (alert_area) {
    if (msg=='') {
      alert_area.update('');
    } else {
      alert_area.insert({bottom: msg});
    }
  }
}

// hides all spinners. this is called by default by most rjs templates.
function hideSpinners() {$$('.spin').invoke('hide');}

function hideAlertMessage(target, fade_seconds) {
  target = $(target);
  if (!target.hasClassName('message'))
    target = target.up('.message');
  if (fade_seconds) {
    Element.fade.delay(fade_seconds, target);
  } else {
    target.hide();
  }
}

// opens the greencloth editing reference.
function quickRedReference() {
  window.open(
    "/do/static/greencloth",
    "redRef",
    "height=600,width=750/inv,channelmode=0,dependent=0," +
    "directories=0,fullscreen=0,location=0,menubar=0," +
    "resizable=0,scrollbars=1,status=1,toolbar=0"
  );
  return false;
}

//
// AUTOCOMPLETE
//

function cgAutocompleteEntities(id, url, opts) {
   var random_id = Math.floor(Math.random() * 1000000000);
   var options = {serviceUrl:url, minChars:2, maxHeight:400, width:300, onSelect: null, message: '', container: '', preloadedOnTop: true, rowRenderer: autoCompleteRowRenderer, selectValue: autoCompleteSelectValue};
   if (opts) {
     if (opts.message)   {options.message   = opts.message}
     if (opts.container) {options.container = opts.container}
     if (opts.onSelect)  {options.onSelect  = opts.onSelect}
   }
   new Autocomplete(id, options, random_id);
}

function autoCompleteRowRenderer(value, re, data) {
  return "<p class='icon xsmall' style='background-image: url(/avatars/" + data + "/xsmall.jpg)'>" + value.replace(/^<em>(.*)<\/em>(<br\/>(.*))?$/gi, function(m, m1, m2, m3){return "<em>" + Autocomplete.highlight(m1,re) + "</em>" + (m3 ? "<br/>" + Autocomplete.highlight(m3, re) : "")}) + "</p>";
}

function autoCompleteSelectValue(value){
  return value.replace(/<em>(.*)<\/em>.*/g,'$1');
}

//
// CRABGRASS DOM EXTENSIONS
//

var CgUtils = {
  scrollToBottom: function(element) {
    element = $(element);
    window.scrollTo(0, element.cumulativeOffset()[1] + element.getHeight() - document.viewport.getDimensions().height);
  }
}
Element.addMethods(CgUtils);

//
// CSS UTILITY
//

function replaceClassName(element, old_class, new_class) {
  element.removeClassName(old_class); element.addClassName(new_class)
}

//
// FORM UTILITY
//

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


// starts watching the textarea when window.onbeforeunload event happens it
// will ask the user if they want to leave the unsaved form everything that
// matches savingSelectors will permenantly disable the confirm message when
// clicked this a way to exclude "Save" and "Cancel" buttons from raising the
// "Do you want to discard this?" dialog

function confirmDiscardingTextArea(textAreaId, discardingMessage,
    savingSelectors) { 

  var textArea = $(textAreaId);
  var confirmActive = true;
  var originalValue = textArea.value;

  window.onbeforeunload = function(ev) {
    if(confirmActive) {
      var newValue = textArea.value;
      if(newValue != originalValue) {
        return discardingMessage;
      }
    }
  };

  // toggle off the confirmation when saving or explicitly discarding the text
  // area (clicking 'cancel' for example)
  savingSelectors.each(function(savingSelector) {
    var savingElements = $$(savingSelector);
    savingElements.each(function(savingElement) {
      savingElement.observe('click', function() {
        // user clicked 'save', 'cancel' or something similar
        // we should no longer display confirmation when leaving page
        confirmActive = false;
      })
    });
  });
}

//
// EVENTS
//

// returns true if the enter key was pressed
function enterPressed(event) {
  event = event || window.event;
  if(event.which) { return(event.which == 13); }
  else { return(event.keyCode == 13); }
}

function eventTarget(event) {
  event = event || window.event;            // IE doesn't pass event as argument.
  return(event.target || event.srcElement); // IE doesn't use .target
}


//
// DYNAMIC TABS
// naming scheme: 
//   location.hash => '#most-viewed', 
//   tablink.id => 'most_viewed_link', 
//   tabcontent.id => 'most_viewed_panel'
//

function evalAttributeOnce(element, attribute) {
  if (element.readAttribute(attribute)) {
    eval(element.readAttribute(attribute));
    element.writeAttribute(attribute, "");
  }
}

function showTab(tabLink, tabContent, hash) {
  tabLink = $(tabLink);
  tabContent = $(tabContent);
  var tabset = tabLink.up('.tabset');
  if (tabset) {
    tabset.select('a').invoke('removeClassName', 'active');
    $$('.tab_content').invoke('hide');
    tabLink.addClassName('active');
    tabContent.show();
    evalAttributeOnce(tabContent, 'data-onvisible');
    tabLink.blur();
    if (hash) {
      window.location.hash = hash;
    }
  }
  return false;
}

var defaultHash = null;

function showTabByHash() {
  var hash = window.location.hash || defaultHash;
  if (hash) {
    hash = hash.replace(/^#/, '').replace(/-/g, '_');
    showTab(hash+'_link', hash+'_panel')
  }
}

// returns true if the element is in a tab content area that is visible.
function isTabVisible(elem) {
  return $(elem).ancestors().find(function(e){return e.hasClassName('tab_content') && e.visible();})
}

//
// TOP MENUS
//

var DropMenu = Class.create({
  initialize: function(menu_id) {
    if(!$(menu_id)) return;
    this.trigger = $(menu_id);
    this.menu = $(menu_id).down('.menu_items');
    this.timeout = null;
    if(!this.trigger) return;
    if(!this.menu) return;
    this.trigger.observe('mouseover', this.showMenuEvent.bind(this));
    this.trigger.observe('mouseout', this.hideMenuEvent.bind(this));
    DropMenu.instances.push(this);
  },

  menuIsOpen: function() {
    return($$('.menu_items').detect(function(e){return e.visible()}) != null);
  },

  clearEvents: function(event) {
    if (this.timeout) window.clearTimeout(this.timeout);
    event.stop();
  },

  showMenuEvent: function(event) {
    evalAttributeOnce(this.menu, 'data-onvisible');
    this.clearEvents(event);
    if (this.menuIsOpen()) {
      DropMenu.instances.invoke('hideMenu');
      this.showMenu();
    } else {
      this.timeout = this.showMenu.bind(this).delay(0.3);
    }
  },

  hideMenuEvent: function(event) {
    this.clearEvents(event);
    this.timeout = this.hideMenu.bind(this).delay(0.3);
  },

  showMenu: function() {
    this.menu.show();
    this.trigger.addClassName('menu_visible');
  },

  hideMenu: function() {
    this.menu.hide();
    this.trigger.removeClassName('menu_visible');
  }

});
DropMenu.instances = [];


document.observe('dom:loaded', function() {
  $$(".drop_menu").each(function(element){
    new DropMenu(element.id);
  })
});

//
// DEAD SIMPLE AJAX HISTORY
// allow location.hash change to trigger a callback event.
// put <javascript>LocationHash.onChange = function(){...}</javascript>
// somewhere on the page.
//

var LocationHash = {
  onChange: null,   // called whenever location.hash changes
  current: '##',
  poll: function() {
    if (window.location.hash != this.current) {
      this.current = window.location.hash;
      this.onChange();
    }
  }
}

document.observe("dom:loaded", function() {
  if (LocationHash.onChange) {setInterval("LocationHash.poll()", 300)}
});

//
// split panel
//

function activatePanelRow(row_id) {
  // reset styles
  $$('.panel_right .row').invoke('hide');
  $$('.panel_arrow').invoke('hide');
  $$('.panel_left .row').invoke('removeClassName', 'active');

  if (row_id) {
    // highlight left panel row
    $('panel_left_'+row_id).addClassName('active');
    var halfHeight = $('panel_left_'+row_id).getHeight() / 2 + "px";
    var borderWidthStr = "#{top} #{right} #{bottom} #{left}".interpolate({top: halfHeight, right:"0px", bottom: halfHeight, left:"10px"});
    $('panel_arrow_'+row_id).setStyle({borderWidth: borderWidthStr, display: 'block'}); 

    // position and show right panel row
    var offset = $('panel_left_'+row_id).offsetTop + 'px';
    $$('.panel_right').first().setStyle({paddingTop:offset})
    $('panel_right_'+row_id).show();
  }
}


//
// FilterPath is a class for managing the path used in ajax page search.
//
// The path is stored in the window.location.hash. Additionally, we keep a
// separate copy in this.location_hash, so we can determine if changes to
// window.location.hash were caused by FilterPath or by some other
// means (e.g. the user hit the back button).
//

var FilterPath = {

  //
  // returns a string snippet suitable for adding to a url.
  // for example: 
  //   remote_function(:url => me_pages_path, :with => 'FilterPath.encode()')
  //
  encode: function() {
    return "filter=" + window.location.hash.sub("#","");
  },

  //
  // sets the current path by replacing the old
  //
  set: function(path) {
    window.location.hash = path;
    this.location_hash = window.location.hash;
  },

  //
  // add a single segment to the path
  //
  add: function(segment) {
    if (window.location.hash.indexOf(segment) == -1) {
      window.location.hash = (window.location.hash + segment).gsub('//','/');
      this.location_hash = window.location.hash;
    }
  },

  //
  // remove a single segment from the path
  //
  remove: function(segment) {
    window.location.hash = window.location.hash.gsub(segment,'/');
    this.location_hash = window.location.hash;
  },

  //
  // returns true if we need to send a request to the server
  // to update the search based on the window.location.hash.
  // we only do this if the window.location.hash was changed by 
  // means other than FilterPath
  //
  shouldUpdateServer: function() {
    if (window.console) { //Only log to console if there is a window.console to log to
      console.log('shouldUpdateServer ' + (Ajax.activeRequestCount == 0 && this.location_hash != window.location.hash));
    }
    return(Ajax.activeRequestCount == 0 && this.location_hash != window.location.hash);
  }
}

//
// RequestQueue allows us to make sure some requests finish before
// others start. Parameters are eval'ed when the request is fired off,
// not when it is queued.
//

var RequestQueue = {

  //
  // adds a new request to the queue.
  //
  add: function(url, options, parameters) {
    this.queue = this.queue || []
    this.queue.push({url:url, options:options, parameters:parameters});
    if (!this.timer)
      this.timer = setInterval("RequestQueue.poll()", 100)
  },

  //
  // If there are no current pending requests, send the next one on the stack.
  //
  poll: function() {
    if (Ajax.activeRequestCount == 0) {
      var req = this.queue.pop();
      if (req) {
        if (req.parameters) {req.options.parameters = eval(req.parameters)}
        new Ajax.Request(req.url, req.options);
      } else {
        clearInterval(this.timer);
        this.timer = false;
      }
    }
  }
}


