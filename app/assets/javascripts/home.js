$(document).ready(function() {

  $('#client_select').on('change', function() {
    var clientId = $(this).children('option:selected').first().val();

    if (clientId) {
      var url = $(this).data('ajaxUrl').replace('_CLIENT_ID_', clientId);

      $.get(url)
        .fail(function() {
          window.alert('There was a problem loading campaigns. Please refresh and re-select your client.');
        });
    };
  });

  $('#client_select').trigger('change');

  $('form#getReport').on('submit', function() {
    // set a timer to un-disable the form submit button after 30 seconds
    // (this should be replaced with a more accurate tactic at some point)
    var $submitBtn = $(this).children('input[type="submit"]');
    window.setTimeout(function() {
      $submitBtn.prop('disabled', false).val('Submit');
    }, 30000);
  });

});
