ajaxUpload.files = {
  // view callback
  changed: function(){},
  pendingFiles: [],
  uploading: false,
  add: function(newFiles) {
    for (var i = 0; i < newFiles.length; i += 1) {
      this.pendingFiles.push(newFiles[i]);
    }
    if(!this.uploading) this.startUpload();
  },
  startUpload: function() {
    this.uploading = true;
    // TODO: we already have a request queue somewhere - combine!
    whilst(getNextFile.bind(this), ajaxUpload.upload.start, done.bind(this));

    function getNextFile() {
      return ajaxUpload.upload.setFile(this.pendingFiles.shift());
    }

    function done() {
      this.uploading = false
    };
  }
}
