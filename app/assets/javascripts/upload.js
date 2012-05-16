// let's not clutter the global scope
(function() {

  var uploadList = {
    // view callback
    changed: function(){},
    pendingFiles: [],
    uploading: false,
    addFiles: function(newFiles) {
      for (var i = 0; i < newFiles.length; i += 1) {
        this.pendingFiles.push(newFiles[i]);
      }
      if(!this.uploading) this.startUpload();
    },
    startUpload: function() {
      this.uploading = true;
      // TODO: we already have a request queue somewhere - combine!
      whilst(getNextFile, uploadFile.start, done);

      function getNextFile() {
        return uploadFile.setFile(uploadList.pendingFiles.shift());
      }

      function done() {
        uploadList.uploading = false
      };
    }
  }

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

  var uploadView = {
    container: null,
    init: function(_container){
      this.container =_container;
    },
    render: function() {
      if (!uploadList.uploading && !uploadFile.isProcessing()) {
        this.hide();
        return
      }
      var html = '<span id="upload-filename" class="left">#{filename} (#{left})</span>' +
                 '<div class="progress progress-striped progress-active">' +
                 '<div class="bar" style="width: #{percent}%;"></div>' +
                 '</div>' +
                 '<span class="left">#{message}</span>';
      this.container.innerHTML = html.interpolate({
        filename: uploadFile.getFile().name,
        percent: uploadFile.getPercent(),
        message: uploadFile.getMessage(),
        left: uploadList.pendingFiles.length
      });
      this.container.classList.remove("hidden");
    },
    hide: function() {
      if (uploadView.container.innerHTML != "") {
        setTimeout(function () {
          uploadView.container.classList.add("hidden")
          uploadView.container.innerHTML = ""
        },1000);
      }
    }
  }


  // Actually confirm support

  document.observe("dom:loaded", function() {
    if (supportAjaxUploadWithProgress()) {
      // Ajax uploads are supported!
      // Init the single-field file upload
      initAjaxUpload();
    }
  });

  function initAjaxUpload() {
    var fileInput = document.getElementById('file-id');
    var fileDrop = document.getElementById('file-drop');
    var form = document.getElementById('form-id');
    if (!form) return;
    if (!fileInput && !fileDrop) return;
    uploadFile.init(form);
    if (fileInput) fileInput.onchange = onFileSelected;
    if (fileDrop) {
      fileDrop.addEventListener("drop", onFileDropped, true);
      fileDrop.addEventListener("dragenter", onDragEnter, true);
      fileDrop.addEventListener("dragover", onDragOver, true);
      fileDrop.addEventListener("dragleave", onDragLeave, true);
    }
    uploadList.changed = uploadView.render.bind(uploadView);
    uploadFile.changed = uploadView.render.bind(uploadView);
    uploadView.init(document.getElementById('current-upload'));
  }

  function onDragEnter(e) {
    e.currentTarget.classList.add("dragging");
    e.stopPropagation();  
    e.preventDefault(); 
  }

  function onDragOver(e) {
    e.stopPropagation();  
    e.preventDefault(); 
  }

  function onDragLeave(e) {
    e.currentTarget.classList.remove("dragging");
    e.stopPropagation();  
    e.preventDefault(); 
  }

  function onFileSelected(e) {
    // FormData only has the file
    var fileInput = document.getElementById('file-id');
    uploadList.addFiles(fileInput.files);
  }

  function onFileDropped(e) {
    uploadList.addFiles(e.dataTransfer.files);
    e.stopPropagation();  
    e.preventDefault(); 
  }

  // HELPERS

  // Function that will allow us to know if Ajax uploads are supported
  function supportAjaxUploadWithProgress() {
    return supportFileAPI() && supportAjaxUploadProgressEvents() && supportFormData();

    // Is the File API supported?
    function supportFileAPI() {
      var fi = document.createElement('INPUT');
      fi.type = 'file';
      return 'files' in fi;
    };

    // Are progress events supported?
    function supportAjaxUploadProgressEvents() {
      var xhr = new XMLHttpRequest();
      return !! (xhr && ('upload' in xhr) && ('onprogress' in xhr.upload));
    };

    // Is FormData supported?
    function supportFormData() {
      return !! window.FormData;
    }
  }

  // taken from the brilliant async.js
  function whilst(test, iterator, callback) {
    if (test()) {
      iterator(function (err) {
        if (err) {
          return callback(err);
        }
        whilst(test, iterator, callback);
      });
    }
    else {
      callback();
    }
  };
}());
