(function () {
  document.observe("dom:loaded", function() {

    // (1) submit the form when the enter key is pressed in the text box
    // (2) don't submit the form if the recipient name field is empty
    // (3) eat the event by returning false on a enter key so that the form
    //     is not submitted.
    function addRecipientOnEnter(event) {
      if (enterPressed(event) && $('recipient_name').value != '') {
        $('add_recipient_button').click()
      }
      return(!enterPressed(event));
    }

    document.on('keypress', 'input#recipient_name', addRecipientOnEnter);
  });
})();
