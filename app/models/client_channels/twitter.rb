class ClientChannels::Twitter < ClientChannel

  def fetch_metrics(from_date, to_date, uid, ga_campaign_name, optional={})
    # Find and return Insights for a Twitter account & campaign
    # * just dummy data for now *
    return {
      twitterClicks: 999,
      twitterCtr: 4.02002002,
      twitterImpressions: 4016
    }
  end

end