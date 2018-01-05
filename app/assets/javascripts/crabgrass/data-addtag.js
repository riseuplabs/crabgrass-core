// Little ui helper that removes the element specified in data-remove
// on successful ajax requests.

(function () {
  document.observe("dom:loaded", function() {

    function addTag(event, trigger) {
      var tagDiv = document.getElementById('added');
      var newTags = trigger.readAttribute('data-addtag');
      var elemId = trigger.readAttribute('data-removetag');
      if (elemId) {
        var elem = document.getElementById(elemId);
        elem.remove();
        tagDiv.insert(newTags);
      }
    };

    document.on('ajax:success', 'a[data-addtag, data-removetag]', addTag);
  });
})();
