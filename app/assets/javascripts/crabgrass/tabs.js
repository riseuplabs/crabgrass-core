//
// DYNAMIC TABS
//
// naming scheme for location hash support:
//
//   location.hash => '#most-viewed',
//   tablink.id => 'most_viewed_link',
//   tabcontent.id => 'most_viewed_panel'
//
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

//
// Activates a tab via javascript. Argument +tabLink+ should be the <a> that was clicked.
// Silently fails if the link does not exist or if the enclosing tabset does not exist.
//
// Transforms this:
//
// ul[data-toggle]
//   li
//     a
//
// into this:
//
// ul[data-toggle]
//   li.active
//     a.active
//
function activateTabLink(tabLink) {
  tabLink = $(tabLink);
  if (tabLink) {
    var tabset = tabLink.up('*[data-toggle]');
    if (tabset) {
      tabset.select('li').invoke('removeClassName', 'active');
      tabset.select('a').invoke('removeClassName', 'active');
      if (tabLink.up('li')) {tabLink.up('li').addClassName('active')}
      tabLink.addClassName('active');
      tabLink.blur();
    }
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

//
// will auto load a dynamic tab if the hash is set.
// this is not appropriate for all pages, so this needs to be called explicitly for pages
// where it is needed.
//
// for example:
//
//  content_for :dom_loaded do
//    showTabByHash();
//
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
