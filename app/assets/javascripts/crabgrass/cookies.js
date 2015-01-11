(function () {
  var selector = '.cookie_warning';
  document.observe("dom:loaded", function() {
    function showIfCookiesDisabled(elem) {
      // two seconds should be enough to read the cookie.
      var expires = (new Date(Date.now() + 2000)).toGMTString();
      document.cookie = "are_cookies_enabled=1; expires=" + expires;
      if (document.cookie.length == 0) {
        elem.show();
      }
    }

    $$(selector).each(showIfCookiesDisabled);

    document.on('modal:onComplete', function(event, elem) {
      var warning = elem.down(selector);
      if (warning) showIfCookiesDisabled(warning);
    });
  });
})();

