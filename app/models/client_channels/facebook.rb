class ClientChannels::Facebook < ClientChannel

  def fetch_metrics(from_date, to_date, uid, optional={})
    # Find and return Insights from a Facebook campaign, and any
    # Google Analytics metrics that we want with them
    FacebookAds.access_token = ENV["FACEBOOK_ACCESS_TOKEN"]
    ad_campaign = FacebookAds::AdCampaign.find(uid)
    insights = ad_campaign.ad_insights(
      range: Date.parse(from_date)..Date.parse(to_date)
    )
    ga_metrics = optional[:summary_metrics].reject{|metric_name| !metric_name.starts_with?("ga:")}
    return parse_facebook_insights(insights, ga_metrics, optional)
  end

  private

  def parse_facebook_insights(insights, ga_metrics, optional)
    # We need a header row e.g. ['impressions', 'clicks', 'cpc'] ...
    # plus a row of summed or averaged values
    parsed_insights = { data_row: [] }
    parsed_insights[:header_row] = insights.first.map{ |key, val|
      # (exclude headers for IDs & non-float values, e.g. dates, for now -
      # this basically simplifies the report until we know how every
      # value should be handled)
      valid_float?(val) && !key.include?("_id") ? key : ""
    }.reject(&:blank?)
    # if we have been given optional summary metrics, exclude any headers
    # that aren't one of those, so they won't appear in the report
    if optional[:summary_metrics].present?
      parsed_insights[:header_row].reject!{ |header| !optional[:summary_metrics].include?(header) }
    end
    # For each header row item, add the summed values to the data row
    # so we get ['summed_impressions_here', 'summed_clicks_here', 'summed_cpc_here']
    # TODO: we shouldn't sum all of these values! e.g. cpc & ctr should probs be averages
    parsed_insights[:header_row].each do |header_item|
      parsed_insights[:data_row].push(insights.sum{ |insight| insight[header_item].to_f }.to_s)
    end
    # If any google_analytics_metrics were given, append those to our rows here
    if ga_metrics.any?
      puts "> need to append some GA metrics"
      fetched_ga_metrics = GoogleAnalytics.fetch_metrics(
        from_date,
        to_date,
        self.client.google_analytics_view_id,
        self.google_analytics_campaign_name,
        ga_metrics
      )
      puts "> fetched_ga_metrics: " + fetched_ga_metrics.inspect

    end
    return parsed_insights
  end

  def valid_float?(value)
    !!Float(value) rescue false
  end

end