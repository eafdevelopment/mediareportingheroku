$(document).ready(function() {

  $(document).on('change', '#client_select', function() {
    clientId = $('#client_select option:selected').val();
    $.ajax('home/update_campaigns', {
      type: 'GET',
      dataType: 'script',
      data: {
        client_id: clientId
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log('AJAX Error: ' + textStatus);
      },
      success: function() {
        console.log('Client selected & campaigns found');
      }
    });
  });
});
