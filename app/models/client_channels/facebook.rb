class ClientChannels::Facebook < ClientChannel

  def generate_report_all_campaigns(from, to)
    headers = AppConfig.facebook_headers.for_csv.map(&:first)
    all_metrics = {
      header_row: AppConfig.facebook_headers.for_csv.map(&:last).concat(AppConfig.google_analytics_headers.for_csv.map(&:last)),
      data_rows: []
    }

    # Find account and all campaigns for that account
    FacebookAds.access_token = ENV["FACEBOOK_ACCESS_TOKEN"]
    account = FacebookAds::AdAccount.find(self.uid)

    # Getting all insights for an account, at ad level
    date_range = Date.parse(from)..Date.parse(to)
    all_campaign_insights = account.ad_insights(range: date_range, time_increment: 1, level: 'ad').group_by(&:campaign_id)
    
    # Make rows with the insights ordered by campaign id
    rows = { data: [] }
    # campgian insights is a hash object with campaign id as key and an 
    # array of campaign insights as the value
    all_campaign_insights.each do |campaign_insights|
      # Insights order by campaign and date_start 
      insights_ordered_by_date = campaign_insights[1].group_by(&:date_start)
      insights_ordered_by_date.each do |day_insights|
        rows[:data].push(make_row(headers, day_insights))
      end
    end

    all_metrics[:data_rows].concat(rows[:data])
    return to_csv(all_metrics)
  end

  # def fetch_facebook_metrics(from_date, to_date, uid, name, headers)
    # Find and return Insights from a Facebook campaign, and any
    # Google Analytics metrics that we want with them
  #   ad_campaign = FacebookAds::AdCampaign.find(uid)

  #   date_range = Date.parse(from_date)..Date.parse(to_date)
  #   insights = ad_campaign.ad_insights(
  #     range: date_range,
  #     time_increment: 1
  #   )

  #   fb_metrics = parse_facebook_insights(insights, headers)
  #   ga_metrics = GoogleAnalytics.fetch_and_parse_metrics(from_date, to_date, self.client.google_analytics_view_id, name)

  #   metrics = {
  #     data_rows: fb_metrics[:data_rows].each_with_index{ |data_row, index| data_row.concat(ga_metrics[:data_rows][index]) unless ga_metrics[:data_rows][index].nil? }
  #   }

  #   return metrics
  # end

  private

  def to_csv(all_metrics)
    csv_report = CSV.generate do |csv|
      csv << all_metrics[:header_row]
      all_metrics[:data_rows].each do |data_row|
        csv << data_row
      end
    end
    return csv_report
  end

  # def parse_facebook_insights(insights, headers)
  #   parsed_insights = { data_rows: [] }

    # Create data rows for each individual date within the date range searched.
    # Data rows are created from the column headers required for the summary table or csv report.
  #   insights_grouped_by_date = insights.group_by(&:date_start)

  #   insights_grouped_by_date.each do |that_days_insights|
  #     parsed_insights[:data_rows].push(make_row(headers, that_days_insights))
  #   end
    
  #   return parsed_insights
  # end

  def make_row(col_headers, insights)
    # Make a row containing the correct value to match each col_header
    row = []
    date = nil
    if valid_date?(insights.first)
      # If passed a set of insights grouped by date, the first value in 'insights'
      # will be a date, so update 'insights' to be the 2nd value (the insights array)
      date = insights.first
      insights = insights.second
    end

    # Start putting values into our row
    col_headers.each do |insight, header|
      case insight
      when 'date_start'
        if date.present? then row.push(date) else row.push('') end
      when 'account_name'
        row.push(self.client.name)
      when 'campaign_name'
        if insights.first && insights.first.campaign_id
          campaign = FacebookAds::AdCampaign.find(insights.first.campaign_id)
          row.push(campaign['name'])
        else
          row.push('')
        end
      when 'ctr'
        # this metric must be calculated later from ga:sessions / impressions
        row.push('')
      when 'cpc'
        # this metric must be calculated later from spend / ga:sessions
        row.push('')
      when 'cpm'
        total_spend = total('spend', insights)
        impressions_per_thousand = total('impressions', insights)/1000
        total_spend != 0 && impressions_per_thousand != 0 ? row.push((total_spend / impressions_per_thousand).round(2).to_s) : ''
      when 'cpp'
        total_spend = total('spend', insights)
        total_reach = total('reach', insights)
        total_spend != 0 && total_reach != 0 ? row.push((total_spend / total_reach).round(5).to_s) : ''
      else
        row.push(insights.sum{ |i| i[insight].to_f }.round(2).to_s)
      end
    end
    row = strip_trailing_zeros(row)
    return row
  end

  def valid_date?(value)
    !!Date.parse(value) rescue false
  end

  def total(field, insights)
    insights.sum{ |insight| insight[field].to_f }
  end

  def strip_trailing_zeros(row)
    # if a value in a row ends with .0, remove that .0
    row.map{|metric| metric.ends_with?(".0") ? metric.chomp(".0") : metric }
  end

  def complete_calculations(all_metrics)
    # Once we have all Facebook & GA metrics together, we can calculate CTR & CPC
    # using Facebook's impressions and spend with ga:sessions
    all_metrics_with_calculations = all_metrics

    summary_row_keypairs = all_metrics[:header_row].zip(all_metrics[:summary_row]).to_h
    if summary_row_keypairs["CTR"] && summary_row_keypairs["Sessions"] && summary_row_keypairs["Impressions"]
      summary_row_keypairs["CTR"] = (summary_row_keypairs["Sessions"].to_f / summary_row_keypairs["Impressions"].to_f).round(5).to_s
    end
    if summary_row_keypairs["CPC"] && summary_row_keypairs["Spend"] && summary_row_keypairs["Sessions"]
      summary_row_keypairs["CPC"] = (summary_row_keypairs["Spend"].to_f / summary_row_keypairs["Sessions"].to_f).round(2).to_s
    end
    updated_summary_row = summary_row_keypairs.map{|k,v| v}
    all_metrics_with_calculations[:summary_row] = updated_summary_row

    all_metrics[:data_rows].each_with_index do |data_row, i|
      data_row_keypairs = all_metrics[:header_row].zip(data_row).to_h
      if data_row_keypairs["CTR"] && data_row_keypairs["Sessions"] && data_row_keypairs["Impressions"]
        data_row_keypairs["CTR"] = (data_row_keypairs["Sessions"].to_f / data_row_keypairs["Impressions"].to_f).round(5).to_s
      end
      if data_row_keypairs["CPC"] && data_row_keypairs["Spend"] && data_row_keypairs["Sessions"]
        data_row_keypairs["CPC"] = (data_row_keypairs["Spend"].to_f / data_row_keypairs["Sessions"].to_f).round(2).to_s
      end
      updated_data_row = data_row_keypairs.map{|k,v| v}
      all_metrics_with_calculations[:data_rows][i] = updated_data_row
    end

    return all_metrics_with_calculations
  end
end