class ClientChannels::Facebook < ClientChannel

  def fetch_metrics(from_date, to_date, uid, optional={})
    # Find and return Insights from a Facebook campaign
    FacebookAds.access_token = ENV["FACEBOOK_ACCESS_TOKEN"]
    ad_campaign = FacebookAds::AdCampaign.find(uid)
    insights = ad_campaign.ad_insights(
      range: Date.parse(from_date)..Date.parse(to_date)
    )
    result = { data_row: [] }
    # Create a header row like ['impressions', 'clicks', 'cpc'] ...
    result[:header_row] = insights.first.map{ |key, val|
      # (exclude headers for IDs & non-float values, e.g. dates, for now -
      # this basically simplifies the report until we know how every
      # value should be handled)
      valid_float?(val) && !key.include?("_id") ? key : ""
    }.reject(&:blank?)
    # if we have been given optional summary metrics, exclude any headers
    # that aren't one of those, so they won't appear in the report
    if optional[:summary_metrics].present?
      result[:header_row].reject!{ |header| !optional[:summary_metrics].include?(header) }
    end
    # For each header row item, add the summed values to the data row
    # so we get ['summed_impressions_here', 'summed_clicks_here', 'summed_cpc_here']
    # TODO: we shouldn't sum all of these values! e.g. cpc & ctr should probs be averages
    result[:header_row].each do |header_item|
      result[:data_row].push(insights.sum{ |insight| insight[header_item].to_f }.to_s)
    end
    return result
  end

  private

  def valid_float?(value)
    !!Float(value) rescue false
  end

end