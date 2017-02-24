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
    fb_metrics = parse_facebook_insights(insights, optional)
    ga_metrics = GoogleAnalytics.fetch_and_parse_metrics(from_date, to_date, self.client.google_analytics_view_id, ga_campaign_name)
    all_metrics = {
      header_row: fb_metrics[:header_row].concat(ga_metrics[:header_row]),
      data_rows: fb_metrics[:data_rows].each_with_index{|data_row, index| data_row.concat(ga_metrics[:data_rows][index]) unless ga_metrics[:data_rows][index].nil? },
      summary_row: fb_metrics[:summary_row].concat(ga_metrics[:summary_row])
    }
    return all_metrics
  end

  private

  def parse_facebook_insights(insights, optional)
    # We need a header row e.g. ['impressions', 'clicks', 'cpc'] ...
    # plus a row of summed or averaged values
    parsed_insights = { data_rows: [], summary_row: [] }

    # If we have been given optional summary metrics, exclude any headers
    # that aren't one of those, so they won't appear in the report
    if optional[:summary_metrics].present?
      # List of report headers in app config with following format {data_attribute: column_header}
      parsed_insights[:header_row] = AppConfig.summary_header_columns.reject{|k,v| k.include?("ga:")}.to_hash
    else
      parsed_insights[:header_row] = AppConfig.csv_header_columns.reject{|k,v| k.include?("ga:")}.to_hash
    end

    # Create data rows for each individual date within the date range searched
    # Data rows are created from the columns in the summary table or csv report
    insights_grouped_by_date = insights.group_by(&:date_start)
    insights_grouped_by_date.each do |that_days_insights|
      parsed_insights[:data_rows].push(make_row(parsed_insights[:header_row], that_days_insights))
    end
    # Include a summary row, too, for displaying in the view
    parsed_insights[:summary_row] = make_row(parsed_insights[:header_row], insights)

    # Return header_row array instead of hash object with 'pretty' column headers
    parsed_insights[:header_row] = parsed_insights[:header_row].values
    
    return parsed_insights
  end

  def make_row(col_headers, insights)
    # For each col_header, add the summed values or calculate the relevant data row
    row = []
    date = nil
    if valid_date?(insights.first)
      # If passed a set of insights grouped by date, the first value in 'insights'
      # will be a date, so update insights to be the second value (the insights array)
      date = insights.first
      insights = insights.second
    end

    col_headers.each do |insight, header|
      if insight == 'ctr'
        average_ctr = average('clicks', 'impressions', insights)
        row.push((average_ctr*100).round(3).to_s)
      elsif insight == 'cpc'
        average_cpc = average('spend', 'clicks', insights)
        row.push(average_cpc.round(2).to_s)
      elsif insight == 'cpm'
        total_spend = total('spend', insights)
        impressions_per_thousand = total('impressions', insights)/1000
        total_spend != 0 && impressions_per_thousand != 0 ? row.push((total_spend / impressions_per_thousand).round(2).to_s) : ''
      elsif insight == 'cpp'
        total_spend = total('spend', insights)
        total_reach = total('reach', insights)
        total_spend != 0 && total_reach != 0 ? row.push((total_spend / total_reach).round(5).to_s) : ''
      elsif insight == 'date_start' && date.present?
        row.push(date)
      elsif insight == 'account_name'
        row.push(self.client.name)
      elsif insight == 'campaign_name'
        if insights.first && insights.first.campaign_id
          campaign = FacebookAds::AdCampaign.find(insights.first.campaign_id)
          row.push(campaign['name'])
        else
          row.push('')
        end
      else
        row.push(insights.sum{ |i| i[insight].to_f }.to_s)
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
    if total_a == 0 && total_b == 0
      0
    else
      total_a / total_b
    end
  end

  def total(field, insights)
    insights.sum{ |insight| insight[field].to_f }
  end
end