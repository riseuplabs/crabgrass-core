//= require_directory ./ajaxUpload

// Actually confirm support

document.observe("dom:loaded", function() {
  if (ajaxUpload.isSupported()) {
    // Ajax uploads are supported!
    // Init the single-field file upload
    ajaxUpload.init({
      form: 'form-id',
      fileDrop: 'file-drop',
      fileInput: 'file-id'
    });
  }
});
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
