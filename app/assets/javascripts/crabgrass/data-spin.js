(function () {
  document.observe("dom:loaded", function() {

    function spin(event, target) {
      var spinnerId = target.readAttribute('data-spin');
      var spinner = document.getElementById(spinnerId);
      spinner.style.display = 'block';
    };

    function stop(event, target) {
      var spinnerId = target.readAttribute('data-spin');
      var spinner = document.getElementById(spinnerId);
      spinner.style.display = 'none';
    };

    document.on('ajax:create', 'a[data-spin]', spin);
    document.on('ajax:complete', 'a[data-spin]', stop);

  });
})();
