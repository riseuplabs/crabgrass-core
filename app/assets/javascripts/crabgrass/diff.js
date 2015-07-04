function renderDiff() {

  function processResponse(response) {
    return response.responseText;
  }

  function fetchVersion(url, callback){
    var req = new Ajax.Request(url, {
      asynchronous:true,
      method:'get',
      requestHeaders: {'Accept': 'text/html'},
      onComplete: function(response) {
        callback(processResponse(response));
      }
    });
  }

  function diffDiv(div) {
    var url = div.readAttribute('data-diff');
    fetchVersion(url, function(former) {
      div.innerHTML = htmldiff(former, div.innerHTML);
    });
  }


  function processDataDiffs(diffList) {
    // stupid NodeList does not understand forEach...
    for (var i = 0; i < diffList.length; ++i) diffDiv(diffList[i]);
  }

  var diffList = document.querySelectorAll("[data-diff]");
  processDataDiffs(diffList);

}
