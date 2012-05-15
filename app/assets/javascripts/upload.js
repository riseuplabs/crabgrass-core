var pendingFiles = [];
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
    // Init the single-field file upload
    initFileOnlyAjaxUpload();
  }
});

function initFileOnlyAjaxUpload() {
  var fileInput = document.getElementById('file-id');
  var fileDrop = document.getElementById('file-drop');
  if (fileInput) fileInput.onchange = onFileSelected;
  if (fileDrop) {
    fileDrop.addEventListener("drop", onFileDropped, true);
    fileDrop.addEventListener("dragenter", onDragEnter, true);
    fileDrop.addEventListener("dragover", onDragOver, true);
    fileDrop.addEventListener("dragleave", onDragLeave, true);
  }
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
  addFiles(fileInput.files);
}

function onFileDropped(e) {
  addFiles(e.dataTransfer.files);
  e.stopPropagation();  
  e.preventDefault(); 
}

function addFiles(newFiles) {
  for (var i = 0; i < newFiles.length; i += 1) {
    pendingFiles.push(newFiles[i]);
  }
  if(!uploading) startUpload();
}

function startUpload() {
  var form = document.getElementById('form-id');
  var action = form.action;
  uploading = true;
  var current;
  // TODO: we already have a request queue somewhere - combine!
  whilst(getNextFile, uploadFile, done);

  function getNextFile() {
    return current = pendingFiles.shift();
  }

  function uploadFile(callback) {
    onProcessingFile(current);
    // Since this is the file only, we send it to a specific location
    var formData = new FormData(form);
    formData.append('asset[uploaded_data]', current);
    // Code common to both variants
    sendXHRequest(formData, action, callback);
  }

  function done() {uploading = false};
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
  // make rails recognize this as xhr
  xhr.setRequestHeader('X-Requested-With','XMLHttpRequest')

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
    // TODO: is this the way to go?
    var resp = evt.target.responseText;
    eval(resp);
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

