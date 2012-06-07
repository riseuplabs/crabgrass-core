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
  activateTabLink(tabLink);
  showTabContent(tabContent);
  if (hash) {
    window.location.hash = hash;
  }
  return false;
}

function activateTabLink(tabLink, spinner) {
  tabLink = $(tabLink);
  var tabset = tabLink.up('.nav-tabs');
  if (tabset) {
    tabset.select('li').invoke('removeClassName', 'active');
    tabLink.up('.nav-tabs li').addClassName('active');
    tabLink.blur();
  } else {
    tabset = tabLink.up('.btn-group');
    tabset.select('a').invoke('removeClassName', 'active');
    tabLink.addClassName('active');
  }
  if (spinner) {
    tabset.select('a').invoke('removeClassName', 'spinner_icon icon');
    tabLink.addClassName('spinner_icon icon');
  }
}

function showTabContent(tabContent) {
  tabContent = $(tabContent);
  if (tabContent) {
    $$('.tab_content').invoke('hide');
    tabContent.show();
    evalAttributeOnce(tabContent, 'data-onvisible');
  }
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
