class ClientChannels::Adwords < ClientChannel

  def fetch_metrics #(from_date, to_date, uid, campaign_name)
    # The following line will apparently help us programmatically set the correct
    # client_customer_id, which is the account ID e.g. for Dirty Martini in AdWords,
    # which needs to be set before requesting info about that account's campaigns
    #
    adwords_client.config.set("authentication.client_customer_id", "752-213-4824")
    campaign_service = adwords_client.service(:CampaignService, :v201609)
    campaigns = campaign_service.get({:fields => ['Id', 'Name', 'Status']})
    puts "> campaigns: " + campaigns.inspect
  end

  private

  # Internal: Build and return a new Adwords API client. Ensures that the
  # client has a valid un-expired token.
  #
  # Subsequent calls to this method will return the same initialized client.
  def adwords_client
    if @adwords_client
      # Ensure token hasn't expired
      @adwords_client.authorize
      update authentication: @adwords_client.get_auth_handler.get_token

      return @adwords_client
    end
  
    authentication_hash = AppConfig.adwords.deep_dup
    authentication_hash[:oauth2_token].merge!(self.authentication)

    @adwords_client = AdwordsApi::Api.new({
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

    # Try and get a new access token if it's expired.
    token = @adwords_client.authorize

    # AdwordsApi does nothing if issued_at is nil (for example, if we've never
    # requested an access token before for this client channel), but for us
    # that means we definitely want to get a new one!
    @adwords_client.get_auth_handler.refresh_token! if !token[:issued_at]

    update authentication: @adwords_client.get_auth_handler.get_token

    return @adwords_client
  end

end
