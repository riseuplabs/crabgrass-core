var uploadFile = (function(){
  var file, action, percent, message, form, processing;

  function init(_form) {
    action = _form.action;
    form = _form;
  }

  function start(callback) {
    // Since this is the file only, we send it to a specific location
    var formData = new FormData(form);
    formData.append('asset[uploaded_data]', file);
    // Code common to both variants
    sendXHRequest(formData, callback);
    uploadFile.changed();
  }

  function sendXHRequest(formData, callback) {
    // Get an XMLHttpRequest instance
    var xhr = new XMLHttpRequest();

    // Set up events
    xhr.upload.addEventListener('loadstart', onloadstartHandler, false);
    xhr.upload.addEventListener('progress', onprogressHandler, false);
    xhr.upload.addEventListener('load', onloadHandler, false);
    xhr.upload.addEventListener('load', function(evt) { callback() }, false);
    xhr.addEventListener('readystatechange', onreadystatechangeHandler, false);

    // Set up request
    xhr.open('POST', action, true);
    // make rails recognize this as xhr
    xhr.setRequestHeader('X-Requested-With','XMLHttpRequest')

    // Fire!
    xhr.send(formData);

    // Handle the start of the transmission
    function onloadstartHandler(evt) {
      message = "upload started ...";
      uploadFile.changed();
    }

    // Handle the end of the transmission
    function onloadHandler(evt) {
      message = "processing upload ...";
      percent = 100;
      processing = true;
      uploadFile.changed();
    }

    function onprogressHandler(evt) {
      percent = Math.round(evt.loaded/evt.total*100);
      uploadFile.changed();
    }

    // Handle the response from the server
    function onreadystatechangeHandler(evt) {
      if (evt.target.readyState != 4) return;
      var status = null;

      try {
        status = evt.target.status;
      }
      catch(e) {
        return;
      }

      if (status == '200' && evt.target.responseText) {
        // TODO: is this the way to go?
        processing = false;
        uploadFile.changed();
        var resp = evt.target.responseText;
        eval(resp);
      }
    }

  }

  return {
    // callback for the view
    changed: function() {},
    // initialize with a form to get params from
    init: init,
    // trigger upload
    start: start,
    setFile: function(_file) { return file = _file },
    getFile: function() { return file },
    getPercent: function() { return percent },
    getMessage: function() { return message },
    isProcessing: function() { return !!processing }
  }
}());
