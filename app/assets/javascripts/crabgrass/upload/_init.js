// this will be required first due to the _ name
// - we use it to define our Namespace

var ajaxUpload = {

  init: function(ids) {
    var fileInput = document.getElementById(ids.fileInput);
    var fileDrop = document.getElementById(ids.fileDrop);
    var form = document.getElementById(ids.form);
    var progress = document.getElementById(ids.progress);
    if (!form) return;
    if (!fileInput && !fileDrop) return;
    this.upload.init(form);
    this.view.init(progress);
    this.handleInput(fileInput);
    this.handleDragAndDrop(fileDrop);
    this.upload.changed = this.view.render.bind(this.view);
  }



};
