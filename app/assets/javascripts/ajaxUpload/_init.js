// this will be required first due to the _ name
// - we use it to define our Namespace

var ajaxUpload = {

  init: function(ids) {
    var fileInput = document.getElementById(ids.fileInput);
    var fileDrop = document.getElementById(ids.fileDrop);
    var form = document.getElementById(ids.form);
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
  }



};
