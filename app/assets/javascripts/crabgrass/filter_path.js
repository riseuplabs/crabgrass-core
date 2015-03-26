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
    //if (window.console) { //Only log to console if there is a window.console to log to
    //  console.log('shouldUpdateServer ' + (Ajax.activeRequestCount == 0 && this.location_hash != window.location.hash));
    //}
    return(Ajax.activeRequestCount == 0 && this.location_hash != window.location.hash);
  }
}