require 'twitter-ads'

class ClientChannels::Twitter < ClientChannel

  def fetch_metrics(from_date, to_date, uid, ga_campaign_name, optional={})
    client = TwitterAds::Client.new(
      ENV['TWITTER_CONSUMER_KEY'],
      ENV['TWITTER_CONSUMER_SECRET'],
      ENV['TWITTER_ACCESS_TOKEN'],
      ENV['TWITTER_ACCESS_TOKEN_SECRET']
    )

    account = client.accounts('18ce53uuays')
    puts client.accounts

    # Find and return Insights for a Twitter account & campaign
    # * just dummy data for now *
    return {
      twitterClicks: 999,
      twitterCtr: 4.02002002,
      twitterImpressions: 4016
    }
  end

end