// Little ui helper that adds parameters specified in data-with
// and callbacks for onLoading and onComplete to ajax requests.

(function () {
  document.observe("dom:loaded", function() {

    function addParams(event, target) {
      var request = event.memo.request;
      var params = target.readAttribute('data-with');
      var loading = target.readAttribute('data-loading');
      var complete = target.readAttribute('data-complete');
      request.options.onLoading = function(request){eval(loading)};
      request.options.onComplete = function(request){eval(complete)};
      request.options.postBody = eval(params);
    };
    document.on('ajax:create', 'a[data-with]', addParams);
  });
})();
