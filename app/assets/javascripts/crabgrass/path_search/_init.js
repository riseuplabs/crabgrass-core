// this will be required first due to the _ name
// - we use it to define our Namespace

var pathSearch = {

  init: function() {
    var search = $$('[data-search=path]').first();
    if (!search) return;
    this.searchUrl = search.readAttribute('data-href');
  },

  isEnabled: function() {
    return !!this.searchUrl;
  },

  fire: function() {
    if (FilterPath.shouldUpdateServer()) { 
      RequestQueue.add(this.searchUrl, {}, "FilterPath.encode() + '&_method=get'")
    }
  }

};
