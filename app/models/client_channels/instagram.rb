class ClientChannels::Instagram < ClientChannel

  def fetch_metrics(from_date, to_date, uid, ga_campaign_name, optional={})
    # Find and return Insights for an Instagram account & campaign
    # * just dummy data for now *
    return {
      igClicks: 999,
      igCtr: 4.02002002,
      igImpressions: 4016
    }
  end

end