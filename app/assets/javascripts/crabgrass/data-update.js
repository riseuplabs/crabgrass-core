(function () {
  document.observe("dom:loaded", function() {

    function update(event, target) {
      var request = event.memo.request;
      var elemId = target.readAttribute('data-update');
      var elem = document.getElementById(elemId);
      elem.innerHTML = request.transport.responseText;
    };

    document.on('ajax:success', 'a[data-update]', update);

  });
})();
