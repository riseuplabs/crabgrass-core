//
// here lies a bunch of javascript that was once used, but is now not. 
// maybe it will be again in the future.
//

//
// CSS
//

function setClassVisibility(selector, visibility) {
  $$(selector).each(function(element){
    visibility ? element.show() : element.hide();
  })
}

//
// FORMS
//

// toggle all checkboxes of a particular css selector, based on the
// checked status of the checkbox passed in.
function toggleAllCheckboxesToMatch(checkbox, selector) {
  $$(selector).each(function(cb) {cb.checked = checkbox.checked});
}

// toggle all checkboxes of a particular css selector to checked boolean parameter
function toggleAllCheckboxes(checked, selector) {
  $$(selector).each(function(cb) {cb.checked = checked});
}

// used to make textareas bigger when they have focus
// e.g. the 'say' box.
function setRows(elem, rows) {
  elem.rows = rows;
  if(rows < 1)
    elem.addClassName('tall');
  else
    elem.removeClassName('tall');
}

//
// POSITION
//

//
// this should be replaced with element.cumulativeOffset()
//
//function absolutePosition(obj) {
//  var curleft = 0;
//  var curtop = 0;
//  if (obj.offsetParent) {
//    do {
//      curleft += obj.offsetLeft;
//      curtop += obj.offsetTop;
//    } while (obj = obj.offsetParent);
//  }
//  return [curleft,curtop];
//}
//function absolutePositionParams(obj) {
//  var obj_dims = absolutePosition(obj);
//  var page_dims = document.viewport.getDimensions();
//  return 'position=' + obj_dims.join('x') + '&page=' + page_dims.width + 'x' + page_dims.height
//}

//
// DESCRIPTIONS
//

var AddDescription = Class.create({
  initialize: function(item) {
    if(!item) return;
    this.trigger = item;
    this.description = item.down('.description');
    this.timeout = null;
    if(!this.trigger) return;
    if(!this.description) return;
    this.trigger.observe('mouseover', this.showDescriptionEvent.bind(this));
    this.trigger.observe('mouseout', this.hideDescriptionEvent.bind(this));
    AddDescription.instances.push(this);
  },

  descriptionIsOpen: function() {
    return($$('.description').detect(function(e){return e.visible()}) != null);
  },

  clearEvents: function(event) {
    if (this.timeout) window.clearTimeout(this.timeout);
    event.stop();
  },

  showDescriptionEvent: function(event) {
    evalOnclickOnce(this.description);
    this.clearEvents(event);
    if (this.descriptionIsOpen()) {
      DropMenu.instances.invoke('hideMenu');
      this.showDescription();
    } else {
      this.timeout = this.showDescription.bind(this).delay(1);
    }
  },

  hideDescriptionEvent: function(event) {
    this.clearEvents(event);
    this.timeout = this.hideDescription.bind(this).delay(.5);
  },

  showDescription: function() {
    this.description.show();
    this.trigger.addClassName('with_description');
  },

  hideDescription: function() {
    this.description.hide();
    this.trigger.removeClassName('with_description');
  }

});
AddDescription.instances = [];


//var statuspostCounter = Class.create({
//  initialize: function(id) {
//    if (!$(id)) return;
//    this.trigger = $(id);
//    this.textarea = $(id);
//    this.trigger.observe("keydown", this.textLimit.bind(this));
//    this.trigger.observe("keyup", this.textLimit.bind(this));
//  },
//  textLimit: function(event) {
//    if (this.textarea.value.length > 140) {
//       this.textarea.value = this.textarea.value.substring(0, 140);
//    }
//  }
//});

//var DropSocial = Class.create({
//  initialize: function() {
//    id = "show-social"
//    if(!$(id)) return;
//    this.trigger = $(id);
//    if(!this.trigger) return;
//    this.container = $('social-activities-dropdown');
//    if (!this.container) return;
//    this.activities = $('social_activities_list');
//    if(!this.activities) return;
//    this.trigger.observe('click', this.toggleActivities.bind(this));
//    document.observe('click', this.hideActivities.bind(this));
//  },
//  IsOpen: function() {
//    return this.container.visible();
//  },
//  toggleActivities: function(event) {
//    if (this.IsOpen()) {
//      this.container.hide();
//      this.clearEvents(event);
//    } else {
//      this.container.show();
//      event.stopPropogation();
//      this.clearEvents(event);
//    }
//  },
//  hideActivities: function(event) {
//    element = Event.findElement(event);
//    elementUp = Event.findElement(event, 'div');
//    if ((element != this.trigger) && (elementUp != this.container)) {
//      if (!this.IsOpen()) return;
//      this.container.hide();
//    }
//  }
//})

//var LoadSocial = Class.create({
//  initialize: function() {
//    this.doRequest();
//    new PeriodicalExecuter(this.doRequest, 120);
//  },
//  doRequest: function() {
//    if ($('social-activities-dropdown').visible()) return;
//    new Ajax.Request('/me/social-activities', {
//      method: 'GET',
//      parameters: {count: 1}
//    });
//  }
//})


document.observe('dom:loaded', function() {
  $$(".drop_menu").each(function(element){
    new DropMenu(element.id);
  })
  $$(".add_description").each(function(element){
    new AddDescription(element);
  })
  new statuspostCounter("say_text");
  new LoadSocial();
  new DropSocial();
});


//
// COMMON MODAL DIALOGS
// todo: change this. it doesn't work well with remembered forms.
//

function loginDialog(txt,options) {
  var form = '' +
  '<form class="login_dialog" method="post" action="/account/login">' +
  '  <input type="hidden" value="#{token}" name="authenticity_token" id="redirect"/>' +
  '  <input type="hidden" value="#{redirect}" name="redirect" id="redirect"/>' +
  '  <label>#{username}</label><input type="text" name="login" id="login" tabindex="1"/>' +
  '  <label>#{password}</label><input type="password" name="password" id="password" tabindex="2"/>' +
  '  <input type="submit" value="#{login}" tabindex="3"/>' +
  '  <span class="small">'
  form += '<a href="/account/signup">#{create_account}</a> | '
  form += '<a href="/account/forgot_password">#{forgot_password}</a></span>' +
  '</form>'
  form = form.interpolate(txt);
  Modalbox.show(form, {title:txt.login, width:350});
}



// 
// This allows you to set and remove global styles programatically
// really cool, but not currently used.
//
//var Style = {
//  set:function(id, css) {
//    var styleNode = $(id);
//    if (!styleNode) {
//      styleNode = new Element('style', {id:id, type:'text/css'});
//      $$('head')[0].appendChild(styleNode);
//    }
//    if(Prototype.Browser.IE) {
//      styleNode.styleSheet.cssText = css;
//    } else {
//      styleNode.update(css);
//    }
//  },
//  clear:function(id) {
//    this.set(id,'');
//  }
//}

