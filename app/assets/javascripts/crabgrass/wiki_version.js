(function () {
  document.observe("dom:loaded", function() {

    function showVersion(event, trigger) {
      var wikiId = trigger.readAttribute('data-wiki-id');
      if (wikiId !== null){
        var wikiVersion = trigger.readAttribute('data-wiki-version');
        new Ajax.Request('/wikis/'+wikiId+'/versions/'+wikiVersion,
                         {asynchronous:true,
                          evalScripts:true,
                          method:'get',
                          onLoaded:function(request){hideSpinners()},
                          onLoading:function(request){showSpinner()}
      });
    }}
    document.on('mousedown', 'li[data-wiki-id, data-wiki-version]', showVersion);
  });
})();
