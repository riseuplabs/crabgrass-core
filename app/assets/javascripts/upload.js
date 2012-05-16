//= require_directory ./upload

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
