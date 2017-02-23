# This module puts together the requested metric names and values from each API,
# returning an object with a header_row and an array of 1+ data rows ready to display
# in the view (as a summary) or to turn into a CSV

module Report

  def self.build_summary_report(from_date, to_date, campaign_channels)
    summary_report = {
      header_row: [],
      data_rows: [],
      summary_row: []
    }
    campaign_channels.each do |campaign_channel|
      metrics = campaign_channel.client_channel.fetch_metrics(
        from_date,
        to_date,
        campaign_channel.uid,
        campaign_channel.google_analytics_campaign_name,
        { summary_metrics: AppConfig.summary_metrics }
      )
      summary_report[:header_row].concat(
        metrics[:client_channel_metrics][:header_row] + metrics[:additional_ga_metrics][:header_row]
      )
      summary_report[:summary_row].concat(
        metrics[:client_channel_metrics][:summary_row] + metrics[:additional_ga_metrics][:summary_row]
      )
    end
    return summary_report
  end

  def self.build_csv_report(from_date, to_date, campaign_channels)
    csv_report = {
      header_row: [],
      data_rows: [],
      summary_row: []
    }
    campaign_channels.each do |campaign_channel|
      metrics = campaign_channel.client_channel.fetch_metrics(
        from_date,
        to_date,
        campaign_channel.uid,
        campaign_channel.google_analytics_campaign_name
      )
      csv_report[:header_row].concat(
        metrics[:client_channel_metrics][:header_row] + metrics[:additional_ga_metrics][:header_row]
      )
      csv_report[:data_rows].concat(
        metrics[:client_channel_metrics][:data_rows] + metrics[:additional_ga_metrics][:data_rows]
      )
    end
    return csv_report
  end

end