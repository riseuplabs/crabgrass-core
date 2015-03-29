ajaxUpload.view = {
  container: null,
  init: function(_container){
    this.container =_container;
  },
  render: function() {
    if (!this.container) return;
    if (!ajaxUpload.files.isUploading() && !ajaxUpload.upload.isProcessing()) {
      this.hide();
      return
    }
    var pending = ajaxUpload.files.length()
    if (pending) {
      pending = this.pendingMessage(pending)
    } else {
      pending = ''
    }
    // markup specific to bootstrap 3
    var html = '<div id="upload-filename" class="left">#{filename}</div>' +
               '<div class="progress">' +
                 '<div class="progress-bar progress-bar-striped progress-info" style="width: #{percent}%"></div>' +
               '</div>'+
               '#{pending}';
    var file = ajaxUpload.upload.getFile();
    var filename = "";
    if(file) {
      filename = file.name;
    }
    this.container.innerHTML = html.interpolate({
      filename: filename.truncate(),
      percent: ajaxUpload.upload.getPercent(),
      message: ajaxUpload.upload.getMessage(),
      pending: pending
    });
    this.container.classList.remove("hide");
  },
  hide: function() {
    if (this.container.innerHTML != "") {
      setTimeout((function () {
        this.container.classList.add("hide")
        this.container.innerHTML = ""
      }).bind(this),1000);
    }
  },
  pendingMessage: function(count) {
    var pending = this.container.readAttribute('data-pending_message');
    pending = pending || '<div>#{pending} files pending</div>';
    return pending.interpolate({pending: count});
  }
}
