$(document).ready(function() {

  $(document).on('change', '#client_select', function() {
    var clientId = $(this).children('option:selected').first().val();
    var url = $(this).data('ajaxUrl').replace('_CLIENT_ID_', clientId);
    $.get(url)
      .fail(function() {
        alert('There was a problem loading campaigns. Please refresh and re-select your client.');
      });
  });
});
