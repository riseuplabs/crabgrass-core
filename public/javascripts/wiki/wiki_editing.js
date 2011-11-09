//
// Javascript needed for wiki editings.
// If you modify this file, or any of the wiki js files, make sure to run 'rake minify'.
//
//

//
// WIKI EDITING POPUPS
//

// give a radio button group name, return the value of the currently
// selected button.
function activeRadioValue(name) {
  try { return $$('input[name='+name+']').detect(function(e){return $F(e)}).value; } catch(e) {}
}

function insertImage(wikiId) {
  var textarea = $('wiki_body');

  try {
    var assetId = activeRadioValue('image');
    var link = $('link_to_image').checked;
    var size = activeRadioValue('image_size');
    var thumbnails = $(assetId+'_thumbnail_data').value.evalJSON();
    var url = thumbnails[size];
    var insertText = '\n!' + url + '!';
    if (link)
      insertText += ':' + thumbnails['full'];
    insertText += '\n';
    insertAtCursor(textarea, insertText);
  } catch(e) {}
}

//
// TEXTAREA HELPERS
//

function insertAtCursor(textarea, text) {
  var element = $(textarea);
  if (document.selection) {
    //IE support
    var sel = document.selection.createRange();
    sel.text = text;
  } else if (element.selectionStart || element.selectionStart == '0') {
    //Mozilla/Firefox/Netscape 7+ support
    var startPos = element.selectionStart;
    var endPos   = element.selectionEnd;
    element.value = element.value.substring(0, startPos) + text + element.value.substring(endPos, element.value.length);
    element.setSelectionRange(startPos, endPos+text.length);
    element.scrollTop = startPos
  } else {
    element.value += text;
  }
  element.focus();
}
