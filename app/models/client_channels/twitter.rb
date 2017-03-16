require 'twitter-ads'
require 'net/http'

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
    campaign_ids = account.campaigns.map{ |c| c.id }
    line_item_ids = account.line_items.map{ |c| c.id }

    from = Time.zone.now.midnight - 10.day
    to =  Time.zone.now.midnight - 8.day

    # GETTING METRICS FROM RUBY SDK
    account.line_items.each do |i|
      puts "Line Item: #{i.id}"
      campaign = account.campaigns(i.campaign_id)
      puts "Campaign Name: #{campaign.name}"
      stats = TwitterAds::LineItem.stats(account, [i.id], ['ENGAGEMENT'], start_time: from, end_time: to, granularity: 'DAY')
      puts stats
      puts '-----------'
    end

    # GETTING METRICS FROM TWURL
    # finds individual line_item: twurl -H ads-api.twitter.com "/1/accounts/18ce53uuays/line_items/6fzcg"
    # find campaign metrics: twurl -H ads-api.twitter.com "/1/stats/accounts/18ce53uuays?entity_ids=1jwhi&entity=CAMPAIGN&start_time=2017-03-10T00:00:00Z&granularity=DAY&metric_groups=ENGAGEMENT&end_time=2017-03-12T00:00:00Z&placement=ALL_ON_TWITTER"
    # find line_item metrics: twurl -H ads-api.twitter.com "/1/stats/accounts/18ce53uuays?entity_ids=6fzcg&entity=LINE_ITEM&start_time=2017-03-10T00:00:00Z&granularity=DAY&metric_groups=ENGAGEMENT&end_time=2017-03-12T00:00:00Z&placement=ALL_ON_TWITTER"    

    # Find and return Insights for a Twitter account & campaign
    # * just dummy data for now *
    return {
      twitterClicks: 999,
      twitterCtr: 4.02002002,
      twitterImpressions: 4016
    }
  end

end
