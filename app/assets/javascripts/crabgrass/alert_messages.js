//
// Crabgrass Alert Messages
//

//
// shows the alert message. if there is a modalbox currently open, then the
// messages shows up there. set msg to "" in order to hide it.
//
function showAlertMessage(msg) {
  Autocomplete.hideAll();
  var alert_area = null;
  var modal    = $('modal_alert_messages');
  var nonmodal = $('alert_messages');
  if (modal && !modal.ancestors().detect(function(e){return !e.visible()})) {
    alert_area = modal;
  } else if (nonmodal) {
    alert_area = nonmodal;
  }
  if (alert_area) {
    if (msg=='') {
      alert_area.update('');
    } else {
      alert_area.insert({bottom: msg});
    }
  }
}

//
// hide any visible alert messages
//
function hideAlertMessage(target, fade_seconds) {
  target = $(target);
  if (!target.hasClassName('message'))
    target = target.up('.message');
  if (fade_seconds) {
    Element.fade.delay(fade_seconds, target);
  } else {
    target.hide();
  }
}
