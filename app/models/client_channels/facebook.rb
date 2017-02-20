class ClientChannels::Facebook < ClientChannel

  # def fetch_campaigns(client)
  #   # Find and store campaigns from a Facebook account in our database
  #   FacebookAds.access_token = ENV["FACEBOOK_ACCESS_TOKEN"]
  #   account = FacebookAds::AdAccount.find("act_1406179109678952")
  #   account_campaigns = account.ad_campaigns #(effective_status: nil)
  #   account_campaigns.each do |fb_campaign|
  #     campaign = Campaign.find_or_create_by(name: fb_campaign.name)
  #     campaign.client = Client.find_by(id: client.id)
  #     campaign.facebook_campaign_id = fb_campaign.id
  #     campaign.save!
  #   end
  # end

  def fetch_metrics(from_date, to_date, uid, optional={})
    # Find and return Insights for a Facebook account & campaign
    # TEMPORARILY SWITCHING TO DUMMY DATA
    # FacebookAds.access_token = ENV["FACEBOOK_ACCESS_TOKEN"]
    # ad_campaign = FacebookAds::AdCampaign.find(uid)
    # insights = ad_campaign.ad_insights # returns an array!
    return {
      facebookCpc: 1.27, #insights.map{ |insight| insight.cpc }.sum,
      facebookCtr: 0.34, #insights.map{ |insight| insight.ctr }.sum,
      facebookImpressions: 142938 #insights.map{ |insight| insight.impressions }.sum
    }
  end

end