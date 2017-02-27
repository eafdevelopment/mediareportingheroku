require 'adwords_api'
require 'googleauth'

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
    adwords = AdwordsApi::Api.new({
      :authentication => {
          # :access_token => 'ya29.Glv_A7K4Hw_KmK21qwuvorWItBZCYjBSPYDRnm9Cjs9sie23gQbAv0Wn0MBMjuywcupT85GVmDqEl-wd2LDZWj8dF6Am86u9Arw_YlMCOrmb2lPZQfsM6zYV9I-c',
          :method => 'OAUTH2_SERVICE_ACCOUNT',
          :oauth2_issuer => 'marketing-reporting@abiding-arch-104914.iam.gserviceaccount.com',
          :oauth2_keyfile => Rails.root.join("private", "analytics_client_secret.json").to_s,
          # :method => 'OAuth2',
          # :oauth2_key => ENV['GOOGLE_CLIENT_SECRETS'],
          # :oauth2_client_id => '805050819915-4oa7i4v3c1mois8rd1f3e4389cq0acl8.apps.googleusercontent.com',
          # :oauth2_client_secret => 'KEPuO1x693iP4bW8_jF-PcOz',
          # :refresh_token => '1/xRj-7WXXpVPTD4k7ss8m73Ivph4zFudEznn_StRVb7M',
          :developer_token => 'VLRWrvozHMMogpI6rJdsBQ',
          :user_agent => 'eight&four'
          :client_customer_id => '316-190-9175', #'529-163-1130',
      },
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