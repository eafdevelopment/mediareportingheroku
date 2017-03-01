class ClientChannels::Adwords < ClientChannel

  def fetch_metrics(from_date, to_date, uid, campaign_name, optional={})
    # Find and return metrics from Google AdWords
    adwords_client = get_adwords_client
    puts "> self.uid: " + self.uid.inspect
    adwords_client.config.set("authentication.client_customer_id", self.uid) # DMU Intl: "752-213-4824"
    campaign_service = adwords_client.service(:CampaignService, :v201609)
    campaigns = campaign_service.get({:fields => ['Id', 'Name', 'Status']})
    puts "> campaigns: " + campaigns.inspect

  end

  private

  def get_adwords_client
    authentication_hash = AppConfig.adwords.merge({
      user_agent: 'eight&four'
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

    # Will raise an exception if authorization fails, but also will refresh
    # the access token if it has expired (which it almost certainly will have)
    adwords.authorize

    return adwords
  end

end
