ajaxUpload.handleInput = function (_fileInput) {
  if (!_fileInput) return;
  var fileInput = _fileInput;
  fileInput.onchange = onFileSelected;

  function onFileSelected(e) {
    // FormData only has the file
    ajaxUpload.files.add(fileInput.files);
  }

};

ajaxUpload.handleDragAndDrop = function (fileDrop) {
  if (!fileDrop) return;

  fileDrop.ondrop      = onFileDropped;
  fileDrop.ondragenter = onDragEnter;
  fileDrop.ondragover  = onDragOver;
  fileDrop.ondragleave = onDragLeave;

  function onFileDropped(e) {
    e.currentTarget.classList.remove("dragging");
    ajaxUpload.files.add(e.dataTransfer.files);
    e.stopPropagation();
    e.preventDefault();
  }

  function onDragEnter(e) {
    e.currentTarget.classList.add("dragging");
    e.stopPropagation();
    e.preventDefault();
  }

  function onDragOver(e) {
    e.currentTarget.classList.add("dragging");
    e.stopPropagation();
    e.preventDefault();
  }

  function onDragLeave(e) {
    e.currentTarget.classList.remove("dragging");
    e.stopPropagation();
    e.preventDefault();
  }

};

