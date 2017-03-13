require 'twitter-ads'

class ClientChannels::Twitter < ClientChannel

  def generate_report_all_campaigns(from, to)

    client = TwitterAds::Client.new(
      ENV['TWITTER_CONSUMER_KEY'],
      ENV['TWITTER_CONSUMER_SECRET'],
      ENV['TWITTER_ACCESS_TOKEN'],
      ENV['TWITTER_ACCESS_TOKEN_SECRET']
    )

    from = DateTime.now - 2
    to = DateTime.now - 1

    account = client.accounts('18ce53uuays')
    line_items = account.line_items(nil, count: 10)[0..9]

    line_items.each do |l|
      campaign = account.campaigns(l.campaign_id.to_s)
      puts "Campaign Info"
      puts "ID: #{l.campaign_id}"
      puts "Name: #{campaign.name}"
    end

    ids = line_items.map(&:id)
    metric_group = ['ENGAGEMENT']
    stats = TwitterAds::LineItem.stats(account, ids, metric_group, start_time: from, end_time: to)

    puts '---------'
    puts stats

    # Find and return Insights for a Twitter account & campaign
    # * just dummy data for now *
    return {
      twitterClicks: 999,
      twitterCtr: 4.02002002,
      twitterImpressions: 4016
    }
  end

end
