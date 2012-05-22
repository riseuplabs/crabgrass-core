//= require_directory ./ajaxUpload


document.observe("dom:loaded", function() {
  initAjaxUpload();
});

// If you add an ajax upload to content added to the page via js
// call this afterwards as the dom:loaded handler will not get it.
function initAjaxUpload() {
// Actually confirm support
  if (ajaxUpload.isSupported()) {
    // Ajax uploads are supported!
    // Init the single-field file upload
    ajaxUpload.init({
      form: 'form-id',
      fileDrop: 'file-drop',
      fileInput: 'file-id',
      progress: 'current-upload'
    });
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
