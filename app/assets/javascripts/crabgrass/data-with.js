// Little ui helper that constructs an ajax request containing parameters specified in data-with
// used for link_to_remote_icon calls in the search form and for sharing pages via the plus button

(function () {
  document.observe("dom:loaded", function() {
    function addParams(event, request) {
      var params = request.readAttribute('data-with')
      var complete = request.readAttribute('data-confirm')
      var loading = request.readAttribute('data-loading')
      new Ajax.Request(request.href, {asynchronous:true, evalScripts:true, parameters: eval(params), onComplete:function(request){eval(complete)}, onLoading:function(request){eval(loading)}});
    };
    document.on('ajax:success', 'a[data-with]', addParams);
  });
})();
