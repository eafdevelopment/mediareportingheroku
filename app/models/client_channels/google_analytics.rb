require 'google/apis/analyticsreporting_v4'
require 'googleauth'

class ClientChannels::GoogleAnalytics < ClientChannel

  def fetch_metrics(params)
    # Find and return metrics from a view in a Google Analytics account
    # params = { uid: '110182207', fromDate: '7daysAgo', startDate: 'today' }
    # IMPORTANT: GA allows request of up to 5 reports, but currently our
    # app will only handle the first returned report
    grr = Google::Apis::AnalyticsreportingV4::GetReportsRequest.new
    rr = Google::Apis::AnalyticsreportingV4::ReportRequest.new
    rr.view_id = params[:uid]
    rr.metrics = [metric("ga:sessions"), metric("ga:sessionDuration")]
    rr.date_ranges = [dateRange("7daysAgo", "today")]
    grr.report_requests = [rr]
    response = google_client.batch_get_reports(grr)
    # turn the response into a set of key-value pairs to return for the view
    report = response.reports.first
    metric_headers = report.column_header.metric_header.metric_header_entries.map{|header| header.name}
    metric_values = report.data.rows.map{|row| row.metrics.map{|metric| metric.values} }.flatten
    return metric_headers.zip(metric_values).to_h
  end

  private

  def google_client
    creds = Google::Auth::ServiceAccountCredentials.make_creds({
      :json_key_io => File.open(Rails.root.join("client_secrets_4023d7d9e162.json").to_s),
      :scope => "https://www.googleapis.com/auth/analytics.readonly"
    })
    client = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new
    client.authorization = creds
    return client
  end

  def dateRange(startDate, endDate)
    range = Google::Apis::AnalyticsreportingV4::DateRange.new
    range.start_date = startDate
    range.end_date = endDate
    return range
  end

  def metric(expression)
    metric = Google::Apis::AnalyticsreportingV4::Metric.new
    metric.expression = expression
    return metric
  end

end