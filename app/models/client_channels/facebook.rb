class ClientChannels::Facebook < ClientChannel

  def fetch_metrics(from_date, to_date, uid, ga_campaign_name, optional={})
    # Find and return Insights from a Facebook campaign, and any
    # Google Analytics metrics that we want with them
    FacebookAds.access_token = ENV["FACEBOOK_ACCESS_TOKEN"]
    ad_campaign = FacebookAds::AdCampaign.find(uid)
    date_range = Date.parse(from_date)..Date.parse(to_date)
    insights = ad_campaign.ad_insights(
      range: date_range,
      time_increment: 1
    )
    return {
      client_channel_metrics: parse_facebook_insights(insights, optional),
      additional_ga_metrics: GoogleAnalytics.fetch_and_parse_metrics(from_date, to_date, self.client.google_analytics_view_id, ga_campaign_name)
    }
  end

  private

  def parse_facebook_insights(insights, optional)
    # We need a header row e.g. ['impressions', 'clicks', 'cpc'] ...
    # plus a row of summed or averaged values
    parsed_insights = { data_row: [] }
    
    parsed_insights[:header_row] = insights.first.map{ |key, val|
      # (exclude IDs, non-float & non-date values for now, to simplify reporting)
      (valid_float?(val) || valid_date?(val)) && !key.include?("_id") ? key : ""
    }.reject(&:blank?)

    # if we have been given optional summary metrics, exclude any headers
    # that aren't one of those, so they won't appear in the report
    if optional[:summary_metrics].present?
      parsed_insights[:header_row].reject!{ |header| !optional[:summary_metrics].include?(header) }
    end
    
    puts parsed_insights[:header_row]
    
    # puts insights
    # insights.each do |insight|
    #   puts insight.ad_id.to_s + ' - ' + insight.date_start.to_s
    # end
    
    insights_grouped_by_date = insights.group_by(&:date_start)
    insights_grouped_by_date.each do |that_days_insights|
      # puts that_days_insights
      parsed_insights[:header_row].each do |header_item|
        

      end
    end

    # # For each header row item, add the summed values to the data row
    # # so we get ['summed_impressions_here', 'summed_clicks_here', 'calculated_cpc_here']
    # parsed_insights[:header_row].each do |header_item|
    #   if header_item == 'ctr'
    #     average_ctr = average('clicks', 'impressions', insights)
    #     parsed_insights[:data_row].push((average_ctr*100).round(3))
    #   elsif header_item == 'cpc'
    #     average_cpc = average('spend', 'clicks', insights)
    #     parsed_insights[:data_row].push(average_cpc.round(2).to_s)
    #   elsif header_item == 'cpm'
    #     total_spend = total('spend', insights)
    #     impressions_per_thousand = total('impressions', insights)/1000
    #     parsed_insights[:data_row].push((total_spend / impressions_per_thousand).round(2).to_s)
    #   else
    #     parsed_insights[:data_row].push(insights.sum{ |insight| insight[header_item].to_f }.to_s)
    #   end
    # end
    return parsed_insights
  end

  def valid_float?(value)
    !!Float(value) rescue false
  end

  def valid_date?(value)
    value.include? '-'
  end

  def average(a, b, insights)
    total_a = insights.sum{ |insight| insight[a].to_f }
    total_b = insights.sum{ |insight| insight[b].to_f }
    total_a / total_b
  end

  def total(field, insights)
    insights.sum{ |insight| insight[field].to_f }
  end
end