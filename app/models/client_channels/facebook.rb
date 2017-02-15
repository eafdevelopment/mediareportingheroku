class Facebook < ClientChannel

  def initialize(client)
    FacebookAds.access_token = ENV["FACEBOOK_ACCESS_TOKEN"]
    @client = client
  end

  def fetch_campaigns
    # Find and store campaigns from a Facebook account in our database
    account = FacebookAds::AdAccount.find(@client.facebook_account_id)
    account_campaigns = account.ad_campaigns #(effective_status: nil)
    account_campaign_names = account_campaigns.map{ |campaign| campaign.name }
    account_campaign_names.each do |name|
      campaign = Campaign.find_or_create_by(name: name)
      campaign.client = Client.find_by(id: @client.id)
      campaign.save!
    end
  end

end