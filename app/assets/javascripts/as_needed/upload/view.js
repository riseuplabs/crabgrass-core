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
    var html = '<div id="upload-filename" class="left">#{filename}</div>' +
               '<div class="progress progress-striped progress-active">' +
               '<div class="bar" style="width: #{percent}%;"></div>' +
               '</div>'+
               '#{pending}';
    this.container.innerHTML = html.interpolate({
      filename: ajaxUpload.upload.getFile().name.truncate(),
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
