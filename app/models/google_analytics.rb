require 'google/apis/analyticsreporting_v4'
require 'googleauth'

module GoogleAnalytics

  def self.fetch_and_parse_metrics(from_date, to_date, uid, campaign_name)
    # Find and return metrics from a view in a Google Analytics account
    # - the uid argument here represents the GA View ID, and the campaign_name
    # is for filtering data within that view (eight&four would go to Reporting >
    # Acquisition > Campaigns in Google Analytics to see the data they want)
    #
    # IMPORTANT: GA allows us to request up to 5 reports, but currently our
    # app will only look at the first returned report
    grr = Google::Apis::AnalyticsreportingV4::GetReportsRequest.new
    rr = Google::Apis::AnalyticsreportingV4::ReportRequest.new
    rr.view_id = uid
    rr.metrics = [
      self.metric("ga:sessions"),
      self.metric("ga:goalCompletionsAll"),
      self.metric("ga:costPerGoalConversion"),
      self.metric("ga:avgSessionDuration")
    ]
    rr.date_ranges = [self.date_range(from_date, to_date)]
    rr.filters_expression = "ga:campaign==" + campaign_name
    grr.report_requests = [rr]
    response = self.google_client.batch_get_reports(grr)
    return self.parse_metrics(response.reports.first)
  end

  private

  def self.google_client
    creds = Google::Auth::ServiceAccountCredentials.make_creds({
      :json_key_io => File.open(Rails.root.join("private/analytics_client_secret.json").to_s),
      :scope => "https://www.googleapis.com/auth/analytics.readonly"
    })
    client = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new
    client.authorization = creds
    return client
  end

  def self.date_range(start_date, end_date)
    range = Google::Apis::AnalyticsreportingV4::DateRange.new
    range.start_date = Date.parse(start_date)
    range.end_date = Date.parse(end_date)
    return range
  end

  def self.metric(expression)
    metric = Google::Apis::AnalyticsreportingV4::Metric.new
    metric.expression = expression
    return metric
  end

  def self.parse_metrics(report)
    parsed_metrics = {
      header_row: report.column_header.metric_header.metric_header_entries.map{|header| header.name},
      data_row: report.data.totals.map{|total_row| total_row.values}.flatten
    }
    # Some of the metrics Google Analytics gives us should be modified
    # for display in the front-end
    parsed_metrics[:header_row].each_with_index do |header, index|
      if header == "ga:avgSessionDuration"
        # Google gives us an avgSessionDuration in seconds, e.g. 36.92846216
        # which we need to turn into a readable time value, e.g. 00:00:37
        avg_session_duration = parsed_metrics[:data_row][index].to_f.round
        parsed_metrics[:data_row][index] = Time.at(avg_session_duration).utc.strftime("%H:%M:%S")
      end
    end
    return parsed_metrics
  end

end