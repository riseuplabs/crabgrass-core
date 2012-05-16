ajaxUpload.files = ( function() {
  var pendingFiles = []
  var uploading = false

  function add(newFiles) {
    for (var i = 0; i < newFiles.length; i += 1) {
      pendingFiles.push(newFiles[i]);
    }
    if(!uploading) startUpload();
  }

  function startUpload() {
    uploading = true;
    // TODO: we already have a request queue somewhere - combine!
    whilst(getNextFile, ajaxUpload.upload.start, done);

    function getNextFile() {
      return ajaxUpload.upload.setFile(pendingFiles.shift());
    }

    function done() {
      uploading = false
    };
  }

  return {
    // view callback
    length: function(){return pendingFiles.length},
    isUploading: function(){return !!uploading},
    add: add 
  }
})();
