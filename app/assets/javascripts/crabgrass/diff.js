function renderDiff() {

  // some characters are modified by the browser once they are inserted into
  // an element. (for example ... -> …).
  // We don't want these changes to show up in the diff. So first we insert the
  // former markup into a div and then we compare the innerHTML.
  function processResponse(response) {
    var div = document.createElement("div");
    div.innerHTML = response.responseText;
    return div;
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

  function diffDiv(current) {
    var url = current.readAttribute('data-diff');
    fetchVersion(url, function(former) {
      current.innerHTML = htmldiff(former.innerHTML, current.innerHTML);
    });
  }


  function processDataDiffs(diffList) {
    // stupid NodeList does not understand forEach...
    for (var i = 0; i < diffList.length; ++i) diffDiv(diffList[i]);
  }

  var diffList = document.querySelectorAll("[data-diff]");
  processDataDiffs(diffList);

}

document.observe("dom:loaded", renderDiff);
