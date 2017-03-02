$(document).ready(function() {

  $('#client_select').on('change', function() {

    var clientId = $(this).children('option:selected').first().val();
    if (clientId) {
      var url = $(this).data('ajaxUrl').replace('_CLIENT_ID_', clientId);
      $.get(url)
        .fail(function() {
          alert('There was a problem loading campaigns. Please refresh and re-select your client.');
        });
    };
  });

  $('#client_select').trigger('change');
});
