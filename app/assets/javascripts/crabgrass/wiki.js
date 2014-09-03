//
// EVENTS
//

document.on('ajax:create', 'a.wiki_tab', function(event) {
  showSpinner();
});

document.on('ajax:complete', 'a.wiki_tab', function(event) {
  hideSpinners();
});

document.on('ajax:create', '#edit_mode_button', function(event) {
  var request = event.memo.request;
  request.url += '&profile=' + window.location.hash.slice(1);
  $('edit_mode_spinner').show();
});

document.on('ajax:complete', '#edit_mode_button', function(event) {
  $('edit_mode_spinner').hide();
});

//
// WIKI HELPERS
//

// returns the wiki id that this element is associated with.
// otherwise, return undef.
function wikiId(element) {
  var wikiDiv = $(element).up('*[data-wiki]');
  if (wikiDiv) {
    return wikiDiv.readAttribute('data-wiki');
  }
}

//
// TEXTAREA DISCARD
// Warn the user if they are about to lose their wiki editing work by clicking away.
// Assign .wiki_away to any link that might discard the text area.
// This supports multiple wikis on the page at the same time, so long as each wiki
// has an enclosing element with 'data-wiki' attribute.
//

// disable check if a save or cancel button is pressed.
document.on('click', 'input.wiki_button', function(event, element) {
  confirmWikiDiscard.disable(wikiId(element));
});

// check for ajax requests that might destroy unsaved content
document.on('ajax:before', 'a.wiki_tab, a.wiki_away', function(event, element) {
  if (confirmWikiDiscard.shouldAsk(wikiId(element))) {
    if (!confirm(confirmWikiDiscard.message)) {
      event.stop();
    }
  }
});

var confirmWikiDiscard = {
  wikis: $H({}),
  setTextArea : function(wikiId, textAreaId, message) {
    this.wikis.set(wikiId, {
      taId:textAreaId, oldValue:$(textAreaId).value, enabled:true
    });
    this.message = message;
    window.onbeforeunload = function(ev) {
      if(this.shouldAsk()) {
        return this.message;
      }
    }.bind(this);
  },
  disable : function(wikiId) {
    this.wikis.get(wikiId).enabled = false;
  },
  shouldAsk : function(wikiId) {
    var changed = false;
    if (wikiId) {
      changed = this.wikiChanged(wikiId);
    } else {
      this.wikis.keys().each(function(id) {
        changed = changed || this.wikiChanged(id);
      }.bind(this));
    }
    return changed;
  },
  wikiChanged : function(wikiId) {
    var item = this.wikis.get(wikiId);
    var textarea = $(item.taId);
    return (item.enabled && textarea && textarea.value != item.oldValue);
  }
}


//
// AUTO UNLOCK
// We don't want to keep the wiki locked after leaving the page.
// Assign .wiki_away to any link that might discard the text area.
//

document.on('ajax:create', 'a.wiki_away', function(event, element) {
  wikiLock.releaseNow(wikiId(element));
});

var wikiLock = {
  locks : $H({}),
  autoRelease : function(wikiId, url) {
    this.locks.set(wikiId, url);
    window.onunload = function(ev) {
      this.releaseNow(null);
    }.bind(this);
  },
  releaseNow : function(wikiId) {
    if (wikiId) {
      this.fireRelease(wikiId);
    } else {
      this.locks.keys().each(function(id) {
        this.fireRelease(id);
      }.bind(this));
    }
  },
  fireRelease : function(wikiId) {
    var url = this.locks.get(wikiId);
    this.locks.unset(wikiId); // <- prevent additional unlocking
    new Ajax.Request(url, {
      method: 'delete', asynchronous: false,
      parameters: {authenticity_token: $$('meta[name=csrf-token]')[0]}
    });
  }
}

//
// WIKI EDITING POPUPS
//

// give a radio button group name, return the value of the currently selected button.
function activeRadioValue(name) {
  try { return $$('input[name='+name+']').detect(function(e){return $F(e)}).value; } catch(e) {}
}

//
// insert image at the current cursor position
//
function insertImage(textarea) {
  var textarea = $(textarea);
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

function updatePreview() {
  var preview_area = $$('.image_preview').first();
  var assetId = activeRadioValue('image');
  var size = 'medium'; //activeRadioValue('image_size');
  var thumbnails = $(assetId+'_thumbnail_data').value.evalJSON();
  var url = thumbnails[size];
  preview_area.update("<img src='" + url + "'></img>")
}

//
// insert text where the cursor currently is. used by image popup
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
