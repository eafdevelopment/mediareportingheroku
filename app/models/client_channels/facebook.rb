class ClientChannels::Facebook < ClientChannel

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