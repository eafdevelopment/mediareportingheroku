$(document).ready(function() {

  $(document).on('change', '#client_select', function() {
    var clientId = $(this).children('option:selected').first().val();
    var url = $(this).data('ajaxUrl').replace('_CLIENT_ID_', clientId);
    $.get(url)
      .done(function() {
        $('#campaigns_select').trigger('change');
      })
      .fail(function() {
        alert('There was a problem loading campaigns. Please refresh and re-select your client.');
      });
  });

  $(document).on('change', '#campaigns_select', function() {
    var campaignId = $(this).children('option:selected').first().val();
    var url = $(this).data('ajaxUrl').replace('_CAMPAIGN_ID_', campaignId);
    $.get(url)
      .fail(function() {
        alert('There was a problem loading campaign channels. Please refresh and re-select your client and campaign.');
      });
  });

});
