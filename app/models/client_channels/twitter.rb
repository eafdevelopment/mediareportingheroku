require 'twitter-ads'

class ClientChannels::Twitter < ClientChannel

  def generate_report_all_campaigns(from, to)

    client = twitter_credentials
    account = client.accounts(self.uid)
    headers = AppConfig.twitter_headers.for_csv.map(&:last).concat(AppConfig.google_analytics_headers.for_csv.map(&:last))

    # Add a day before the search query because Twitter only accepts date
    # params with time set at midnight, so first date isn't included in metrics
    # Then remove added day from dates array
    from = format_date(from)
    to = (format_date(to)) #+ 1.day
    puts from
    puts to
    puts from.iso8601
    puts to.iso8601
    dates_array = (from..(to + 1.hour)).map{ |date| date.strftime("%d-%m-%Y") }

    # Getting metrics from Twitter Ads Ruby SDK
    api_metrics = get_twitter_metrics(account, from, to)

    # Arranging data with dates, campaign & metrics
    report_metrics = format_twitter_metrics(api_metrics, dates_array)

    # Getting report rows and returning a CSV
    data = parse_metrics(report_metrics[:data_rows], headers)

    return to_csv(headers, data[:rows])
  end

  private

  def to_csv(header_row, data_rows)
    csv_report = CSV.generate do |csv|
      csv << header_row
      data_rows.each do |data_row|
        csv << data_row
      end
    end
    return csv_report
  end

  def twitter_credentials
    TwitterAds::Client.new(
      ENV['TWITTER_CONSUMER_KEY'],
      ENV['TWITTER_CONSUMER_SECRET'],
      ENV['TWITTER_ACCESS_TOKEN'],
      ENV['TWITTER_ACCESS_TOKEN_SECRET']
    )
  end

  def format_date(date_string)
    now = DateTime.now 
    datetime = Time.parse(date_string)
    return DateTime.new(datetime.year, datetime.month, datetime.day, 0, 0, 0, now.zone)
  end

  def get_twitter_metrics(account, from, to)
    api_metrics = {}
    account.line_items.each do |i|
      campaign = account.campaigns(i.campaign_id)
      # Exclude Campaigns that have 'EXPIRED' or have are 'BUDGET_EXPIRED'
      # So as to keep API requests as low as possible
      # Include Campaigns that are ACTIVE or 'PAUSED_BY_ADVERTISER'
      if !campaign.reasons_not_servable.include?('EXPIRED') && !campaign.reasons_not_servable.include?('BUDGET_EXHAUSTED')
        puts "Getting metrics for campaign: #{campaign.name}"
        stats = TwitterAds::LineItem.stats(account, [i.id], ['ENGAGEMENT', 'BILLING'], start_time: from, end_time: to, granularity: 'DAY')

        impressions = stats.first[:id_data].first[:metrics][:impressions]
        total_spend = stats.first[:id_data].first[:metrics][:billed_charge_local_micro]
        billed_spend = total_spend ? total_spend.map{ |amount| (amount.to_f/1000000) } : nil

        api_metrics[campaign.name] = []
        
        campaign_metrics = {
          impressions: impressions ? impressions : '-',
          spend: billed_spend ? (billed_spend) : '-'
        }

        api_metrics[campaign.name] << campaign_metrics
      end
    end
    return api_metrics
  end

  def format_twitter_metrics(api_metrics, dates_array)
    report_metrics = { 
      data_rows: {  }
    }
    # Iterate through each date within the range searched
    dates_array.each_with_index do |date, index|
      campaigns = []
      # Iterate through campaigns collecting Twitter & GA metrics
      api_metrics.each do |campaign_name, metrics|
        campaign_object = {
          name: campaign_name, 
          metrics: {
            impressions: metrics.first[:impressions][index],
            spend: metrics.first[:spend][index]
          }
        }
        campaigns << campaign_object
      end
      # Save array of campaigns and metrics to each date
      report_metrics[:data_rows][date] = campaigns
    end
    return report_metrics
  end

  def parse_metrics(metrics_data, headers)
    all_data_rows = { rows: [], headers: [] }
    metrics_data.each do |date, campaigns_array|
      campaigns_array.each do |c|
        row = []
        headers.each do |header|
          case header
          when 'Date'
            row << date
          when 'Campaign'
            row << c[:name]
          when 'Impressions'
            if c[:metrics][:impressions] != nil
              row << c[:metrics][:impressions] 
            else
              row << '-'
            end
          when 'Spend'
            if c[:metrics][:spend] != nil
              row << c[:metrics][:spend].to_f.round(2)
            else
              row << '0'
            end
          when 'CPM'
            calculate_cpm(row, c[:metrics][:spend], c[:metrics][:impressions])
          end
        end
        # Add GA metrics onto individual row
        puts "Getting GA data from #{c[:name]}"
        ga_data = GoogleAnalytics.fetch_and_parse_metrics(date, date, self.client.google_analytics_view_id, c[:name])
        ga_data[:data_rows].any? ? ga_twitter_row = row.concat(ga_data[:data_rows].first) : ga_twitter_row = row

        all_data_rows[:rows] << ga_twitter_row
      end
    end

    return all_data_rows
  end

  def calculate_cpm(row, spend, impressions)
    if spend != nil && impressions != nil &&
      spend != '-' && impressions != '-'
        cpm = (spend/impressions) * 1000
        row << cpm.round(2)
    else
      row << '-'
    end
    return row
  end
end
