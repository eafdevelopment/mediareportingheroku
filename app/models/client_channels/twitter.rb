require 'twitter-ads'

class ClientChannels::Twitter < ClientChannel

  # From Twitter:
  # Campaign Name
  # Impressions
  # Spend

  def generate_report_all_campaigns(from, to)

    client = TwitterAds::Client.new(
      ENV['TWITTER_CONSUMER_KEY'],
      ENV['TWITTER_CONSUMER_SECRET'],
      ENV['TWITTER_ACCESS_TOKEN'],
      ENV['TWITTER_ACCESS_TOKEN_SECRET']
    )
    account = client.accounts(self.uid)

    from = Time.zone.now.midnight - 10.day
    to =  Time.zone.now.midnight - 5.day
    # from = Time.zone.parse('08-10-2016').midnight
    # to = Time.zone.parse('11-10-2016').midnight

    data = {}

    # GETTING METRICS FROM RUBY SDK
    account.line_items.each do |i|
      campaign = account.campaigns(i.campaign_id)

      # Excluse Campaigns that have 'EXPIRED' or have are 'BUDGET_EXPIRED'
      # So as to keep API requests as low as possible
      # Including Campaigns that are ACTIVE or 'PAUSED_BY_ADVERTISER'
      if !campaign.reasons_not_servable.include?('EXPIRED') && !campaign.reasons_not_servable.include?('BUDGET_EXHAUSTED')
        puts "Getting metrics for campaign: #{campaign.name}"
        stats = TwitterAds::LineItem.stats(account, [i.id], ['ENGAGEMENT'], start_time: from, end_time: to, granularity: 'DAY')
        impressions = stats.first[:id_data].first[:metrics][:impressions]
        
        if impressions == nil
          data[campaign.name] = nil
        else
          data[campaign.name] = impressions
        end
      end
    end

    puts data

    # Find and return Insights for a Twitter account & campaign
    # * just dummy data for now *
    # return {
    #   twitterClicks: 999,
    #   twitterCtr: 4.02002002,
    #   twitterImpressions: 4016
    # }
  end

end
