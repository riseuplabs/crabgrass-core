// Little ui helper that removes the element specified in data-remove
// on successful ajax requests.

(function () {
  document.observe("dom:loaded", function() {

    function removeElement(event, trigger) {
      var elemId = trigger.readAttribute('data-remove');
      var elem = document.getElementById(elemId);
      elem.remove();
    };

    document.on('ajax:success', 'a[data-remove]', removeElement);
  });
})();
