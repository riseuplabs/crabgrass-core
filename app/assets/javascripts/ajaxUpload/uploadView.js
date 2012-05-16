var uploadView = {
  container: null,
  init: function(_container){
    this.container =_container;
  },
  render: function() {
    if (!uploadList.uploading && !uploadFile.isProcessing()) {
      this.hide();
      return
    }
    var html = '<span id="upload-filename" class="left">#{filename} (#{left})</span>' +
               '<div class="progress progress-striped progress-active">' +
               '<div class="bar" style="width: #{percent}%;"></div>' +
               '</div>' +
               '<span class="left">#{message}</span>';
    this.container.innerHTML = html.interpolate({
      filename: uploadFile.getFile().name,
      percent: uploadFile.getPercent(),
      message: uploadFile.getMessage(),
      left: uploadList.pendingFiles.length
    });
    this.container.classList.remove("hidden");
  },
  hide: function() {
    if (uploadView.container.innerHTML != "") {
      setTimeout(function () {
        uploadView.container.classList.add("hidden")
        uploadView.container.innerHTML = ""
      },1000);
    }
  }
}
