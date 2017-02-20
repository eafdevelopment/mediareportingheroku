$(document).ready(function() {

  $(document).on('change', '#client_select', function() {
    var clientId = $('#client_select option:selected').val();
    $.ajax('home/update_campaigns', {
      type: 'GET',
      dataType: 'script',
      data: {
        client_id: clientId
      },
      error: function(jqXHR, textStatus, errorThrown) {
        alert('There was a problem loading campaigns. Please refresh and re-select your client');
      },
      success: function() {
        console.log('Client selected & campaigns found');
        $('#campaigns_select').trigger('change');
      }
    });
  });

  $(document).on('change', '#campaigns_select', function() {
    var campaignId = $('#campaigns_select option:selected').val();
    $.ajax('home/update_campaign_channels', {
      type: 'GET',
      dataType: 'script',
      data: {
        campaign_id: campaignId
      },
      error: function(jqXHR, textStatus, errorThrown) {
        alert('There was a problem loading channels. Please refresh and re-select your client and campaign');
      },
      success: function() {
        console.log('Campaign selected & campaign channels found');
      }
    });
  });

});
