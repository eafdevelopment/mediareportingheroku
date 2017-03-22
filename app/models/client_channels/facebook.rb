require 'rest-client'

class ClientChannels::Facebook < ClientChannel

  TARGET = "facebook"

  def generate_report_all_campaigns(from, to)
    insight_names = AppConfig.fb_and_insta_headers.for_csv.map(&:first)
    all_metrics = {
      header_row: AppConfig.fb_and_insta_headers.for_csv.map(&:last).concat(AppConfig.google_analytics_headers.for_csv.map(&:last)),
      data_rows: []
    }

    begin
      campaigns_res = RestClient.get("https://graph.facebook.com/v2.8/#{self.uid}/campaigns", {params: {
        access_token: ENV["FACEBOOK_ACCESS_TOKEN"],
        fields: "name,id,status",
        status: ["ACTIVE", "PAUSED", "DELETED", "ARCHIVED"]
      }})
      campaigns = JSON.parse(campaigns_res.body)["data"]
      campaigns.each_with_index do |campaign, index|
        if index < 11
          puts "---------------------------------"
          puts "> campaign: " +  campaign.inspect
          # check whether this is a Facebook campaign (not Instagram)
          if campaign_targeting_correct?(campaign)
            puts "> facebook campaign"
            res_insights = RestClient.get("https://graph.facebook.com/v2.8/#{campaign["id"]}/insights", {params: {
              access_token: ENV["FACEBOOK_ACCESS_TOKEN"],
              time_range: {"since": from, "until": to},
              fields: insight_names.join(","),
              time_increment: 1
            }})
            campaign_insights = JSON.parse(res_insights)["data"]
            campaign_insights.each do |insights|
              # create the data rows that we need for the CSV
              all_metrics[:data_rows].push(make_row(insight_names, insights))
              # TODO: concat GA metrics
              # !
            end
          end
        end
      end
    rescue => e
      puts "> EXCEPTION: " + e.inspect
      if e.try(:response) # if API error
        puts "> " + JSON.parse(e.response).inspect
      end
    end
    puts "> all_metrics: " + all_metrics.inspect

    return to_csv(all_metrics)
  end

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

  def campaign_targeting_correct?(campaign)
    res_adsets = RestClient.get("https://graph.facebook.com/v2.8/#{campaign["id"]}/adsets", {params: {
      access_token: ENV["FACEBOOK_ACCESS_TOKEN"],
      fields: "id,targeting"
    }})
    campaign_adsets = JSON.parse(res_adsets)["data"]
    if campaign_adsets.first["targeting"]["publisher_platforms"].include?(TARGET)
      return true
    else
      return false
    end
  end

  def parse_insights(insights, campaign_name, status, insight_names)
    puts "> parsing insights: " + insights.inspect
    row = [date, campaign_name, status]
    insight_names.each do |insight_name|
      puts "> insight_name: " + insight_name.inspect
      if insights.any? && insights[insight_name].present?
        row.push(insight[insight_name])
      else
        row.push("")
      end
    end
    # fb_row = make_row(headers, insights_for_day)
    # puts "> fb_row: " + fb_row.inspect
    # rows[:data].push(fb_row)
    # insights.each do |insights_for_day|
    #   # puts "> insights_for_day: " + insights_for_day.inspect
      
    #   #   # Insights ordered by campaign and date_start 
    #   #   insights_ordered_by_date = campaign_insights[1].group_by(&:date_start)
    #   #   insights_ordered_by_date.each do |day_insights|
        
    #   # # Facebook metrics for single row (one campaign, one day)
    #   # fb_row = make_row(headers, insights_for_day)

    #   # # GA metrics for single row (one campaign, one day)
    #   # ga_row = GoogleAnalytics.fetch_and_parse_metrics(fb_row.first, fb_row.first, self.client.google_analytics_view_id, campaign_name)
          
    #   # # Create row of FB & GA campaign metrics if there are any
    #   # ga_row[:data_rows].any? ? campaign_row = fb_row.concat(ga_row[:data_rows].first) : campaign_row = fb_row

    #   # rows[:data].push(fb_row)
    # end
    puts "> returning row: " + row.inspect
    return row
  end

  def make_row(col_headers, insights)
    # Make a row with the correct insight value ordering according to col_headers
    row = []
    col_headers.each do |header|
      puts "> checking header: " + header.inspect
      insight = insights[header]
      puts "> matching insight: " + insight.inspect
      if insight.present?
        if header == "date_start" || header == "account_name" || header =="campaign_name"
          puts ">> don't modify insight"
          row.push(insights[header])
        else
          puts ">> modify insight" 
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
    puts "> returning row: " + row.inspect
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