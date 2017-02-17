class ClientChannels::Facebook < ClientChannel

  # def fetch_campaigns(client)
  #   # Find and store campaigns from a Facebook account in our database
  #   FacebookAds.access_token = ENV["FACEBOOK_ACCESS_TOKEN"]
  #   account = FacebookAds::AdAccount.find(client.facebook_account_id)
  #   account_campaigns = account.ad_campaigns #(effective_status: nil)
  #   account_campaigns.each do |fb_campaign|
  #     campaign = Campaign.find_or_create_by(name: fb_campaign.name)
  #     campaign.client = Client.find_by(id: client.id)
  #     campaign.facebook_campaign_id = fb_campaign.id
  #     campaign.save!
  #   end
  # end

  def fetch_metrics(params)
    # Find and return Insights for a Facebook account & campaign
    # parameters = { campaign_id: 'xyz', fromDate: '', startDate: '' }
    FacebookAds.access_token = ENV["FACEBOOK_ACCESS_TOKEN"]
    ad_campaign = FacebookAds::AdCampaign.find(params[:campaign_id])
    insights = ad_campaign.ad_insights
  end

end