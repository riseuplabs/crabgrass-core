//
// MISC CRABGRASS HELPERS
//
// stuff that doesn't go anywhere else.
//

//
// hides all spinners. this is called by default by most rjs templates.
//
function hideSpinners() {
  $$('.spin').invoke('hide');
  $$('html').invoke('removeClassName', 'busy');
}

function showSpinner() {
  $$('html').invoke('addClassName', 'busy');
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
// CSS/DOM UTILITY
//

function replaceClassName(element, old_class, new_class) {
  element.removeClassName(old_class); element.addClassName(new_class)
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
// DEAD SIMPLE AJAX HISTORY
// allow location.hash change to trigger a callback event.
// put <javascript>LocationHash.onChange = function(){...}</javascript>
// somewhere on the page.
//

var LocationHash = {
  onChange: null,   // called whenever location.hash changes
  current: '##',
  polling: false,
  poll: function() {
    if (window.location.hash != this.current) {
      this.current = window.location.hash;
      if (this.onChange) { this.onChange(); }
    }
  },
  setHandler: function(handler) {
    this.onChange = handler;
    this.startPolling();
  },
  startPolling: function() {
    if (!this.polling) { setInterval("LocationHash.poll()", 300) }
    this.polling = true;
  }
}
