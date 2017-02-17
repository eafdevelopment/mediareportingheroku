class ClientChannels::Twitter < ClientChannel

  def fetch_metrics(params)
    # Find and return Insights for a Twitter account & campaign
    # params = { uid: 'xxxx', fromDate: '', startDate: '' }
    # * just dummy data for now *
    return {
      twitterClicks: 999,
      twitterCtr: 4.02002002,
      twitterImpressions: 4016
    }
  end

end