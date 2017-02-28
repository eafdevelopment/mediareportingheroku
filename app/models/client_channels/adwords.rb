class ClientChannels::Adwords < ClientChannel

  def fetch_metrics #(from_date, to_date, uid, campaign_name)
    # Find and return metrics from Google AdWords
    adwords_client = get_adwords_client
    # The following line will apparently help us programmatically set the correct
    # client_customer_id, which is the account ID e.g. for Dirty Martini in AdWords,
    # which needs to be set before requesting info about that account's campaigns
    #
    # adwords_client.config.set("authentication.client_customer_id", "529-163-1130")
    campaign_service = adwords_client.service(:CampaignService, :v201609)
    campaigns = campaign_service.get({:fields => ['Id', 'Name', 'Status']})
    puts "> campaigns: " + campaigns.inspect
  end

  private

  def get_adwords_client
    # TEMP
    # What if we build our own URL to request a refresh token?
    # (if re-using, make sure client_id param is updated to match
    # whatever OAuth2 client_id you're using in the Developer Console)
    # https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=805050819915-8or80ct5vsanmfi0mt1mkhkus04pncii.apps.googleusercontent.com&redirect_uri=http://localhost:3000&scope=https://www.googleapis.com/auth/adwords&access_type=offline
    # END TEMP
    
    authentication_hash = AppConfig.adwords.merge({
      user_agent: 'eight&four',
      client_customer_id: '316-190-9175'
    })

    adwords = AdwordsApi::Api.new({
      :authentication => authentication_hash,
      :service => {
        :environment => 'PRODUCTION'
      },
      :connection => {
        :enable_gzip => 'FALSE'
      },
      :library => {
        :log_level => 'INFO' # or DEBUG
      }
    })
    return adwords
  end

end
