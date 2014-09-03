//= require_directory ./upload

document.observe("dom:loaded", function() {
  initAjaxUpload();
});


//
// If you add an ajax upload form to a page via ajax,
// call this afterwards as the dom:loaded handler will
// not have activated the form.
//
function initAjaxUpload() {
  // Actually confirm support
  if (ajaxUpload.isSupported()) {
    // Ajax uploads are supported!
    // Init the single-field file upload
    ajaxUpload.init({
      form: 'upload-form',
      fileDrop: 'upload-drop',
      fileInput: 'upload-input',
      progress: 'upload-progress'
    });
  }
}

//
// taken from the brilliant async.js
//
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
}
