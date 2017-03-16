require 'twitter-ads'

class ClientChannels::Twitter < ClientChannel

  # From Twitter:
  # Campaign Name
  # Impressions
  # Spend

  def generate_report_all_campaigns(from, to)

    client = twitter_credentials
    account = client.accounts(self.uid)

    # Add a day before the search query because Twitter only accepts date
    # params with time set at midnight, so first date isn't included in metrics
    from = format_date(from) - 1.day
    to = format_date(to)
    # Remove first date from dates array as there are no metrics
    time_array = ((from..to).map{ |date| date.strftime("%d-%m-%Y") }).drop(1)
    api_metrics = {}

    #  GETTING METRICS FROM RUBY SDK
    account.line_items.each do |i|
      campaign = account.campaigns(i.campaign_id)

      # Exclude Campaigns that have 'EXPIRED' or have are 'BUDGET_EXPIRED'
      # So as to keep API requests as low as possible
      # Include Campaigns that are ACTIVE or 'PAUSED_BY_ADVERTISER'
      if !campaign.reasons_not_servable.include?('EXPIRED') && !campaign.reasons_not_servable.include?('BUDGET_EXHAUSTED')
        puts "Getting metrics for campaign: #{campaign.name}"
        stats = TwitterAds::LineItem.stats(account, [i.id], ['ENGAGEMENT'], start_time: from, end_time: to, granularity: 'DAY')
        impressions = stats.first[:id_data].first[:metrics][:impressions]
        
        if impressions == nil
          api_metrics[campaign.name] = nil
        else
          api_metrics[campaign.name] = impressions
        end
      end
    end

    puts api_metrics
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

  def format_date(date_string)
    now = DateTime.now 
    datetime = Time.parse(date_string)
    return DateTime.new(datetime.year, datetime.month, datetime.day, 0, 0, 0, now.zone)
  end
end
