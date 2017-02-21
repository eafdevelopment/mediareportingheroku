# This module puts together the requested metric names and values from each API,
# returning an object with a header_row and an array of 1+ data rows ready to display
# in the view (as a summary) or to turn into a CSV

module Report

  def self.build_summary_report(from_date, to_date, campaign_channels)
    summary_report = {
      header_row: [],
      data_rows: []
    }
    campaign_channels.each do |campaign_channel|
      metrics = campaign_channel.client_channel.fetch_metrics(from_date, to_date, campaign_channel.uid, {
        summary_metrics: ['impressions', 'clicks', 'cpc', 'ctr']
      })
      summary_report[:header_row].concat(metrics[:header_row])
      summary_report[:data_rows].push(metrics[:data_row])
    end
    # puts "> summary_report: " + summary_report.inspect
    return summary_report
  end

  def self.build_csv_report(from_date, to_date, campaign_channels)
    csv_report = {
      header_row: [],
      data_rows: []
    }
    campaign_channels.each do |campaign_channel|
      metrics = campaign_channel.client_channel.fetch_metrics(from_date, to_date, campaign_channel.uid)
      csv_report[:header_row].concat(metrics[:header_row])
      csv_report[:data_rows].push(metrics[:data_row])
    end
    # puts "> csv_report: " + csv_report.inspect
    return csv_report
  end

end