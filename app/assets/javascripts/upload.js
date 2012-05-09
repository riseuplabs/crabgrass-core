var files = [];
var uploading = false;

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

// Actually confirm support

document.observe("dom:loaded", function() {
  if (supportAjaxUploadWithProgress()) {
    // Ajax uploads are supported!
    // Change the support message and enable the upload button
    var notice = document.getElementById('support-notice');
    // var uploadBtn = document.getElementById('upload-button-id');
    if (notice) {
      notice.innerHTML = "Your browser supports HTML uploads. Go try me! :-)";
    }
    // uploadBtn.removeAttribute('disabled');

    // Init the single-field file upload
    initFileOnlyAjaxUpload();
  }
});

function initFullFormAjaxUpload() {
  var form = document.getElementById('form-id');
  form.onsubmit = function() {
    // FormData receives the whole form
    var formData = new FormData(form);

    // FormData only has the file
    var fileInput = document.getElementById('file-id');
    var files = fileInput.files;
    for (var i = 0; i < files.length; i++) {
      file = files.item(i);
      formData.append('asset' + i, file);
    }

    // We send the data where the form wanted
    var action = form.getAttribute('action');

    // Code common to both variants
    sendXHRequest(formData, action);

    // Avoid normal form submission
    return false;
  }
}

function initFileOnlyAjaxUpload() {
  var fileInput = document.getElementById('file-id');

  if (!fileInput) return;

  fileInput.onchange = function (evt) {

    // FormData only has the file
    var fileInput = document.getElementById('file-id');
    var addedFiles = fileInput.files;
    for (var i = 0; i < addedFiles.length; i += 1) {
      files.push(addedFiles[i]);
    }
    if(!uploading) startUpload();
  }
}

function startUpload(action) {
	var form = document.getElementById('form-id');
	var action = form.action + '.json';
  uploading = true;
  forEachSeries(files, function(file, callback) {

    onProcessingFile(file);
    // Since this is the file only, we send it to a specific location
    var formData = new FormData(form);
    formData.append('asset[uploaded_data]', file);
    // Code common to both variants
    sendXHRequest(formData, action, callback);
  }, function() {uploading = false});
}

// Once the FormData instance is ready and we know
// where to send the data, the code is the same
// for both variants of this technique
function sendXHRequest(formData, uri, callback) {
  // Get an XMLHttpRequest instance
  var xhr = new XMLHttpRequest();

  // Set up events
  xhr.upload.addEventListener('loadstart', onloadstartHandler, false);
  xhr.upload.addEventListener('progress', onprogressHandler, false);
  xhr.upload.addEventListener('load', onloadHandler, false);
  xhr.upload.addEventListener('load', function(evt) { callback() }, false);
  xhr.addEventListener('readystatechange', onreadystatechangeHandler, false);

  // Set up request
  xhr.open('POST', uri, true);

  // Fire!
  xhr.send(formData);
}

function showUploadState() {
  var upload = document.getElementById('current-upload');
  upload.setAttribute("class", "alert hook")
}

function updateUploadState(message, filename) {
  if (message) document.getElementById('upload-message').innerHTML = message;
  if (filename) document.getElementById('upload-filename').innerHTML = filename;
}

function onProcessingFile(file) {
  showUploadState();
  updateUploadState("starting upload...", file.name);
}

// Handle the start of the transmission
function onloadstartHandler(evt) {
  updateUploadState("upload started ...");
}

// Handle the end of the transmission
function onloadHandler(evt) {
  var progress = document.getElementById('upload-progress');
  // TODO: make sure this is not hidden behind progress bar
  updateUploadState("upload successful ...");
  progress.innerHTML = '&nbsp;100&nbsp;%';
  progress.setAttribute("style", "width: 100%");
}

// Handle the progress
function onprogressHandler(evt) {
  var percent = Math.round(evt.loaded/evt.total*100);
  var progress = document.getElementById('upload-progress');
  progress.innerHTML = '&nbsp;' + percent + '&nbsp;%';
  progress.setAttribute("style", "width: " + percent + '%;');
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
		// TODO: respond to successful upload
  }
}

// taken from the brilliant async.js
function forEachSeries(arr, iterator, callback) {
  if (!arr.length) {
    return callback();
  }
  var completed = 0;
  var iterate = function () {
    iterator(arr[completed], function (err) {
      if (err) {
        callback(err);
        callback = function () {};
      }
      else {
        completed += 1;
        if (completed === arr.length) {
          callback();
        }
        else {
          iterate();
        }
      }
    });
  };
  iterate();
};

