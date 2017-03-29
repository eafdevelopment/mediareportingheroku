class ClientChannels::Facebook < ClientChannel

  def generate_report_all_campaigns(from, to)
    begin
      insight_names = AppConfig.fb_and_insta_headers.for_csv.map(&:first)
      all_metrics = {
        header_row: AppConfig.fb_and_insta_headers.for_csv.map(&:last).concat(AppConfig.google_analytics_headers.for_csv.map(&:last)),
        data_rows: []
      }

      campaigns_res = RestClient.get("https://graph.facebook.com/v2.8/#{self.uid}/campaigns", {params: {
        access_token: ENV["FACEBOOK_ACCESS_TOKEN"],
        fields: "name,id,status",
        status: ["ACTIVE", "PAUSED", "DELETED", "ARCHIVED"]
      }})
      campaigns = JSON.parse(campaigns_res.body)["data"]

      campaigns.each_with_index do |campaign, index|
        # check whether this campaign is targeting the correct platform
        if campaign_targeting_correct?(campaign)
          res_insights = RestClient.get("https://graph.facebook.com/v2.8/#{campaign["id"]}/insights", {params: {
            access_token: ENV["FACEBOOK_ACCESS_TOKEN"],
            time_range: {"since": from, "until": to},
            fields: insight_names.join(","),
            time_increment: 1
          }})
          campaign_insights = JSON.parse(res_insights)["data"]
          # create the data row for each insight that we need for the CSV
          campaign_insights.each do |insights|
            fb_fields = make_row(insight_names, insights)
            ga_fields = GoogleAnalytics.fetch_and_parse_metrics(insights["date_start"], insights["date_stop"], self.client.google_analytics_view_id, insights["campaign_name"])[:data_rows][0]
            all_metrics[:data_rows].push(fb_fields + ga_fields)
          end
        end
      end
      return { csv: to_csv(all_metrics) }

    rescue => e
      # if a problem occurs, log the exception to Rollbar and return a
      # message to ReportWorker to put in the dataset's status explanation
      Rollbar.log(e)
      return { error: (e.try(:message) || e.try(:response) || e.inspect) }
    end
  end

  private

  def targeting_platform
    "facebook"
  end

  def campaign_targeting_correct?(campaign)
    res_adsets = RestClient.get("https://graph.facebook.com/v2.8/#{campaign["id"]}/adsets", {params: {
      access_token: ENV["FACEBOOK_ACCESS_TOKEN"],
      fields: "id,targeting"
    }})
    campaign_adsets = JSON.parse(res_adsets)["data"]
    if campaign_adsets.present? && campaign_adsets.any? && campaign_adsets.first["targeting"]["publisher_platforms"].include?(targeting_platform)
      return true
    else
      return false
    end
  end

  def make_row(col_headers, insights)
    # Make a row with the correct insight value ordering according to col_headers
    row = []
    col_headers.each do |header|
      insight = insights[header]
      if insight.present?
        if header == "date_start" || header == "account_name" || header =="campaign_name"
          row.push(insights[header])
        else
          row.push(insights[header].to_f.round(2).to_s)
        end
      else
        row.push("")
      end
    end
    
    #   case insight
    #   when 'date_start'
    #     if date.present? then row.push(date) else row.push('') end
    #   when 'account_name'
    #     row.push(self.client.name)
    #   when 'campaign_name'
    #     if insights.first && insights.first.campaign_id
    #       campaign = FacebookAds::AdCampaign.find(insights.first.campaign_id)
    #       row.push(campaign['name'])
    #     else
    #       row.push('')
    #     end
    #   when 'ctr'
    #     # this metric must be calculated later from ga:sessions / impressions
    #     row.push('')
    #   when 'cpc'
    #     # this metric must be calculated later from spend / ga:sessions
    #     row.push('')
    #   when 'cpm'
    #     total_spend = total('spend', insights)
    #     impressions_per_thousand = total('impressions', insights)/1000
    #     total_spend != 0 && impressions_per_thousand != 0 ? row.push((total_spend / impressions_per_thousand).round(2).to_s) : ''
    #   when 'cpp'
    #     total_spend = total('spend', insights)
    #     total_reach = total('reach', insights)
    #     total_spend != 0 && total_reach != 0 ? row.push((total_spend / total_reach).round(5).to_s) : ''
    #   else
    #     row.push(insights.sum{ |i| i[insight].to_f }.round(2).to_s)
    #   end
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

  def to_csv(all_metrics)
    csv_report = CSV.generate do |csv|
      csv << all_metrics[:header_row]
      all_metrics[:data_rows].each do |data_row|
        csv << data_row
      end
    end
    return csv_report
  end
end