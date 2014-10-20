//= require_directory ./path_search

document.observe("dom:loaded", function() {
  initPathSearch();
});

function initPathSearch() {
  pathSearch.init();
  if (pathSearch.isEnabled()) {
    LocationHash.setHandler( function() {
      pathSearch.fire();
    });
  }
};

