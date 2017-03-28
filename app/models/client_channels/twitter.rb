require 'twitter-ads'

class ClientChannels::Twitter < ClientChannel

  def generate_report_all_campaigns(from, to)
    client = twitter_credentials
    account = client.accounts(self.uid)
    headers = AppConfig.twitter_headers.for_csv.map(&:last).concat(AppConfig.google_analytics_headers.for_csv.map(&:last))
    from = format_date(from, account.timezone)
    to = format_date(to, account.timezone)
    dates_array = from..to

    # Getting metrics from Twitter Ads Ruby SDK, fetching one
    # block of stats per date to bypass 7-day limits
    data_rows = []
    campaigns = get_campaigns(self.uid)
    campaigns.each do |campaign|
      puts "> getting stats for campaign: #{campaign[:name]}"
      dates_array.each do |date|
        date_string = date.strftime('%Y-%m-%d')
        stats = get_stats(campaign[:id], date, date+1.day)
        impressions = begin stats.first[:id_data].first[:metrics][:impressions].first rescue nil end
        total_spend = begin stats.first[:id_data].first[:metrics][:billed_charge_local_micro].first rescue nil end
        billed_spend = total_spend ? (total_spend.to_f/1000000).round(2) : nil
        ga_data = GoogleAnalytics.fetch_and_parse_metrics(date_string, date_string, self.client.google_analytics_view_id, campaign[:name])
        data_rows.push(
          [ date_string,
            account.name,
            campaign[:name],
            campaign[:entity_status],
            (impressions ? impressions : '-'),
            (billed_spend ? billed_spend : '-'),
            calculate_cpm(billed_spend, impressions)
          ].concat(ga_data[:data_rows].first)
        )
      end
    end
    return to_csv(headers, data_rows)
  end

  private

  def twitter_credentials
    TwitterAds::Client.new(
      ENV['TWITTER_CONSUMER_KEY'],
      ENV['TWITTER_CONSUMER_SECRET'],
      ENV['TWITTER_ACCESS_TOKEN'],
      ENV['TWITTER_ACCESS_TOKEN_SECRET']
    )
  end

  def format_date(date_string, timezone)
    datetime = Time.parse(date_string)
    return DateTime.new(datetime.year, datetime.month, datetime.day, 0, 0, 0, timezone)
  end

  def get_campaigns(account_id)
    campaigns_req = TwitterAds::Request.new(twitter_credentials, :get, "/1/accounts/#{account_id}/campaigns")
    campaigns_result = campaigns_req.perform
    campaigns = campaigns_result.body[:data]
    return campaigns.select{|campaign| 
      !campaign[:reasons_not_servable].include?('EXPIRED') && !campaign[:reasons_not_servable].include?('BUDGET_EXHAUSTED')
    }
  end
  
  def get_stats(campaign_id, from, to)
    stats_req = TwitterAds::Request.new(twitter_credentials, :get,  "/1/stats/accounts/#{self.uid}", {params: {
      entity: "CAMPAIGN",
      entity_ids: campaign_id,
      start_time:  from.strftime('%Y-%m-%dT%H:%M:%S%z'),
      end_time:  to.strftime('%Y-%m-%dT%H:%M:%S%z'),
      granularity: 'TOTAL',
      placement: 'ALL_ON_TWITTER',
      metric_groups: 'ENGAGEMENT,BILLING'
    }})
    stats_res = stats_req.perform
    return stats_res.body[:data]
  end

  def calculate_cpm(spend, impressions)
    if spend.present? && impressions.present? && spend != '-' && impressions != '-'
      return ((spend/impressions) * 1000).round(2)
    else
      return '-'
    end
  end

  def to_csv(header_row, data_rows)
    csv_report = CSV.generate do |csv|
      csv << header_row
      data_rows.each do |data_row|
        csv << data_row
      end
    end
    return csv_report
  end
end
