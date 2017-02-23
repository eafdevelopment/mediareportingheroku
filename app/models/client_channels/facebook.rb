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
    parsed_insights = { data_rows: [], summary_row: [] }
    parsed_insights[:header_row] = insights.first.map{ |key, val|
      # (exclude IDs, non-float & non-date values for now, to simplify reporting)
      (key == "date_start" || valid_float?(val)) && !key.include?("_id") ? key : ""
    }.reject(&:blank?)
    # if we have been given optional summary metrics, exclude any headers
    # that aren't one of those, so they won't appear in the report
    if optional[:summary_metrics].present?
      parsed_insights[:header_row].reject!{ |header| !optional[:summary_metrics].include?(header) }
    end
    insights_grouped_by_date = insights.group_by(&:date_start)
    insights_grouped_by_date.each do |that_days_insights|
      parsed_insights[:data_rows].push(make_row(parsed_insights[:header_row], that_days_insights))
    end
    parsed_insights[:summary_row] = make_row(parsed_insights[:header_row], insights)
    return parsed_insights
  end

  def make_row(col_headers, insights)
    # For each col_header, add the summed values to the data row
    row = []
    date = nil
    if valid_date?(insights.first)
      # if passed a set of insights grouped by date, the first value in 'insights'
      # will be a date, so update insights to be the second value (the insights array)
      date = insights.first
      insights = insights.second
    end
    col_headers.each do |header_item|
      if header_item == 'ctr'
        average_ctr = average('clicks', 'impressions', insights)
        row.push((average_ctr*100).round(3).to_s)
      elsif header_item == 'cpc'
        average_cpc = average('spend', 'clicks', insights)
        row.push(average_cpc.round(2).to_s)
      elsif header_item == 'cpm'
        total_spend = total('spend', insights)
        impressions_per_thousand = total('impressions', insights)/1000
        row.push((total_spend / impressions_per_thousand).round(2).to_s)
      elsif header_item == 'cpp'
        total_spend = total('spend', insights)
        total_reach = total('reach', insights)
        row.push((total_spend / total_reach).round(5).to_s)
      elsif header_item == 'date_start' && date.present?
        row.push(date)
      else
        row.push(insights.sum{ |insight| insight[header_item].to_f }.to_s)
      end
    end
    return row
  end

  def valid_float?(value)
    !!Float(value) rescue false
  end

  def valid_date?(value)
    !!Date.parse(value) rescue false
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