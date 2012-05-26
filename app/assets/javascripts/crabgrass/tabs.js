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
    tabset.select('li').invoke('removeClassName', 'active');
    $$('.tab_content').invoke('hide');
    tabLink.up('.tabset li').addClassName('active');
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
