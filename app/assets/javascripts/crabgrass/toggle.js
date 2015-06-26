//
// CRABGRASS TOGGLE UTILITIES
//

// Links with icons to toggle between two states and show a spinner in between.
// The link send POST and DELETE requests depending on the state.
//
// Usage:
//
// set data-toggle on a link like this
//
// link_to label, url,
//   remote: true,
//   icon: :current
//   data: { toggle: { current_icon_class: other_icon_class } },
//   method: :post
//
// When the link is clicked the current_icon_class will change to spinner_icon.
// Once the request returns it will...
//  * switch to other_icon_class if the request was successful
//  * return to current_icon_class if the request failed.
//

(function () {
  document.observe("dom:loaded", function() {

    function spinToggle(event, toggle) {
      var change = JSON.parse(toggle.readAttribute('data-toggle'));
      for(var from in change) {
        toggle.classList.remove(from);
        toggle.classList.add('spinner_icon');
      }
    }

    function revertToggle(event, toggle) {
      var change = JSON.parse(toggle.readAttribute('data-toggle'));
      for(var from in change) {
        toggle.classList.remove('spinner_icon');
        toggle.classList.add(from);
      }
    }

    function changeToggle(event, toggle) {
      var change = JSON.parse(toggle.readAttribute('data-toggle'));
      var inverse = {}
      for(var from in change) {
        var to = change[from];
        toggle.classList.remove('spinner_icon');
        toggle.classList.add(to);
        inverse[to] = from;
      }
      // toggle the other way round next time.
      toggle.writeAttribute('data-toggle', JSON.stringify(inverse));
    }

    function changeToggleMethod(event, toggle) {
      var old = toggle.readAttribute('data-method');
      if (old == 'post')   toggle.writeAttribute('data-method', 'delete');
      if (old == 'delete') toggle.writeAttribute('data-method', 'post');
    }

    document.on('ajax:create', 'a[data-toggle]', spinToggle);
    document.on('ajax:failure', 'a[data-toggle]', revertToggle);
    document.on('ajax:success', 'a[data-toggle]', changeToggle);
    document.on('ajax:success', 'a[data-toggle]', changeToggleMethod);

  });
})();

