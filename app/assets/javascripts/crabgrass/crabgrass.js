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
// replaces an element with a new one if it is empty.
//
function replaceIfEmpty(selector, newElement) {
  var el = $$(selector).first()
  if (el && el.empty()) {
    el.replace(newElement);
  }
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
// sliding list
//
// left and right contain these keys:
//   path  -- the url path of the panel. this is used both for history
//           and loading content via ajax.
//   domid -- dom id of the element to update
//
function activateSlidingRow(left, right) {
  History.replaceState({slide_right:'sliding-list', update:left}, null, left.path);
  History.pushState({slide_left:'sliding-list', update:right}, null, right.path);
}
