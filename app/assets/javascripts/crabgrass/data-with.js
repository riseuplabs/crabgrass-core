// Little ui helper that adds parameters specified in data-with
// to ajax requests.

(function () {
  document.observe("dom:loaded", function() {

    function addSearchParams(event, request) {
      var params = request.readAttribute('data-with')
      return new Ajax.Request('/me/pages', {asynchronous:true, evalScripts:true, parameters: eval(params)});
    };
    document.on('ajax:success', 'a[data-with]', addSearchParams);
  });
})();
